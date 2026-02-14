class Product {
  String id;
  String title;
  String imagePath;
  double price;
  String location;
  int reviewsCount;
  String description;
  bool liked;

  Product({
    required this.id,
    required this.title,
    required this.imagePath,
    required this.price,
    required this.location,
    required this.reviewsCount,
    required this.description,
    required this.liked,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'imagePath': imagePath,
      'price': price,
      'location': location,
      'reviewsCount': reviewsCount,
      'description': description,
      'liked': liked,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      imagePath: map['imagePath'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      location: map['location'] ?? '',
      reviewsCount: map['reviewsCount'] ?? 0,
      description: map['description'] ?? '',
      liked: map['liked'] ?? false,
    );
  }
}


