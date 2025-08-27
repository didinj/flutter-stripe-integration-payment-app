import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class PaymentService {
  final String backendUrl = "http://localhost:5000"; // change if deployed

  Future<String?> createPaymentIntent(int amount, String currency) async {
    try {
      final response = await http.post(
        Uri.parse("$backendUrl/create-payment-intent"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"amount": amount, "currency": currency}),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return jsonResponse["clientSecret"];
      } else {
        if (kDebugMode) {
          print("Failed to create payment intent: ${response.body}");
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error creating payment intent: $e");
      }
      return null;
    }
  }
}
