import 'package:mockito/annotations.dart';
import 'package:sahabi_guide/features/auth/data/datasources/passport_auth_local_data_source.dart';
import 'package:sahabi_guide/features/auth/data/datasources/passport_auth_remote_data_source.dart';
import 'package:sahabi_guide/features/auth/data/repositories/passport_auth_repository_impl.dart';

@GenerateMocks([
  PassportAuthRepository,
  PassportAuthRemoteDataSource,
  PassportAuthLocalDataSource,
])
void main() {}
