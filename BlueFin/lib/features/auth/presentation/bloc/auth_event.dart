import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object> get props => [];
}

class AuthSignInRequested extends AuthEvent {
  final String email;
  final String password;
  const AuthSignInRequested(this.email, this.password);
  @override
  List<Object> get props => [email, password];
}

class AuthSignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String? name;
  const AuthSignUpRequested(this.email, this.password, this.name);
  @override
  List<Object> get props => [email, password, name ?? ''];
}

class AuthCheckStatusRequested extends AuthEvent {}

class AuthSignOutRequested extends AuthEvent {}