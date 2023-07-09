import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:meta/meta.dart';

part 'location_event.dart';
part 'location_state.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  LocationBloc() : super(LocationInitial()) {
    StreamSubscription? locationSubscription;
    on<OnLocationConnected>((event, emit) {
      emit(LocationConnected(message: 'Location is on'));
    });

    on<OnLocationNotConnected>((event, emit) async {
      emit(
        LocationNotConnected(
          message: 'Location is off please turn on Location',
        ),
      );
    });

    locationSubscription = Geolocator.getServiceStatusStream().listen((event) {
      if (event == ServiceStatus.enabled) {
        add(OnLocationConnected());
      } else if (event == ServiceStatus.disabled) {
        add(OnLocationNotConnected());
      }
    });
  }
}
