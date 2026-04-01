import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'Home.dart';
import 'RazorpayScreen.dart';

void main() {
  runApp(viewcartandpay());
}

class viewcartandpay extends StatefulWidget {
  const viewcartandpay({Key? key}) : super(key: key);

  @override
  State<viewcartandpay> createState() => _viewcartandpayState();
}

class _viewcartandpayState extends State<viewcartandpay> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: viewcartandpay_sub());
  }
}

class viewcartandpay_sub extends StatefulWidget {
  const viewcartandpay_sub({Key? key}) : super(key: key);

  @override
  State<viewcartandpay_sub> createState() => _viewcartandpay_subState();
}

class _viewcartandpay_subState extends State<viewcartandpay_sub> {
  List<Joke> cartItems = [];
  double totalAmount = 0;
  bool isLoading = false;
  Map<String, Map<String, dynamic>> productStockInfo = {};

  // Reward points related
  int userRewardPoints = 0;
  TextEditingController rewardPointsController = TextEditingController();
  double discountAmount = 0;
  double finalAmount = 0;

  // Track if any product is out of stock
  bool hasOutOfStockItems = false;

  @override
  void initState() {
    super.initState();
    _fetchUserRewardPoints();
  }

  Future<List<Joke>> _getJokes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? uid = prefs.getString("uid");
    var data = await http.post(
        Uri.parse(prefs.getString("ip").toString() + "/view_cart"),
        body: {'uid': uid});

    var jsonData = json.decode(data.body);
    List<Joke> jokes = [];
    totalAmount = 0;
    hasOutOfStockItems = false;

    for (var joke in jsonData["data"]) {
      print(joke);
      Joke newJoke = Joke(
        joke["id"].toString(),
        joke["username"],
        joke["product"].toString(),
        joke["quantity"].toString(),
        joke["price"].toString(),
        joke["stock"].toString(),
      );
      jokes.add(newJoke);

      double itemPrice = double.tryParse(joke["price"].toString()) ?? 0;
      double itemQty = double.tryParse(joke["quantity"].toString()) ?? 0;
      totalAmount += (itemPrice * itemQty);

      int availableStock = int.tryParse(joke["stock"].toString()) ?? 0;
      int requestedQty = int.tryParse(joke["quantity"].toString()) ?? 0;
      bool isAvailable = availableStock >= requestedQty;

      if (!isAvailable) {
        hasOutOfStockItems = true;
      }

      productStockInfo[newJoke.id] = {
        'stock': availableStock,
        'quantity': requestedQty,
        'isAvailable': isAvailable,
        'productName': newJoke.product.toString(),
      };
    }
    cartItems = jokes;
    _calculateDiscount();

