import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/i_auth_repository.dart';

class SignUpParams {
  final String email;
  final String password;
  final String? name;
  const SignUpParams({required this.email, required this.password, this.name});
}

class SignUpUseCase implements UseCase<User, SignUpParams> {
  final IAuthRepository repository;
  const SignUpUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(SignUpParams params) {
    return repository.signUp(params.email, params.password, params.name);
  }
}