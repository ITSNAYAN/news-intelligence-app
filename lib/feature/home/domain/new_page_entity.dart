import 'package:news_api_app/feature/home/domain/entity/article_entity.dart';
// this enity we create for the one api call returns two things page which is token and list of data 
// this is helpful for pagination as if it covers first page and when it move to next page it store the 
// page data and move to next page if next page != null we get more news data and appendn new data  to the data 

class NewPageEntity {
  const  NewPageEntity({required this.articles , this.nextPage});
  final List<ArticleEntity> articles ; 
  final String? nextPage ; 
}