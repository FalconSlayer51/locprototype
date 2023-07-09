

// ignore_for_file: depend_on_referenced_packages

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:locprototype/auth/bloc/auth_bloc.dart';
import 'package:locprototype/firebase_options.dart';
import 'package:locprototype/internet/bloc/internet_service_bloc.dart';
import 'package:locprototype/location_bloc/bloc/location_bloc.dart';
import 'package:locprototype/screens/home_screen.dart';
import 'package:locprototype/screens/landing_screen.dart';

late final Position position;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final GoogleMapsFlutterPlatform mapsImplementation =
      GoogleMapsFlutterPlatform.instance;
  if (mapsImplementation is GoogleMapsFlutterAndroid) {
    mapsImplementation.useAndroidViewSurface = true;
  }
  await Geolocator.requestPermission();
  position = await Geolocator.getCurrentPosition();
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthBloc(),
        ),
        BlocProvider(
          create: (context) => InternetServiceBloc(),
        ),
        BlocProvider(
          create: (context) => LocationBloc(),
        )
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: FirebaseAuth.instance.currentUser != null
          ? MyHomePage(
              title: 'loc chat',
              position: position,
            )
          : LandingScreen(
              position: position,
            ),
    );
  }
}
