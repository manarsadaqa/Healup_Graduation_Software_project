import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// إعادة تسمية الحزم باستخدام alias لتجنب التعارض
import 'package:location/location.dart' as loc; // الحزمة الخاصة بالحصول على الموقع
import 'package:geocoding/geocoding.dart'; // الحزمة الخاصة بتحويل العنوان إلى إحداثيات

class OrderTrackingPage extends StatefulWidget {
  final String patientAddress; // إضافة المتغير لتخزين العنوان

  const OrderTrackingPage({Key? key, required this.patientAddress}) : super(key: key);

  @override
  State<OrderTrackingPage> createState() => OrderTrackingPageState();
}

class OrderTrackingPageState extends State<OrderTrackingPage> {
  final Completer<GoogleMapController> _controller = Completer();
  static const String healupLocation = 'مجمع حكيم الطبي نابلس '; // العنوان الثابت

  LatLng? patientLocation; // الموقع الذي سيتم تحديده بواسطة العنوان
  LatLng? healupLocationLatLng; // إحداثيات موقع healupLocation

  static const String google_api_key = 'AIzaSyB-86UTgKSTmSjppYQccJKIbHLjXfc-Q0o';
  static const Color primaryColor = Color(0xFF7B61FF);
  static const double defaultPadding = 16.0;

  List<LatLng> polylineCoordinates = [];
  loc.LocationData? currentLocation;

  void getCurrentLocation() async {
    loc.Location location = loc.Location(); // استخدام الحزمة مع الاسم المستعار

    location.getLocation().then((location) {
      currentLocation = location;
    });

    GoogleMapController googleMapController = await _controller.future;

    location.onLocationChanged.listen((newLoc) {
      currentLocation = newLoc;
      googleMapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            zoom: 15.5,
            target: LatLng(
              newLoc.latitude!,
              newLoc.longitude!,
            ),
          ),
        ),
      );

      setState(() {});
    });
  }

  void getPolyPoints() async {
    if (patientLocation != null && healupLocationLatLng != null) {
      PolylinePoints polylinePoints = PolylinePoints();

      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        google_api_key,
        PointLatLng(healupLocationLatLng!.latitude, healupLocationLatLng!.longitude), // استخدام healupLocation كنقطة بداية
        PointLatLng(patientLocation!.latitude, patientLocation!.longitude), // تحديث الوجهة
      );

      if (result.points.isNotEmpty) {
        result.points.forEach(
              (PointLatLng point) => polylineCoordinates.add(
            LatLng(point.latitude, point.longitude),
          ),
        );
        setState(() {});
      }
    }
  }

  // دالة لتحويل العنوان إلى إحداثيات
  Future<void> getLocations() async {
    try {
      // تحويل عنوان المريض إلى إحداثيات
      List<Location> locations = await locationFromAddress(widget.patientAddress);
      if (locations.isNotEmpty) {
        setState(() {
          patientLocation = LatLng(locations[0].latitude, locations[0].longitude);
        });
      }

      // تحويل عنوان healupLocation إلى إحداثيات
      List<Location> healupLocations = await locationFromAddress(healupLocation);
      if (healupLocations.isNotEmpty) {
        setState(() {
          healupLocationLatLng = LatLng(healupLocations[0].latitude, healupLocations[0].longitude);
        });
      }

      // استدعاء getPolyPoints بعد تحديد المواقع
      getPolyPoints();
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  void initState() {
    getCurrentLocation();
    getLocations(); // استدعاء دالة تحويل العناوين إلى إحداثيات
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print('Patient Address: ${widget.patientAddress}');

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Track order",
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
      ),
      body: currentLocation == null || patientLocation == null || healupLocationLatLng == null
          ? const Center(child: Text("Loading"))
          : GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
          zoom: 15.5,
        ),
        polylines: {
          Polyline(
            polylineId: PolylineId("route"),
            points: polylineCoordinates,
            color: primaryColor,
            width: 6,
          ),
        },
        markers: {
          Marker(
            markerId: const MarkerId("currentLocation"),
            position: LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
          ),
          if (healupLocationLatLng != null)
            Marker(
              markerId: MarkerId("healupLocation"),
              position: healupLocationLatLng!,
              infoWindow: InfoWindow(title: 'Healup Location'), // نص العنوان
            ),
          if (patientLocation != null)
            Marker(
              markerId: MarkerId("patient"),
              position: patientLocation!,
              infoWindow: InfoWindow(title: 'Patient Location'),
            ),
        },
        onMapCreated: (mapController) {
          _controller.complete(mapController);
        },
      ),
    );
  }
}


