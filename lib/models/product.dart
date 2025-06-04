class Product {
  final int? id;
  final String name;
  final String? description;
  final double price;
  final String category;
  final bool available;
  final String? imageUrl;

  Product({
    this.id,
    required this.name,
    this.description,
    required this.price,
    required this.category,
    this.available = true,
    this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'available': available ? 1 : 0,
      'image_url': imageUrl,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      price: map['price'].toDouble(),
      category: map['category'],
      available: map['available'] == 1,
      imageUrl: map['image_url'],
    );
  }
}