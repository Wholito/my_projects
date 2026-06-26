import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user.dart';

abstract class IAuthRepository {
  Future<Either<Failure, User>> signIn(String email, String password);
  Future<Either<Failure, User>> signUp(String email, String password, String? name);
  Future<Either<Failure, User>> getCurrentUser();
  Future<Either<Failure, void>> signOut();
}