    return jokes;
  }

  Future<void> _fetchUserRewardPoints() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? ip = prefs.getString("ip");
      String? uid = prefs.getString("uid");

      var response = await http.post(
        Uri.parse("$ip/uprofile_edit"),
        body: {'uid': uid},
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data['data'] != null && data['data'].length > 0) {
          setState(() {
            userRewardPoints = int.tryParse(data['data'][0]['rewards'].toString()) ?? 0;
          });
        }
      }
    } catch (e) {
      print('Error fetching reward points: $e');
    }
  }

  void _calculateDiscount() {
    String pointsStr = rewardPointsController.text.trim();

    if (pointsStr.isEmpty) {
      setState(() {
        discountAmount = 0;
        finalAmount = totalAmount;
      });
      return;
    }

    try {
      int pointsToUse = int.parse(pointsStr);

      if (pointsToUse < 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid reward points')),
        );
        return;
      }

      if (pointsToUse > userRewardPoints) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Insufficient reward points. Available: $userRewardPoints')),
        );
        rewardPointsController.text = userRewardPoints.toString();
        pointsToUse = userRewardPoints;
      }

      setState(() {
        discountAmount = pointsToUse.toDouble();
        finalAmount = (totalAmount - discountAmount).clamp(0.0, double.infinity);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid input')),
      );
    }
  }

  Future<void> _placeOrderDirectly() async {
    try {
      setState(() {
        isLoading = true;
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? ip = prefs.getString("ip");
      String? uid = prefs.getString("uid");

      int pointsUsed = 0;
      if (rewardPointsController.text.isNotEmpty) {
        pointsUsed = int.tryParse(rewardPointsController.text) ?? 0;
      }

      var response = await http.post(
        Uri.parse("$ip/place_order"),
        body: {
          'uid': uid,
          'total_amount': totalAmount.toString(),
          'discount_amount': discountAmount.toString(),
          'final_amount': finalAmount.toString(),
          'reward_points_used': pointsUsed.toString(),
        },
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        if (data['status'] == 'ok') {
          await _clearCart();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Order placed successfully!'),
              backgroundColor: Colors.green,
            ),
          );

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => home()),
                (route) => false,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to place order: ${data['message']}')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Server error')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error placing order: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _clearCart() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? ip = prefs.getString("ip");
      String? uid = prefs.getString("uid");

      await http.post(
        Uri.parse("$ip/clear_cart"),
        body: {'uid': uid},
      );
    } catch (e) {
      print('Error clearing cart: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "View Cart",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFF2E7D32),
        leading: IconButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => home()));
          },
          icon: Icon(Icons.arrow_back, color: Colors.white),
        ),
        centerTitle: true,
        elevation: 2,
      ),
      body: Container(
        color: Colors.grey[50],
        child: FutureBuilder(
          future: _getJokes(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.data == null) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
                ),
              );
            } else if (snapshot.data.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    SizedBox(height: 20),
                    Text(
                      "Your cart is empty",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Add waste management items to get started",
                      style: TextStyle(
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return Column(
                children: [
                  // Cart Summary Banner
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF2E7D32), Color(0xFF43A047)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Your Cart',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              '${snapshot.data.length} items',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '₹${totalAmount.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Out of stock warning
                  if (hasOutOfStockItems)
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFEF5350), Color(0xFFE53935)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning_amber_rounded, color: Colors.white, size: 20),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Some items need attention before checkout',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Cart Items List
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.all(16),
                      itemCount: snapshot.data.length,
                      itemBuilder: (BuildContext context, int index) {
                        var i = snapshot.data![index];
                        var stockInfo = productStockInfo[i.id] ?? {'isAvailable': true, 'stock': 0, 'quantity': 0};
                        bool isAvailable = stockInfo['isAvailable'] ?? true;
                        int availableStock = stockInfo['stock'] ?? 0;
                        int requestedQty = stockInfo['quantity'] ?? 0;
                        double itemTotal = (double.tryParse(i.price) ?? 0) * (double.tryParse(i.quantity) ?? 0);

                        return Container(
                          margin: EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                            border: Border.all(
                              color: isAvailable ? Colors.green.shade100 : Colors.red.shade100,
                              width: 1.5,
                            ),
                          ),
                          child: Stack(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Product Header
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            i.product.toString(),
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.grey[800],
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: isAvailable ? Color(0xFFE8F5E9) : Color(0xFFFFEBEE),
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(
                                              color: isAvailable ? Color(0xFFC8E6C9) : Color(0xFFFFCDD2),
                                            ),
                                          ),
                                          child: Text(
                                            isAvailable ? 'In Stock' : 'Low Stock',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: isAvailable ? Color(0xFF2E7D32) : Color(0xFFD32F2F),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    SizedBox(height: 12),

                                    // Product Details Grid
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey[50],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: EdgeInsets.all(12),
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              _buildDetailItem('Quantity', i.quantity.toString()),
                                              _buildDetailItem('Price', '₹${i.price.toString()}'),
                                              _buildDetailItem('Total', '₹${itemTotal.toStringAsFixed(2)}'),
                                            ],
                                          ),
                                          SizedBox(height: 8),
                                          if (!isAvailable)
                                            Container(
                                              width: double.infinity,
                                              padding: EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: Colors.orange.shade50,
                                                borderRadius: BorderRadius.circular(6),
                                                border: Border.all(color: Colors.orange.shade100),
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(Icons.info_outline, color: Colors.orange, size: 16),
                                                  SizedBox(width: 6),
                                                  Expanded(
                                                    child: Text(
                                                      'Available: $availableStock units',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.orange.shade800,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),

                                    SizedBox(height: 16),

                                    // Action Buttons
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            height: 36,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(color: Colors.grey[300]!),
                                            ),
                                            child: TextButton.icon(
                                              onPressed: () => _deleteFromCart(i.id),
                                              icon: Icon(
                                                Icons.delete_outline,
                                                size: 18,
                                                color: Colors.red,
                                              ),
                                              label: Text(
                                                "Remove",
                                                style: TextStyle(
                                                  color: Colors.red,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              style: TextButton.styleFrom(
                                                padding: EdgeInsets.zero,
                                              ),
                                            ),
                                          ),
                                        ),
                                        if (!isAvailable) ...[
                                          SizedBox(width: 10),
                                          Container(
                                            height: 36,
                                            child: ElevatedButton(
                                              onPressed: () => _removeOutOfStockItem(i.id),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(Icons.close, size: 18),
                                                  SizedBox(width: 4),
                                                  Text("Remove"),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // Stock Badge Corner
                              if (!isAvailable)
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(12),
                                        bottomLeft: Radius.circular(12),
                                      ),
                                    ),
                                    child: Text(
                                      '!',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  // Bottom Summary Panel
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: Offset(0, -5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Reward Points Section
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Color(0xFFC8E6C9)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.card_giftcard_rounded,
                                    color: Color(0xFF2E7D32),
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Reward Points',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF2E7D32),
                                    ),
                                  ),
                                  Spacer(),
                                  Text(
                                    'Available: $userRewardPoints pts',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF4CAF50),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12),
                              TextField(
                                controller: rewardPointsController,
                                keyboardType: TextInputType.number,
                                onChanged: (value) => _calculateDiscount(),
                                decoration: InputDecoration(
                                  hintText: 'Enter points to redeem (1 point = ₹1)',
                                  hintStyle: TextStyle(color: Colors.grey[600]),
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: Colors.grey[300]!),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: Colors.grey[300]!),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: Color(0xFF2E7D32)),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  prefixIcon: Icon(
                                    Icons.confirmation_number_outlined,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                              if (discountAmount > 0) ...[
                                SizedBox(height: 10),
                                Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Color(0xFFC8E6C9),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.discount, color: Color(0xFF2E7D32), size: 18),
                                      SizedBox(width: 6),
                                      Text(
                                        'Points Discount: -₹${discountAmount.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF2E7D32),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),

                        SizedBox(height: 16),

                        // Price Summary
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Color(0xFFF1F8E9),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Color(0xFFDCEDC8)),
                          ),
                          child: Column(
                            children: [
                              _buildPriceRow('Subtotal', '₹${totalAmount.toStringAsFixed(2)}'),
                              if (discountAmount > 0)
                                _buildPriceRow('Points Discount', '-₹${discountAmount.toStringAsFixed(2)}', isDiscount: true),
                              Divider(color: Colors.grey[300], height: 20),
                              _buildPriceRow(
                                'Total Amount',
                                finalAmount <= 0
                                    ? 'FREE'
                                    : '₹${finalAmount.toStringAsFixed(2)}',
                                isTotal: true,
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 16),

                        // Validation Message
                        if (hasOutOfStockItems)
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.orange.shade100),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline, color: Colors.orange, size: 18),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Please remove out-of-stock items to proceed',
                                    style: TextStyle(
                                      color: Colors.orange.shade800,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        SizedBox(height: 16),

                        // Checkout Button
                        Container(
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              if (!hasOutOfStockItems && !isLoading)
                                BoxShadow(
                                  color: Color(0xFF2E7D32).withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: isLoading || hasOutOfStockItems
                                ? null
                                : () {
                              if (finalAmount <= 0) {
                                _placeOrderDirectly();
                              } else {
                                _navigateToPayment();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: hasOutOfStockItems || isLoading
                                  ? Colors.grey[400]
                                  : finalAmount <= 0
                                  ? Color(0xFF4CAF50)
                                  : Color(0xFF2E7D32),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: isLoading
                                ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text(
                                  "Processing...",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            )
                                : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  finalAmount <= 0
                                      ? Icons.check_circle_outline
                                      : Icons.lock_open_outlined,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  finalAmount <= 0
                                      ? "Confirm Order"
                                      : "Proceed to Payment",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: 8),

                        // Secure Payment Note
                        if (!hasOutOfStockItems && !isLoading)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                'Secure payment • 100% Safe & Verified',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  void _navigateToPayment() {
    if (cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cart is empty')),
      );
      return;
    }

    bool allInStock = !hasOutOfStockItems;
    if (!allInStock) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please remove out-of-stock items first')),
      );
      return;
    }

    int pointsUsed = 0;
    if (rewardPointsController.text.isNotEmpty) {
      pointsUsed = int.tryParse(rewardPointsController.text) ?? 0;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RazorpayScreen(
          amount: finalAmount,
          discountAmount: discountAmount,
          rewardPointsUsed: pointsUsed,
        ),
      ),
    ).then((value) {
      if (value == true) {
        setState(() {});
      }
    });
  }

  Future<void> _deleteFromCart(String cartId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? ip = prefs.getString("ip");

      var response = await http.post(
        Uri.parse("$ip/delete_cart_item"),
        body: {'cart_id': cartId},
      );

      if (response.statusCode == 200) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Item removed from cart'),
            backgroundColor: Color(0xFF2E7D32),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error removing item: $e')),
      );
    }
  }

  Future<void> _removeOutOfStockItem(String cartId) async {
    await _deleteFromCart(cartId);
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2E7D32),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isDiscount = false, bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
              color: isTotal ? Colors.grey[800] : Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
              color: isTotal
                  ? Color(0xFF2E7D32)
                  : isDiscount
                  ? Colors.green.shade700
                  : Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }
}

