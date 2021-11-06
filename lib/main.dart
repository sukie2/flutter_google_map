import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  LatLng _currentPos = LatLng(6.8, 79.9); //Default to sri lanka
  Completer<GoogleMapController> _controller = Completer();

  final Map<String, Marker> _markers = {};

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Stack(
          children: [
            GoogleMap(
              markers: _markers.values.toSet(),
              myLocationButtonEnabled: true,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
              initialCameraPosition: CameraPosition(
                target: _currentPos,
                zoom: 6.0,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(28.0),
              child: FlatButton(
                color: Colors.cyan,
                child: Text("Start"),
                onPressed: () {
                  _getCurrentLocation();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  _getCurrentLocation() {
    Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.best,
            forceAndroidLocationManager: true)
        .then((Position position) {
      setState(() {
        _currentPos = LatLng(position.latitude, position.longitude);
        Marker curMarker = Marker(
          markerId: MarkerId("current"),
          position: _currentPos,
          infoWindow: InfoWindow(
            title: "you",
            snippet: "snippet",
          ),
        );
        Marker marker2 = Marker(
          markerId: MarkerId("Branch"),
          position: LatLng(6.843667, 39.958322),
          infoWindow: InfoWindow(
            title: "Branch",
            snippet: "Kottawa",
          ),
        );
        _markers.clear();
        _markers['current'] = curMarker;
        _markers['branch'] = marker2;
        updateCameraLocation(_currentPos, LatLng(6.843667, 39.958322));
      });
    }).catchError((e) {
      print(e);
    });
  }

  Future<void> updateCameraLocation(
    LatLng source,
    LatLng destination,
  ) async {
    if (_controller == null) return;

    LatLngBounds bounds;

    if (source.latitude > destination.latitude &&
        source.longitude > destination.longitude) {
      bounds = LatLngBounds(southwest: destination, northeast: source);
    } else if (source.longitude > destination.longitude) {
      bounds = LatLngBounds(
          southwest: LatLng(source.latitude, destination.longitude),
          northeast: LatLng(destination.latitude, source.longitude));
    } else if (source.latitude > destination.latitude) {
      bounds = LatLngBounds(
          southwest: LatLng(destination.latitude, source.longitude),
          northeast: LatLng(source.latitude, destination.longitude));
    } else {
      bounds = LatLngBounds(southwest: source, northeast: destination);
    }

    CameraUpdate cameraUpdate = CameraUpdate.newLatLngBounds(bounds, 70);

    return checkCameraLocation(cameraUpdate);
  }

  Future<void> checkCameraLocation(CameraUpdate cameraUpdate) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(cameraUpdate);
    LatLngBounds l1 = await controller.getVisibleRegion();
    LatLngBounds l2 = await controller.getVisibleRegion();

    if (l1.southwest.latitude == -90 || l2.southwest.latitude == -90) {
      return checkCameraLocation(cameraUpdate);
    }
  }
}
