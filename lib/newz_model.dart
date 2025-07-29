class NewsArticle {
  final String imageUrl;
  final String category;
  final String dev;
  final String timeAgo;
  final String headline;
  final bool isVerified;

  NewsArticle({
    required this.imageUrl,
    required this.category,
    required this.dev,
    required this.timeAgo,
    required this.headline,
    this.isVerified = false,
  });
}