// import 'dart:async';
//
// import 'package:flutter/material.dart';
// import 'package:flutter_polyline_points/flutter_polyline_points.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// // إعادة تسمية الحزم باستخدام alias لتجنب التعارض
// import 'package:location/location.dart' as loc; // الحزمة الخاصة بالحصول على الموقع
// import 'package:geocoding/geocoding.dart'; // الحزمة الخاصة بتحويل العنوان إلى إحداثيات
//
// class OrderTrackingPage extends StatefulWidget {
//   final String patientAddress; // إضافة المتغير لتخزين العنوان
//
//   const OrderTrackingPage({Key? key, required this.patientAddress}) : super(key: key);
//
//   @override
//   State<OrderTrackingPage> createState() => OrderTrackingPageState();
// }
//
// class OrderTrackingPageState extends State<OrderTrackingPage> {
//   final Completer<GoogleMapController> _controller = Completer();
//   static const String healupLocation = 'مجمع حكيم الطبي نابلس '; // العنوان الثابت
//
//   static const LatLng sourceLocation = LatLng(32.240398, 35.229759); // الموقع الثابت
//   LatLng? patientLocation; // الموقع الذي سيتم تحديده بواسطة العنوان
//   LatLng? healupLocationLatLng; // إحداثيات موقع healupLocation
//
//   static const String google_api_key = 'AIzaSyB-86UTgKSTmSjppYQccJKIbHLjXfc-Q0o';
//   static const Color primaryColor = Color(0xFF7B61FF);
//   static const double defaultPadding = 16.0;
//
//   List<LatLng> polylineCoordinates = [];
//   loc.LocationData? currentLocation;
//
//   void getCurrentLocation() async {
//     loc.Location location = loc.Location(); // استخدام الحزمة مع الاسم المستعار
//
//     location.getLocation().then((location) {
//       currentLocation = location;
//     });
//
//     GoogleMapController googleMapController = await _controller.future;
//
//     location.onLocationChanged.listen((newLoc) {
//       currentLocation = newLoc;
//       googleMapController.animateCamera(
//         CameraUpdate.newCameraPosition(
//           CameraPosition(
//             zoom: 15.5,
//             target: LatLng(
//               newLoc.latitude!,
//               newLoc.longitude!,
//             ),
//           ),
//         ),
//       );
//
//       setState(() {});
//     });
//   }
//
//   void getPolyPoints() async {
//     if (patientLocation != null && healupLocationLatLng != null) {
//       PolylinePoints polylinePoints = PolylinePoints();
//
//       PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
//         google_api_key,
//         PointLatLng(sourceLocation.latitude, sourceLocation.longitude),
//         PointLatLng(patientLocation!.latitude, patientLocation!.longitude), // تحديث الوجهة
//       );
//
//       if (result.points.isNotEmpty) {
//         result.points.forEach(
//               (PointLatLng point) => polylineCoordinates.add(
//             LatLng(point.latitude, point.longitude),
//           ),
//         );
//         setState(() {});
//       }
//     }
//   }
//
//   // دالة لتحويل العنوان إلى إحداثيات
//   Future<void> getLocations() async {
//     try {
//       // تحويل عنوان المريض إلى إحداثيات
//       List<Location> locations = await locationFromAddress(widget.patientAddress);
//       if (locations.isNotEmpty) {
//         setState(() {
//           patientLocation = LatLng(locations[0].latitude, locations[0].longitude);
//         });
//       }
//
//       // تحويل عنوان healupLocation إلى إحداثيات
//       List<Location> healupLocations = await locationFromAddress(healupLocation);
//       if (healupLocations.isNotEmpty) {
//         setState(() {
//           healupLocationLatLng = LatLng(healupLocations[0].latitude, healupLocations[0].longitude);
//         });
//       }
//
//       // استدعاء getPolyPoints بعد تحديد المواقع
//       getPolyPoints();
//     } catch (e) {
//       print('Error: $e');
//     }
//   }
//
//   @override
//   void initState() {
//     getCurrentLocation();
//     getLocations(); // استدعاء دالة تحويل العناوين إلى إحداثيات
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     print('Patient Address: ${widget.patientAddress}');
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           "Track order",
//           style: TextStyle(color: Colors.black, fontSize: 16),
//         ),
//       ),
//       body: currentLocation == null || patientLocation == null || healupLocationLatLng == null
//           ? const Center(child: Text("Loading"))
//           : GoogleMap(
//         initialCameraPosition: CameraPosition(
//           target: LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
//           zoom: 15.5,
//         ),
//         polylines: {
//           Polyline(
//             polylineId: PolylineId("route"),
//             points: polylineCoordinates,
//             color: primaryColor,
//             width: 6,
//           ),
//         },
//         markers: {
//           Marker(
//             markerId: const MarkerId("currentLocation"),
//             position: LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
//           ),
//           // const Marker(
//           //   markerId: MarkerId("source"),
//           //   position: sourceLocation,
//           // ),
//           if (patientLocation != null)
//             Marker(
//               markerId: MarkerId("patient"),
//               position: patientLocation!,
//               infoWindow: InfoWindow(title: 'Patient Location'),
//             ),
//           if (healupLocationLatLng != null)
//             Marker(
//               markerId: MarkerId("healupLocation"),
//               position: healupLocationLatLng!,
//               infoWindow: InfoWindow(title: 'Healup Location'), // نص العنوان
//             ),
//         },
//         onMapCreated: (mapController) {
//           _controller.complete(mapController);
//         },
//       ),
//     );
//   }
// }


