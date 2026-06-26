import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../../domain/usecases/sign_in.dart';
import '../../domain/usecases/sign_up.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/sign_out.dart';
import '../../../../core/usecases/usecase.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInUseCase signIn;
  final SignUpUseCase signUp;
  final GetCurrentUserUseCase getCurrentUser;
  final SignOutUseCase signOut;

  AuthBloc({
    required this.signIn,
    required this.signUp,
    required this.getCurrentUser,
    required this.signOut,
  }) : super(AuthInitial()) {
    on<AuthCheckStatusRequested>(_onCheckStatus);
    on<AuthSignInRequested>(_onSignIn);
    on<AuthSignUpRequested>(_onSignUp);
    on<AuthSignOutRequested>(_onSignOut);
  }

  void _onCheckStatus(
      AuthCheckStatusRequested event,
      Emitter<AuthState> emit,
      ) async {
    emit(AuthLoading());
    final result = await getCurrentUser(NoParams());
    result.fold(
          (failure) => emit(AuthUnauthenticated()),
          (user) => emit(AuthAuthenticated(user)),
    );
  }

  void _onSignIn(
      AuthSignInRequested event,
      Emitter<AuthState> emit,
      ) async {
    emit(AuthLoading());
    final result = await signIn(SignInParams(
      email: event.email,
      password: event.password,
    ));
    result.fold(
          (failure) => emit(AuthError(failure.message)),
          (user) => emit(AuthAuthenticated(user)),
    );
  }

  void _onSignUp(
      AuthSignUpRequested event,
      Emitter<AuthState> emit,
      ) async {
    emit(AuthLoading());
    final result = await signUp(SignUpParams(
      email: event.email,
      password: event.password,
      name: event.name,
    ));
    result.fold(
          (failure) => emit(AuthError(failure.message)),
          (user) => emit(AuthAuthenticated(user)),
    );
  }

  void _onSignOut(
      AuthSignOutRequested event,
      Emitter<AuthState> emit,
      ) async {
    emit(AuthLoading());
    final result = await signOut(NoParams());
    result.fold(
          (failure) => emit(AuthError(failure.message)),
          (_) => emit(AuthUnauthenticated()),
    );
  }
}