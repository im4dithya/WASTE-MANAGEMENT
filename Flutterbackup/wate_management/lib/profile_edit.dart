import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

import 'Home.dart';

class profileeditsub extends StatefulWidget {
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

  const profileeditsub({
    Key? key,
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
  }) : super(key: key);

  @override
  State<profileeditsub> createState() => _profileeditsubState();
}

class _profileeditsubState extends State<profileeditsub> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController phonenumber = TextEditingController();
  TextEditingController housename = TextEditingController();
  TextEditingController post = TextEditingController();
  TextEditingController pin = TextEditingController();
  TextEditingController latitude = TextEditingController();
  TextEditingController longitude = TextEditingController();
  TextEditingController rewards = TextEditingController();

  String? selectedAreaId;
  bool _isLoading = false;
  bool _isUpdating = false;

  List<Map<String, String>> areaList = [];

  @override
  void initState() {
    super.initState();
    name.text = widget.name;
    email.text = widget.email;
    phonenumber.text = widget.phonenumber;
    housename.text = widget.housename;
    post.text = widget.post;
    pin.text = widget.pin;
    latitude.text = widget.latitude;
    longitude.text = widget.longitude;
    rewards.text = widget.rewards;

    // Load areas from backend and set selected area if possible
    fetchAreas();
  }

  Future<void> fetchAreas() async {
    setState(() {
      _isLoading = true;
    });

    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      final uri = Uri.parse("${sh.getString('ip')}/uview_area");
      final resp = await http.get(uri);
      if (resp.statusCode == 200) {
        final body = json.decode(resp.body);
        if (body != null && body['status'] == 'ok') {
          final List data = body['data'] ?? [];
          List<Map<String, String>> parsed = [];
          for (var e in data) {
            parsed.add({
              'id': e['id'].toString(),
              'district': e['district']?.toString() ?? '',
              'panchayath': e['panchayath']?.toString() ?? '',
            });
          }
          String? foundId;
          for (var a in parsed) {
            if (a['panchayath'] == widget.area || a['id'] == widget.area) {
              foundId = a['id'];
              break;
            }
          }
          setState(() {
            areaList = parsed;
            selectedAreaId = foundId;
          });
        }
      }
    } catch (e) {
      print('fetchAreas error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    phonenumber.dispose();
    housename.dispose();
    post.dispose();
    pin.dispose();
    latitude.dispose();
    longitude.dispose();
    rewards.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Edit Profile",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.green[700],
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(15),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.green[100]!),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green[700],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Update Your Profile",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[800],
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "Please fill in your details accurately",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 25),

              // Personal Information Section
              Text(
                "Personal Information",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                ),
              ),
              SizedBox(height: 10),
              Divider(color: Colors.green[100], thickness: 2),
              SizedBox(height: 15),

              // Name Field
              Text(
                "Full Name",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 5),
              TextFormField(
                controller: name,
                decoration: InputDecoration(
                  hintText: "Enter your full name",
                  prefixIcon: Icon(Icons.person, color: Colors.green[700]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    // borderSide: BorderSide(color: Colors.grey[400]),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.green[700]!, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.green[50]!.withOpacity(0.3),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  if (value.length < 3) {
                    return 'Name must be at least 3 characters';
                  }
                  return null;
                },
              ),
              SizedBox(height: 15),

              // Email Field
              Text(
                "Email Address",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 5),
              TextFormField(
                controller: email,
                decoration: InputDecoration(
                  hintText: "Enter your email address",
                  prefixIcon: Icon(Icons.email, color: Colors.green[700]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    // borderSide: BorderSide(color: Colors.grey[400]),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.green[700]!, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.green[50]!.withOpacity(0.3),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 15),

              // Phone Number Field
              Text(
                "Phone Number",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 5),
              TextFormField(
                controller: phonenumber,
                decoration: InputDecoration(
                  hintText: "Enter your phone number",
                  prefixIcon: Icon(Icons.phone, color: Colors.green[700]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    // borderSide: BorderSide(color: Colors.grey[400]),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.green[700]!, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.green[50]!.withOpacity(0.3),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                    return 'Please enter a valid 10-digit phone number';
                  }
                  return null;
                },
                keyboardType: TextInputType.phone,
                maxLength: 10,
              ),
              SizedBox(height: 25),

              // Address Information Section
              Text(
                "Address Information",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                ),
              ),
              SizedBox(height: 10),
              Divider(color: Colors.green[100], thickness: 2),
              SizedBox(height: 15),

              // Area Selection
              Text(
                "Area / Panchayath",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 5),
              _isLoading
                  ? Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 10),
                    Text("Loading areas..."),
                  ],
                ),
              )
                  : Container(
                decoration: BoxDecoration(
                  color: Colors.green[50]!.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                  // border: Border.all(color: Colors.grey[400]),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButtonFormField<String>(
                    value: selectedAreaId,
                    items: areaList.map((area) {
                      final label = '${area['panchayath']}';
                      return DropdownMenuItem(
                        value: area['id'],
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            label,
                            style: TextStyle(fontSize: 16),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedAreaId = value;
                      });
                    },
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.location_city, color: Colors.green[700]),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select your area';
                      }
                      return null;
                    },
                    dropdownColor: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    icon: Icon(Icons.arrow_drop_down, color: Colors.green[700]),
                  ),
                ),
              ),
              SizedBox(height: 15),

              // House Name
              Text(
                "House Name / Number",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 5),
              TextFormField(
                controller: housename,
                decoration: InputDecoration(
                  hintText: "Enter house name or number",
                  prefixIcon: Icon(Icons.home, color: Colors.green[700]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    // borderSide: BorderSide(color: Colors.grey[400]),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.green[700]!, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.green[50]!.withOpacity(0.3),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter house name/number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 15),

              // Post Office
              Text(
                "Post Office",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 5),
              TextFormField(
                controller: post,
                decoration: InputDecoration(
                  hintText: "Enter post office name",
                  prefixIcon: Icon(Icons.local_post_office, color: Colors.green[700]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    // borderSide: BorderSide(color: Colors.grey[400]),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.green[700]!, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.green[50]!.withOpacity(0.3),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter post office';
                  }
                  return null;
                },
              ),
              SizedBox(height: 15),

              // PIN Code
              Text(
                "PIN Code",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 5),
              TextFormField(
                controller: pin,
                decoration: InputDecoration(
                  hintText: "Enter 6-digit PIN code",
                  prefixIcon: Icon(Icons.pin, color: Colors.green[700]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    // borderSide: BorderSide(color: Colors.grey[400]),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.green[700]!, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.green[50]!.withOpacity(0.3),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter PIN code';
                  }
                  if (!RegExp(r'^[0-9]{6}$').hasMatch(value)) {
                    return 'Please enter a valid 6-digit PIN code';
                  }
                  return null;
                },
                keyboardType: TextInputType.number,
                maxLength: 6,
              ),
              SizedBox(height: 25),

              // Location Section
              Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.blue[100]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.blue[700], size: 24),
                        SizedBox(width: 10),
                        Text(
                          "Location Coordinates",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[800],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Pick your exact location on the map. This helps in waste collection scheduling.",
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    SizedBox(height: 15),

                    // Coordinates Display
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.blue[200]!),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Latitude",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  latitude.text.isEmpty || latitude.text == 'pending'
                                      ? "Not set"
                                      : latitude.text,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: latitude.text.isEmpty || latitude.text == 'pending'
                                        ? Colors.grey[500]
                                        : Colors.green[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.blue[200]!),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Longitude",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  longitude.text.isEmpty || longitude.text == 'pending'
                                      ? "Not set"
                                      : longitude.text,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: longitude.text.isEmpty || longitude.text == 'pending'
                                        ? Colors.grey[500]
                                        : Colors.green[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 15),

                    // Map Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.map),
                        label: Text(latitude.text.isEmpty || latitude.text == 'pending'
                            ? 'Pick Location on Map'
                            : 'Update Location'),
                        onPressed: () async {
                          double lat = double.tryParse(latitude.text) ?? 20.5937;
                          double lng = double.tryParse(longitude.text) ?? 78.9629;

                          final result = await Navigator.push<LatLng?>(
                            context,
                            MaterialPageRoute(builder: (_) => LocationPicker(initial: LatLng(lat, lng))),
                          );

                          if (result != null) {
                            setState(() {
                              latitude.text = result.latitude.toStringAsFixed(6);
                              longitude.text = result.longitude.toStringAsFixed(6);
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Location updated successfully'),
                                backgroundColor: Colors.green,
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[700],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isUpdating ? null : () async {
                    if (_formKey.currentState!.validate()) {
                      setState(() {
                        _isUpdating = true;
                      });

                      await _updateProfile();

                      setState(() {
                        _isUpdating = false;
                      });
                    }
                  },
                  child: _isUpdating
                      ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 10),
                      Text("UPDATING..."),
                    ],
                  )
                      : Text(
                    "UPDATE PROFILE",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 5,
                    shadowColor: Colors.green.withOpacity(0.5),
                  ),
                ),
              ),
              SizedBox(height: 10),

              // Cancel Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    "CANCEL",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _updateProfile() async {
    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      final response = await http.post(
        Uri.parse("${sh.getString('ip')}/user_edit_profile"),
        body: {
          "uid": widget.id,
          "name": name.text,
          "email": email.text,
          "area": selectedAreaId ?? "",
          "phonenumber": phonenumber.text,
          "housename": housename.text,
          "post": post.text,
          "pin": pin.text,
          "latitude": latitude.text,
          "longitude": longitude.text,
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                SizedBox(width: 10),
                Text('Profile updated successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );

        await Future.delayed(Duration(milliseconds: 1500));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => home()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white, size: 20),
                SizedBox(width: 10),
                Text('Update failed. Please try again.'),
              ],
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Text('Error: $e'),
            ],
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
}


