part of 'auth_bloc.dart';

class AuthEvent {
  final AuthRepository authRepository = AuthRepository();
  final BuildContext context;
  final Position position;
  AuthEvent({
    required this.context,
    required this.position,
  });
}
