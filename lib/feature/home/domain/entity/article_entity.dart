// we define this feild in the entity that ui will show this is complty unaware what the api will send 
//from the server thats why use proper null safty and feilds which we show on ui 

class ArticleEntity {
  const ArticleEntity({required this.id , required this.title , this.link,
  this.description,
  this.imageUrl,
  this.sourceName,
  this.pubDate,
  this.publishedAt,
  this.url,
  });
  final String id;
  final String title;
  final String? link;
  final String? description; // nullable: the API may omit it
  final String? imageUrl;
  final String? sourceName;
  final DateTime? pubDate;
  final String? publishedAt;
  final String? url;
}