import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import 'cart_service.dart';
import 'notification_service.dart';

class CheckoutPage extends StatefulWidget {
  final List<Map<String, dynamic>> selectedItems;

  const CheckoutPage({
    Key? key,
    required this.selectedItems,
  }) : super(key: key);

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  int _selectedShippingIndex = 0;
  int _selectedPaymentIndex = 0;
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cardController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  bool _isProcessing = false;
  final _formKey = GlobalKey<FormState>();

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

  @override
  void dispose() {
    _addressController.dispose();
    _cardController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  String _formatPrice(double price) {
    return NumberFormat.currency(locale: 'en_US', symbol: '\$').format(price);
  }

  double get subtotal {
    return widget.selectedItems.fold(0, (sum, item) {
      final price = item['price'] is num ? item['price'].toDouble() : 0.0;
      final quantity = item['quantity'] ?? 1;
      return sum + (price * quantity);
    });
  }

  double get shippingPrice => _shippingOptions[_selectedShippingIndex]['price'];
  double get total => subtotal + shippingPrice;

  Future<void> _processPayment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isProcessing = true);

    try {
      // Simulate payment processing
      await Future.delayed(const Duration(seconds: 2));

      final orderId = DateTime.now().millisecondsSinceEpoch.toString().substring(6);
      final orderDetails = {
        'items': List.from(widget.selectedItems),
        'shipping': _shippingOptions[_selectedShippingIndex],
        'payment': _paymentOptions[_selectedPaymentIndex],
        'address': _addressController.text,
        'total': total,
        'date': DateTime.now(),
        'orderId': orderId,
      };

      // Place order and clear cart
      CartService.placeOrder(orderDetails);
      CartService.clearCart();

      // Add notification
      NotificationService.addNotification(
        title: 'Order Confirmed',
        message: 'Your order #$orderId has been placed',
        category: 'Order',
      );

      Navigator.pushNamedAndRemoveUntil(
        context,
        '/home',
        (route) => false,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment successful! Your cart has been cleared.'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final cardColor = isDarkMode ? Colors.grey[800] : Colors.white;
    final backgroundColor = isDarkMode ? Colors.grey[900] : Colors.grey[100];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Complete Your Purchase',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Order Items
                    Card(
                      elevation: 2,
                      color: cardColor,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Your Items',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            const Divider(),
                            ...widget.selectedItems.map((item) => ListTile(
                              leading: item['image'] != null
                                  ? Image.asset(item['image'], width: 50, height: 50)
                                  : Icon(Icons.shopping_bag, color: textColor),
                              title: Text(
                                item['name'] ?? 'Unknown Item',
                                style: TextStyle(color: textColor),
                              ),
                              subtitle: Text(
                                'Qty: ${item['quantity'] ?? 1}',
                                style: TextStyle(color: textColor),
                              ),
                              trailing: Text(
                                _formatPrice(item['price'] ?? 0),
                                style: TextStyle(color: textColor),
                              ),
                            )).toList(),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Shipping Method
                    Text(
                      'Shipping Method',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    ..._shippingOptions.asMap().entries.map((entry) => RadioListTile<int>(
                      title: Text(
                        entry.value['title'],
                        style: TextStyle(color: textColor),
                      ),
                      subtitle: Text(
                        entry.value['duration'],
                        style: TextStyle(color: textColor),
                      ),
                      secondary: Text(
                        _formatPrice(entry.value['price']),
                        style: TextStyle(color: textColor),
                      ),
                      value: entry.key,
                      groupValue: _selectedShippingIndex,
                      onChanged: (value) => setState(() => _selectedShippingIndex = value!),
                    )).toList(),
                    const SizedBox(height: 16),

                    // Shipping Address
                    Text(
                      'Shipping Address',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _addressController,
                      decoration: InputDecoration(
                        labelText: 'Full Address',
                        labelStyle: TextStyle(color: textColor),
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_on, color: textColor),
                      ),
                      style: TextStyle(color: textColor),
                      maxLines: 3,
                      validator: (value) => value?.isEmpty ?? true ? 'Please enter address' : null,
                    ),
                    const SizedBox(height: 16),

                    // Payment Method
                    Text(
                      'Payment Method',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    ..._paymentOptions.asMap().entries.map((entry) => RadioListTile<int>(
                      title: Text(
                        entry.value['title'],
                        style: TextStyle(color: textColor),
                      ),
                      secondary: Icon(
                        entry.value['icon'],
                        color: textColor,
                      ),
                      value: entry.key,
                      groupValue: _selectedPaymentIndex,
                      onChanged: (value) => setState(() => _selectedPaymentIndex = value!),
                    )).toList(),
                    
                    // Payment Details (shown only for credit card)
                    if (_selectedPaymentIndex == 0) ...[
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Cardholder Name',
                          labelStyle: TextStyle(color: textColor),
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person, color: textColor),
                        ),
                        style: TextStyle(color: textColor),
                        validator: (value) => value?.isEmpty ?? true ? 'Please enter name' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _cardController,
                        decoration: InputDecoration(
                          labelText: 'Card Number',
                          labelStyle: TextStyle(color: textColor),
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.credit_card, color: textColor),
                        ),
                        style: TextStyle(color: textColor),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value?.isEmpty ?? true) return 'Please enter card number';
                          if (value!.length < 16) return 'Invalid card number';
                          return null;
                        },
                      ),
                    ],
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // Price Summary and Payment Button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: backgroundColor,
                border: Border(top: BorderSide(color: Colors.grey.shade300)),
              ),
              child: Column(
                children: [
                  _buildSummaryRow('Subtotal', _formatPrice(subtotal)),
                  _buildSummaryRow('Shipping', _formatPrice(shippingPrice)),
                  const Divider(),
                  _buildSummaryRow('Total', _formatPrice(total), isTotal: true),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: _isProcessing ? null : _processPayment,
                      child: _isProcessing
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Complete Payment',
                              style: TextStyle(fontSize: 18, color: Colors.white),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final textColor = themeProvider.isDarkMode ? Colors.white : Colors.black;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: textColor,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.blue : textColor,
            ),
          ),
        ],
      ),
    );
  }
}