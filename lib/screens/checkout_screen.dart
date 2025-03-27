import 'package:flutter/material.dart';
import 'cart_service.dart';

class CheckoutScreen extends StatefulWidget {
  final List<Map<String, dynamic>> selectedItems;

  const CheckoutScreen({
    Key? key,
    required this.selectedItems,
  }) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _selectedShippingIndex = 0;
  int _selectedPaymentIndex = 0;
  final TextEditingController _addressController = TextEditingController();
  bool _showAddressError = false;

  final List<Map<String, dynamic>> _shippingOptions = [
    {'title': 'Standard', 'duration': '5-7 days', 'price': 4.99},
    {'title': 'Express', 'duration': '2-3 days', 'price': 9.99},
    {'title': 'Next Day', 'duration': '1 day', 'price': 14.99},
  ];

  final List<Map<String, dynamic>> _paymentOptions = [
    {'icon': Icons.credit_card, 'title': 'Credit Card'},
    {'icon': Icons.payment, 'title': 'PayPal'},
    {'icon': Icons.apple, 'title': 'Apple Pay'},
  ];

  double _parsePrice(dynamic price) {
    if (price is num) return price.toDouble();
    if (price is String) {
      return double.tryParse(price.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
    }
    return 0.0;
  }

  String _formatPrice(double price) {
    return '\$${price.toStringAsFixed(2)}';
  }

  double get subtotal {
    return widget.selectedItems.fold(0, (sum, item) {
      final price = _parsePrice(item['price']);
      final quantity = item['quantity'] ?? 1;
      return sum + (price * quantity);
    });
  }

  double get shippingPrice => _shippingOptions[_selectedShippingIndex]['price'];
  double get total => subtotal + shippingPrice;

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Complete Your Purchase', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            _buildSection('Selected Items', _buildSelectedItems()),
            _buildSection('Shipping Method', _buildShippingOptions()),
            _buildSection('Shipping Address', _buildAddressField()),
            _buildSection('Payment Method', _buildPaymentOptions()),
            _buildSection('Order Summary', _buildOrderSummary()),
            const SizedBox(height: 16),
            _buildPlaceOrderButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        content,
      ],
    );
  }

  Widget _buildSelectedItems() {
    return Column(
      children: widget.selectedItems.map((item) {
        final quantity = item['quantity'] ?? 1;
        return ListTile(
          leading: item['image'] != null
              ? Image.asset(item['image'], width: 50, height: 50)
              : const Icon(Icons.image),
          title: Text(item['name'] ?? 'Unknown Item'),
          subtitle: Text('Qty: $quantity'),
        );
      }).toList(),
    );
  }

  Widget _buildShippingOptions() {
    return Column(
      children: _shippingOptions.asMap().entries.map((entry) {
        final index = entry.key;
        final option = entry.value;
        return RadioListTile<int>(
          title: Text(option['title']),
          subtitle: Text(option['duration']),
          secondary: Text(_formatPrice(option['price'])),
          value: index,
          groupValue: _selectedShippingIndex,
          onChanged: (value) => setState(() => _selectedShippingIndex = value!),
        );
      }).toList(),
    );
  }

  Widget _buildAddressField() {
    return TextField(
      controller: _addressController,
      decoration: InputDecoration(
        labelText: 'Shipping Address',
        errorText: _showAddressError ? 'Please enter address' : null,
        border: const OutlineInputBorder(),
      ),
      maxLines: 3,
    );
  }

  Widget _buildPaymentOptions() {
    return Column(
      children: _paymentOptions.asMap().entries.map((entry) {
        final index = entry.key;
        final option = entry.value;
        return RadioListTile<int>(
          title: Text(option['title']),
          secondary: Icon(option['icon']),
          value: index,
          groupValue: _selectedPaymentIndex,
          onChanged: (value) => setState(() => _selectedPaymentIndex = value!),
        );
      }).toList(),
    );
  }

  Widget _buildOrderSummary() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSummaryRow('Subtotal', _formatPrice(subtotal)),
            _buildSummaryRow('Shipping', _formatPrice(shippingPrice)),
            const Divider(),
            _buildSummaryRow('Total', _formatPrice(total), isTotal: true),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            fontSize: isTotal ? 18 : 16,
          )),
          Text(value, style: TextStyle(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            fontSize: isTotal ? 18 : 16,
            color: isTotal ? Colors.blue : Colors.black,
          )),
        ],
      ),
    );
  }

  // In your _buildPlaceOrderButton method:
// In your _buildPlaceOrderButton method:
Widget _buildPlaceOrderButton(BuildContext context) {
  return SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: () {
        if (_addressController.text.isEmpty) {
          setState(() => _showAddressError = true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enter shipping address')),
          );
          return;
        }

        try {
          CartService.placeOrder({
            'items': widget.selectedItems,
            'shipping': _shippingOptions[_selectedShippingIndex],
            'payment': _paymentOptions[_selectedPaymentIndex],
            'address': _addressController.text,
            'total': total,
          });
          
          // Navigate to Home and clear stack
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/home',
            (route) => false,
          );
          
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Payment successful')),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error occurred: ${e.toString()}')),
          );
        }
      },
      child: const Text('Complete Payment'),
    ),
  );
}
}