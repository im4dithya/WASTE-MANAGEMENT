import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import 'Home.dart';

void main() {
  runApp(publicoffence());
}

class publicoffence extends StatelessWidget {
  const publicoffence({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: publicoffence_sub(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.grey[50],
      ),
    );
  }
}

class publicoffence_sub extends StatefulWidget {
  const publicoffence_sub({Key? key}) : super(key: key);

  @override
  State<publicoffence_sub> createState() => _State();
}

class _State extends State<publicoffence_sub> {
  PlatformFile? _selectedFile;
  Uint8List? _webFileBytes;
  String? _result;
  String? _latitude;
  String? _longitude;
  bool _gettingLocation = false;
  bool _isUploading = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _descriptionController = TextEditingController();

  Future<void> _getLocation() async {
    setState(() => _gettingLocation = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please enable location services'),
            backgroundColor: Colors.orange[800],
          ),
        );
        setState(() => _gettingLocation = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Location permission is required to report offences'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _gettingLocation = false);
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _latitude = position.latitude.toStringAsFixed(6);
        _longitude = position.longitude.toStringAsFixed(6);
        _gettingLocation = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Location captured successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to get location: $e'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => _gettingLocation = false);
    }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.image, // Changed to image only for waste management
      allowCompression: true,
    );

    if (result != null) {
      // Validate file size (max 5MB)
      if (result.files.first.size > 5 * 1024 * 1024) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('File size should be less than 5MB'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Validate file type for images
      final validExtensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp'];
      final extension = result.files.first.name.split('.').last.toLowerCase();
      if (!validExtensions.contains(extension)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please select an image file (JPG, PNG, GIF, BMP)'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        _selectedFile = result.files.first;
        _result = null;
      });

      if (kIsWeb) {
        _webFileBytes = result.files.first.bytes;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('File selected: ${result.files.first.name}'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select an image of the waste issue'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_latitude == null || _longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please capture the location of the waste'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      var request = await http.MultipartRequest(
        'POST',
        Uri.parse('${sh.getString('ip')}/sndpublicoffence'),
      );

      request.fields['uid'] = sh.getString('uid').toString();
      request.fields['latitude'] = _latitude!;
      request.fields['longitude'] = _longitude!;
      request.fields['description'] = _descriptionController.text.trim();

      if (kIsWeb) {
        request.files.add(http.MultipartFile.fromBytes(
          'file',
          _webFileBytes!,
          filename: _selectedFile!.name,
        ));
      } else {
        request.files.add(await http.MultipartFile.fromPath(
          'file',
          _selectedFile!.path!,
        ));
      }

      var response = await request.send();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Waste issue reported successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        await Future.delayed(Duration(seconds: 1));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => home()),
        );
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to report: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  void _clearForm() {
    setState(() {
      _selectedFile = null;
      _webFileBytes = null;
      _latitude = null;
      _longitude = null;
      _descriptionController.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Form cleared'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Report Waste Management Issue',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        elevation: 2,
        actions: [
          IconButton(
            icon: Icon(Icons.home),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => home()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Report Improper Waste Disposal',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.green[800],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Help keep our environment clean by reporting waste management issues. '
                            'Please provide accurate location and clear photos.',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 25),

              // File Upload Section
              _buildSection(
                title: '1. Upload Evidence',
                subtitle: 'Take a clear photo of the waste issue',
                icon: Icons.photo_camera,
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(10),
                        // border: Border.all(color: Colors.grey[300]),
                      ),
                      child: _selectedFile != null
                          ? Column(
                        children: [
                          Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.green, size: 24),
                              SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _selectedFile!.name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      '${(_selectedFile!.size / 1024).toStringAsFixed(1)} KB',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete_outline, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    _selectedFile = null;
                                    _webFileBytes = null;
                                  });
                                },
                              ),
                            ],
                          ),
                          if (_selectedFile!.extension != null)
                            Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: Chip(
                                label: Text(
                                  _selectedFile!.extension!.toUpperCase(),
                                  style: TextStyle(fontSize: 11),
                                ),
                                backgroundColor: Colors.green[100],
                              ),
                            ),
                        ],
                      )
                          : Center(
                        child: Column(
                          children: [
                            Icon(Icons.cloud_upload, size: 50, color: Colors.grey[400]),
                            SizedBox(height: 10),
                            Text(
                              'No file selected',
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.upload_file, size: 20),
                        label: Text(
                          "Select Photo",
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        onPressed: _pickFile,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 25),

              // Location Section
              _buildSection(
                title: '2. Capture Location',
                subtitle: 'Get precise coordinates of the waste location',
                icon: Icons.location_on,
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(10),
                        // border: Border.all(color: Colors.grey[300]),
                      ),
                      child: _latitude != null && _longitude != null
                          ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.green, size: 24),
                              SizedBox(width: 10),
                              Text(
                                'Location Captured',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.green[700],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildLocationInfo(
                                  'Latitude',
                                  _latitude!,
                                  Icons.explore,
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: _buildLocationInfo(
                                  'Longitude',
                                  _longitude!,
                                  Icons.explore,
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                          : Center(
                        child: Column(
                          children: [
                            Icon(Icons.location_off, size: 50, color: Colors.grey[400]),
                            SizedBox(height: 10),
                            Text(
                              'No location captured yet',
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: _gettingLocation
                            ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                            : Icon(Icons.my_location, size: 20),
                        label: Text(
                          _gettingLocation ? "Getting Location..." : "Capture Current Location",
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        onPressed: _gettingLocation ? null : _getLocation,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 25),

              // Description Section
              _buildSection(
                title: '3. Additional Details',
                subtitle: 'Provide more information about the issue',
                icon: Icons.description,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 4,
                      maxLength: 500,
                      decoration: InputDecoration(
                        hintText: 'Describe the waste issue, type of waste, severity, etc...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.green, width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.all(16),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please describe the waste issue';
                        }
                        if (value.trim().length < 10) {
                          return 'Description should be at least 10 characters';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Tip: Mention waste type (plastic, organic, construction), quantity, and any safety concerns',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 30),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: Icon(Icons.clear, size: 20),
                      label: Text(
                        "Clear Form",
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      onPressed: _clearForm,
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        side: BorderSide(color: Colors.grey),
                      ),
                    ),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: _isUploading
                          ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                          : Icon(Icons.send, size: 20),
                      label: Text(
                        _isUploading ? "Submitting..." : "Submit Report",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      onPressed: _isUploading ? null : _submitReport,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        backgroundColor: Colors.green[700],
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20),

              // Disclaimer
              Card(
                elevation: 0,
                color: Colors.blue[50],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: Colors.blue[100]!),
                ),
                child: Padding(
                  padding: EdgeInsets.all(15),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue[700], size: 22),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Your report helps maintain a clean environment. False reporting may lead to penalties.',
                          style: TextStyle(
                            color: Colors.blue[800],
                            fontSize: 13,
                          ),
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
    );
  }

  Widget _buildSection({
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget child,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: Colors.green[700], size: 22),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 15),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildLocationInfo(String label, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: Colors.grey[600]),
              SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            double.parse(value).toStringAsFixed(6),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.green[700],
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}





// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:file_picker/file_picker.dart';
// import 'dart:typed_data';
// import 'Home.dart';
// void main(){
//   runApp(publicoffence());
// }
// class publicoffence extends StatelessWidget {
//   const publicoffence({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(home: publicoffence_sub(),);
//   }
// }
// class  publicoffence_sub extends StatefulWidget {
//   const publicoffence_sub({Key? key}) : super(key: key);
//
//   @override
//   State<publicoffence_sub> createState() => _State();
// }
//
// class _State extends State<publicoffence_sub> {
//   PlatformFile? _selectedFile;
//   Uint8List? _webFileBytes;
//   String? _result;
//   String? _latitude;
//   String? _longitude;
//   bool _gettingLocation = false;
//
//   Future<void> _getLocation() async {
//     setState(() => _gettingLocation = true);
//     try {
//       bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//       if (!serviceEnabled) {
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Location services disabled')));
//         setState(() => _gettingLocation = false);
//         return;
//       }
//
//       LocationPermission permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Location permission denied')));
//         setState(() => _gettingLocation = false);
//         return;
//       }
//
//       Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
//       setState(() {
//         _latitude = position.latitude.toString();
//         _longitude = position.longitude.toString();
//         _gettingLocation = false;
//       });
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Location captured: ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}')));
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
//       setState(() => _gettingLocation = false);
//     }
//   }
//
//   Future<void> _pickFile() async {
//     FilePickerResult? result = await FilePicker.platform.pickFiles(
//       allowMultiple: false,
//       type: FileType.any, // Any file type allowed
//     );
//
//     if (result != null) {
//       setState(() {
//         _selectedFile = result.files.first;
//         _result = null;
//       });
//
//       if (kIsWeb) {
//         _webFileBytes = result.files.first.bytes;
//       }
//     }
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Report Public Offence')),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             ElevatedButton.icon(
//               icon: Icon(Icons.upload_file),
//               label: Text("Select File"),
//               onPressed: _pickFile,
//             ),
//             if (_selectedFile != null) ...[
//               SizedBox(height: 10),
//               Text("Selected: ${_selectedFile!.name}"),
//             ],
//             SizedBox(height: 20),
//             ElevatedButton.icon(
//               icon: Icon(Icons.location_on),
//               label: _gettingLocation ? Text("Getting location...") : Text("Capture Location"),
//               onPressed: _gettingLocation ? null : _getLocation,
//             ),
//             if (_latitude != null && _longitude != null) ...[
//               SizedBox(height: 10),
//               Text("Latitude: ${double.parse(_latitude!).toStringAsFixed(6)}", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
//               Text("Longitude: ${double.parse(_longitude!).toStringAsFixed(6)}", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
//             ],
//             SizedBox(height: 30),
//             ElevatedButton(
//               onPressed: () async {
//                 if (_selectedFile == null) {
//                   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please select a file')));
//                   return;
//                 }
//                 if (_latitude == null || _longitude == null) {
//                   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please capture location')));
//                   return;
//                 }
//
//                 SharedPreferences sh = await SharedPreferences.getInstance();
//                 var request = await http.MultipartRequest(
//                   'POST',
//                   Uri.parse('${sh.getString('ip')}/sndpublicoffence'),
//                 );
//
//                 request.fields['uid'] = sh.getString('uid').toString();
//                 request.fields['latitude'] = _latitude!;
//                 request.fields['longitude'] = _longitude!;
//
//                 if (kIsWeb) {
//                   request.files.add(http.MultipartFile.fromBytes(
//                     'file',
//                     _webFileBytes!,
//                     filename: _selectedFile!.name,
//                   ));
//                 } else {
//                   request.files.add(await http.MultipartFile.fromPath(
//                     'file',
//                     _selectedFile!.path!,
//                   ));
//                 }
//
//                 var response = await request.send();
//                 if (response.statusCode == 200) {
//                   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Offence reported successfully')));
//                   Navigator.push(context, MaterialPageRoute(builder: (context) => home()));
//                 } else {
//                   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to report offence')));
//                 }
//               },
//               child: Text("Send Report"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
