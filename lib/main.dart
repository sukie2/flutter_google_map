import 'package:flutter/material.dart';
import 'package:flutter_google_map/map_controller.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'location_data.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  LatLng _currentPos = LatLng(6.8, 79.9); //Default to sri lanka
  LatLng _selectedPosition = LatLng(6.8, 79.9);
  MapController _mapController = MapController();
  List<LocationData> _bankLocations = [
    LocationData(
        lat: 6.854257,
        lon: 79.914516,
        name: "Maharagama Branch",
        branchCode: "4333"),
    LocationData(
        lat: 6.843667,
        lon: 79.958322,
        name: "Kottawa Branch",
        branchCode: "4340"),
    LocationData(
        lat: 6.838959,
        lon: 79.987155,
        name: "Homagama Branch",
        branchCode: "4555")
  ];

  final Map<String, Marker> _markers = {};

  @override
  Widget build(BuildContext context) {
    int _index = 0;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Stack(
          children: [
            GoogleMap(
              markers: _markers.values.toSet(),
              myLocationButtonEnabled: true,
              onMapCreated: (GoogleMapController controller) {
                _mapController.googleMapController.complete(controller);
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
            Align(
              alignment: FractionalOffset.bottomCenter,
              child: SizedBox(
                height: 200, // card height
                child: PageView.builder(
                  itemCount: 10,
                  controller: PageController(viewportFraction: 0.8),
                  onPageChanged: (int index) => setState(() => _index = index),
                  itemBuilder: (_, i) {
                    return Transform.scale(
                      scale: i == _index ? 1 : .97,
                      child: Card(
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: Center(
                          child: Text(
                            "Branch ${i + 1}",
                            style: TextStyle(fontSize: 32),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //Call this to set the selected position from the horizontal list of cards
  _setSelectedPosition(LocationData selectedPosition) {
    _selectedPosition = LatLng(selectedPosition.lat, selectedPosition.lon);
    // _mapController.updateCameraLocation(_currentPos,
    //     LatLng(_selectedPosition.latitude, _selectedPosition.longitude));
  }

  //Trigger GPS and find users location
  _getCurrentLocation() {
    //Default select
    _setSelectedPosition(_bankLocations.first);

    Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.best,
            forceAndroidLocationManager: true)
        .then((Position position) {
      setState(() {
        _currentPos = LatLng(position.latitude, position.longitude);

        //Add your current GPS location as a pin
        LocationData currentPosition = LocationData(
            lat: position.latitude,
            lon: position.longitude,
            name: "You",
            branchCode: "");
        _bankLocations.add(currentPosition);
        _mapController.addMarkersToMap(_markers, _bankLocations);

        //Zooms and focuses on the current location pin and selected location pin
        _mapController.updateCameraLocation(_currentPos,
            LatLng(_selectedPosition.latitude, _selectedPosition.longitude));
      });
    }).catchError((e) {
      print(e);
    });
  }
}
