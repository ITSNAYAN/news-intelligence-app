import 'package:news_api_app/feature/home/domain/entity/article_entity.dart';

class ArticleDataModel {
  ArticleDataModel({
    required this.id , 
    required this.title,
    required this.link ,
    this.description,
    this. imageUrl,
    this.sourceName,
    this.pubDate,
  
  });
  final String id;
  final String title;
  final String link;
  final String? description; // nullable: the API may sometimes give null 
  final String? imageUrl;
  final String? sourceName;
  final String? pubDate;

  factory ArticleDataModel.fromJson (Map<String,dynamic>json) => ArticleDataModel(
        id: json['article_id'] as String? ?? '',
        title: json['title'] as String? ?? 'Untitled',
        link: json['link'] as String? ?? '',
        description: json['description'] as String?,
        imageUrl: json['image_url'] as String?,
        sourceName: json['source_name'] as String?,
        pubDate: json['pubDate'] as String?,
     );


   
   //we create this entity which act as a bridge between artical entity and artical model 
   //so the api response is not dependent on the ui feilds which we take from artical entity 


   ArticleEntity toEntity() => ArticleEntity(
    id: id,
     title: title, 
     link: link,
      description: description,

     imageUrl: imageUrl,
      sourceName: sourceName,
       pubDate: pubDate==null ?null :DateTime.tryParse('${pubDate}Z'),
       publishedAt: pubDate, 
       url: link,
     );
    

}