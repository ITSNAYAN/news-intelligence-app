import 'package:news_api_app/feature/auth/data/auth_data_model.dart';

abstract class AuthDataSource {
  Future<void> saveUser(AuthDataModel user) ;
   AuthDataModel? getUserData();
   Future<void> clearUser();
}