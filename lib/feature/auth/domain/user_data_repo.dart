import 'package:news_api_app/feature/auth/domain/user_data_entity.dart';

abstract class UserDataRepo {
   // we make the abstract class so we can follow proper oops structure 

   Future<UserEntity> login ({required String email , required String password});
   Future<UserEntity?> getCurrentUser();
   Future<void> onLogout();
   
}