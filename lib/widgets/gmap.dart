import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GMap extends StatefulWidget {
  const GMap({
    Key? key,
    this.onMapCreated,
    required this.markers,
  }) : super(key: key);
  final Function(GoogleMapController)? onMapCreated;
  final Set<Marker> markers;
  @override
  State<GMap> createState() => _GMapState();
}

class _GMapState extends State<GMap> {
  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      onMapCreated: widget.onMapCreated,
      markers: widget.markers,
      myLocationButtonEnabled: true,
      myLocationEnabled: true,
      initialCameraPosition: const CameraPosition(
        target: LatLng(25.1193, 55.3773),
      ),
    );
  }
}
