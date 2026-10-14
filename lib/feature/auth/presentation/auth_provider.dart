import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:news_api_app/feature/auth/data/auth_data_source.dart';
import 'package:news_api_app/feature/auth/data/auth_data_source_impl.dart';
import 'package:news_api_app/feature/auth/data/user_data_repo_impl.dart';
import 'package:news_api_app/feature/auth/domain/user_data_repo.dart';

// Overridden in main.dart with the opened box.
final authBoxProvider = Provider<Box<String>>(
  (ref) => throw UnimplementedError('Override authBoxProvider in main()'),
);

final authDataSourceProvider = Provider<AuthDataSource>(
  (ref) => AuthDataSourceImpl(ref.watch(authBoxProvider)),
);

// Typed as the ABSTRACT repo,
final userDataRepoProvider = Provider<UserDataRepo>(
  (ref) => UserDataRepoImpl(ref.watch(authDataSourceProvider)),
);