import 'package:news_api_app/feature/auth/domain/user_data_entity.dart';

class AuthDataModel {
        const AuthDataModel({required this.id, required this.email , required this.name});
        final String id ; 
        final String  email ; 
        final String name; 
   // factory constructor is used to handle api correctly 
   factory AuthDataModel.fromJson(Map<String, dynamic > json ) =>AuthDataModel(
    id:  json['id'] as String ,
    email: json['email'] as String ,
    name: json['name'] as String,
   );
       
   Map<String ,dynamic> toJson() =>{'id' : id , 'email': email ,'name': name } ;

  // we use this as data comming from the backend serever  so to map the entity from the server we write this 

   UserEntity toEntity() => UserEntity(email:email , id: id , name: name );
   factory AuthDataModel.fromEntity (UserEntity entity) => 
   AuthDataModel(id: entity.id, email: entity.email, name: entity.name);
}