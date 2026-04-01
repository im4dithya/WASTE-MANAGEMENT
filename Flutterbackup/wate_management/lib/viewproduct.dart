import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'Home.dart';

void main() {
  runApp(viewproduct());
}

class viewproduct extends StatelessWidget {
  const viewproduct({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: viewproduct_sub());
  }
}

class viewproduct_sub extends StatefulWidget {
  const viewproduct_sub({Key? key}) : super(key: key);

  @override
  State<viewproduct_sub> createState() => _viewproduct_subState();
}

class _viewproduct_subState extends State<viewproduct_sub> {
  TextEditingController _quantityController = TextEditingController();
  String _searchQuery = '';

  Future<List<Joke>> _getJokes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var data = await http.post(
      Uri.parse("${prefs.getString("ip")}/uview_product"),
      body: {},
    );

    var jsonData = json.decode(data.body);
    List<Joke> jokes = [];
    for (var joke in jsonData["data"]) {
      print(joke);
      Joke newJoke = Joke(
        joke["id"].toString(),
        joke["recyclername"].toString(),
        joke["name"].toString(),
        "${prefs.getString("ip")}${joke["photo"].toString()}",
        joke["price"].toString(),
        joke["quantity"].toString().trim(),
      );
      jokes.add(newJoke);
    }
    return jokes;
  }

  List<Joke> _filterProducts(List<Joke> products) {
    if (_searchQuery.isEmpty) return products;
    return products.where((product) {
      return product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          product.recyclername.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Eco Products",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFF0A7A5E),
        leading: IconButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => home()));
          },
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
        ),
        elevation: 0,
      ),
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Search and Filter Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Search Bar
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: "Search products...",
                      border: InputBorder.none,
                      icon: Icon(Icons.search, color: Color(0xFF0A7A5E)),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                        icon: Icon(Icons.clear, size: 20),
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                          : null,
                    ),
                  ),
                ),
                SizedBox(height: 12),
                // Stats Bar
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: FutureBuilder<List<Joke>>(
                    future: _getJokes(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data != null) {
                        int inStock = snapshot.data!.where((p) {
                          int quantity = int.tryParse(p.quantity) ?? 0;
                          return quantity > 0;
                        }).length;
                        int outOfStock = snapshot.data!.length - inStock;

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem("Total", snapshot.data!.length.toString(), Icons.grid_view, Color(0xFF0A7A5E)),
                            _buildStatItem("In Stock", inStock.toString(), Icons.check_circle, Colors.green),
                            _buildStatItem("Out of Stock", outOfStock.toString(), Icons.cancel, Colors.orange),
                          ],
                        );
                      }
                      return Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF0A7A5E),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // Products Grid
          Expanded(
            child: FutureBuilder<List<Joke>>(
              future: _getJokes(),
              builder: (BuildContext context, AsyncSnapshot<List<Joke>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: Color(0xFF0A7A5E),
                        ),
                        SizedBox(height: 20),
                        Text(
                          "Loading eco products...",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text("Error loading products"),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 80,
                          color: Colors.grey[300],
                        ),
                        SizedBox(height: 20),
                        Text(
                          "No products available",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                    List<Joke> filteredProducts = _filterProducts(snapshot.data!);
                  if (filteredProducts.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 80,
                            color: Colors.grey[300],
                          ),
                          SizedBox(height: 20),
                          Text(
                            "No products found",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            _searchQuery.isEmpty ? "No products available" : "No results for '$_searchQuery'",
                            style: TextStyle(
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      var product = filteredProducts[index];
                      int productQuantity = int.tryParse(product.quantity.trim()) ?? 0;
                      bool isInStock = productQuantity > 0;

                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                            // Product Image Container
                            Stack(
                              children: [
                                Container(
                                  height: 120,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Color(0xFFE8F5E9),
                                        Color(0xFFC8E6C9),
                                      ],
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                                    child: product.photo.isNotEmpty
                                        ? Image.network(
                                      product.photo,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Center(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.recycling,
                                                size: 50,
                                                color: Color(0xFF0A7A5E),
                                              ),
                                              SizedBox(height: 8),
                                              Text(
                                                "Eco Product",
                                                style: TextStyle(
                                                  color: Color(0xFF0A7A5E),
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    )
                                        : Center(
                                      child: Icon(
                                        Icons.recycling,
                                        size: 50,
                                        color: Color(0xFF0A7A5E),
                                      ),
                                    ),
                                  ),
                                ),
                                // Stock Badge
                                Positioned(
                                  top: 2,
                                  right: 8,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isInStock ? Colors.green : Colors.red,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      isInStock ? "IN STOCK" : "OUT OF STOCK",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            // Product Details
                            Flexible(
                              child: Padding(
                                padding: const EdgeInsets.all(2),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                  // Product Name
                                  Text(
                                    product.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 1),
                                  // Recycler Name
                                  Text(
                                    product.recyclername,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 1),
                                  // Price
                                  Row(
                                    children: [
                                      Text(
                                        "₹${product.price}",
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF0A7A5E),
                                        ),
                                      ),
                                      Spacer(),
                                      Text(
                                        "${product.quantity.trim()} units",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 1),
                                  // Add to Cart Button
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: isInStock ? () => _showAddToCartDialog(context, product) : null,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: isInStock ? Color(0xFF0A7A5E) : Colors.grey[400],
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        padding: EdgeInsets.symmetric(vertical: 8),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.shopping_cart,
                                            size: 16,
                                            color: Colors.white,
                                          ),
                                          SizedBox(width: 6),
                                          Text(
                                            "Add to Cart",
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Future<void> _showAddToCartDialog(BuildContext context, Joke product) async {
    _quantityController.clear();
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.shopping_cart, color: Color(0xFF0A7A5E)),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Add ${product.name} to Cart',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Preview
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: product.photo.isNotEmpty
                              ? DecorationImage(
                            image: NetworkImage(product.photo),
                            fit: BoxFit.cover,
                          )
                              : null,
                          color: Colors.white,
                        ),
                        child: product.photo.isEmpty
                            ? Icon(Icons.recycling, color: Color(0xFF0A7A5E))
                            : null,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4),
                            Text(
                              product.recyclername,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '₹${product.price}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0A7A5E),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                // Stock Info
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Available Stock:',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Color(0xFF0A7A5E).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${product.quantity} units',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0A7A5E),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                // Quantity Input
                Text(
                  'Enter Quantity:',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: _quantityController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Color(0xFFF5F5F5),
                    hintText: 'Enter quantity (1-${product.quantity})',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Color(0xFF0A7A5E)),
                    ),
                    prefixIcon: Icon(Icons.format_list_numbered, color: Color(0xFF0A7A5E)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey[600]!),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () async {
                String quantity = _quantityController.text.trim();

                if (quantity.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please enter a quantity'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }

                try {
                  int qty = int.parse(quantity);
                  int available = int.parse(product.quantity);

                  if (qty <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Quantity must be greater than 0'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                    return;
                  }

                  if (qty > available) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Quantity exceeds available stock'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  // Add to cart via API
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  String? ip = prefs.getString("ip");
                  String? uid = prefs.getString("uid");

                  print('Adding to cart: uid=$uid, product_id=${product.id}, quantity=$quantity');

                  var response = await http.post(
                    Uri.parse("$ip/add_to_cart"),
                    body: {
                      'uid': uid,
                      'product_id': product.id,
                      'quantity': quantity,
                    },
                  );

                  print('Response status: ${response.statusCode}');
                  print('Response body: ${response.body}');

                  var responseData = json.decode(response.body);

                  if (response.statusCode == 200 && responseData['status'] == 'ok') {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('✓ ${product.name} added to cart!',style:TextStyle(fontWeight:FontWeight.bold,color: Colors.white),),
                        backgroundColor: Colors.blue,
                        duration: Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to add to cart: ${responseData['message'] ?? 'Unknown error'}'),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                } catch (e) {
                  print('Exception adding to cart: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: Please enter a valid number'),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              child: Text('Add to Cart'),
            ),
          ],
        );
      },
    );
  }
}

class Joke {
  final String id;
  final String recyclername;
  final String name;
  final String photo;
  final String price;
  final String quantity;

  Joke(this.id, this.recyclername, this.name, this.photo, this.price, this.quantity);
}



// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart'as http;
//
// import 'Home.dart';
// void main(){
//   runApp(viewproduct());
// }
// class viewproduct extends StatelessWidget {
//   const viewproduct({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(home: viewproduct_sub(),);
//   }
// }
// class viewproduct_sub extends StatefulWidget {
//   const viewproduct_sub({Key? key}) : super(key: key);
//
//   @override
//   State<viewproduct_sub> createState() => _viewproduct_subState();
// }
//
// class _viewproduct_subState extends State<viewproduct_sub> {
//   TextEditingController _quantityController = TextEditingController();
//
//   Future<List<Joke>> _getJokes() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     // String b = prefs.getString("lid").toString();
//     // String foodimage="";
//     var data =
//     await http.post(Uri.parse(prefs.getString("ip").toString()+"/uview_product"),
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
//         joke["recyclername"],
//         joke["name"].toString(),
//         prefs.getString("ip").toString()+joke["photo"].toString(),
//         joke["price"].toString(),
//         joke["quantity"].toString(),
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
//         title: Text("view product"),
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
//                             // Product Image
//                             ClipRRect(
//                               borderRadius: BorderRadius.circular(8),
//                               child: i.photo.isNotEmpty
//                                   ? Image.network(
//                                 i.photo,
//                                 height: 200,
//                                 width: double.infinity,
//                                 fit: BoxFit.cover,
//                                 errorBuilder: (context, error, stackTrace) {
//                                   print('Image error: $error');
//                                   print('Photo URL: ${i.photo}');
//                                   return Container(
//                                     height: 200,
//                                     width: double.infinity,
//                                     color: Colors.grey.shade300,
//                                     child: Column(
//                                       mainAxisAlignment: MainAxisAlignment.center,
//                                       children: [
//                                         Icon(Icons.image_not_supported, size: 40),
//                                         SizedBox(height: 8),
//                                         Text('Image not available'),
//                                       ],
//                                     ),
//                                   );
//                                 },
//                               )
//                                   : Container(
//                                 height: 200,
//                                 width: double.infinity,
//                                 color: Colors.grey.shade300,
//                                 child: Icon(Icons.image, size: 50),
//                               ),
//                             ),
//                             SizedBox(height: 16),
//
//                             // Product Name (Header)
//                             Text(
//                               i.name.toString(),
//                               style: TextStyle(
//                                 fontSize: 22,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.black87,
//                               ),
//                             ),
//                             SizedBox(height: 8),
//
//                             // Recycler Info
//                             Container(
//                               padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                               decoration: BoxDecoration(
//                                 color: Colors.blue.shade100,
//                                 borderRadius: BorderRadius.circular(20),
//                               ),
//                               child: Text(
//                                 'By: ${i.recyclername.toString()}',
//                                 style: TextStyle(
//                                   fontSize: 14,
//                                   color: Colors.blue.shade800,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                             ),
//                             SizedBox(height: 16),
//
//                             // Price and Stock Info Row
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       'Price',
//                                       style: TextStyle(
//                                         fontSize: 12,
//                                         color: Colors.grey,
//                                       ),
//                                     ),
//                                     SizedBox(height: 4),
//                                     Text(
//                                       '₹${i.price.toString()}',
//                                       style: TextStyle(
//                                         fontSize: 24,
//                                         fontWeight: FontWeight.bold,
//                                         color: Colors.green,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 Column(
//                                   crossAxisAlignment: CrossAxisAlignment.end,
//                                   children: [
//                                     Text(
//                                       'Stock Available',
//                                       style: TextStyle(
//                                         fontSize: 12,
//                                         color: Colors.grey,
//                                       ),
//                                     ),
//                                     SizedBox(height: 4),
//                                     Container(
//                                       padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//                                       decoration: BoxDecoration(
//                                         color: (int.tryParse(i.quantity.toString()) ?? 0) > 0
//                                             ? Colors.green.shade100
//                                             : Colors.red.shade100,
//                                         borderRadius: BorderRadius.circular(8),
//                                       ),
//                                       child: Text(
//                                         '${i.quantity.toString()} units',
//                                         style: TextStyle(
//                                           fontSize: 14,
//                                           fontWeight: FontWeight.bold,
//                                           color: (int.tryParse(i.quantity.toString()) ?? 0) > 0
//                                               ? Colors.green
//                                               : Colors.red,
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                             SizedBox(height: 16),
//
//                             // Divider
//                             Divider(thickness: 1, height: 1),
//                             SizedBox(height: 16),
//
//                             // Additional Info
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                               children: [
//                                 _buildInfoChip('ID', i.id.toString()),
//                                 Spacer(),
//                                 _buildInfoChip(
//                                   'Status',
//                                   (int.tryParse(i.quantity.toString()) ?? 0) > 0
//                                       ? 'In Stock'
//                                       : 'Out of Stock',
//                                 ),
//                               ],
//                             ),
//
//                             SizedBox(height: 16),
//                             SizedBox(
//                               width: double.infinity,
//                               child: ElevatedButton.icon(
//                                 onPressed: (int.tryParse(i.quantity.toString()) ?? 0) > 0
//                                     ? () => _showAddToCartDialog(context, i)
//                                     : null,
//                                 icon: Icon(Icons.shopping_cart),
//                                 label: Text(
//                                   (int.tryParse(i.quantity.toString()) ?? 0) > 0
//                                       ? "Add to Cart"
//                                       : "Out of Stock",
//                                 ),
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor:
//                                       (int.tryParse(i.quantity.toString()) ?? 0) > 0
//                                           ? Colors.green
//                                           : Colors.grey,
//                                   disabledBackgroundColor: Colors.grey.shade300,
//                                   padding: EdgeInsets.symmetric(vertical: 12),
//                                 ),
//                               ),
//                             ),
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
//
//   Future<void> _showAddToCartDialog(BuildContext context, Joke product) async {
//     _quantityController.clear();
//     return showDialog<void>(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Add ${product.name} to Cart'),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text('Product: ${product.name}'),
//               SizedBox(height: 8),
//               Text('Price: ${product.price}'),
//               SizedBox(height: 8),
//               Text('Available: ${product.quantity}'),
//               SizedBox(height: 12),
//               TextField(
//                 controller: _quantityController,
//                 keyboardType: TextInputType.number,
//                 decoration: InputDecoration(
//                   labelText: 'Enter Quantity',
//                   hintText: 'Max: ${product.quantity}',
//                   border: OutlineInputBorder(),
//                 ),
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               child: Text('Cancel'),
//               onPressed: () => Navigator.of(context).pop(),
//             ),
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
//               child: Text('Add to Cart'),
//               onPressed: () async {
//                 String quantity = _quantityController.text.trim();
//
//                 if (quantity.isEmpty) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(content: Text('Please enter a quantity')),
//                   );
//                   return;
//                 }
//
//                 try {
//                   int qty = int.parse(quantity);
//                   int available = int.parse(product.quantity);
//
//                   if (qty <= 0) {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(content: Text('Quantity must be greater than 0')),
//                     );
//                     return;
//                   }
//
//                   if (qty > available) {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(content: Text('Quantity exceeds available stock')),
//                     );
//                     return;
//                   }
//
//                   // Add to cart via API
//                   SharedPreferences prefs = await SharedPreferences.getInstance();
//                   String? ip = prefs.getString("ip");
//                   String? uid = prefs.getString("uid");
//
//                   print('Adding to cart: uid=$uid, product_id=${product.id}, quantity=$quantity');
//
//                   var response = await http.post(
//                     Uri.parse("$ip/add_to_cart"),
//                     body: {
//                       'uid': uid,
//                       'product_id': product.id,
//                       'quantity': quantity,
//                     },
//                   );
//
//                   print('Response status: ${response.statusCode}');
//                   print('Response body: ${response.body}');
//
//                   var responseData = json.decode(response.body);
//
//                   if (response.statusCode == 200 && responseData['status'] == 'ok') {
//                     Navigator.of(context).pop();
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(
//                         content: Text('${product.name} added to cart!'),
//                         backgroundColor: Colors.green,
//                         duration: Duration(seconds: 2),
//                       ),
//                     );
//                   } else {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(
//                         content: Text('Failed to add to cart: ${responseData['message'] ?? 'Unknown error'}'),
//                         backgroundColor: Colors.red,
//                       ),
//                     );
//                   }
//                 } catch (e) {
//                   print('Exception adding to cart: $e');
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: Text('Error: $e'),
//                       backgroundColor: Colors.red,
//                     ),
//                   );
//                 }
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   Widget _buildInfoChip(String label, String value) {
//     return Column(
//       children: [
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: 12,
//             color: Colors.grey.shade600,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//         SizedBox(height: 4),
//         Container(
//           padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//           decoration: BoxDecoration(
//             color: Colors.grey.shade200,
//             borderRadius: BorderRadius.circular(6),
//           ),
//           child: Text(
//             value,
//             style: TextStyle(
//               fontSize: 12,
//               fontWeight: FontWeight.bold,
//               color: Colors.black87,
//             ),
//           ),
//         ),
//       ],
//     );
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
//
// class Joke {
//   final String id;
//   final String recyclername;
//
//   final String name;
//   final String photo;
//   final String price;
//   final String quantity;
//
//
//
//
//
//   Joke(this.id,this.recyclername, this.name,this.photo,this.price,this.quantity);
// //  print("hiiiii");
// }
//
