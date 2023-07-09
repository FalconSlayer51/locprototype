import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:locprototype/screens/chat_screen.dart';
import 'package:locprototype/screens/contacts_screen.dart';
import 'package:locprototype/screens/map_builder.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';

import '../internet/bloc/internet_service_bloc.dart';
import '../location_bloc/bloc/location_bloc.dart';

class MyHomePage extends StatefulWidget {
  static Route getRoute({required String title, required Position position}) =>
      MaterialPageRoute(
        builder: (context) => MyHomePage(
          title: title,
          position: position,
        ),
      );
  const MyHomePage({
    Key? key,
    required this.position,
    required this.title,
  }) : super(key: key);

  final Position position;
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final GeoFlutterFire geo;
  late GoogleMapController myMapController;
  late Stream<List<DocumentSnapshot>> stream;
  final radius = BehaviorSubject<double>.seeded(1.0);
  int index = 0;

  //final Set<Marker> _markers = new Set();
  // static const LatLng _mainLocation = const LatLng(25.69893, 32.6421);

  late final Set<Marker> markers = <Marker>{};

  Future<void> _updateFirebase() async {
    await Geolocator.requestPermission();
    final position = await Geolocator.getCurrentPosition();
    final geo = GeoFlutterFire();
    final newLoc =
        geo.point(latitude: position.latitude, longitude: position.longitude);
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({'position': newLoc.data});
    log('updated');

    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateFirebase();
    });
    super.initState();
    geo = GeoFlutterFire();
    GeoFirePoint center = geo.point(
        latitude: widget.position.latitude,
        longitude: widget.position.longitude);
    stream = radius.switchMap((value) {
      var collectionRef = FirebaseFirestore.instance.collection('users');
      log(FirebaseAuth.instance.currentUser!.uid);
      return geo
          .collection(collectionRef: collectionRef)
          .within(center: center, radius: value, field: 'position');
    });
  }

  @override
  void dispose() {
    radius.close();
    super.dispose();
  }

  void _addMarker() {
    myMapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(widget.position.latitude, widget.position.longitude),
          zoom: 15.0,
        ),
      ),
    );
  }

  onMapCreated(GoogleMapController controller) {
    setState(() {
      myMapController = controller;
      _addMarker();
      stream.listen((List<DocumentSnapshot> documentList) {
        // ignore: avoid_function_literals_in_foreach_calls
        documentList.forEach((DocumentSnapshot element) {
          Map<String, dynamic> snapData =
              element.data() as Map<String, dynamic>;
          final GeoPoint point = snapData['position']['geopoint'];

          if (snapData['uid'] == FirebaseAuth.instance.currentUser!.uid) return;
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
          setState(() {});
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      MapBuilder(position: widget.position),
      ContactsScreen(),
    ];

    final pageTitles = ['Maps', 'Chats'];
    return Scaffold(
      appBar: AppBar(
        title: Text(
          pageTitles[index],
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        toolbarHeight: 100,
        actions: [
          GestureDetector(
            onTap: () {
              //implementation for the drawer
            },
            child: Container(
              padding: const EdgeInsets.all(18),
              child: CircleAvatar(
                backgroundImage: NetworkImage(
                  FirebaseAuth.instance.currentUser!.photoURL!,
                ),
              ),
            ),
          )
        ],
      ),
      body: BlocBuilder<LocationBloc, LocationState>(
        builder: (context, state) {
          if (state is LocationNotConnected) {
            return Center(
              child: Column(
                children: [
                  const Icon(Icons.location_off),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(state.message),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await Geolocator.openLocationSettings();
                    },
                    child: const Text('enable location access'),
                  ),
                ],
              ),
            );
          }
          return BlocBuilder<InternetServiceBloc, InternetServiceState>(
            builder: (context, state) {
              if (state is NotConnected) {
                return Center(
                  child: Column(
                    children: [
                      const Icon(Icons.signal_wifi_off_rounded),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(state.message)
                    ],
                  ),
                );
              }
              return pages[index];
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addMarker,
        child: const Icon(Icons.location_pin),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (value) => setState(() {
          index = value;
        }),
        selectedIndex: index,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            label: 'maps',
            selectedIcon: Icon(Icons.map),
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_outlined),
            label: 'chats',
            selectedIcon: Icon(Icons.chat),
          ),
        ],
      ),
    );
  }
}

class BottomSheetWidget extends StatelessWidget {
  const BottomSheetWidget({
    super.key,
    required this.snapData,
  });

  final Map<String, dynamic> snapData;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      height: 250,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Column(
                children: [
                  const Text(
                    'Let\'s chat with',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    width: 170,
                    child: Text(
                      '${snapData['username']}',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                width: 100,
              ),
              CircleAvatar(
                backgroundImage: NetworkImage(
                  snapData['profilePhoto'],
                ),
                radius: 30,
              )
            ],
          ),
          const SizedBox(
            height: 30,
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(ChatScreen.getRoute(
                username: snapData['username'],
                photoUrl: snapData['profilePhoto'],
                recieverUid: snapData['uid'],
              ));
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: Colors.purple,
            ),
            child: const Text(
              'chat',
              style: TextStyle(color: Colors.white),
            ),
          )
        ],
      ),
    );
  }
}