// Location Picker Widget (Enhanced)
class LocationPicker extends StatefulWidget {
  final LatLng initial;
  const LocationPicker({Key? key, required this.initial}) : super(key: key);

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  final MapController _mapController = MapController();
  late LatLng _picked;

  @override
  void initState() {
    super.initState();
    _picked = widget.initial;
  }

  Future<void> _useCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please enable location services'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Location permission is required'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    try {
      Position pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      final cur = LatLng(pos.latitude, pos.longitude);
      if (mounted) {
        setState(() {
          _picked = cur;
        });
        _mapController.move(cur, 15);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Location updated to current position'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to get current location'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Select Location',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue[700],
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, _picked);
            },
            child: Text(
              'CONFIRM',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: widget.initial,
              initialZoom: 12,
              onTap: (tapPos, point) {
                setState(() {
                  _picked = point;
                });
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _picked,
                    child: Container(
                      child: Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 48,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Information Panel
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tap on map to select location',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue, size: 16),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'This location will be used for waste collection scheduling',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Coordinates Display
          Positioned(
            bottom: 100,
            left: 16,
            right: 16,
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'LATITUDE',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            _picked.latitude.toStringAsFixed(6),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700],
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'LONGITUDE',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            _picked.longitude.toStringAsFixed(6),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            onPressed: _useCurrentLocation,
            label: Text('Current Location'),
            icon: Icon(Icons.my_location),
            backgroundColor: Colors.blue[700],
            foregroundColor: Colors.white,
          ),
          SizedBox(height: 16),
          FloatingActionButton.extended(
            onPressed: () {
              Navigator.pop(context, _picked);
            },
            label: Text('Confirm Location'),
            icon: Icon(Icons.check),
            backgroundColor: Colors.green[700],
            foregroundColor: Colors.white,
          ),
        ],
      ),
    );
  }
}





// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:geolocator/geolocator.dart';
//
// import 'Home.dart';
//
// class profileeditsub extends StatefulWidget {
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
//
//   const profileeditsub({
//     Key? key,
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
//   }) : super(key: key);
//
//   @override
//   State<profileeditsub> createState() => _profileeditsubState();
// }
//
// class _profileeditsubState extends State<profileeditsub> {
//   TextEditingController name = TextEditingController();
//   TextEditingController email = TextEditingController();
//   TextEditingController phonenumber = TextEditingController();
//   TextEditingController housename = TextEditingController();
//   TextEditingController post = TextEditingController();
//   TextEditingController pin = TextEditingController();
//   TextEditingController latitude = TextEditingController();
//   TextEditingController longitude = TextEditingController();
//   TextEditingController rewards = TextEditingController();
//
//   String? selectedAreaId;
//
//   List<Map<String, String>> areaList = [];
//
//   @override
//   void initState() {
//     super.initState();
//     name.text = widget.name;
//     email.text = widget.email;
//     phonenumber.text = widget.phonenumber;
//     housename.text = widget.housename;
//     post.text = widget.post;
//     pin.text = widget.pin;
//     latitude.text = widget.latitude;
//     longitude.text = widget.longitude;
//     rewards.text = widget.rewards;
//     // Load areas from backend and set selected area if possible
//     fetchAreas();
//   }
//
//   Future<void> fetchAreas() async {
//     try {
//       SharedPreferences sh = await SharedPreferences.getInstance();
//       final uri = Uri.parse("${sh.getString('ip')}/uview_area");
//       final resp = await http.get(uri);
//       if (resp.statusCode == 200) {
//         final body = json.decode(resp.body);
//         if (body != null && body['status'] == 'ok') {
//           final List data = body['data'] ?? [];
//           List<Map<String, String>> parsed = [];
//           for (var e in data) {
//             parsed.add({
//               'id': e['id'].toString(),
//               'district': e['district']?.toString() ?? '',
//               'panchayath': e['panchayath']?.toString() ?? '',
//             });
//           }
//           String? foundId;
//           for (var a in parsed) {
//             if (a['panchayath'] == widget.area || a['id'] == widget.area) {
//               foundId = a['id'];
//               break;
//             }
//           }
//           setState(() {
//             areaList = parsed;
//             selectedAreaId = foundId;
//           });
//         }
//       }
//     } catch (e) {
//       print('fetchAreas error: $e');
//     }
//   }
//
//   @override
//   void dispose() {
//     name.dispose();
//     email.dispose();
//     phonenumber.dispose();
//     housename.dispose();
//     post.dispose();
//     pin.dispose();
//     latitude.dispose();
//     longitude.dispose();
//     rewards.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Edit Profile")),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.all(12),
//         child: Column(
//           children: [
//
//             TextField(
//               controller: name,
//               decoration: InputDecoration(
//                 hintText: "Name",
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             SizedBox(height: 10),
//
//             TextField(
//               controller: email,
//               decoration: InputDecoration(
//                 hintText: "Email",
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             SizedBox(height: 10),
//
//             /// AREA SELECT (fetched from backend)
//             areaList.isEmpty
//                 ? Center(
//                     child: Padding(
//                       padding: EdgeInsets.all(8),
//                       child: CircularProgressIndicator(),
//                     ),
//                   )
//                 : DropdownButtonFormField<String>(
//                     value: selectedAreaId,
//                     items: areaList.map((area) {
//                       final label = '${area['panchayath']}';
//                       return DropdownMenuItem(
//                         value: area['id'],
//                         child: Text(label, overflow: TextOverflow.ellipsis),
//                       );
//                     }).toList(),
//                     onChanged: (value) {
//                       setState(() {
//                         selectedAreaId = value;
//                       });
//                     },
//                     decoration: InputDecoration(
//                       labelText: "Area",
//                       border: OutlineInputBorder(),
//                     ),
//                   ),
//             SizedBox(height: 10),
//
//             TextField(
//               controller: phonenumber,
//               decoration: InputDecoration(
//                 hintText: "Phone Number",
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             SizedBox(height: 10),
//
//             TextField(
//               controller: housename,
//               decoration: InputDecoration(
//                 hintText: "House Name",
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             SizedBox(height: 10),
//
//             TextField(
//               controller: post,
//               decoration: InputDecoration(
//                 hintText: "Post",
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             SizedBox(height: 10),
//
//             TextField(
//               controller: pin,
//               decoration: InputDecoration(
//                 hintText: "PIN",
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             SizedBox(height: 10),
//
//             // Latitude & Longitude (pick via map)
//             Text(
//               'Location Coordinates',
//               style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 8),
//             Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: latitude,
//                     readOnly: true,
//                     decoration: InputDecoration(
//                       hintText: "Latitude",
//                       border: OutlineInputBorder(),
//                       helperText: latitude.text.isEmpty || latitude.text == 'pending' ? 'Not set - use map' : '',
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: TextField(
//                     controller: longitude,
//                     readOnly: true,
//                     decoration: InputDecoration(
//                       hintText: "Longitude",
//                       border: OutlineInputBorder(),
//                       helperText: longitude.text.isEmpty || longitude.text == 'pending' ? 'Not set - use map' : '',
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton.icon(
//                 icon: const Icon(Icons.map),
//                 label: const Text('Pick Location on Map'),
//                 onPressed: () async {
//                   // parse existing coords or provide default (India center)
//                   double lat = double.tryParse(latitude.text) ?? 20.5937;
//                   double lng = double.tryParse(longitude.text) ?? 78.9629;
//                   print('Pushing LocationPicker with initial: LatLng($lat, $lng)');
//                   final result = await Navigator.push<LatLng?>(
//                     context,
//                     MaterialPageRoute(builder: (_) => LocationPicker(initial: LatLng(lat, lng))),
//                   );
//                   print('LocationPicker returned: $result');
//                   if (result != null) {
//                     print('Setting latitude to ${result.latitude.toStringAsFixed(6)}, longitude to ${result.longitude.toStringAsFixed(6)}');
//                     setState(() {
//                       latitude.text = result.latitude.toStringAsFixed(6);
//                       longitude.text = result.longitude.toStringAsFixed(6);
//                     });
//                     print('After setState - latitude: ${latitude.text}, longitude: ${longitude.text}');
//                   } else {
//                     print('Result is null!');
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(content: Text('No location selected')),
//                     );
//                   }
//                 },
//                 style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey),
//               ),
//             ),
//             SizedBox(height: 10),
//
//             SizedBox(height: 20),
//
//             ElevatedButton(
//               onPressed: () async {
//                 try {
//                   SharedPreferences sh = await SharedPreferences.getInstance();
//                   final response = await http.post(
//                     Uri.parse("${sh.getString('ip')}/user_edit_profile"),
//                     body: {
//                       "uid": widget.id,
//                       "name": name.text,
//                       "email": email.text,
//                       "area": selectedAreaId ?? "",
//                       "phonenumber": phonenumber.text,
//                       "housename": housename.text,
//                       "post": post.text,
//                       "pin": pin.text,
//                       "latitude": latitude.text,
//                       "longitude": longitude.text,
//                     },
//                   );
//
//                   if (response.statusCode == 200) {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(content: Text('Profile updated successfully')),
//                     );
//                     Navigator.pushReplacement(
//                       context,
//                       MaterialPageRoute(builder: (context) => home()),
//                     );
//                   } else {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(content: Text('Update failed: ${response.statusCode}')),
//                     );
//                   }
//                 } catch (e) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(content: Text('Error: $e')),
//                   );
//                 }
//               },
//               child: Text("SUBMIT"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
//
// // Simple full-screen Google Map picker. Requires `google_maps_flutter` dependency
// class LocationPicker extends StatefulWidget {
//   final LatLng initial;
//   const LocationPicker({Key? key, required this.initial}) : super(key: key);
//
//   @override
//   State<LocationPicker> createState() => _LocationPickerState();
// }
//
// class _LocationPickerState extends State<LocationPicker> {
//   final MapController _mapController = MapController();
//   late LatLng _picked;
//
//   @override
//   void initState() {
//     super.initState();
//     _picked = widget.initial;
//     print('LocationPicker init: $_picked');
//   }
//
//   Future<void> _useCurrentLocation() async {
//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location services disabled')));
//       }
//       return;
//     }
//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) permission = await Geolocator.requestPermission();
//     if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location permission denied')));
//       }
//       return;
//     }
//     Position pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
//     final cur = LatLng(pos.latitude, pos.longitude);
//     if (mounted) {
//       setState(() {
//         _picked = cur;
//         print('Current location: $_picked');
//       });
//       _mapController.move(cur, 15);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         print('Back button pressed. Returning: $_picked');
//         Navigator.pop(context, _picked);
//         return false; // prevent default back behavior
//       },
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text('Pick location'),
//           leading: SizedBox.shrink(), // Hide default back button
//           actions: [
//             TextButton(
//               onPressed: () {
//                 print('Returning picked location: $_picked');
//                 Navigator.pop(context, _picked);
//               },
//               child: const Text('Done', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
//             )
//           ],
//         ),
//         body: Stack(
//           children: [
//             FlutterMap(
//               mapController: _mapController,
//               options: MapOptions(
//                 initialCenter: widget.initial,
//                 initialZoom: 12,
//                 onTap: (tapPos, point) {
//                   setState(() {
//                     _picked = point;
//                     print('Tapped location: $_picked');
//                   });
//                 },
//               ),
//               children: [
//                 TileLayer(urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'com.example.app'),
//                 MarkerLayer(
//                   markers: [
//                     Marker(point: _picked, child: Icon(Icons.location_on, color: Colors.red, size: 40)),
//                   ],
//                 ),
//               ],
//             ),
//             Positioned(
//               bottom: 16,
//               left: 16,
//               right: 16,
//               child: Container(
//                 padding: EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(8),
//                   boxShadow: [BoxShadow(blurRadius: 8, color: Colors.black26)],
//                 ),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Text('Lat: ${_picked.latitude.toStringAsFixed(6)}'),
//                     Text('Lng: ${_picked.longitude.toStringAsFixed(6)}'),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//         floatingActionButton: FloatingActionButton.extended(
//           onPressed: _useCurrentLocation,
//           label: const Text('Use current location'),
//           icon: const Icon(Icons.my_location),
//         ),
//       ),
//     );
//   }
// }
