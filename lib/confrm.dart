import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rider/destination.dart';

import 'ride.dart';
class ConfrmScreen extends StatefulWidget {
  final String previousLocation;
  final LatLng previousLatLng;

  const ConfrmScreen({
    required this.previousLocation,
    required this.previousLatLng,
  });

  @override
  _ConfrmScreenState createState() => _ConfrmScreenState();
}

class _ConfrmScreenState extends State<ConfrmScreen> {
  TextEditingController _destinationController = TextEditingController();
  TextEditingController _currentLocationController = TextEditingController();
  GoogleMapController? _mapController;
  LatLng? _currentLatLng;
  LatLng? _destinationLatLng;
  List<dynamic> _searchResults = [];
  bool _searchingForDestination = true;
  String apiKey = "AIzaSyBUgSu9gDfWED4zGg6hXi1IiRUJYL7QX3s";

  List<LatLng> _routePoints = [];

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    _destinationController.text = widget.previousLocation;
    _destinationLatLng = widget.previousLatLng;


    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    _currentLatLng = LatLng(position.latitude, position.longitude);
    _getAddressFromLatLng(_currentLatLng!, isCurrentLocation: true);


    if (_currentLatLng != null && _destinationLatLng != null) {
      _fetchRoute(_currentLatLng!, _destinationLatLng!);
    }
  }

  Future<void> _getAddressFromLatLng(LatLng latLng, {required bool isCurrentLocation}) async {
    final response = await http.get(
      Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${latLng.latitude},${latLng.longitude}&key=$apiKey',
      ),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      String address = data['results'][0]['formatted_address'];
      setState(() {
        if (isCurrentLocation) {
          _currentLocationController.text = address;
        } else {
          _destinationController.text = address;
        }
      });
    }
  }

  Future<void> _searchLocation(String query) async {
    final response = await http.get(
      Uri.parse(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&key=$apiKey',
      ),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _searchResults = data['predictions'];
      });
    }
  }

  Future<void> _selectLocation(String placeId, bool isCurrentLocation) async {
    final response = await http.get(
      Uri.parse(
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$apiKey',
      ),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final location = data['result']['geometry']['location'];
      LatLng selectedLatLng = LatLng(location['lat'], location['lng']);
      String address = data['result']['formatted_address'];

      setState(() {
        if (isCurrentLocation) {
          _currentLocationController.text = address;
          _currentLatLng = selectedLatLng;
        } else {
          _destinationController.text = address;
          _destinationLatLng = selectedLatLng;
        }
        _searchResults = [];
        _routePoints.clear(); // Clear previous polyline points
      });

      if (_currentLatLng != null && _destinationLatLng != null) {
        _fetchRoute(_currentLatLng!, _destinationLatLng!);
      }
    }
  }

  Future<void> _fetchRoute(LatLng origin, LatLng destination) async {
    final response = await http.get(
      Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&key=$apiKey',
      ),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['routes'].isNotEmpty) {
        String polyline = data['routes'][0]['overview_polyline']['points'];
        setState(() {
          _routePoints = _decodePolyline(polyline);
        });
      }
    }
  }

  List<LatLng> _decodePolyline(String polyline) {
    List<LatLng> points = [];
    int index = 0, len = polyline.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int shift = 0, result = 0;
      int byte;
      do {
        byte = polyline.codeUnitAt(index++) - 63;
        result |= (byte & 0x1F) << shift;
        shift += 5;
      } while (byte >= 0x20);
      int deltaLat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += deltaLat;

      shift = 0;
      result = 0;
      do {
        byte = polyline.codeUnitAt(index++) - 63;
        result |= (byte & 0x1F) << shift;
        shift += 5;
      } while (byte >= 0x20);
      int deltaLng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += deltaLng;

      points.add(LatLng(lat / 1e5, lng / 1e5));
    }

    return points;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        onWillPop: () async {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) =>  DestinationScreen()),
      );

      return true; // Allow the back press
    },
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFF4B4B), Color(0xFFFF4B4B)], // Red background
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            children: [
              SizedBox(
                height: 40,
              ),
              Align(
                alignment: Alignment.topLeft,
                child: TextButton(onPressed: (){
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) =>  DestinationScreen()),
                  );
                }, child:Icon(Icons.arrow_back,color: Colors.black,size: 25,) ),
              ),
              SizedBox(
                height: 80,
              ),

              Padding(
                padding: const EdgeInsets.only(left: 40),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: const Text(
                    textAlign: TextAlign.start,
                    "Confirm Details",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Container(
                 // height: 40,
                  child: TextField(
                    maxLines: null,
                    scrollPhysics: BouncingScrollPhysics(),
                    controller: _destinationController,
                    decoration: InputDecoration(

                      hintText: "Enter destination",
                      hintStyle: TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchingForDestination = true;
                      });
                      if (value.isNotEmpty) _searchLocation(value);
                    },
                  ),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Container(

                  //height: 40,
                  child: TextField(
                    maxLines: null,
                    controller: _currentLocationController,
                    decoration: InputDecoration(

                      hintText: "Enter a current location",
                      hintStyle: TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchingForDestination = false;
                      });
                      if (value.isNotEmpty) _searchLocation(value);
                    },
                  ),
                ),
              ),
              if (_searchResults.isNotEmpty)
                Expanded(
                  child: ListView.builder(
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final result = _searchResults[index];
                      return ListTile(
                        title: Text(result['description']),
                        onTap: () => _selectLocation(
                          result['place_id'],
                          !_searchingForDestination,
                        ),
                      );
                    },
                  ),
                )
              else
                SizedBox(
                  height: 20,
                ),
               _searchResults.isNotEmpty?Container(): Flexible(
                  child: _currentLatLng == null
                      ? Center(child: CircularProgressIndicator())
                      : Container(
                    height: MediaQuery.of(context).size.height * 0.35, // Responsive map height
                    width: MediaQuery.of(context).size.width * 0.8, // Responsive map width
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                        child: GoogleMap(
                                        initialCameraPosition: CameraPosition(
                        target: _currentLatLng ?? widget.previousLatLng,
                        zoom: 12,
                                        ),
                                        onMapCreated: (controller) {
                        _mapController = controller;
                                        },
                                        markers: {
                        if (_currentLatLng != null)
                          Marker(
                            markerId: MarkerId('current'),
                            position: _currentLatLng!,
                            infoWindow: InfoWindow(title: "Current Location"),
                          ),
                        if (_destinationLatLng != null)
                          Marker(
                            markerId: MarkerId('destination'),
                            position: _destinationLatLng!,
                            infoWindow: InfoWindow(title: "Destination"),
                          ),
                                        },
                                        polylines: {
                        if (_routePoints.isNotEmpty)
                          Polyline(
                            polylineId: PolylineId('route'),
                            points: _routePoints,
                            color: Colors.blue,
                            width: 5,
                          ),
                                        },
                                      ),
                      ),
                ),
              const SizedBox(height: 20),
              _searchResults.isNotEmpty?Container():Container(
                padding:EdgeInsets.only(left: 5,right: 5) ,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(20))
                ),

                child: TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) =>  RideScreen(previousLocation: _destinationController.text, previousLatLng: _currentLocationController.text,)),
                    );

                  },

                  child: const Text(
                    "Search RideRadar",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}