
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'Home.dart';

void main() {
  runApp(viewtype());
}

class viewtype extends StatelessWidget {
  const viewtype({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: viewtype_sub(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.grey[50],
      ),
    );
  }
}

class viewtype_sub extends StatefulWidget {
  const viewtype_sub({Key? key}) : super(key: key);

  @override
  State<viewtype_sub> createState() => _viewtype_subState();
}

class _viewtype_subState extends State<viewtype_sub> {
  bool _isLoading = true;
  String? _errorMessage;
  List<Joke> _wasteTypes = [];

  Future<List<Joke>> _getJokes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final ip = prefs.getString("ip");

      if (ip == null || ip.isEmpty) {
        throw Exception('Server configuration missing');
      }

      var data = await http.post(
        Uri.parse("$ip/view_type"),
        body: {},
      ).timeout(Duration(seconds: 30));

      if (data.statusCode == 200) {
        var jsonData = json.decode(data.body);

        if (jsonData["data"] == null) {
          throw Exception('Invalid response format');
        }

        List<Joke> jokes = [];
        for (var joke in jsonData["data"]) {
          Joke newJoke = Joke(
            joke["id"]?.toString() ?? 'N/A',
            joke["waste"]?.toString() ?? 'Unnamed',
            joke["amount"]?.toString() ?? '0.00',
            joke["note"]?.toString() ?? 'No description available',
            joke["rewards"]?.toString() ?? '0',
          );
          jokes.add(newJoke);
        }

        setState(() {
          _isLoading = false;
          _wasteTypes = jokes;
        });
        return jokes;
      } else {
        throw Exception('Server error: ${data.statusCode}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
      return [];
    }
  }

  IconData _getWasteIcon(String wasteType) {
    final type = wasteType.toLowerCase();
    if (type.contains('plastic') || type.contains('pet') || type.contains('polythene')) {
      return Icons.recycling;
    } else if (type.contains('organic') || type.contains('food') || type.contains('biodegradable')) {
      return Icons.restaurant;
    } else if (type.contains('paper') || type.contains('cardboard') || type.contains('newspaper')) {
      return Icons.description;
    } else if (type.contains('glass') || type.contains('bottle')) {
      return Icons.local_drink;
    } else if (type.contains('metal') || type.contains('aluminium') || type.contains('steel')) {
      return Icons.construction;
    } else if (type.contains('e-waste') || type.contains('electronic') || type.contains('battery')) {
      return Icons.devices;
    } else if (type.contains('hazardous') || type.contains('chemical') || type.contains('medical')) {
      return Icons.dangerous;
    } else if (type.contains('textile') || type.contains('fabric') || type.contains('cloth')) {
      return Icons.checkroom;
    } else if (type.contains('rubber') || type.contains('tire')) {
      return Icons.tire_repair;
    } else {
      return Icons.delete_sweep;
    }
  }

  Color _getWasteColor(String wasteType) {
    final type = wasteType.toLowerCase();
    if (type.contains('plastic')) return Colors.blue;
    if (type.contains('organic')) return Colors.brown;
    if (type.contains('paper')) return Colors.orange;
    if (type.contains('glass')) return Colors.cyan;
    if (type.contains('metal')) return Colors.grey;
    if (type.contains('e-waste')) return Colors.purple;
    if (type.contains('hazardous')) return Colors.red;
    return Colors.green;
  }

