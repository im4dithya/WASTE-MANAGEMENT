
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:wate_management/publicoffence.dart';
import 'Home.dart';

void main() {
  runApp(ViewPublicOffence());
}

class ViewPublicOffence extends StatelessWidget {
  const ViewPublicOffence({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ViewPublicOffenceSub(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.grey[50],
      ),
    );
  }
}

class ViewPublicOffenceSub extends StatefulWidget {
  const ViewPublicOffenceSub({Key? key}) : super(key: key);

  @override
  State<ViewPublicOffenceSub> createState() => _ViewPublicOffenceSubState();
}

class _ViewPublicOffenceSubState extends State<ViewPublicOffenceSub> {
  bool _isLoading = true;
  String? _errorMessage;
  List<PublicOffence> _offences = [];

  Future<void> _openLocationOnMap(String latitude, String longitude) async {
    if (latitude == 'pending' || longitude == 'pending' || latitude.isEmpty || longitude.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Location data not available for this offence'),
          backgroundColor: Colors.orange[800],
        ),
      );
      return;
    }

    try {
      final lat = double.parse(latitude);
      final lng = double.parse(longitude);

      // Validate coordinates
      if (lat < -90 || lat > 90 || lng < -180 || lng > 180) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invalid coordinate values'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final googleMapsUrl = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
      final appleMapsUrl = 'https://maps.apple.com/?q=$lat,$lng';

      if (await canLaunch(googleMapsUrl)) {
        await launch(googleMapsUrl);
      } else if (await canLaunch(appleMapsUrl)) {
        await launch(appleMapsUrl);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open map application'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error opening map: Invalid location data'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<List<PublicOffence>> _getOffences() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final ip = prefs.getString('ip');
      final uid = prefs.getString('uid');

      // Validate required data
      if (ip == null || ip.isEmpty) {
        throw Exception('Server configuration missing');
      }
      if (uid == null || uid.isEmpty) {
        throw Exception('User not logged in');
      }

      var data = await http.post(
        Uri.parse('$ip/uview_public_offence'),
        body: {'uid': uid},
      ).timeout(Duration(seconds: 30));

      if (data.statusCode == 200) {
        var jsonData = json.decode(data.body);

        if (jsonData['data'] == null) {
          throw Exception('Invalid response format from server');
        }

        List<PublicOffence> offences = [];

        for (var item in jsonData['data'] ?? []) {
          String photoPath = item['photo']?.toString() ?? '';
          String fullPhotoUrl = photoPath.isNotEmpty
              ? '$ip/${photoPath.startsWith('/') ? photoPath.substring(1) : photoPath}'
              : '';

          offences.add(PublicOffence(
            id: item['id']?.toString() ?? 'N/A',
            photo: fullPhotoUrl,
            username: item['username']?.toString() ?? 'Anonymous',
            status: item['status']?.toString() ?? 'pending',
            date: item['date']?.toString() ?? 'Unknown date',
            latitude: item['latitude']?.toString() ?? 'pending',
            longitude: item['longitude']?.toString() ?? 'pending',
          ));
        }

        setState(() {
          _isLoading = false;
          _offences = offences;
        });
        return offences;
      } else {
        throw Exception('Server responded with status: ${data.statusCode}');
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
      case 'approved':
      case 'resolved':
      case 'completed':
        return Colors.green;
      case 'pending':
      case 'in review':
        return Colors.orange[700]!;
      case 'rejected':
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
      case 'resolved':
        return Icons.check_circle;
      case 'pending':
        return Icons.pending;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  String _formatDate(String dateStr) {
    try {
      if (dateStr == 'Unknown date' || dateStr.isEmpty) return 'Unknown date';
      final date = DateTime.tryParse(dateStr);
      if (date != null) {
        return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
      }
      return dateStr;
    } catch (e) {
      return dateStr;
    }
  }

  @override
  void initState() {
    super.initState();
    _getOffences();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Reported Waste Offences',
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
            icon: Icon(Icons.refresh),
            onPressed: () {
              _getOffences();
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
              'Loading reported offences...',
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
              'Failed to load offences',
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
                _getOffences();
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
          : _offences.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.report_problem_outlined,
              color: Colors.grey[400],
              size: 80,
            ),
            SizedBox(height: 20),
            Text(
              "No Offences Reported",
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Report waste offences to help keep the environment clean",
              style: TextStyle(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => publicoffence()),
                );
              },
              icon: Icon(Icons.add_circle),
              label: Text('Report New Offence'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: () async {
          await _getOffences();
        },
        color: Colors.green[700],
        child: ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: _offences.length,
          itemBuilder: (context, index) {
            final offence = _offences[index];
            final statusColor = _getStatusColor(offence.status);
            final formattedDate = _formatDate(offence.date);
            final hasLocation = offence.latitude != 'pending' &&
                offence.longitude != 'pending' &&
                offence.latitude.isNotEmpty &&
                offence.longitude.isNotEmpty;

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
                    // Status and Date Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
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
                                _getStatusIcon(offence.status),
                                color: statusColor,
                                size: 14,
                              ),
                              SizedBox(width: 6),
                              Text(
                                offence.status.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: statusColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          formattedDate,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 12),

                    // Report Details
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.person,
                                color: Colors.green[700],
                                size: 16,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Reported By',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    Text(
                                      offence.username,
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
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                color: Colors.green[700],
                                size: 16,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Location Status',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    Text(
                                      hasLocation ? 'Coordinates available' : 'Location not set',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: hasLocation ? Colors.green[700] : Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 12),

                    // Photo Section
                    Text(
                      'Offence Evidence',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey[100],
                      ),
                      child: offence.photo.isNotEmpty && offence.photo.contains('http')
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          offence.photo,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.broken_image,
                                    color: Colors.grey[400],
                                    size: 40,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Failed to load image',
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      )
                          : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.no_photography,
                              color: Colors.grey[400],
                              size: 40,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'No image available',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 12),

                    // Location Details
                    if (hasLocation)
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue[100]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.explore,
                                  color: Colors.blue[700],
                                  size: 16,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Coordinates',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.blue[800],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Latitude',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      Text(
                                        double.tryParse(offence.latitude)?.toStringAsFixed(6) ?? offence.latitude,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          fontFamily: 'monospace',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Longitude',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      Text(
                                        double.tryParse(offence.longitude)?.toStringAsFixed(6) ?? offence.longitude,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          fontFamily: 'monospace',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                    SizedBox(height: 16),

                    // Action Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: hasLocation
                            ? () => _openLocationOnMap(offence.latitude, offence.longitude)
                            : null,
                        icon: Icon(Icons.map, size: 18),
                        label: Text('View on Map'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[700],
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => publicoffence()),
          );
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        tooltip: 'Report New Offence',
      ),
    );
  }
}

