import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:BlueFin/core/errors/failures.dart';
import 'package:BlueFin/core/usecases/usecase.dart';
import 'package:BlueFin/features/auth/domain/entities/user.dart';
import 'package:BlueFin/features/auth/domain/usecases/sign_in.dart';
import 'package:BlueFin/features/auth/domain/usecases/sign_up.dart';
import 'package:BlueFin/features/auth/domain/usecases/get_current_user.dart';
import 'package:BlueFin/features/auth/domain/usecases/sign_out.dart';
import 'package:BlueFin/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:BlueFin/features/auth/presentation/bloc/auth_event.dart';
import 'package:BlueFin/features/auth/presentation/bloc/auth_state.dart';

class MockSignInUseCase extends Mock implements SignInUseCase {}
class MockSignUpUseCase extends Mock implements SignUpUseCase {}
class MockGetCurrentUserUseCase extends Mock implements GetCurrentUserUseCase {}
class MockSignOutUseCase extends Mock implements SignOutUseCase {}

void main() {
  late AuthBloc bloc;
  late MockSignInUseCase mockSignIn;
  late MockSignUpUseCase mockSignUp;
  late MockGetCurrentUserUseCase mockGetCurrentUser;
  late MockSignOutUseCase mockSignOut;

  final tUser = User(id: '1', email: 'test@test.com');
  final tSignInParams = SignInParams(email: 'test@test.com', password: 'pass');
  final tSignUpParams = SignUpParams(email: 'test@test.com', password: 'pass', name: 'User');

  setUpAll(() {
    registerFallbackValue(tSignInParams);
    registerFallbackValue(tSignUpParams);
    registerFallbackValue(const NoParams());
  });

  setUp(() {
    mockSignIn = MockSignInUseCase();
    mockSignUp = MockSignUpUseCase();
    mockGetCurrentUser = MockGetCurrentUserUseCase();
    mockSignOut = MockSignOutUseCase();
    bloc = AuthBloc(
      signIn: mockSignIn,
      signUp: mockSignUp,
      getCurrentUser: mockGetCurrentUser,
      signOut: mockSignOut,
    );
  });

  blocTest<AuthBloc, AuthState>(
    'emits [AuthLoading, AuthAuthenticated] when sign in success',
    build: () {
      when(() => mockSignIn(any())).thenAnswer((_) async => Right(tUser));
      return bloc;
    },
    act: (bloc) => bloc.add(const AuthSignInRequested('test@test.com', 'pass')),
    expect: () => [
      AuthLoading(),
      AuthAuthenticated(tUser),
    ],
  );

  blocTest<AuthBloc, AuthState>(
    'emits [AuthLoading, AuthError] when sign in fails',
    build: () {
      when(() => mockSignIn(any())).thenAnswer((_) async => const Left(ServerFailure('Invalid credentials')));
      return bloc;
    },
    act: (bloc) => bloc.add(const AuthSignInRequested('test@test.com', 'wrong')),
    expect: () => [
      AuthLoading(),
      const AuthError('Invalid credentials'),
    ],
  );

  blocTest<AuthBloc, AuthState>(
    'emits [AuthLoading, AuthAuthenticated] when check status success',
    build: () {
      when(() => mockGetCurrentUser(any())).thenAnswer((_) async => Right(tUser));
      return bloc;
    },
    act: (bloc) => bloc.add(AuthCheckStatusRequested()),
    expect: () => [
      AuthLoading(),
      AuthAuthenticated(tUser),
    ],
  );

  blocTest<AuthBloc, AuthState>(
    'emits [AuthLoading, AuthUnauthenticated] when no user',
    build: () {
      when(() => mockGetCurrentUser(any())).thenAnswer((_) async => const Left(CacheFailure('User not found')));
      return bloc;
    },
    act: (bloc) => bloc.add(AuthCheckStatusRequested()),
    expect: () => [
      AuthLoading(),
      AuthUnauthenticated(),
    ],
  );
}