import 'package:auth_flow_app/core/network/supabase/auth_client.dart';
import 'package:auth_flow_app/core/network/supabase/auth_client_impl.dart';
import 'package:auth_flow_app/features/auth/data/datasources/email_auth_datasource.dart';
import 'package:auth_flow_app/features/auth/data/datasources/email_auth_datasource_impl.dart';
import 'package:auth_flow_app/features/auth/data/datasources/phone_auth_datasource.dart';
import 'package:auth_flow_app/features/auth/data/datasources/phone_auth_datasource_impl.dart';
import 'package:auth_flow_app/features/auth/data/datasources/session_datasource.dart';
import 'package:auth_flow_app/features/auth/data/datasources/session_datasource_impl.dart';
import 'package:auth_flow_app/features/auth/data/datasources/social_auth_datasource.dart';
import 'package:auth_flow_app/features/auth/data/datasources/social_auth_datasource_impl.dart';
import 'package:auth_flow_app/features/auth/data/repositories/email_auth_repository_impl.dart';
import 'package:auth_flow_app/features/auth/data/repositories/phone_auth_repository_impl.dart';
import 'package:auth_flow_app/features/auth/data/repositories/profile_repository_impl.dart';
import 'package:auth_flow_app/features/auth/data/repositories/session_repository_impl.dart';
import 'package:auth_flow_app/features/auth/data/repositories/social_auth_repository_impl.dart';
import 'package:auth_flow_app/features/auth/domain/repositories/email_auth_repository.dart';
import 'package:auth_flow_app/features/auth/domain/repositories/phone_auth_repository.dart';
import 'package:auth_flow_app/features/auth/domain/repositories/profile_repository.dart';
import 'package:auth_flow_app/features/auth/domain/repositories/session_repository.dart';
import 'package:auth_flow_app/features/auth/domain/repositories/social_auth_repository.dart';
import 'package:auth_flow_app/features/auth/presentation/bloc/email_auth/email_auth_bloc.dart';
import 'package:auth_flow_app/features/auth/presentation/bloc/phone_auth/phone_auth_bloc.dart';
import 'package:auth_flow_app/features/auth/presentation/bloc/profile/profile_bloc.dart';
import 'package:auth_flow_app/features/auth/presentation/bloc/session/session_bloc.dart';
import 'package:auth_flow_app/features/auth/presentation/bloc/social_auth/social_auth_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final sl = GetIt.instance;

  Future<void> initDependencies() async {
  sl.registerLazySingleton<AuthClient>(
    () => AuthClientImpl(Supabase.instance.client.auth),
  );

  sl.registerLazySingleton<EmailAuthDataSource>(() => EmailAuthDataSourceImpl(sl()));
  sl.registerLazySingleton<SocialAuthDataSource>(() => SocialAuthDataSourceImpl(sl()));
  sl.registerLazySingleton<PhoneAuthDataSource>(() => PhoneAuthDataSourceImpl(sl()));
  sl.registerLazySingleton<SessionDataSource>(() => SessionDataSourceImpl(sl()));

  sl.registerLazySingleton<EmailAuthRepository>(
    () => EmailAuthRepositoryImpl(emailAuthDataSource: sl()),
  );
  sl.registerLazySingleton<SocialAuthRepository>(
    () => SocialAuthRepositoryImpl(socialAuthDataSource: sl()),
  );
  sl.registerLazySingleton<PhoneAuthRepository>(
    () => PhoneAuthRepositoryImpl(phoneAuthDataSource: sl()),
  );
  sl.registerLazySingleton<SessionRepository>(
    () => SessionRepositoryImpl(sessionDataSource: sl()),
  );
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(profileDataSource: sl()),
  );

  sl.registerFactory(() => EmailAuthBloc(emailAuthRepository: sl()));
  sl.registerFactory(() => SocialAuthBloc(socialAuthRepository: sl()));
  sl.registerFactory(() => PhoneAuthBloc(phoneAuthRepository: sl()));
  sl.registerFactory(() => SessionBloc(sessionRepository: sl()));
  sl.registerFactory(() => ProfileBloc(profileRepository: sl()));
}