class PublicOffence {
  final String id;
  final String photo;
  final String username;
  final String status;
  final String date;
  final String latitude;
  final String longitude;

  PublicOffence({
    required this.id,
    required this.photo,
    required this.username,
    required this.status,
    required this.date,
    required this.latitude,
    required this.longitude,
  });
}












// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
// import 'package:url_launcher/url_launcher.dart';
// import 'package:wate_management/publicoffence.dart';
// import 'Home.dart';
//
// void main() {
//   runApp(ViewPublicOffence());
// }
//
// class ViewPublicOffence extends StatelessWidget {
//   const ViewPublicOffence({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(home: ViewPublicOffenceSub());
//   }
// }
//
// class ViewPublicOffenceSub extends StatefulWidget {
//   const ViewPublicOffenceSub({Key? key}) : super(key: key);
//
//   @override
//   State<ViewPublicOffenceSub> createState() => _ViewPublicOffenceSubState();
// }
//
// class _ViewPublicOffenceSubState extends State<ViewPublicOffenceSub> {
//   Future<void> _openLocationOnMap(String latitude, String longitude) async {
//     if (latitude == 'pending' || longitude == 'pending') {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Location not available for this offence')),
//       );
//       return;
//     }
//
//     try {
//       final lat = double.parse(latitude);
//       final lng = double.parse(longitude);
//       final googleMapsUrl = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
//
//       if (await canLaunch(googleMapsUrl)) {
//         await launch(googleMapsUrl);
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Could not open map')),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Invalid coordinates: $e')),
//       );
//     }
//   }
//
//   Future<List<PublicOffence>> _getOffences() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     final ip = prefs.getString('ip') ?? '';
//
//     try {
//       var data = await http.post(
//         Uri.parse('$ip/uview_public_offence'),body: {'uid': prefs.getString('uid')},
//       );
//
//       if (data.statusCode == 200) {
//         var jsonData = json.decode(data.body);
//         List<PublicOffence> offences = [];
//
//         for (var item in jsonData['data'] ?? []) {
//           offences.add(PublicOffence(
//             id: item['id'].toString(),
//             photo: prefs.getString('ip').toString()+item['photo'].toString(),
//             username: item['username'].toString(),
//             status: item['status'].toString(),
//             date: item['date'].toString(),
//             latitude: item['latitude'].toString(),
//             longitude: item['longitude'].toString(),
//           ));
//         }
//         return offences;
//       } else {
//         throw Exception('Failed to load offences');
//       }
//     } catch (e) {
//       print('Error: $e');
//       throw e;
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Public Offences'),
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
//
//       body: FutureBuilder<List<PublicOffence>>(
//         future: _getOffences(),
//         builder: (BuildContext context, AsyncSnapshot<List<PublicOffence>> snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           }
//           if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return const Center(child: Text('No public offences reported'));
//           }
//
//           final offences = snapshot.data!;
//           return ListView.builder(
//             itemCount: offences.length,
//             itemBuilder: (context, index) {
//               final offence = offences[index];
//               final ipBase = snapshot.data![index].photo.split('/media/')[0];
//               final fullImageUrl = '${ipBase}${offence.photo}';
//
//               return Card(
//                 margin: const EdgeInsets.all(10),
//                 elevation: 5,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.all(12),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Image
//                       ClipRRect(
//                         borderRadius: BorderRadius.circular(8),
//                         child: FutureBuilder(
//                           future: Future.value(snapshot.data![index].photo),
//                           builder: (context, AsyncSnapshot<String> imgSnapshot) {
//                             final photoUrl = snapshot.data![index].photo;
//                             print('Loading image: $photoUrl');
//                             return Image.network(
//                               photoUrl,
//                               height: 200,
//                               width: double.infinity,
//                               fit: BoxFit.cover,
//                               errorBuilder: (context, error, stackTrace) {
//                                 print('Image loading error: $error');
//                                 return Container(
//                                   height: 200,
//                                   color: Colors.grey[300],
//                                   child: Column(
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     children: [
//                                       const Icon(Icons.image_not_supported, size: 50),
//                                       const SizedBox(height: 8),
//                                       Text('Failed to load image', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
//                                       Text(photoUrl, style: TextStyle(fontSize: 10, color: Colors.red), maxLines: 2, overflow: TextOverflow.ellipsis),
//                                     ],
//                                   ),
//                                 );
//                               },
//                             );
//                           },
//                         ),
//                       ),
//                       const SizedBox(height: 12),
//
//                       // Status badge
//                       Container(
//                         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                         decoration: BoxDecoration(
//                           color: offence.status == 'pending' ? Colors.orange : Colors.green,
//                           borderRadius: BorderRadius.circular(4),
//                         ),
//                         child: Text(
//                           offence.status.toUpperCase(),
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontWeight: FontWeight.bold,
//                             fontSize: 12,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//
//                       // Details
//                       _buildDetail('Username', offence.username),
//                       _buildDetail('Date', offence.date),
//                       _buildDetail('Latitude', offence.latitude != 'pending' ? '${double.parse(offence.latitude).toStringAsFixed(4)}' : 'Not set'),
//                       _buildDetail('Longitude', offence.longitude != 'pending' ? '${double.parse(offence.longitude).toStringAsFixed(4)}' : 'Not set'),
//                       const SizedBox(height: 12),
//
//                       // Open Location Button
//                       SizedBox(
//                         width: double.infinity,
//                         child: ElevatedButton.icon(
//                           icon: Icon(Icons.map),
//                           label: Text('View Location on Map'),
//                           onPressed: () => _openLocationOnMap(offence.latitude, offence.longitude),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.blue,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (context) => publicoffence()),
//           );
//         },
//         child: const Icon(Icons.add),
//       )
//     );
//   }
//
//   Widget _buildDetail(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         children: [
//           SizedBox(
//             width: 100,
//             child: Text(
//               label,
//               style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
//             ),
//           ),
//           Flexible(
//             child: Text(
//               value,
//               style: const TextStyle(color: Colors.black),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class PublicOffence {
//   final String id;
//   final String photo;
//   final String username;
//   final String status;
//   final String date;
//   final String latitude;
//   final String longitude;
//
//   PublicOffence({
//     required this.id,
//     required this.photo,
//     required this.username,
//     required this.status,
//     required this.date,
//     required this.latitude,
//     required this.longitude,
//   });
// }
