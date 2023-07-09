import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:geolocator/geolocator.dart';
import 'package:locprototype/auth/bloc/auth_bloc.dart';
import 'package:locprototype/screens/home_screen.dart';

import '../internet/bloc/internet_service_bloc.dart';
import '../location_bloc/bloc/location_bloc.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({
    Key? key,
    required this.position,
  }) : super(key: key);
  final Position position;
  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  void _getPermissions() async {
    //bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    // serviceEnabled = await Geolocator.isLocationServiceEnabled();
    // if (!serviceEnabled) {
    //   // Location services are not enabled don't continue
    //   // accessing the position and request users of the
    //   // App to enable the location services.
    //   return Future.error('Location services are disabled.');
    // }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
  }

  @override
  void initState() {
    _getPermissions();
    super.initState();
  }

  Future<void> _signIn(BuildContext context) async {
    BlocProvider.of<AuthBloc>(context).add(
      AuthEvent(context: context, position: widget.position),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MultiBlocListener(
        listeners: [
          BlocListener<InternetServiceBloc, InternetServiceState>(
            listener: (context, state) {
              if (state is NotConnected) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                  ),
                );
              }
              if (state is Connected) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                  ),
                );
              }
            },
          ),
          BlocListener<LocationBloc, LocationState>(
            listener: (context, state) {
              if (state is LocationNotConnected) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                  ),
                );
              }
              if (state is LocationConnected) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                  ),
                );
              }
            },
          ),
        ],
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthCompleted) {
              Future.delayed(Duration.zero, () {
                Navigator.of(context).pushReplacement(
                  MyHomePage.getRoute(
                      title: 'loc chat', position: widget.position),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Sign in completed'),
                  ),
                );
              });
            }

            return Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Welcome to LocPro',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                    'chat with strangers',
                    style: TextStyle(
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 100),
                  InkWell(
                    child: ElevatedButton(
                      onPressed:
                          state is AuthLoading ? () {} : () => _signIn(context),
                      style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50)),
                      child: state is AuthLoading
                          ? const CircularProgressIndicator()
                          : const Text('Sign in with google'),
                    ),
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
