import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


class GMap extends StatefulWidget {
  const GMap({
    Key? key,
    this.onMapCreated,
    required this.markers,
    required this.position,
  }) : super(key: key);
  final Function(GoogleMapController)? onMapCreated;
  final Set<Marker> markers;
  final Position position;
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
      zoomGesturesEnabled: true,
      zoomControlsEnabled: true,
      initialCameraPosition:  CameraPosition(
        target: LatLng(widget.position.latitude, widget.position.longitude),
      ),
    );
  }
}
