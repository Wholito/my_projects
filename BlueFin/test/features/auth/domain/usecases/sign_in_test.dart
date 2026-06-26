import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:BlueFin/core/errors/failures.dart';
import 'package:BlueFin/features/auth/domain/entities/user.dart';
import 'package:BlueFin/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:BlueFin/features/auth/domain/usecases/sign_in.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late SignInUseCase useCase;
  late MockAuthRepository mockRepo;

  setUp(() {
    mockRepo = MockAuthRepository();
    useCase = SignInUseCase(mockRepo);
  });

  const tUser = User(id: '1', email: 'test@test.com');
  const tParams = SignInParams(email: 'test@test.com', password: 'pass');

  test('should return User when sign in success', () async {
    when(() => mockRepo.signIn(any(), any()))
        .thenAnswer((_) async => const Right(tUser));

    final result = await useCase(tParams);

    expect(result, const Right(tUser));
    verify(() => mockRepo.signIn('test@test.com', 'pass')).called(1);
  });

  test('should return ServerFailure when sign in fails', () async {
    const failure = ServerFailure('Invalid credentials');
    when(() => mockRepo.signIn(any(), any()))
        .thenAnswer((_) async => const Left(failure));

    final result = await useCase(tParams);

    expect(result, const Left(failure));
    verify(() => mockRepo.signIn('test@test.com', 'pass')).called(1);
  });
}