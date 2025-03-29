import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
                    const Text(
                      'Complete Your Purchase',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),
                    
                    // Order Items
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Your Items',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const Divider(),
                            ...widget.selectedItems.map((item) => ListTile(
                              leading: item['image'] != null
                                  ? Image.asset(item['image'], width: 50, height: 50)
                                  : const Icon(Icons.shopping_bag),
                              title: Text(item['name'] ?? 'Unknown Item'),
                              subtitle: Text('Qty: ${item['quantity'] ?? 1}'),
                              trailing: Text(_formatPrice(item['price'] ?? 0)),
                            )).toList(),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Shipping Method
                    const Text(
                      'Shipping Method',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    ..._shippingOptions.asMap().entries.map((entry) => RadioListTile<int>(
                      title: Text(entry.value['title']),
                      subtitle: Text(entry.value['duration']),
                      secondary: Text(_formatPrice(entry.value['price'])),
                      value: entry.key,
                      groupValue: _selectedShippingIndex,
                      onChanged: (value) => setState(() => _selectedShippingIndex = value!),
                    )).toList(),
                    const SizedBox(height: 16),

                    // Shipping Address
                    const Text(
                      'Shipping Address',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: 'Full Address',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_on),
                      ),
                      maxLines: 3,
                      validator: (value) => value?.isEmpty ?? true ? 'Please enter address' : null,
                    ),
                    const SizedBox(height: 16),

                    // Payment Method
                    const Text(
                      'Payment Method',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    ..._paymentOptions.asMap().entries.map((entry) => RadioListTile<int>(
                      title: Text(entry.value['title']),
                      secondary: Icon(entry.value['icon']),
                      value: entry.key,
                      groupValue: _selectedPaymentIndex,
                      onChanged: (value) => setState(() => _selectedPaymentIndex = value!),
                    )).toList(),
                    
                    // Payment Details (shown only for credit card)
                    if (_selectedPaymentIndex == 0) ...[
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Cardholder Name',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) => value?.isEmpty ?? true ? 'Please enter name' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _cardController,
                        decoration: const InputDecoration(
                          labelText: 'Card Number',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.credit_card),
                        ),
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
                color: Colors.grey.shade100,
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
                              style: TextStyle(fontSize: 18),
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
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.blue : null,
            ),
          ),
        ],
      ),
    );
  }
}