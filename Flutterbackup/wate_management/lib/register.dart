

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:wate_management/login.dart';

class Register extends StatelessWidget {
  const Register({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Registersub();
  }
}

class Registersub extends StatefulWidget {
  const Registersub({Key? key}) : super(key: key);

  @override
  State<Registersub> createState() => _RegistersubState();
}

class _RegistersubState extends State<Registersub> {
  final TextEditingController name = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController phone = TextEditingController();
  final TextEditingController housename = TextEditingController();
  final TextEditingController post = TextEditingController();
  final TextEditingController pin = TextEditingController();
  final TextEditingController latitude = TextEditingController();
  final TextEditingController longitude = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController confirmPassword = TextEditingController();

  String? selectedAreaId;
  List<Map<String, String>> areaList = [];
  LatLng? selectedLocation;
  final MapController _mapController = MapController();
  bool _isLoading = false;
  bool _gettingLocation = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    fetchAreas();
  }

  // Get current location
  Future<void> _useCurrentLocation() async {
    setState(() => _gettingLocation = true);

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Please enable location services to proceed"),
            backgroundColor: Colors.orange[800],
            behavior: SnackBarBehavior.floating,
          ),
        );
        setState(() => _gettingLocation = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
                "Location permission is required for waste management services"),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
        setState(() => _gettingLocation = false);
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      LatLng current = LatLng(position.latitude, position.longitude);

      setState(() {
        selectedLocation = current;
        _gettingLocation = false;
      });
      _mapController.move(current, 15);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Location captured successfully"),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error getting location: $e"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      setState(() => _gettingLocation = false);
    }
  }

  // Load Panchayath data
  Future<void> fetchAreas() async {
    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      final response =
      await http.get(Uri.parse("${sh.getString('ip')}/loadPanchayath"));

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body['status'] == 'ok') {
          setState(() {
            areaList = List<Map<String, String>>.from(
              body['data'].map((e) => {
                "id": e['id'].toString(),
                "panchayath": e['panchayath'].toString(),
              }),
            );
          });
        }
      }
    } catch (e) {
      debugPrint("Area fetch error: $e");
    }
  }

  // Form validation method
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your phone number';
    }
    if (value.length != 10) {
      return 'Phone number must be 10 digits';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'Phone number must contain only digits';
    }
    return null;
  }

  String? _validatePIN(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter PIN code';
    }
    if (value.length != 6) {
      return 'PIN code must be 6 digits';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'PIN code must contain only digits';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter $fieldName';
    }
    return null;
  }

  String? _validateLocation() {
    if (selectedLocation == null) {
      return 'Please select your location on the map';
    }
    return null;
  }

  String? _validateArea(String? value) {
    if (selectedAreaId == null || selectedAreaId!.isEmpty) {
      return 'Please select your area';
    }
    return null;
  }

  // Form submission method
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please select your location on the map"),
          backgroundColor: Colors.orange[800],
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (selectedAreaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please select your area"),
          backgroundColor: Colors.orange[800],
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      final response = await http.post(
        Uri.parse("${sh.getString('ip')}/register_user"),
        body: {
          "name": name.text,
          "email": email.text,
          "area": selectedAreaId!,
          "phone": phone.text,
          "housename": housename.text,
          "post": post.text,
          "pin": pin.text,
          'latitude': selectedLocation!.latitude.toString(),
          'longitude': selectedLocation!.longitude.toString(),
          "password": password.text,
          "confirm_password": confirmPassword.text,
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData['status'] == 'ok') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("Registration successful! Please login."),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const login()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(responseData['invalid'] ?? "Registration failed"),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        throw Exception('Failed to register');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    phone.dispose();
    housename.dispose();
    post.dispose();
    pin.dispose();
    latitude.dispose();
    longitude.dispose();
    password.dispose();
    confirmPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Create Account",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.green[700],
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Header with gradient
              Container(
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.green[700]!,
                      Colors.green[600]!,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.app_registration,
                        size: 40,
                        color: Colors.white,
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Waste Management Registration",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Personal Information Card
                    _buildSectionCard(
                      title: "Personal Information",
                      icon: Icons.person,
                      children: [
                        _buildTextField(
                          controller: name,
                          label: "Full Name",
                          icon: Icons.person_outline,
                          validator: (value) =>
                              _validateRequired(value, 'your name'),
                        ),
                        const SizedBox(height: 15),
                        _buildTextField(
                          controller: email,
                          label: "Email Address",
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: _validateEmail,
                        ),
                        const SizedBox(height: 15),
                        _buildTextField(
                          controller: phone,
                          label: "Phone Number",
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          validator: _validatePhone,
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Area Selection Card
                    _buildSectionCard(
                      title: "Area Information",
                      icon: Icons.location_city,
                      children: [
                        areaList.isEmpty
                            ? Container(
                          padding: const EdgeInsets.all(20),
                          child: Center(
                            child: Column(
                              children: [
                                CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation(
                                      Colors.green[700]),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  "Loading areas...",
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                        )
                            : _buildDropdownField(
                          value: selectedAreaId,
                          items: areaList,
                          onChanged: (v) =>
                              setState(() => selectedAreaId = v),
                          validator: _validateArea,
                        ),
                        const SizedBox(height: 15),
                        _buildTextField(
                          controller: housename,
                          label: "House Name/Number",
                          icon: Icons.home_outlined,
                          validator: (value) =>
                              _validateRequired(value, 'house name'),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                controller: post,
                                label: "Post Office",
                                icon: Icons.local_post_office_outlined,
                                validator: (value) =>
                                    _validateRequired(value, 'post office'),
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: _buildTextField(
                                controller: pin,
                                label: "PIN Code",
                                icon: Icons.numbers_outlined,
                                keyboardType: TextInputType.number,
                                validator: _validatePIN,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Location Picker Card
                    _buildSectionCard(
                      title: "Location Selection",
                      icon: Icons.map_outlined,
                      children: [
                        Text(
                          "Tap on the map or use current location to set your house location",
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          height: 250,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[300]!, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: FlutterMap(
                              mapController: _mapController,
                              options: MapOptions(
                                initialCenter:
                                selectedLocation ?? LatLng(11.2588, 75.7804),
                                initialZoom: selectedLocation != null ? 15 : 10,
                                onTap: (tapPosition, point) {
                                  setState(() => selectedLocation = point);
                                  _mapController.move(point, 15);
                                },
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate:
                                  'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  subdomains: const ['a', 'b', 'c'],
                                  userAgentPackageName:
                                  'com.example.waste_management',
                                ),
                                if (selectedLocation != null)
                                  MarkerLayer(
                                    markers: [
                                      Marker(
                                        width: 50,
                                        height: 50,
                                        point: selectedLocation!,
                                        child: Icon(
                                          Icons.location_on,
                                          color: Colors.red,
                                          size: 40,
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (selectedLocation != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.green[100]!),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: Colors.green[700],
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Location Set Successfully",
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.green[700],
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        "Lat: ${selectedLocation!.latitude.toStringAsFixed(6)} | Lng: ${selectedLocation!.longitude.toStringAsFixed(6)}",
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey[700],
                                          fontFamily: 'monospace',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 15),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _gettingLocation ? null : _useCurrentLocation,
                            icon: _gettingLocation
                                ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                AlwaysStoppedAnimation(Colors.white),
                              ),
                            )
                                : Icon(Icons.my_location, size: 18),
                            label: Text(_gettingLocation
                                ? "Getting Location..."
                                : "Use Current Location"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[700],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14, horizontal: 20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 2,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Password Card
                    _buildSectionCard(
                      title: "Security",
                      icon: Icons.lock_outline,
                      children: [
                        _buildTextField(
                          controller: password,
                          label: "Password",
                          icon: Icons.lock_outline,
                          obscureText: true,
                          validator: _validatePassword,
                        ),
                        const SizedBox(height: 15),
                        _buildTextField(
                          controller: confirmPassword,
                          label: "Confirm Password",
                          icon: Icons.lock_outline,
                          obscureText: true,
                          validator: _validateConfirmPassword,
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),

                    // Submit Button
                    _isLoading
                        ? Center(
                      child: CircularProgressIndicator(
                        valueColor:
                        AlwaysStoppedAnimation(Colors.green[700]),
                      ),
                    )
                        : ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                        shadowColor: Colors.green[200],
                      ),
                      child: const Text(
                        "CREATE ACCOUNT",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // Login Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Already have an account? ",
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => const login()),
                            );
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                          ),
                          child: Text(
                            "Login",
                            style: TextStyle(
                              color: Colors.green[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: Colors.green[700],
                  size: 20,
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.green[700]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.green[700]!, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: TextStyle(color: Colors.grey[600]),
      ),
      style: TextStyle(fontSize: 15, color: Colors.grey[800]),
    );
  }

  Widget _buildDropdownField({
    required String? value,
    required List<Map<String, String>> items,
    required Function(String?)? onChanged,
    String? Function(String?)? validator,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items
          .map(
            (a) => DropdownMenuItem(
          value: a['id'],
          child: Text(
            a['panchayath']!,
            style: TextStyle(color: Colors.grey[800]),
          ),
        ),
      )
          .toList(),
      onChanged: onChanged,
      validator: validator,
      decoration: InputDecoration(
        labelText: "Select Area",
        prefixIcon: Icon(Icons.location_on_outlined, color: Colors.green[700]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.green[700]!, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: TextStyle(color: Colors.grey[600]),
      ),
      icon: Icon(Icons.arrow_drop_down, color: Colors.green[700]),
      borderRadius: BorderRadius.circular(10),
      style: TextStyle(fontSize: 15, color: Colors.grey[800]),
    );
  }

  Widget field(TextEditingController c, String h, {bool obscure = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: c,
        obscureText: obscure,
        decoration: InputDecoration(
            hintText: h,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
      ),
    );
  }

  Widget readonly(TextEditingController c, String h) {
    return TextField(
      controller: c,
      readOnly: true,
      decoration: InputDecoration(
          hintText: h,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
    );
  }
}

/* ================= LOCATION PICKER ================= */

class LocationPicker extends StatefulWidget {
  final LatLng initial;
  const LocationPicker({Key? key, required this.initial}) : super(key: key);

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  final MapController _mapController = MapController();
  late LatLng picked;

  @override
  void initState() {
    super.initState();
    picked = widget.initial;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pick Location"),
        backgroundColor: Colors.green[700],
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 10),
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context, picked),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.green[700],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 2,
              ),
              child: const Text("DONE"),
            ),
          )
        ],
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: widget.initial,
          initialZoom: 13,
          onTap: (_, point) => setState(() => picked = point),
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.app',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: picked,
                child: const Icon(Icons.location_on,
                    color: Colors.red, size: 40),
              ),
            ],
          ),
        ],
      ),
    );
  }
}






//
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:wate_management/login.dart';
//
// import 'Home.dart';
//
// class Register extends StatelessWidget {
//   const Register({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return const Registersub();
//   }
// }
//
// class Registersub extends StatefulWidget {
//   const Registersub({Key? key}) : super(key: key);
//
//   @override
//   State<Registersub> createState() => _RegistersubState();
// }
//
// class _RegistersubState extends State<Registersub> {
//   final TextEditingController name = TextEditingController();
//   final TextEditingController email = TextEditingController();
//   final TextEditingController phone = TextEditingController();
//   final TextEditingController housename = TextEditingController();
//   final TextEditingController post = TextEditingController();
//   final TextEditingController pin = TextEditingController();
//   final TextEditingController latitude = TextEditingController();
//   final TextEditingController longitude = TextEditingController();
//   final TextEditingController password = TextEditingController();
//   final TextEditingController confirmPassword = TextEditingController();
//
//   String? selectedAreaId;
//   List<Map<String, String>> areaList = [];
//   LatLng? selectedLocation;
//   final MapController _mapController = MapController();
//   bool _isLoading = false;
//   bool _gettingLocation = false;
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//
//   @override
//   void initState() {
//     super.initState();
//     fetchAreas();
//   }
//
//
//   // Get current location
//   Future<void> _useCurrentLocation() async {
//     setState(() => _gettingLocation = true);
//
//     try {
//       bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//       if (!serviceEnabled) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: const Text("Please enable location services to proceed"),
//             backgroundColor: Colors.orange[800],
//             behavior: SnackBarBehavior.floating,
//           ),
//         );
//         setState(() => _gettingLocation = false);
//         return;
//       }
//
//       LocationPermission permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//       }
//       if (permission == LocationPermission.denied ||
//           permission == LocationPermission.deniedForever) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: const Text("Location permission is required for waste management services"),
//             backgroundColor: Colors.red,
//             behavior: SnackBarBehavior.floating,
//           ),
//         );
//         setState(() => _gettingLocation = false);
//         return;
//       }
//
//       Position position = await Geolocator.getCurrentPosition(
//           desiredAccuracy: LocationAccuracy.high
//       );
//       LatLng current = LatLng(position.latitude, position.longitude);
//
//       setState(() {
//         selectedLocation = current;
//         _gettingLocation = false;
//       });
//       _mapController.move(current, 15);
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: const Text("Location captured successfully"),
//           backgroundColor: Colors.green,
//           behavior: SnackBarBehavior.floating,
//         ),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text("Error getting location: $e"),
//           backgroundColor: Colors.red,
//           behavior: SnackBarBehavior.floating,
//         ),
//       );
//       setState(() => _gettingLocation = false);
//     }
//   }
//
//
//   // Load Panchayath data
//   Future<void> fetchAreas() async {
//     try {
//       SharedPreferences sh = await SharedPreferences.getInstance();
//       final response =
//       await http.get(Uri.parse("${sh.getString('ip')}/loadPanchayath"));
//
//       if (response.statusCode == 200) {
//         final body = json.decode(response.body);
//         if (body['status'] == 'ok') {
//           setState(() {
//             areaList = List<Map<String, String>>.from(
//               body['data'].map((e) => {
//                 "id": e['id'].toString(),
//                 "panchayath": e['panchayath'].toString(),
//               }),
//             );
//           });
//         }
//       }
//     } catch (e) {
//       debugPrint("Area fetch error: $e");
//     }
//   }
//
//   @override
//   void dispose() {
//     name.dispose();
//     email.dispose();
//     phone.dispose();
//     housename.dispose();
//     post.dispose();
//     pin.dispose();
//     latitude.dispose();
//     longitude.dispose();
//     password.dispose();
//     confirmPassword.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Register")),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(12),
//         child: Column(
//           children: [
//             field(name, "Name"),
//             field(email, "Email"),
//
//             areaList.isEmpty
//                 ? const CircularProgressIndicator()
//                 : DropdownButtonFormField<String>(
//               value: selectedAreaId,
//               items: areaList
//                   .map(
//                     (a) => DropdownMenuItem(
//                   value: a['id'],
//                   child: Text(a['panchayath']!),
//                 ),
//               )
//                   .toList(),
//               onChanged: (v) => setState(() => selectedAreaId = v),
//               decoration: const InputDecoration(
//                   labelText: "Area",
//                   border: OutlineInputBorder()),
//             ),
//
//             const SizedBox(height: 10),
//             field(phone, "Phone"),
//             field(housename, "House Name"),
//             field(post, "Post"),
//             field(pin, "PIN"),
//
//             // const SizedBox(height: 10),
//             // Row(
//             //   children: [
//             //     Expanded(child: readonly(latitude, "Latitude")),
//             //     const SizedBox(width: 8),
//             //     Expanded(child: readonly(longitude, "Longitude")),
//             //   ],
//             // ),
//
//             // Location Picker Section
//             SizedBox(height: 12),
//             Card(
//               elevation: 2,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       "Tap on map or use current location to set your house location",
//                       style: TextStyle(
//                         color: Colors.grey[600],
//                         fontSize: 13,
//                       ),
//                     ),
//                     SizedBox(height: 12),
//                     Container(
//                       height: 250,
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(10),
//                         border: Border.all(color: Colors.grey[300]!, width: 1),
//                       ),
//                       child: ClipRRect(
//                         borderRadius: BorderRadius.circular(10),
//                         child: FlutterMap(
//                           mapController: _mapController,
//                           options: MapOptions(
//                             initialCenter: selectedLocation ?? LatLng(11.2588, 75.7804),
//                             initialZoom: selectedLocation != null ? 15 : 10,
//                             onTap: (tapPosition, point) {
//                               setState(() => selectedLocation = point);
//                               _mapController.move(point, 15);
//                             },
//                           ),
//                           children: [
//                             TileLayer(
//                               urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
//                               subdomains: const ['a', 'b', 'c'],
//                               userAgentPackageName: 'com.example.waste_management',
//                             ),
//                             if (selectedLocation != null)
//                               MarkerLayer(
//                                 markers: [
//                                   Marker(
//                                     width: 50,
//                                     height: 50,
//                                     point: selectedLocation!,
//                                     child: Icon(Icons.location_on, color: Colors.red, size: 40),
//                                   ),
//                                 ],
//                               ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: 12),
//                     if (selectedLocation != null)
//                       Container(
//                         padding: EdgeInsets.all(12),
//                         decoration: BoxDecoration(
//                           color: Colors.green[50],
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: Row(
//                           children: [
//                             Icon(Icons.gps_fixed, color: Colors.green[700], size: 18),
//                             SizedBox(width: 10),
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     "Location Set",
//                                     style: TextStyle(
//                                       fontSize: 12,
//                                       fontWeight: FontWeight.w500,
//                                       color: Colors.green[700],
//                                     ),
//                                   ),
//                                   SizedBox(height: 2),
//                                   Text(
//                                     "Lat: ${selectedLocation!.latitude.toStringAsFixed(6)} | Lng: ${selectedLocation!.longitude.toStringAsFixed(6)}",
//                                     style: TextStyle(
//                                       fontSize: 11,
//                                       color: Colors.grey[700],
//                                       fontFamily: 'monospace',
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     SizedBox(height: 15),
//                     SizedBox(
//                       width: double.infinity,
//                       child: ElevatedButton.icon(
//                         onPressed: _gettingLocation ? null : _useCurrentLocation,
//                         icon: _gettingLocation
//                             ? SizedBox(
//                           width: 16,
//                           height: 16,
//                           child: CircularProgressIndicator(
//                             strokeWidth: 2,
//                             valueColor: AlwaysStoppedAnimation(Colors.white),
//                           ),
//                         )
//                             : Icon(Icons.my_location, size: 18),
//                         label: Text(_gettingLocation ? "Getting Location..." : "Use Current Location"),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.green[700],
//                           foregroundColor: Colors.white,
//                           padding: EdgeInsets.symmetric(vertical: 14),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 10),
//             field(password, "Password", obscure: true),
//             field(confirmPassword, "Confirm Password", obscure: true),
//
//             const SizedBox(height: 20),
//             ElevatedButton(
//               child: const Text("SUBMIT"),
//               onPressed: () async {
//                 SharedPreferences sh =
//                 await SharedPreferences.getInstance();
//
//                 final response = await http.post(
//                   Uri.parse("${sh.getString('ip')}/register_user"),
//                   body: {
//                     "name": name.text,
//                     "email": email.text,
//                     "area": selectedAreaId ?? "",
//                     "phone": phone.text,
//                     "housename": housename.text,
//                     "post": post.text,
//                     "pin": pin.text,
//                     'latitude': selectedLocation!.latitude.toString(),
//                     'longitude': selectedLocation!.longitude.toString(),
//                     "password": password.text,
//                     "confirm_password": confirmPassword.text,
//                   },
//                 );
//
//                 if (response.statusCode == 200) {
//                   Navigator.pushReplacement(
//                     context,
//                     MaterialPageRoute(builder: (_) => const login()),
//                   );
//                 }
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget field(TextEditingController c, String h,
//       {bool obscure = false}) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 10),
//       child: TextField(
//         controller: c,
//         obscureText: obscure,
//         decoration:
//         InputDecoration(hintText: h, border: OutlineInputBorder()),
//       ),
//     );
//   }
//
//   Widget readonly(TextEditingController c, String h) {
//     return TextField(
//       controller: c,
//       readOnly: true,
//       decoration:
//       InputDecoration(hintText: h, border: OutlineInputBorder()),
//     );
//   }
// }
//
// /* ================= LOCATION PICKER ================= */
//
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
//   late LatLng picked;
//
//   @override
//   void initState() {
//     super.initState();
//     picked = widget.initial;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Pick Location"),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, picked),
//             child: const Text("DONE",
//                 style: TextStyle(color: Colors.white)),
//           )
//         ],
//       ),
//       body: FlutterMap(
//         mapController: _mapController,
//         options: MapOptions(
//           initialCenter: widget.initial,
//           initialZoom: 13,
//           onTap: (_, point) => setState(() => picked = point),
//         ),
//         children: [
//           TileLayer(
//             urlTemplate:
//             'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
//             userAgentPackageName: 'com.example.app',
//           ),
//           MarkerLayer(
//             markers: [
//               Marker(
//                 point: picked,
//                 child: const Icon(Icons.location_on,
//                     color: Colors.red, size: 40),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
