import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class VerifyIdentityPage extends StatefulWidget {
  const VerifyIdentityPage({super.key});

  @override
  State<VerifyIdentityPage> createState() => _VerifyIdentityPageState();
}

class _VerifyIdentityPageState extends State<VerifyIdentityPage> {
  final TextEditingController _cardController = TextEditingController();
  String _cardIssuer = '';
  bool _isBinValid = false;
  bool _isLoading = false;
  bool _showFullCard = false;
  Map<String, dynamic> _cardDetails = {};

  // Expanded Thai bank BIN database with full details
  final Map<String, Map<String, dynamic>> _thaiBins = {
    '4484': {
      'scheme': 'visa',
      'bank': {'name': 'Kasikorn Bank'},
      'country': {'name': 'Thailand'},
      'brand': 'Classic',
    },
    '4532': {
      'scheme': 'visa',
      'bank': {'name': 'Siam Commercial Bank'},
      'country': {'name': 'Thailand'},
      'brand': 'Platinum',
    },
    '5522': {
      'scheme': 'mastercard',
      'bank': {'name': 'Bangkok Bank'},
      'country': {'name': 'Thailand'},
      'brand': 'World',
    },
  };

  @override
  void dispose() {
    _cardController.dispose();
    super.dispose();
  }

  Future<void> _validateBin(String input) async {
    final digits = input.replaceAll(RegExp(r'\s+'), '');

    if (_isLoading || digits.length < 6) return;

    setState(() {
      _isLoading = true;
      _isBinValid = false;
      _cardIssuer = '';
      _cardDetails = {};
    });

    // Check Thai BINs first
    bool foundThaiBin = false;
    for (final prefix in _thaiBins.keys) {
      if (digits.startsWith(prefix)) {
        await Future.delayed(
          Duration(milliseconds: 50),
        ); // Smooth UI transition
        setState(() {
          _cardDetails = _thaiBins[prefix]!;
          _cardIssuer =
              '${_cardDetails['bank']['name']} (${_cardDetails['scheme']})';
          _isBinValid = true;
        });
        foundThaiBin = true;
        break;
      }
    }

    if (foundThaiBin) {
      setState(() => _isLoading = false);
      return;
    }

    // Proceed with API call
    final httpClient = HttpClient();
    try {
      final request = await httpClient.getUrl(
          Uri.parse('https://lookup.binlist.net/${digits.substring(0, 6)}'),
        )
        ..headers.add('Accept-Version', '3');

      final response = await request.close().timeout(Duration(seconds: 2));
      if (response.statusCode != 200) throw Exception('Invalid response');

      final jsonData = jsonDecode(
        await response.transform(utf8.decoder).join(),
      );

      setState(() {
        _cardDetails = jsonData;
        _cardIssuer = _formatIssuer(jsonData);
        _isBinValid = true;
      });
    } catch (e) {
      final isThaiCard =
          digits.length >= 8 &&
          (digits.startsWith('4') || digits.startsWith('5'));
      setState(() {
        _isBinValid = isThaiCard;
        _cardIssuer = isThaiCard ? 'Thai Bank Card' : 'Unsupported';
        if (isThaiCard) _cardDetails = _createThaiCardDetails(digits);
      });
    } finally {
      httpClient.close();
      setState(() => _isLoading = false);
    }
  }

  String _formatIssuer(Map<String, dynamic> data) {
    final scheme = data['scheme']?.toString().toUpperCase() ?? 'Unknown';
    final bank = data['bank']?['name']?.toString();
    return bank != null ? '$scheme • $bank' : scheme;
  }

  Map<String, dynamic> _createThaiCardDetails(String digits) => {
    'scheme': digits.startsWith('4') ? 'VISA' : 'Mastercard',
    'bank': {'name': 'Thai Bank'},
    'country': {'name': 'Thailand'},
    'type': 'Credit/Debit',
  };

  String _formatCardInput(String input) {
    final digits = input.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.isEmpty) return '';

    final buffer = StringBuffer();
    for (int i = 0; i < min(digits.length, 8); i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(digits[i]);
    }

    if (digits.length > 8) {
      buffer.write(' ${'•' * min(digits.length - 8, 4)}');
      if (digits.length > 12) {
        buffer.write(' ${'•' * min(digits.length - 12, 4)}');
      }
    }

    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Verify Payment Method',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/signin');
          },
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your card number to verify payment method',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),

            TextFormField(
              controller: _cardController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(19),
                TextInputFormatter.withFunction((oldValue, newValue) {
                  return TextEditingValue(
                    text: _formatCardInput(newValue.text),
                    selection: TextSelection.collapsed(
                      offset: _formatCardInput(newValue.text).length,
                    ),
                  );
                }),
              ],
              decoration: InputDecoration(
                labelText: 'Card Number',
                hintText: '4242 4242 •••• ••••',
                border: const OutlineInputBorder(),
                suffixIcon:
                    _isLoading
                        ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : _cardIssuer.isNotEmpty
                        ? Chip(
                          label: Text(
                            "Supported",
                            style: const TextStyle(fontSize: 12),
                          ),
                          backgroundColor:
                              _isBinValid ? Colors.green[100] : Colors.red[100],
                        )
                        : IconButton(
                          icon: Icon(
                            _showFullCard
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() => _showFullCard = !_showFullCard);
                          },
                        ),
              ),
              obscureText: !_showFullCard,
              obscuringCharacter: '•',
              onChanged: _validateBin,
            ),
            const SizedBox(height: 16),

            // Supported Card Types Info
            const Text(
              'Supported cards: Visa, Mastercard, and major Thai bank cards',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 8),

            // Card Details Display
            if (_cardDetails.isNotEmpty && _isBinValid)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Card Details',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      'Bank',
                      _cardDetails['bank']?['name'] ?? 'Unknown',
                    ),
                    _buildDetailRow(
                      'Country',
                      _cardDetails['country']?['name'] ?? 'Unknown',
                    ),
                    _buildDetailRow(
                      'Type',
                      _cardDetails['scheme']?.toString().toUpperCase() ??
                          'Unknown',
                    ),
                    _buildDetailRow(
                      'Brand',
                      _cardDetails['brand']?.toString().toUpperCase() ??
                          'Unknown',
                    ),
                  ],
                ),
              ),

            if (_cardIssuer.isNotEmpty && !_isBinValid)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'This card type is not supported. Please use Visa, Mastercard, or a major Thai bank card.',
                  style: TextStyle(color: Colors.red[700], fontSize: 12),
                ),
              ),

            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isBinValid ? Colors.blue : Colors.grey[400],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed:
                    _isBinValid
                        ? () {
                          Navigator.pushReplacementNamed(context, '/home');
                        }
                        : null,
                child: const Text(
                  'Continue',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCardDetails() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : _isBinValid
              ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.credit_card, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        _cardIssuer,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                        ),
                      ),
                    ],
                  ),
                  Divider(height: 24, thickness: 1),
                  _buildDetailRow('Card Type', _cardDetails['scheme'] ?? 'N/A'),
                  _buildDetailRow(
                    'Bank',
                    _cardDetails['bank']?['name'] ?? 'N/A',
                  ),
                  _buildDetailRow(
                    'Country',
                    _cardDetails['country']?['name'] ?? 'N/A',
                  ),
                  _buildDetailRow('Category', _cardDetails['type'] ?? 'N/A'),
                ],
              )
              : Text(
                'Invalid card number',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
