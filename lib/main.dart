// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'payment_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey = "pk_test_xxxxxxxxxxxxx"; // replace with your key
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Stripe Payment',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const PaymentScreen(),
    );
  }
}

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final PaymentService _paymentService = PaymentService();
  bool _isLoading = false;

  Future<void> _makePayment() async {
    setState(() => _isLoading = true);

    try {
      // Step 1: Create Payment Intent on backend
      final clientSecret = await _paymentService.createPaymentIntent(
        1000,
        "usd",
      ); // $10

      if (clientSecret == null) {
        throw Exception("Failed to get client secret");
      }

      // Step 2: Initialize payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          style: ThemeMode.light,
          merchantDisplayName: "Djamware Shop",
        ),
      );

      // Step 3: Present payment sheet
      await Stripe.instance.presentPaymentSheet();

      // Success case
      _showMessage("Payment Successful ✅");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SuccessScreen()),
      );
    } on StripeException catch (e) {
      // Stripe-specific errors (canceled, card declined, etc.)
      _showMessage("Payment canceled or failed: ${e.error.localizedMessage}");
    } catch (e) {
      // Other errors
      _showMessage("Something went wrong: $e");
    }

    setState(() => _isLoading = false);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Stripe Payment")),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : ElevatedButton(
                onPressed: _makePayment,
                child: const Text("Pay \$10"),
              ),
      ),
    );
  }
}

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Payment Success")),
      body: const Center(
        child: Icon(Icons.check_circle, color: Colors.green, size: 100),
      ),
    );
  }
}
