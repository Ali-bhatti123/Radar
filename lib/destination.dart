import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import 'confrm.dart';





class DestinationScreen extends StatefulWidget {
  @override
  _DestinationScreenState createState() => _DestinationScreenState();
}

class _DestinationScreenState extends State<DestinationScreen> {
  TextEditingController _searchController = TextEditingController();
  GoogleMapController? _mapController;
  LatLng? _currentLocation;
  List<dynamic> _searchResults = [];
  String apiKey = "AIzaSyBUgSu9gDfWED4zGg6hXi1IiRUJYL7QX3s";

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
    });
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
    } else {
      setState(() {
        _searchResults = [];
      });
    }
  }

  Future<void> _selectLocation(String placeId, String description) async {
    final response = await http.get(
      Uri.parse(
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$apiKey',
      ),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final location = data['result']['geometry']['location'];
      LatLng selectedLatLng = LatLng(location['lat'], location['lng']);
      setState(() {
        _searchController.text = description;
        _currentLocation = selectedLatLng;
        _searchResults = [];
      });
      _mapController?.animateCamera(
        CameraUpdate.newLatLng(selectedLatLng),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) =>  ConfrmScreen(previousLocation: _searchController.text, previousLatLng: _currentLocation!)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.red.shade700, Colors.red.shade400],
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
                          SystemNavigator.pop();
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
              "Enter Destination",
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
         padding: const EdgeInsets.symmetric(horizontal: 30),
         child: TextField(
           maxLines: null,
           controller: _searchController,
           decoration: InputDecoration(
             hintText: "Enter Destination",
             hintStyle: TextStyle(color: Colors.grey),
             filled: true,
             fillColor: Colors.white,
             border: OutlineInputBorder(
               borderRadius: BorderRadius.circular(10),
               borderSide: BorderSide.none,
             ),
           ),
           onChanged: (value) {
             if (value.isNotEmpty) _searchLocation(value);
           },
         ),
                      ),
      
                    if (_searchResults.isNotEmpty)
                      Expanded(
               child: ListView.builder(
                 shrinkWrap: true,
      
                 itemCount: _searchResults.length,
                 itemBuilder: (context, index) {
                   final result = _searchResults[index];
                   return ListTile(
                     title: Text(result['description'],
                     style: TextStyle(color: Colors.white),),
                     onTap: () =>_selectLocation(
                       result['place_id'],
                       result['description'],
                     ),
      
      
                   );
                 },
               ),
                               )
      
                    else
                      SizedBox(
         height: 20,
                      ),
                     _currentLocation == null
                                    ?  Center(child: CircularProgressIndicator())
                                    : Flexible(
                                      child: _searchResults.isEmpty?Container(
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
                                          target: _currentLocation!,
                                          zoom: 14,
                                        ),
                                        onMapCreated: (controller) {
                                          _mapController = controller;
                                        },
                                      ),
                                                                          ):Container(),
                                    ),
                    ]),
      ));
  }
}

