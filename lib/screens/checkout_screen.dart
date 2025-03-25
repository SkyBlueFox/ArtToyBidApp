import 'package:flutter/material.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Checkout',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
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
            const Text(
              'Complete Your Purchase',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 24),
            _buildSection('Selected Items', _buildSelectedItems()),
            _buildSection('Shipping Method', _buildShippingOptions()),
            _buildSection('Shipping Address', _buildAddressField()),
            _buildSection('Payment Method', _buildPaymentOptions()),
            _buildSection('Order Summary', _buildOrderSummary()),
            _buildProceedButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        content,
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSelectedItems() {
    return const Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Art Toy Name'),
              Text('\$49.99'),
              Text('Quantity: 1'),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Accessory Name'),
              Text('\$49.99'),
              Text('Quantity: 1'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildShippingOptions() {
    return Column(
      children: [
        _buildShippingOption(
          title: 'Standard Shipping',
          duration: '5-7 business days',
          price: '\$4.99',
          isSelected: true,
        ),
        const SizedBox(height: 8),
        _buildShippingOption(
          title: 'Express Shipping',
          duration: '2-3 business days',
          price: '\$9.99',
          isSelected: false,
        ),
        const SizedBox(height: 8),
        _buildShippingOption(
          title: 'Next Day Delivery',
          duration: '1 business day',
          price: '\$14.99',
          isSelected: false,
        ),
      ],
    );
  }

  Widget _buildShippingOption({
    required String title,
    required String duration,
    required String price,
    required bool isSelected,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected ? Colors.blue : Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: ListTile(
        title: Text(title),
        subtitle: Text(duration),
        trailing: Text(
          price,
          style: TextStyle(
            color: isSelected ? Colors.blue : Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        onTap: () {},
      ),
    );
  }

  Widget _buildAddressField() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Enter your shipping address',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        suffixIcon: IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () {},
        ),
      ),
    );
  }

  Widget _buildPaymentOptions() {
    return Column(
      children: [
        _buildPaymentOption(
          icon: Icons.credit_card,
          title: 'Credit Card',
          isSelected: true,
        ),
        const SizedBox(height: 8),
        _buildPaymentOption(
          icon: Icons.payment,
          title: 'PayPal',
          isSelected: false,
        ),
        const SizedBox(height: 8),
        _buildPaymentOption(
          icon: Icons.apple,
          title: 'Apple Pay',
          isSelected: false,
        ),
      ],
    );
  }

  Widget _buildPaymentOption({
    required IconData icon,
    required String title,
    required bool isSelected,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected ? Colors.blue : Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? Colors.blue : Colors.black,
        ),
        title: Text(title),
        trailing: isSelected
            ? const Icon(Icons.check_circle, color: Colors.blue)
            : null,
        onTap: () {},
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Column(
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Subtotal'),
            Text('\$99.98'),
          ],
        ),
        const SizedBox(height: 8),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Shipping'),
            Text('\$4.99'),
          ],
        ),
        const Divider(height: 24),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total',
              style: TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              '\$104.97',
              style: TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProceedButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: () {
          Navigator.pushNamed(context, '/tracking');
        },
        child: const Text(
          'Proceed to Payment',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}