  @override
  void initState() {
    super.initState();
    _getJokes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Waste Types & Pricing",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.green[700],
        elevation: 2,
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => home()),
            );
          },
          icon: Icon(Icons.arrow_back, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              _getJokes();
            },
            tooltip: 'Refresh',
          ),
        ],
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
              'Loading waste types...',
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
              'Failed to load waste types',
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
                _getJokes();
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
          : _wasteTypes.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.category_outlined,
              color: Colors.grey[400],
              size: 80,
            ),
            SizedBox(height: 20),
            Text(
              "No Waste Types Available",
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Waste categories will appear here once added",
              style: TextStyle(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: () async {
          await _getJokes();
        },
        color: Colors.green[700],
        child: ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: _wasteTypes.length,
          itemBuilder: (BuildContext context, int index) {
            var i = _wasteTypes[index];
            final wasteColor = _getWasteColor(i.waste);
            final amount = double.tryParse(i.amount) ?? 0.0;
            final rewards = int.tryParse(i.rewards) ?? 0;

            return Card(
              margin: EdgeInsets.only(bottom: 16),
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Waste Type Header
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: wasteColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            _getWasteIcon(i.waste),
                            color: wasteColor,
                            size: 24,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                i.waste,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Type ID: ${i.id}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 16),

                    // Pricing Section
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Price per unit',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '₹$amount',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[700],
                                ),
                              ),
                            ],
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: Colors.grey[300],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Reward Points',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                ),
                              ),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.workspace_premium,
                                    color: Colors.orange[700],
                                    size: 16,
                                  ),
                                  SizedBox(width: 6),
                                  // Text(
                                  //   '$points',
                                  //   style: TextStyle(
                                  //     fontSize: 16,
                                  //     fontWeight: FontWeight.bold,
                                  //     color: Colors.orange[700],
                                  //   ),
                                  // ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 12),

                    // Description
                    if (i.note.isNotEmpty && i.note != 'No description available')
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue[100]!),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.blue[700],
                              size: 18,
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Description',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.blue[800],
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    i.note,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                    SizedBox(height: 12),

                    // Additional Information
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoItem(
                            'Waste ID',
                            i.id,
                            Icons.tag,
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: Colors.grey[300],
                        ),
                        Expanded(
                          child: _buildInfoItem(
                            'Rewards per unit',
                            '$rewards pts',
                            Icons.workspace_premium_outlined,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
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

class Joke {
  final String id;
  final String waste;
  final String amount;
  final String note;
  final String rewards;

  Joke(this.id, this.waste, this.amount, this.note, this.rewards);
}











// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart'as http;
//
// import 'Home.dart';
// void main(){
//   runApp(viewtype());
// }
// class viewtype extends StatelessWidget {
//   const viewtype({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(home: viewtype_sub(),);
//   }
// }
// class viewtype_sub extends StatefulWidget {
//   const viewtype_sub({Key? key}) : super(key: key);
//
//   @override
//   State<viewtype_sub> createState() => _viewtype_subState();
// }
//
// class _viewtype_subState extends State<viewtype_sub> {
//   Future<List<Joke>> _getJokes() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     // String b = prefs.getString("lid").toString();
//     // String foodimage="";
//     var data =
//     await http.post(Uri.parse(prefs.getString("ip").toString()+"/view_type"),
//         body: {}
//     );
//
//     var jsonData = json.decode(data.body);
// //    print(jsonData);
//     List<Joke> jokes = [];
//     for (var joke in jsonData["data"]) {
//       print(joke);
//       Joke newJoke = Joke(
//         joke["id"].toString(),
//         joke["waste"],
//         joke["amount"].toString(),
//         joke["note"].toString(),
//         joke["rewards"].toString(),
//       );
//       jokes.add(newJoke);
//     }
//     return jokes;
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//
//         title: Text("view type"),
//         leading: IconButton(onPressed: (){
//           Navigator.push(context, MaterialPageRoute(builder: (context)=>home()));
//
//         }, icon: Icon(Icons.arrow_back)),
//       ),
//       body:
//
//
//       Container(
//
//         child:
//         FutureBuilder(
//           future: _getJokes(),
//           builder: (BuildContext context, AsyncSnapshot snapshot) {
// //              print("snapshot"+snapshot.toString());
//             if (snapshot.data == null) {
//               return Container(
//                 child: Center(
//                   child: Text("Loading..."),
//                 ),
//               );
//             } else {
//               return ListView.builder(
//                 itemCount: snapshot.data.length,
//                 itemBuilder: (BuildContext context, int index) {
//                   var i = snapshot.data![index];
//                   return Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Card(
//                       elevation: 3,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10),
//                         side: BorderSide(color: Colors.grey.shade300),
//                       ),
//                       child: Padding(
//                         padding: const EdgeInsets.all(16.0),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//
//                             SizedBox(height: 10),
//                             _buildRow("id:", i.id.toString()),
//                             _buildRow("waste:", i.waste.toString()),
//                             _buildRow("amount:", i.amount.toString()),
//                             _buildRow("note:", i.note.toString()),
//                             _buildRow("rewards:", i.rewards.toString()),
//
//                           ],
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               );
//
//
//             }
//           },
//
//
//         ),
//
//
//
//
//
//       ),
//       // floatingActionButton: FloatingActionButton(
//       //   child: Icon(Icons.add),
//       //   onPressed: () {
//       //     Navigator.push(context, MaterialPageRoute(
//       //         builder: (context)=>user_send_complaint(
//       //         )));
//       //   },
//       //
//       // ),
//     );
//   }
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
//
// class Joke {
//   final String id;
//   final String waste;
//
//   final String amount;
//   final String note;
//   final String rewards;
//
//
//
//
//
//   Joke(this.id,this.waste, this.amount,this.note,this.rewards);
// //  print("hiiiii");
// }
//
