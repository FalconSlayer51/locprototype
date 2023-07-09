part of 'location_bloc.dart';

@immutable
abstract class LocationState {}

class LocationInitial extends LocationState {}

class LocationConnected extends LocationState {
  final String message;
  LocationConnected({
    required this.message
  });
}

class LocationNotConnected extends LocationState {
  final String message;
  LocationNotConnected({required this.message});
}
