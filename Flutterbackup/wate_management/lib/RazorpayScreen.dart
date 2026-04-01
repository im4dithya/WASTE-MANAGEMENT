// pubspec
// razorpay_flutter: ^1.4.0
// #  razorpay_web: ^1.0.0
// js: ^0.6.7
// web: ^0.1.4-beta

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:wate_management/Home.dart';
import 'mobile_razorpay_helper.dart'
if (dart.library.js) 'web_razorpay_helper.dart' as razorpay_helper;
import 'package:razorpay_flutter/razorpay_flutter.dart' as razorpay_flutter;

class RazorpayScreen extends StatefulWidget {
  final double amount;
  final double discountAmount;
  final int rewardPointsUsed;

  RazorpayScreen({
    this.amount = 0,
    this.discountAmount = 0,
    this.rewardPointsUsed = 0,
  });

  @override
  _RazorpayScreenState createState() => _RazorpayScreenState();
}

class _RazorpayScreenState extends State<RazorpayScreen> {
  razorpay_flutter.Razorpay? _razorpay;
  late double finalAmount;
  String _paymentMode = "online"; // Default selection

  @override
  void initState() {
    finalAmount = widget.amount;
    print('RazorpayScreen initialized with amount: $finalAmount');
    super.initState();
    if (!kIsWeb) {
      _razorpay = razorpay_flutter.Razorpay();
      _razorpay?.on(razorpay_flutter.Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
      _razorpay?.on(razorpay_flutter.Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
      _razorpay?.on(razorpay_flutter.Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    }
  }

  void _openCheckout() {
    var options = {
      'key': 'rzp_test_HKCAwYtLt0rwQe',
      'amount': '${(finalAmount * 100).toInt()}',
      'name': 'Neuronexus',
      'description': 'Test Payment',
      'prefill': {
        'contact': '8888888888',
        'email': 'test@neuronexus.com',
      },
      'theme': {'color': '#3399cc'}
    };

    if (kIsWeb) {
      razorpay_helper.openRazorpayWeb(
        options,
        onSuccess: (paymentId) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Payment Successful: $paymentId')),
          );
          updatepaymentstatus();
        },
        onError: (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Payment Failed: $error')),
          );
        },
      );
    } else {
      _razorpay?.open(options);
    }
  }

  void _handlePaymentSuccess(razorpay_flutter.PaymentSuccessResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Payment Successful: ${response.paymentId}")),
    );
    updatepaymentstatus(paymentId: response.paymentId);
  }

  void _handlePaymentError(razorpay_flutter.PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Payment Failed: ${response.message}")),
    );
  }

  void _handleExternalWallet(razorpay_flutter.ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Wallet Selected: ${response.walletName}")),
    );
  }

  Future<void> updatepaymentstatus({String? paymentId}) async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    String ip = sh.getString("ip") ?? "http://localhost:8000";
    String uid = sh.getString("uid") ?? "";
    
    // Generate payment ID for offline or use Razorpay ID
    String finalPaymentId = paymentId ?? 'OFFLINE_${DateTime.now().millisecondsSinceEpoch}';
    
    // Calculate original amount (before discount)
    // If discount > 0: originalAmount = finalAmount + discountAmount
    // If discount = 0: originalAmount = finalAmount (no discount applied)
    double originalAmount = finalAmount + widget.discountAmount;
    
    print('Payment calculation:');
    print('  Final Amount (to pay): $finalAmount');
    print('  Discount Amount: ${widget.discountAmount}');
    print('  Original Amount (total): $originalAmount');
    print('  Reward Points Used: ${widget.rewardPointsUsed}');
    print('  No Reward Used: ${widget.rewardPointsUsed == 0}');
    
    try {
      // Create order with reward discount
      var response = await http.post(
        Uri.parse("$ip/place_order"),
        body: {
          "uid": uid,
          "payment_id": finalPaymentId,
          "total_amount": originalAmount.toString(),
          "payment_mode": _paymentMode,
          "reward_points_used": widget.rewardPointsUsed.toString(),
          "discount_amount": widget.discountAmount.toString(),
        },
      );

      print('Place order response: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        print("Order placed successfully: ${data['order_id']}");
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Order placed successfully!')),
        );
        
        // Navigate back and refresh cart
        Navigator.pop(context, true);
      } else {
        var errorData = json.decode(response.body);
        print("Order placement failed: ${errorData['message']}");
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to place order: ${errorData['message']}')),
        );
      }
    } catch (e) {
      print('Error placing order: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  void dispose() {
    if (!kIsWeb) _razorpay?.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
        title: Text('Payment Options'),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [Colors.white, Colors.blue[50]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 15,
                  spreadRadius: 5,
                ),
              ],
            ),
            padding: EdgeInsets.all(25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.account_balance_wallet, size: 60, color: Colors.blueAccent),
                SizedBox(height: 10),
                Text(
                  'Select Your Payment Method',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                ),
                SizedBox(height: 25),
                AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      RadioListTile<String>(
                        title: Row(
                          children: [
                            Icon(Icons.wifi, color: Colors.green),
                            SizedBox(width: 10),
                            Text('Online Payment'),
                          ],
                        ),
                        value: 'online',
                        groupValue: _paymentMode,
                        onChanged: (value) {
                          setState(() => _paymentMode = value!);
                        },
                      ),
                      Divider(height: 0),
                      RadioListTile<String>(
                        title: Row(
                          children: [
                            Icon(Icons.money_off, color: Colors.redAccent),
                            SizedBox(width: 10),
                            Text('Offline Payment'),
                          ],
                        ),
                        value: 'offline',
                        groupValue: _paymentMode,
                        onChanged: (value) {
                          setState(() => _paymentMode = value!);
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    if (_paymentMode == 'online') {
                      _openCheckout();
                    } else {
                      updatepaymentstatus();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 35, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 8,
                    backgroundColor: _paymentMode == 'online'
                        ? Colors.green
                        : Colors.orangeAccent,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _paymentMode == 'online' ? Icons.payment : Icons.check_circle_outline,
                        color: Colors.white,
                      ),
                      SizedBox(width: 10),
                      Text(
                        _paymentMode == 'online'
                            ? 'Pay ₹${finalAmount.toStringAsFixed(2)} Online'
                            : 'Confirm Offline Booking',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  '* All payments are secure and encrypted',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

}
