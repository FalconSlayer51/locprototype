part of 'internet_service_bloc.dart';

@immutable
abstract class InternetServiceState {}

class InternetServiceInitial extends InternetServiceState {}

class Connected extends InternetServiceState {
  final String message;
  Connected({
    required this.message,
  });
}

class NotConnected extends InternetServiceState {
  final String message;
  NotConnected({
    required this.message,
  });
}
