import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:wate_management/Home.dart';

void main() {
  runApp(ViewStatusApp());
}

class ViewStatusApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ViewStatusPage(),
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.grey[50],
      ),
    );
  }
}

class ViewStatusPage extends StatefulWidget {
  @override
  _ViewStatusPageState createState() => _ViewStatusPageState();
}

class _ViewStatusPageState extends State<ViewStatusPage> {
  bool _isLoading = true;
  String? _errorMessage;

  Future<List<PaymentModel>> fetchPayments() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final ip = prefs.getString("ip");
      final uid = prefs.getString("uid");

      if (ip == null || ip.isEmpty) {
        throw Exception('Server configuration missing');
      }

      if (uid == null || uid.isEmpty) {
        throw Exception('User not logged in');
      }

      final response = await http.post(
        Uri.parse("$ip/uview_payment"),
        body: {"uid": uid},
      ).timeout(Duration(seconds: 30));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData["data"] == null) {
          throw Exception('Invalid response format');
        }

        List<PaymentModel> list = [];

        for (var item in jsonData["data"]) {
          list.add(
            PaymentModel(
              id: item["id"]?.toString() ?? 'N/A',
              date: item["date"]?.toString() ?? 'N/A',
              status: item["status"]?.toString() ?? 'Pending',
              recyclerName: item["recyclername"]?.toString() ?? 'Not assigned',
              paymentMode: item["payementmode"]?.toString() ?? 'N/A',
              amount: item["amount"]?.toString() ?? '0.00',
              qty: item["qty"]?.toString() ?? '0',
              productName: item["productname"]?.toString() ?? 'N/A',
              price: item["price"]?.toString() ?? '0.00',
              total: item["total"]?.toString() ?? '0.00',
              photo: item["photo"]?.toString() ?? '',
              orderId: item["orderid"]?.toString() ?? 'N/A',
            ),
          );
        }

        setState(() {
          _isLoading = false;
        });
        return list;
      } else {
        throw Exception('Server responded with status: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
      return [];
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'success':
        return Colors.green;
      case 'pending':
        return Colors.orange[700]!;
      case 'failed':
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'success':
        return Icons.check_circle;
      case 'pending':
        return Icons.pending;
      case 'failed':
      case 'cancelled':
        return Icons.error;
      default:
        return Icons.info;
    }
  }

  IconData _getPaymentModeIcon(String mode) {
    switch (mode.toLowerCase()) {
      case 'cash':
        return Icons.money;
      case 'card':
        return Icons.credit_card;
      case 'online':
      case 'razorpay':
        return Icons.payment;
      case 'wallet':
        return Icons.account_balance_wallet;
      default:
        return Icons.payments;
    }
  }

  IconData _getProductIcon(String productName) {
    if (productName.toLowerCase().contains('plastic')) {
      return Icons.recycling;
    } else if (productName.toLowerCase().contains('organic')) {
      return Icons.restaurant;
    } else if (productName.toLowerCase().contains('paper')) {
      return Icons.description;
    } else if (productName.toLowerCase().contains('glass')) {
      return Icons.local_drink;
    } else if (productName.toLowerCase().contains('metal')) {
      return Icons.construction;
    } else if (productName.toLowerCase().contains('e-waste')) {
      return Icons.devices;
    } else {
      return Icons.delete_sweep;
    }
  }

  @override
  void initState() {
    super.initState();
    fetchPayments();
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
      body: _isLoading
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green[700]!),
            ),
            SizedBox(height: 20),
            Text(
              'Loading payment history...',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      )
          : _errorMessage != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 60,
            ),
            SizedBox(height: 20),
            Text(
              'Failed to load payments',
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                _errorMessage!,
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _errorMessage = null;
                });
                fetchPayments();
              },
              icon: Icon(Icons.refresh),
              label: Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      )
          : FutureBuilder<List<PaymentModel>>(
        future: fetchPayments(),
        builder: (context, snapshot) {
          if (snapshot.data == null || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long,
                    color: Colors.grey[400],
                    size: 80,
                  ),
                  SizedBox(height: 20),
                  Text(
                    "No Payment Records Found",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Your waste service payment history will appear here",
                    style: TextStyle(
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _isLoading = true;
                      });
                      fetchPayments();
                    },
                    icon: Icon(Icons.refresh),
                    label: Text('Refresh'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }

          final data = snapshot.data!;

          return RefreshIndicator(
            onRefresh: () async {
              await fetchPayments();
            },
            color: Colors.green[700],
            child: ListView.builder(
              itemCount: data.length,
              padding: EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final i = data[index];
                final statusColor = _getStatusColor(i.status);
                final totalAmount = double.tryParse(i.total) ?? 0.0;

                return Card(
                  margin: EdgeInsets.only(bottom: 16),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Order Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        _getProductIcon(i.productName),
                                        color: Colors.green[700],
                                        size: 20,
                                      ),
                                      SizedBox(width: 8),
                                      Flexible(
                                        child: Text(
                                          i.productName,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey[800],
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Order #${i.orderId}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: statusColor),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _getStatusIcon(i.status),
                                    color: statusColor,
                                    size: 14,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    i.status.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: statusColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 16),
                        Divider(color: Colors.grey[300]),

                        // Order Details
                        Row(
                          children: [
                            Expanded(
                              child: _buildDetailItem('Quantity', '${i.qty} units', Icons.scale),
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: Colors.grey[300],
                            ),
                            Expanded(
                              child: _buildDetailItem('Unit Price', '₹${i.price}', Icons.monetization_on),
                            ),
                          ],
                        ),

                        SizedBox(height: 12),

                        // Recycler Info
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.business,
                                color: Colors.green[700],
                                size: 16,
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Recycler',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    Text(
                                      i.recyclerName,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 12),

                        // Payment Info
                        Row(
                          children: [
                            Expanded(
                              child: _buildDetailItem(
                                'Payment Mode',
                                i.paymentMode,
                                _getPaymentModeIcon(i.paymentMode),
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: Colors.grey[300],
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Date',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    i.date,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 16),

                        // Total Amount
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total Amount',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green[800],
                                ),
                              ),
                              Text(
                                '₹${totalAmount.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[700],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // View Photo Button (if available)
                        // if (i.photo.isNotEmpty && i.photo != 'N/A')
                          // Padding(
                          //   padding: EdgeInsets.only(top: 12),
                          //   child: OutlinedButton.icon(
                          //     onPressed: () {
                          //       // TODO: Implement photo viewer
                          //     },
                          //     icon: Icon(Icons.image, size: 16),
                          //     label: Text('View Receipt'),
                          //     style: OutlinedButton.styleFrom(
                          //       minimumSize: Size.fromHeight(40),
                          //       shape: RoundedRectangleBorder(
                          //         borderRadius: BorderRadius.circular(8),
                          //       ),
                          //       side: BorderSide(color: Colors.green),
                          //     ),
                          //   ),
                          // ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 4),
        Row(
          children: [
            Icon(icon, size: 14, color: Colors.green[700]),
            SizedBox(width: 6),
            Flexible(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class PaymentModel {
  final String id;
  final String date;
  final String status;
  final String recyclerName;
  final String paymentMode;
  final String amount;
  final String qty;
  final String productName;
  final String price;
  final String total;
  final String photo;
  final String orderId;

  PaymentModel({
    required this.id,
    required this.date,
    required this.status,
    required this.recyclerName,
    required this.paymentMode,
    required this.amount,
    required this.qty,
    required this.productName,
    required this.price,
    required this.total,
    required this.photo,
    required this.orderId,
  });
}







// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
//
// void main() {
//   runApp(ViewStatusApp());
// }
//
// class ViewStatusApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: ViewStatusPage(),
//     );
//   }
// }
//
// class ViewStatusPage extends StatefulWidget {
//   @override
//   _ViewStatusPageState createState() => _ViewStatusPageState();
// }
//
// class _ViewStatusPageState extends State<ViewStatusPage> {
//
//   Future<List<PaymentModel>> fetchPayments() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//
//     final response = await http.post(
//       Uri.parse(prefs.getString("ip").toString() + "/uview_payment"),
//       body: {
//         "uid": prefs.getString("uid").toString(),
//       },
//     );
//
//     final jsonData = json.decode(response.body);
//
//     List<PaymentModel> list = [];
//
//     for (var item in jsonData["data"]) {
//       list.add(
//         PaymentModel(
//           id: item["id"].toString(),
//           date: item["date"].toString(),
//           status: item["status"].toString(),
//           recyclerName: item["recyclername"].toString(),
//           paymentMode: item["payementmode"].toString(),
//           amount: item["amount"].toString(),
//           qty: item["qty"].toString(),
//           productName: item["productname"].toString(),
//           price: item["price"].toString(),
//           total: item["total"].toString(),
//           photo: item["photo"].toString(),
//           orderId: item["orderid"].toString(),
//         ),
//       );
//     }
//
//     return list;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("View Payments"),
//         backgroundColor: Colors.green,
//       ),
//       body: FutureBuilder<List<PaymentModel>>(
//         future: fetchPayments(),
//         builder: (context, snapshot) {
//
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           }
//
//           if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return Center(child: Text("No data found"));
//           }
//
//           final data = snapshot.data!;
//
//           return ListView.builder(
//             itemCount: data.length,
//             itemBuilder: (context, index) {
//               final i = data[index];
//
//               return Card(
//                 margin: EdgeInsets.all(10),
//                 elevation: 4,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Padding(
//                   padding: EdgeInsets.all(14),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//
//                       buildRow("Order ID", i.orderId),
//                       buildRow("Product", i.productName),
//                       buildRow("Quantity", i.qty),
//                       buildRow("Price", i.price),
//                       buildRow("Total", i.total),
//                       Divider(),
//                       buildRow("Recycler", i.recyclerName),
//                       buildRow("Payment Mode", i.paymentMode),
//                       buildRow("Status", i.status),
//                       buildRow("Date", i.date),
//
//                     ],
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
//
//   Widget buildRow(String title, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         children: [
//           SizedBox(
//             width: 120,
//             child: Text(
//               "$title :",
//               style: TextStyle(fontWeight: FontWeight.bold),
//             ),
//           ),
//           Expanded(
//             child: Text(
//               value,
//               style: TextStyle(color: Colors.grey.shade800),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class PaymentModel {
//   final String id;
//   final String date;
//   final String status;
//   final String recyclerName;
//   final String paymentMode;
//   final String amount;
//   final String qty;
//   final String productName;
//   final String price;
//   final String total;
//   final String photo;
//   final String orderId;
//
//   PaymentModel({
//     required this.id,
//     required this.date,
//     required this.status,
//     required this.recyclerName,
//     required this.paymentMode,
//     required this.amount,
//     required this.qty,
//     required this.productName,
//     required this.price,
//     required this.total,
//     required this.photo,
//     required this.orderId,
//   });
// }
