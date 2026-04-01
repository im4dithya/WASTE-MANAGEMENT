import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'profile_edit.dart';
import 'Home.dart';

class viewprofile extends StatelessWidget {
  const viewprofile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: viewprofilesub(),
      // theme: ThemeData(
      //   primarySwatch: Colors.green,
      //   scaffoldBackgroundColor: Colors.grey[50],
      // ),
    );
  }
}

class viewprofilesub extends StatefulWidget {
  const viewprofilesub({Key? key}) : super(key: key);

  @override
  State<viewprofilesub> createState() => _viewprofilesubState();
}

class _viewprofilesubState extends State<viewprofilesub> {
  Future<List<UserProfile>> _getProfiles() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final ip = prefs.getString('ip') ?? '';
    final uid = prefs.getString('uid') ?? '';

    try {
      var data = await http.post(
        Uri.parse('$ip/uprofile_edit'),
        body: {'uid': uid},
      );

      if (data.statusCode == 200) {
        var jsonData = json.decode(data.body);
        List<UserProfile> profiles = [];

        for (var item in jsonData['data'] ?? []) {
          profiles.add(UserProfile(
            id: item['id'].toString(),
            name: item['name'].toString(),
            email: item['email'].toString(),
            area: item['area'].toString(),
            phonenumber: item['phonenumber'].toString(),
            housename: item['housename'].toString(),
            post: item['post'].toString(),
            pin: item['pin'].toString(),
            latitude: item['latitude'].toString(),
            longitude: item['longitude'].toString(),
            rewards: item['rewards'].toString(),
            aid: item['aid'].toString(),
          ));
        }
        return profiles;
      } else {
        throw Exception('Failed to load profile: ${data.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Profile',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.green[700],
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => home()),
            );
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.home),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => home()),
              );
            },
            tooltip: 'Go Home',
          ),
        ],
      ),
      body: FutureBuilder<List<UserProfile>>(
        future: _getProfiles(),
        builder: (BuildContext context, AsyncSnapshot<List<UserProfile>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.green[700]!),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Loading profile...',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
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
                    'Failed to load profile',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    snapshot.error.toString(),
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {});
                    },
                    icon: Icon(Icons.refresh),
                    label: Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person_outline,
                    color: Colors.grey[400],
                    size: 80,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'No profile data available',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Please complete your profile setup',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }

          final profiles = snapshot.data!;

          return ListView.builder(
            itemCount: profiles.length,
            itemBuilder: (context, index) {
              final p = profiles[index];
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Profile Header Card
                    Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            // Profile Icon and Name
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.green[100],
                                borderRadius: BorderRadius.circular(40),
                              ),
                              child: Icon(
                                Icons.person,
                                size: 40,
                                color: Colors.green[700],
                              ),
                            ),
                            SizedBox(height: 15),
                            Text(
                              p.name,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.green[800],
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              p.email,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 15),
                            Divider(color: Colors.grey[300]),

                            // Reward Points Badge
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.orange[50],
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.orange[200]!),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.workspace_premium,
                                    color: Colors.orange[700],
                                    size: 18,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    '${p.rewards} Reward Points',
                                    style: TextStyle(
                                      color: Colors.orange[700],
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 20),

                    // Contact Information Card
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.contact_phone,
                                  color: Colors.green[700],
                                  size: 20,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'Contact Information',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 15),
                            _buildDetailRow('Phone Number', p.phonenumber, Icons.phone),
                            _buildDetailRow('Area', p.area, Icons.location_on),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 15),

                    // Address Information Card
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.home,
                                  color: Colors.green[700],
                                  size: 20,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'Address Details',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 15),
                            _buildDetailRow('House Name', p.housename, Icons.house),
                            _buildDetailRow('Post Office', p.post, Icons.local_post_office),
                            _buildDetailRow('PIN Code', p.pin, Icons.pin),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 15),

                    // Location Information Card
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.location_pin,
                                  color: Colors.green[700],
                                  size: 20,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'Location Coordinates',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 15),
                            Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.explore, color: Colors.blue[700], size: 18),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Latitude',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        Text(
                                          p.latitude,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey[800],
                                            fontFamily: 'monospace',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 20),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Longitude',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        Text(
                                          p.longitude,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey[800],
                                            fontFamily: 'monospace',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 25),

                    // Edit Profile Button
                    Container(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => profileeditsub(
                                id: p.id,
                                name: p.name,
                                email: p.email,
                                area: p.area,
                                phonenumber: p.phonenumber,
                                housename: p.housename,
                                post: p.post,
                                pin: p.pin,
                                latitude: p.latitude,
                                longitude: p.longitude,
                                rewards: p.rewards,
                              ),
                            ),
                          ).then((value) {
                            if (value == true) {
                              setState(() {});
                            }
                          });
                        },
                        icon: Icon(Icons.edit, size: 20),
                        label: Text(
                          'Edit Profile',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[700],
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                      ),
                    ),

                    SizedBox(height: 15),

                    // Refresh Button
                    OutlinedButton.icon(
                      onPressed: () {
                        setState(() {});
                      },
                      icon: Icon(Icons.refresh, size: 18),
                      label: Text('Refresh Profile'),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: Colors.grey[400]!),
                      ),
                    ),

                    SizedBox(height: 30),

                    // Footer Note
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.green[700], size: 18),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Keep your profile updated for better waste management service delivery',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 16,
              color: Colors.green[700],
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
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
                  value.isEmpty ? 'Not provided' : value,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[800],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class UserProfile {
  final String id;
  final String name;
  final String email;
  final String area;
  final String phonenumber;
  final String housename;
  final String post;
  final String pin;
  final String latitude;
  final String longitude;
  final String rewards;
  final String aid;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.area,
    required this.phonenumber,
    required this.housename,
    required this.post,
    required this.pin,
    required this.latitude,
    required this.longitude,
    required this.rewards,
    required this.aid,
  });
}




// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
// import 'profile_edit.dart';
// import 'Home.dart';
//
// class viewprofile extends StatelessWidget {
//   const viewprofile({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return const viewprofilesub();
//   }
// }
//
// class viewprofilesub extends StatefulWidget {
//   const viewprofilesub({Key? key}) : super(key: key);
//
//   @override
//   State<viewprofilesub> createState() => _viewprofilesubState();
// }
//
// class _viewprofilesubState extends State<viewprofilesub> {
//   Future<List<UserProfile>> _getProfiles() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//
//     final ip = prefs.getString('ip') ?? '';
//     final uid = prefs.getString('uid') ?? '';
//
//     var data = await http.post(
//       Uri.parse('$ip/uprofile_edit'),
//       body: {'uid': uid},
//     );
//
//     var jsonData = json.decode(data.body);
//     List<UserProfile> profiles = [];
//
//     for (var item in jsonData['data'] ?? []) {
//       profiles.add(UserProfile(
//         id: item['id'].toString(),
//         name: item['name'].toString(),
//         email: item['email'].toString(),
//         area: item['area'].toString(),
//         phonenumber: item['phonenumber'].toString(),
//         housename: item['housename'].toString(),
//         post: item['post'].toString(),
//         pin: item['pin'].toString(),
//         latitude: item['latitude'].toString(),
//         longitude: item['longitude'].toString(),
//         rewards: item['rewards'].toString(),
//         aid: item['aid'].toString(),
//       ));
//     }
//     return profiles;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('View Profile'),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () {
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(builder: (context) => home()),
//             );
//           },
//         ),
//       ),
//       body: FutureBuilder<List<UserProfile>>(
//         future: _getProfiles(),
//         builder: (BuildContext context, AsyncSnapshot<List<UserProfile>> snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return const Center(child: Text('No profile data available'));
//           }
//
//           final profiles = snapshot.data!;
//
//           return ListView.builder(
//             itemCount: profiles.length,
//             itemBuilder: (context, index) {
//               final p = profiles[index];
//               return Card(
//                 margin: const EdgeInsets.all(10),
//                 child: Padding(
//                   padding: const EdgeInsets.all(12),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       _buildRow('Name', p.name),
//                       _buildRow('Email', p.email),
//                       _buildRow('Area', p.area),
//                       _buildRow('Phone', p.phonenumber),
//                       _buildRow('House', p.housename),
//                       _buildRow('Post', p.post),
//                       _buildRow('PIN', p.pin),
//                       _buildRow('Latitude', p.latitude),
//                       _buildRow('Longitude', p.longitude),
//                       _buildRow('Rewards', p.rewards),
//                       const SizedBox(height: 10),
//                       ElevatedButton(
//                         onPressed: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => profileeditsub(
//                                 id: p.id,
//                                 name: p.name,
//                                 email: p.email,
//                                 area: p.area,
//                                 phonenumber: p.phonenumber,
//                                 housename: p.housename,
//                                 post: p.post,
//                                 pin: p.pin,
//                                 latitude: p.latitude,
//                                 longitude: p.longitude,
//                                 rewards: p.rewards,
//                               ),
//                             ),
//                           );
//                         },
//                         child: const Text('EDIT'),
//                       )
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
//   Widget _buildRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         children: [
//           SizedBox(width: 100, child: Text('$label :', style: const TextStyle(fontWeight: FontWeight.w600))),
//           Expanded(child: Text(value)),
//         ],
//       ),
//     );
//   }
// }
//
// class UserProfile {
//   final String id;
//   final String name;
//   final String email;
//   final String area;
//   final String phonenumber;
//   final String housename;
//   final String post;
//   final String pin;
//   final String latitude;
//   final String longitude;
//   final String rewards;
//   final String aid;
//
//   UserProfile({
//     required this.id,
//     required this.name,
//     required this.email,
//     required this.area,
//     required this.phonenumber,
//     required this.housename,
//     required this.post,
//     required this.pin,
//     required this.latitude,
//     required this.longitude,
//     required this.rewards,
//     required this.aid,
//   });
// }
