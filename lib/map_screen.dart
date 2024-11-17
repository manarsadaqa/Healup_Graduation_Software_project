import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatelessWidget {
  final String address;
  final LatLng location;

  const MapScreen({super.key, required this.address, required this.location});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map Location'),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: location,
          zoom: 14, // Adjust zoom level as needed
        ),
        markers: {
          Marker(
            markerId: MarkerId(address),
            position: location,
            infoWindow: InfoWindow(title: address),
          ),
        },
      ),
    );
  }
}
