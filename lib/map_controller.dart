import 'dart:async';

import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'location_data.dart';

class MapController {
  Completer<GoogleMapController> googleMapController = Completer();

  addMarkersToMap(
      Map<String, Marker> markersMap, List<LocationData> bankLocations) {
    markersMap.clear();
    for (var location in bankLocations) {
      Marker marker = Marker(
        markerId: MarkerId(location.branchCode),
        position: LatLng(location.lat, location.lon),
        infoWindow: InfoWindow(
          title: location.name,
        ),
      );
      markersMap[location.name] = marker;
    }
  }

  Future<void> updateCameraLocation(
    LatLng source,
    LatLng destination,
  ) async {
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
    final GoogleMapController controller = await googleMapController.future;
    controller.animateCamera(cameraUpdate);
    LatLngBounds l1 = await controller.getVisibleRegion();
    LatLngBounds l2 = await controller.getVisibleRegion();

    if (l1.southwest.latitude == -90 || l2.southwest.latitude == -90) {
      return checkCameraLocation(cameraUpdate);
    }
  }
}
