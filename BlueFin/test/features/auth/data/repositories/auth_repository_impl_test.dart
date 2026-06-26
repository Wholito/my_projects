import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:BlueFin/core/errors/exceptions.dart';
import 'package:BlueFin/core/errors/failures.dart';
import 'package:BlueFin/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:BlueFin/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:BlueFin/features/auth/data/models/user_model.dart';
import 'package:BlueFin/features/auth/data/models/token_model.dart';
import 'package:BlueFin/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:BlueFin/features/auth/domain/entities/user.dart';

class MockAuthLocalDataSource extends Mock implements IAuthLocalDataSource {}
class MockAuthRemoteDataSource extends Mock implements IAuthRemoteDataSource {}

void main() {
  late AuthRepositoryImpl repository;
  late MockAuthLocalDataSource mockLocal;
  late MockAuthRemoteDataSource mockRemote;

  final tUserModel = UserModel(id: '1', email: 'test@test.com');
  final tToken = TokenModel(accessToken: 'token', expiresAt: DateTime.now().add(const Duration(days: 30)));
  final tUser = User(id: '1', email: 'test@test.com');

  setUpAll(() {
    registerFallbackValue(tUserModel);
    registerFallbackValue(tToken);
  });

  setUp(() {
    mockLocal = MockAuthLocalDataSource();
    mockRemote = MockAuthRemoteDataSource();
    repository = AuthRepositoryImpl(mockLocal, mockRemote);
  });

  test('getCurrentUser should return User when local data exists', () async {
    when(() => mockLocal.getUser()).thenAnswer((_) async => tUserModel);

    final result = await repository.getCurrentUser();

    expect(result, Right(tUser));
    verify(() => mockLocal.getUser()).called(1);
  });

  test('getCurrentUser should return CacheFailure when no user', () async {
    when(() => mockLocal.getUser()).thenAnswer((_) async => null);

    final result = await repository.getCurrentUser();

    expect(result, Left(CacheFailure('Пользователь не найден')));
    verify(() => mockLocal.getUser()).called(1);
  });

  test('signUp should save user and token', () async {
    when(() => mockRemote.signUp(any(), any(), any()))
        .thenAnswer((_) async => (tUserModel, tToken));
    when(() => mockLocal.saveUserAndToken(any(), any())).thenAnswer((_) async {});
    when(() => mockLocal.saveUserId(any())).thenAnswer((_) async {});

    final result = await repository.signUp('test@test.com', 'pass', 'User');

    expect(result.isRight(), true);
    verify(() => mockLocal.saveUserAndToken(any(), any())).called(1);
    verify(() => mockLocal.saveUserId(any())).called(1);
    verify(() => mockRemote.signUp('test@test.com', 'pass', 'User')).called(1);
  });
}