part of 'location_bloc.dart';

@immutable
abstract class LocationEvent {}

class OnLocationConnected extends LocationEvent {}

class OnLocationNotConnected extends LocationEvent {}