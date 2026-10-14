import 'package:news_api_app/core/error.dart';
import 'package:news_api_app/feature/auth/data/auth_data_model.dart';
import 'package:news_api_app/feature/auth/data/auth_data_source.dart';
import 'package:news_api_app/feature/auth/domain/user_data_entity.dart';
import 'package:news_api_app/feature/auth/domain/user_data_repo.dart';

class UserDataRepoImpl implements UserDataRepo{
  UserDataRepoImpl(this._localDb);
     final AuthDataSource _localDb ; 

     static final _correctEmail = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
      

      // this function use when user login to the account 
      @override
    Future<UserEntity>login({required String email , required String password}) async {
      // implement this network delay so the loading state is visible in the UI.
    await Future<void>.delayed(const Duration(seconds: 1));

    final trimmedEmail = email.trim();
    if (!_correctEmail.hasMatch(trimmedEmail)) {
      throw const AuthFailure('Please enter a valid email address.');
    }
    if (password.length < 6) {
      throw const AuthFailure('Password must be at least 6 characters.');
    }
     final model = AuthDataModel(
      // we put hashCode is here to hashing the id ;
      id: trimmedEmail.hashCode.toString(),
      email: trimmedEmail,
      name: trimmedEmail.split('@').first,
    );
     try{
         await _localDb.saveUser(model);
     }catch(_) {
      throw const CacheFailure();
     }

     return model.toEntity();
     }

     // get user data 
     @override
     Future<UserEntity?> getCurrentUser() async{
      try{
        return _localDb.getUserData()?.toEntity();
      }catch(_){
        throw const CacheFailure();
      }
     }

     // clear User Data 
      @override
      Future<void> onLogout() async{
      try{
        return _localDb.clearUser();
      }catch(_){
        throw const CacheFailure();
      }
     }
}