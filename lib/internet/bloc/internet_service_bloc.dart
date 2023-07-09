import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:meta/meta.dart';

part 'internet_service_event.dart';
part 'internet_service_state.dart';

class InternetServiceBloc
    extends Bloc<InternetServiceEvent, InternetServiceState> {
  StreamSubscription? subscription;
  InternetServiceBloc() : super(InternetServiceInitial()) {
    on<OnConnected>((event, emit) {
      emit(Connected(message: 'Connected to internet'));
    });

    on<OnNotConnected>((event, emit) {
      emit(NotConnected(message: 'Not connected to internet'));
    });

    subscription = Connectivity().onConnectivityChanged.listen((event) {
      if (event == ConnectivityResult.mobile ||
          event == ConnectivityResult.wifi) {
        add(OnConnected());
      } else {
        add(OnNotConnected());
      }
    });
  }
}