class Joke {
  final String id;
  final String username;
  final String product;
  final String quantity;
  final String price;
  final String stock;

  Joke(this.id, this.username, this.product, this.quantity, this.price, this.stock);
}











// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
//
// import 'Home.dart';
// import 'RazorpayScreen.dart';
//
// void main() {
//   runApp(viewcartandpay());
// }
//
// class viewcartandpay extends StatefulWidget {
//   const viewcartandpay({Key? key}) : super(key: key);
//
//   @override
//   State<viewcartandpay> createState() => _viewcartandpayState();
// }
//
// class _viewcartandpayState extends State<viewcartandpay> {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(home: viewcartandpay_sub());
//   }
// }
//
// class viewcartandpay_sub extends StatefulWidget {
//   const viewcartandpay_sub({Key? key}) : super(key: key);
//
//   @override
//   State<viewcartandpay_sub> createState() => _viewcartandpay_subState();
// }
//
// class _viewcartandpay_subState extends State<viewcartandpay_sub> {
//   List<Joke> cartItems = [];
//   double totalAmount = 0;
//   bool isLoading = false;
//   Map<String, Map<String, dynamic>> productStockInfo = {}; // Track stock info: {stock, quantity, isAvailable}
//
//   // Reward points related
//   int userRewardPoints = 0;
//   TextEditingController rewardPointsController = TextEditingController();
//   double discountAmount = 0;
//   double finalAmount = 0;
//
//   // Track if any product is out of stock
//   bool hasOutOfStockItems = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchUserRewardPoints();
//   }
//
//   Future<List<Joke>> _getJokes() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? uid = prefs.getString("uid");
//     var data = await http.post(
//         Uri.parse(prefs.getString("ip").toString() + "/view_cart"),
//         body: {'uid': uid}
//     );
//
//     var jsonData = json.decode(data.body);
//     List<Joke> jokes = [];
//     totalAmount = 0;
//     hasOutOfStockItems = false;
//
//     for (var joke in jsonData["data"]) {
//       print(joke);
//       Joke newJoke = Joke(
//         joke["id"].toString(),
//         joke["username"],
//         joke["product"].toString(),
//         joke["quantity"].toString(),
//         joke["price"].toString(),
//         joke["stock"].toString(),
//       );
//       jokes.add(newJoke);
//
//       // Calculate item total: price × quantity
//       double itemPrice = double.tryParse(joke["price"].toString()) ?? 0;
//       double itemQty = double.tryParse(joke["quantity"].toString()) ?? 0;
//       totalAmount += (itemPrice * itemQty);
//
//       // Check stock availability
//       int availableStock = int.tryParse(joke["stock"].toString()) ?? 0;
//       int requestedQty = int.tryParse(joke["quantity"].toString()) ?? 0;
//       bool isAvailable = availableStock >= requestedQty;
//
//       if (!isAvailable) {
//         hasOutOfStockItems = true;
//       }
//
//       productStockInfo[newJoke.id] = {
//         'stock': availableStock,
//         'quantity': requestedQty,
//         'isAvailable': isAvailable,
//         'productName': newJoke.product.toString(),
//       };
//     }
//     cartItems = jokes;
//
//     // Calculate final amount after initial discount calculation
//     _calculateDiscount();
//
//     return jokes;
//   }
//
//   Future<void> _fetchUserRewardPoints() async {
//     try {
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       String? ip = prefs.getString("ip");
//       String? uid = prefs.getString("uid");
//
//       var response = await http.post(
//         Uri.parse("$ip/uprofile_edit"),
//         body: {'uid': uid},
//       );
//
//       if (response.statusCode == 200) {
//         var data = json.decode(response.body);
//         if (data['data'] != null && data['data'].length > 0) {
//           setState(() {
//             userRewardPoints = int.tryParse(data['data'][0]['rewards'].toString()) ?? 0;
//           });
//         }
//       }
//     } catch (e) {
//       print('Error fetching reward points: $e');
//     }
//   }
//
//   void _calculateDiscount() {
//     String pointsStr = rewardPointsController.text.trim();
//
//     // Reset discount if no points entered
//     if (pointsStr.isEmpty) {
//       setState(() {
//         discountAmount = 0;
//         finalAmount = totalAmount;
//       });
//       return;
//     }
//
//     try {
//       int pointsToUse = int.parse(pointsStr);
//
//       // Validate
//       if (pointsToUse < 0) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Invalid reward points')),
//         );
//         return;
//       }
//
//       if (pointsToUse > userRewardPoints) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Insufficient reward points. Available: $userRewardPoints')),
//         );
//         rewardPointsController.text = userRewardPoints.toString();
//         pointsToUse = userRewardPoints;
//       }
//
//       // 1 point = 1 rupee discount
//       setState(() {
//         discountAmount = pointsToUse.toDouble();
//         finalAmount = (totalAmount - discountAmount).clamp(0.0, double.infinity);
//       });
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Invalid input')),
//       );
//     }
//   }
//
//   Future<void> _placeOrderDirectly() async {
//     try {
//       setState(() {
//         isLoading = true;
//       });
//
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       String? ip = prefs.getString("ip");
//       String? uid = prefs.getString("uid");
//
//       // Get reward points used
//       int pointsUsed = 0;
//       if (rewardPointsController.text.isNotEmpty) {
//         pointsUsed = int.tryParse(rewardPointsController.text) ?? 0;
//       }
//
//       // Call API to place order directly (without payment)
//       var response = await http.post(
//         Uri.parse("$ip/place_order"),
//         body: {
//           'uid': uid,
//           'total_amount': totalAmount.toString(),
//           'discount_amount': discountAmount.toString(),
//           'final_amount': finalAmount.toString(),
//           'reward_points_used': pointsUsed.toString(),
//         },
//       );
//
//       if (response.statusCode == 200) {
//         var data = json.decode(response.body);
//
//         if (data['status'] == 'ok') {
//           // Clear cart
//           await _clearCart();
//
//           // Show success message
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text('Order placed successfully!'),
//               backgroundColor: Colors.green,
//             ),
//           );
//
//           // Navigate back to home
//           Navigator.pushAndRemoveUntil(
//             context,
//             MaterialPageRoute(builder: (context) => home()),
//                 (route) => false,
//           );
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Failed to place order: ${data['message']}')),
//           );
//         }
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Server error')),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error placing order: $e')),
//       );
//     } finally {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }
//
//   Future<void> _clearCart() async {
//     try {
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       String? ip = prefs.getString("ip");
//       String? uid = prefs.getString("uid");
//
//       await http.post(
//         Uri.parse("$ip/clear_cart"),
//         body: {'uid': uid},
//       );
//     } catch (e) {
//       print('Error clearing cart: $e');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("View Cart and Pay"),
//         leading: IconButton(
//           onPressed: () {
//             Navigator.push(context, MaterialPageRoute(builder: (context) => home()));
//           },
//           icon: Icon(Icons.arrow_back),
//         ),
//       ),
//       body: Container(
//         child: FutureBuilder(
//           future: _getJokes(),
//           builder: (BuildContext context, AsyncSnapshot snapshot) {
//             if (snapshot.data == null) {
//               return Container(
//                 child: Center(
//                   child: CircularProgressIndicator(),
//                 ),
//               );
//             } else if (snapshot.data.isEmpty) {
//               return Center(
//                 child: Text("Cart is empty"),
//               );
//             } else {
//               return Column(
//                 children: [
//                   // Out of stock warning banner
//                   if (hasOutOfStockItems)
//                     Container(
//                       width: double.infinity,
//                       padding: EdgeInsets.all(12),
//                       color: Colors.red.shade100,
//                       child: Row(
//                         children: [
//                           Icon(Icons.warning, color: Colors.red),
//                           SizedBox(width: 8),
//                           Expanded(
//                             child: Text(
//                               'Some items are out of stock. Please update quantities or remove them.',
//                               style: TextStyle(color: Colors.red),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//
//                   Expanded(
//                     child: ListView.builder(
//                       itemCount: snapshot.data.length,
//                       itemBuilder: (BuildContext context, int index) {
//                         var i = snapshot.data![index];
//                         var stockInfo = productStockInfo[i.id] ?? {'isAvailable': true, 'stock': 0, 'quantity': 0};
//                         bool isAvailable = stockInfo['isAvailable'] ?? true;
//                         int availableStock = stockInfo['stock'] ?? 0;
//                         int requestedQty = stockInfo['quantity'] ?? 0;
//
//                         return Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: Card(
//                             elevation: 3,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(10),
//                               side: BorderSide(color: isAvailable ? Colors.grey.shade300 : Colors.red),
//                             ),
//                             child: Padding(
//                               padding: const EdgeInsets.all(16.0),
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   SizedBox(height: 10),
//                                   _buildRow("Product:", i.product.toString()),
//                                   _buildRow("Quantity:", i.quantity.toString()),
//                                   _buildRow("Price:", "₹${i.price.toString()}"),
//                                   _buildRow("Total:", "₹${((double.tryParse(i.price) ?? 0) * (double.tryParse(i.quantity) ?? 0)).toStringAsFixed(2)}"),
//                                   SizedBox(height: 8),
//
//                                   // Stock Status with detailed message
//                                   Container(
//                                     padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                                     decoration: BoxDecoration(
//                                       color: isAvailable ? Colors.green.shade100 : Colors.red.shade100,
//                                       borderRadius: BorderRadius.circular(6),
//                                     ),
//                                     child: Row(
//                                       mainAxisSize: MainAxisSize.min,
//                                       children: [
//                                         Icon(
//                                           isAvailable ? Icons.check_circle : Icons.warning,
//                                           color: isAvailable ? Colors.green : Colors.red,
//                                           size: 16,
//                                         ),
//                                         SizedBox(width: 6),
//                                         Text(
//                                           isAvailable
//                                               ? 'In Stock ($availableStock available)'
//                                               : 'Out of Stock! Available: $availableStock, Requested: $requestedQty',
//                                           style: TextStyle(
//                                             fontSize: 12,
//                                             fontWeight: FontWeight.bold,
//                                             color: isAvailable ? Colors.green : Colors.red,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//
//                                   SizedBox(height: 12),
//                                   Row(
//                                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                     children: [
//                                       if (!isAvailable)
//                                         ElevatedButton(
//                                           onPressed: () => _removeOutOfStockItem(i.id),
//                                           style: ElevatedButton.styleFrom(
//                                             backgroundColor: Colors.red,
//                                           ),
//                                           child: Text("Remove"),
//                                         ),
//                                       TextButton.icon(
//                                         onPressed: () => _deleteFromCart(i.id),
//                                         icon: Icon(Icons.delete),
//                                         label: Text("Remove"),
//                                         style: TextButton.styleFrom(
//                                           foregroundColor: Colors.red,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//
//                   // Bottom order section
//                   Container(
//                     padding: EdgeInsets.all(16),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.grey.withOpacity(0.5),
//                           blurRadius: 5,
//                         )
//                       ],
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.stretch,
//                       children: [
//                         Text(
//                           "Total Items: ${snapshot.data.length}",
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         SizedBox(height: 12),
//
//                         // Reward Points Section
//                         Container(
//                           padding: EdgeInsets.all(12),
//                           decoration: BoxDecoration(
//                             color: Colors.orange.shade100,
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 '🎁 Your Reward Points: $userRewardPoints',
//                                 style: TextStyle(
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.orange.shade800,
//                                 ),
//                               ),
//                               SizedBox(height: 8),
//                               TextField(
//                                 controller: rewardPointsController,
//                                 keyboardType: TextInputType.number,
//                                 onChanged: (value) => _calculateDiscount(),
//                                 decoration: InputDecoration(
//                                   hintText: 'Enter points to redeem (1 point = ₹1)',
//                                   border: OutlineInputBorder(),
//                                   contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
//                                 ),
//                               ),
//                               if (discountAmount > 0)
//                                 Padding(
//                                   padding: const EdgeInsets.only(top: 8.0),
//                                   child: Text(
//                                     'Discount: -₹${discountAmount.toStringAsFixed(2)}',
//                                     style: TextStyle(
//                                       fontSize: 12,
//                                       color: Colors.green,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                 ),
//                             ],
//                           ),
//                         ),
//
//                         SizedBox(height: 12),
//
//                         // Final Amount
//                         Container(
//                           padding: EdgeInsets.all(12),
//                           decoration: BoxDecoration(
//                             color: Colors.blue.shade50,
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Row(
//                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Text('Subtotal:'),
//                                   Text('₹${totalAmount.toStringAsFixed(2)}'),
//                                 ],
//                               ),
//                               if (discountAmount > 0)
//                                 Row(
//                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     Text('Discount:'),
//                                     Text(
//                                       '-₹${discountAmount.toStringAsFixed(2)}',
//                                       style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
//                                     ),
//                                   ],
//                                 ),
//                               Divider(),
//                               Row(
//                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Text(
//                                     'Final Amount:',
//                                     style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//                                   ),
//                                   Text(
//                                     finalAmount <= 0
//                                         ? 'FREE'
//                                         : '₹${finalAmount.toStringAsFixed(2)}',
//                                     style: TextStyle(
//                                       fontWeight: FontWeight.bold,
//                                       fontSize: 16,
//                                       color: finalAmount <= 0 ? Colors.green : Colors.blue,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ),
//
//                         SizedBox(height: 12),
//
//                         // Validation messages
//                         if (hasOutOfStockItems)
//                           Container(
//                             padding: EdgeInsets.all(8),
//                             decoration: BoxDecoration(
//                               color: Colors.red.shade50,
//                               borderRadius: BorderRadius.circular(6),
//                             ),
//                             child: Text(
//                               '⚠️ Please remove out-of-stock items before proceeding',
//                               style: TextStyle(color: Colors.red),
//                               textAlign: TextAlign.center,
//                             ),
//                           ),
//
//                         SizedBox(height: 12),
//
//                         // Payment/Order Button
//                         ElevatedButton.icon(
//                           onPressed: isLoading || hasOutOfStockItems ? null : () {
//                             if (finalAmount <= 0) {
//                               // Direct order placement for zero amount
//                               _placeOrderDirectly();
//                             } else {
//                               // Navigate to payment for non-zero amount
//                               _navigateToPayment();
//                             }
//                           },
//                           icon: Icon(
//                             finalAmount <= 0 ? Icons.shopping_cart_checkout : Icons.payment,
//                           ),
//                           label: Text(
//                             isLoading
//                                 ? "Processing..."
//                                 : finalAmount <= 0
//                                 ? "Place Order (Free)"
//                                 : "Proceed to Payment",
//                           ),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: finalAmount <= 0 ? Colors.green : Colors.blue,
//                             padding: EdgeInsets.symmetric(vertical: 14),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               );
//             }
//           },
//         ),
//       ),
//     );
//   }
//
//   void _navigateToPayment() {
//     if (cartItems.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Cart is empty')),
//       );
//       return;
//     }
//
//     // Check if all items are in stock
//     bool allInStock = !hasOutOfStockItems;
//     if (!allInStock) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Please remove out-of-stock items first')),
//       );
//       return;
//     }
//
//     // Get reward points used
//     int pointsUsed = 0;
//     if (rewardPointsController.text.isNotEmpty) {
//       pointsUsed = int.tryParse(rewardPointsController.text) ?? 0;
//     }
//
//     print('Navigation to RazorpayScreen:');
//     print('  Total Amount: $totalAmount');
//     print('  Discount: $discountAmount');
//     print('  Final Amount: $finalAmount');
//     print('  Points Used: $pointsUsed');
//
//     // Navigate to RazorpayScreen with cart data
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => RazorpayScreen(
//           amount: finalAmount,
//           discountAmount: discountAmount,
//           rewardPointsUsed: pointsUsed,
//         ),
//       ),
//     ).then((value) {
//       if (value == true) {
//         // Payment successful, refresh cart
//         setState(() {});
//       }
//     });
//   }
//
//   Future<void> _deleteFromCart(String cartId) async {
//     try {
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       String? ip = prefs.getString("ip");
//
//       var response = await http.post(
//         Uri.parse("$ip/delete_cart_item"),
//         body: {'cart_id': cartId},
//       );
//
//       if (response.statusCode == 200) {
//         setState(() {});
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Item removed from cart')),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error removing item: $e')),
//       );
//     }
//   }
//
//   Future<void> _removeOutOfStockItem(String cartId) async {
//     await _deleteFromCart(cartId);
//   }
//
//   Widget _buildRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         children: [
//           SizedBox(
//             width: 100,
//             child: Text(
//               label,
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//           SizedBox(width: 5),
//           Flexible(
//             child: Text(
//               value,
//               style: TextStyle(
//                 color: Colors.grey.shade800,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class Joke {
//   final String id;
//   final String username;
//   final String product;
//   final String quantity;
//   final String price;
//   final String stock;
//
//   Joke(this.id, this.username, this.product, this.quantity, this.price, this.stock);
// }