// import 'dart:async';
//
// import 'package:flutter/material.dart';
// import 'package:flutter_polyline_points/flutter_polyline_points.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// // إعادة تسمية الحزم باستخدام alias لتجنب التعارض
// import 'package:location/location.dart' as loc; // الحزمة الخاصة بالحصول على الموقع
// import 'package:geocoding/geocoding.dart'; // الحزمة الخاصة بتحويل العنوان إلى إحداثيات
//
// class OrderTrackingPage extends StatefulWidget {
//   final String patientAddress; // إضافة المتغير لتخزين العنوان
//
//   const OrderTrackingPage({Key? key, required this.patientAddress}) : super(key: key);
//
//   @override
//   State<OrderTrackingPage> createState() => OrderTrackingPageState();
// }
//
// class OrderTrackingPageState extends State<OrderTrackingPage> {
//   final Completer<GoogleMapController> _controller = Completer();
//   static const String healupLocation = 'مجمع حكيم الطبي نابلس ';
//
//   static const LatLng sourceLocation = LatLng(32.240398, 35.229759); // الموقع الثابت
//   LatLng? patientLocation; // الموقع الذي سيتم تحديده بواسطة العنوان
//
//   static const String google_api_key = 'AIzaSyB-86UTgKSTmSjppYQccJKIbHLjXfc-Q0o';
//   static const Color primaryColor = Color(0xFF7B61FF);
//   static const double defaultPadding = 16.0;
//
//   List<LatLng> polylineCoordinates = [];
//   loc.LocationData? currentLocation;
//
//   void getCurrentLocation() async {
//     loc.Location location = loc.Location(); // استخدام الحزمة مع الاسم المستعار
//
//     location.getLocation().then((location) {
//       currentLocation = location;
//     });
//
//     GoogleMapController googleMapController = await _controller.future;
//
//     location.onLocationChanged.listen((newLoc) {
//       currentLocation = newLoc;
//       googleMapController.animateCamera(
//         CameraUpdate.newCameraPosition(
//           CameraPosition(
//             zoom: 15.5,
//             target: LatLng(
//               newLoc.latitude!,
//               newLoc.longitude!,
//             ),
//           ),
//         ),
//       );
//
//       setState(() {});
//     });
//   }
//
//   void getPolyPoints() async {
//     if (patientLocation != null) {
//       PolylinePoints polylinePoints = PolylinePoints();
//
//       PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
//         google_api_key,
//         PointLatLng(sourceLocation.latitude, sourceLocation.longitude),
//         PointLatLng(patientLocation!.latitude, patientLocation!.longitude), // تحديث الوجهة
//       );
//
//       if (result.points.isNotEmpty) {
//         result.points.forEach(
//               (PointLatLng point) => polylineCoordinates.add(
//             LatLng(point.latitude, point.longitude),
//           ),
//         );
//         setState(() {});
//       }
//     }
//   }
//
//   // دالة لتحويل العنوان إلى إحداثيات
//   Future<void> getPatientLocation(String address) async {
//     try {
//       List<Location> locations = await locationFromAddress(address);
//       if (locations.isNotEmpty) {
//         setState(() {
//           patientLocation = LatLng(locations[0].latitude, locations[0].longitude);
//         });
//         getPolyPoints(); // استدعاء getPolyPoints بعد تحديد موقع المريض
//       }
//     } catch (e) {
//       print('Error: $e');
//     }
//   }
//
//   @override
//   void initState() {
//     getCurrentLocation();
//     getPatientLocation(widget.patientAddress); // استدعاء دالة تحويل العنوان إلى إحداثيات
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     print('Patient Address: ${widget.patientAddress}');
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           "Track order",
//           style: TextStyle(color: Colors.black, fontSize: 16),
//         ),
//       ),
//       body: currentLocation == null || patientLocation == null
//           ? const Center(child: Text("Loading"))
//           : GoogleMap(
//         initialCameraPosition: CameraPosition(
//           target: LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
//           zoom: 16.5,
//         ),
//         polylines: {
//           Polyline(
//             polylineId: PolylineId("route"),
//             points: polylineCoordinates,
//             color: primaryColor,
//             width: 6,
//           ),
//         },
//         markers: {
//           Marker(
//             markerId: const MarkerId("currentLocation"),
//             position: LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
//           ),
//           const Marker(
//             markerId: MarkerId("source"),
//             position: sourceLocation,
//           ),
//           if (patientLocation != null)
//             Marker(
//               markerId: MarkerId("patient"),
//               position: patientLocation!,
//               infoWindow: InfoWindow(title: 'Patient Location'),
//             ),
//         },
//         onMapCreated: (mapController) {
//           _controller.complete(mapController);
//         },
//       ),
//     );
//   }
// }
