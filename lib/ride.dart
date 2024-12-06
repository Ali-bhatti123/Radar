import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'confrm.dart';


class RideScreen extends StatefulWidget {
  final String previousLocation;
  final String previousLatLng;

  const RideScreen({
    required this.previousLocation,
    required this.previousLatLng,
  });
  @override
  State<RideScreen> createState() => _RideScreenState();
}

class _RideScreenState extends State<RideScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:  WillPopScope(
        onWillPop: () async {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) =>  ConfrmScreen(previousLocation: widget.previousLocation, previousLatLng: LatLng(10,20),)),
          );

      return true;
    },
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFF6161), Color(0xFFD90000)], // Background gradient
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 30,
              ),
              Align(
                alignment: Alignment.topLeft,
                child: TextButton(onPressed: (){
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) =>  ConfrmScreen(previousLocation: widget.previousLocation, previousLatLng: LatLng(10,20),)),
                  );
                }, child:Icon(Icons.arrow_back,color: Colors.black,size: 25,) ),
              ),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: const Text(
                  "Ride To....",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(left: 30,right: 30),
                child: Container(
                  //height: 40,
                  child: TextField(
                    maxLines: null,
                   // textAlignVertical: TextAlignVertical.top,
                   // expands: true,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: "${widget.previousLocation}",hintStyle: TextStyle(
                      color: Colors.black,

                    ),

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Padding(
                padding: const EdgeInsets.only(left: 30,right: 30),
                child: Container(
                //  height: 40,
                  child: TextField(
                    maxLines: null,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: "${widget.previousLatLng}",
                        hintStyle: TextStyle(
                    color: Colors.black,

                    ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),
              //const SizedBox(height: 5),
              Expanded(
                child: ListView(
                  children: [
                    _buildRideOption(context, "assets/1.jpg"),
                    _buildRideOption(context, "assets/2.jpg"),
                    _buildRideOption(context, "assets/3.jpg"),
                    _buildRideOption(context, "assets/4.jpg"),
                    _buildRideOption(context, "assets/5.jpg"),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRideOption(BuildContext context, String imagePath) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0,horizontal: 20),
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(topRight: Radius.circular(20),bottomRight: Radius.circular(20)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(.0),
                child: Image.asset(imagePath),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
