import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:locprototype/widgets/gmap.dart';
import 'package:locprototype/widgets/loader.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';

import 'home_screen.dart';

class MapBuilder extends StatefulWidget {
  MapBuilder({
    Key? key,
    required this.position,
  }) : super(key: key);
  final Position position;

  @override
  State<MapBuilder> createState() => _MapBuilderState();
}

class _MapBuilderState extends State<MapBuilder> {
  final geo = GeoFlutterFire();

  final collectionRef = FirebaseFirestore.instance.collection('users');

  final radius = BehaviorSubject<double>.seeded(1.0);

  late GoogleMapController mapController;

  onMapCreated(GoogleMapController controller) {
      mapController = controller;
      mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(widget.position.latitude, widget.position.longitude),
            zoom: 15.0,
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final center = geo.point(
        latitude: widget.position.latitude,
        longitude: widget.position.longitude);
    return StreamBuilder(
      stream: radius.switchMap((value) {
        var collectionRef = FirebaseFirestore.instance.collection('users');
        log(FirebaseAuth.instance.currentUser!.uid);
        return geo
            .collection(collectionRef: collectionRef)
            .within(center: center, radius: value, field: 'position');
      }),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Loader();
        }
        final Set<Marker> markers = <Marker>{};
        if (snapshot.hasData) {
          snapshot.data!.forEach((element) {
            Map<String, dynamic> snapData =
                element.data() as Map<String, dynamic>;
            final GeoPoint point = snapData['position']['geopoint'];

            if (snapData['uid'] == FirebaseAuth.instance.currentUser!.uid)
              return;
            markers.add(
              Marker(
                anchor: const Offset(0.5, 1.0),
                markerId: MarkerId(const Uuid().v1()),
                position: LatLng(
                  point.latitude,
                  point.longitude,
                ),
                onTap: () => showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return BottomSheetWidget(snapData: snapData);
                  },
                ),
                icon: BitmapDescriptor.defaultMarker,
                infoWindow: InfoWindow(
                  title: snapData['username'],
                ),
              ),
            );
          });
        }
        if (snapshot.data!.isEmpty) {
          return const Center(
            child: Text('no one near you found'),
          );
        }
        return GMap(
          markers: markers,
          onMapCreated: onMapCreated,
          position: widget.position,
        );
      },
    );
  }
}
