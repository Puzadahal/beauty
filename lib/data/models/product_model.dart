import 'package:equatable/equatable.dart';

class ProductModel extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? originalPrice;
  final String imageUrl;
  final List<String> imageUrls;
  final String category;
  final String brand;
  final double rating;
  final int reviewCount;
  final int stock;
  final bool isAvailable;
  final bool isFeatured;
  final Map<String, dynamic>? attributes;

  const ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.originalPrice,
    required this.imageUrl,
    this.imageUrls = const [],
    required this.category,
    required this.brand,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.stock = 0,
    this.isAvailable = true,
    this.isFeatured = false,
    this.attributes,
  });

  bool get isOnSale => originalPrice != null && originalPrice! > price;
  double get discountPercentage {
    if (originalPrice == null || originalPrice! <= price) return 0;
    return ((originalPrice! - price) / originalPrice!) * 100;
  }

  ProductModel copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    double? originalPrice,
    String? imageUrl,
    List<String>? imageUrls,
    String? category,
    String? brand,
    double? rating,
    int? reviewCount,
    int? stock,
    bool? isAvailable,
    bool? isFeatured,
    Map<String, dynamic>? attributes,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      imageUrl: imageUrl ?? this.imageUrl,
      imageUrls: imageUrls ?? this.imageUrls,
      category: category ?? this.category,
      brand: brand ?? this.brand,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      stock: stock ?? this.stock,
      isAvailable: isAvailable ?? this.isAvailable,
      isFeatured: isFeatured ?? this.isFeatured,
      attributes: attributes ?? this.attributes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'originalPrice': originalPrice,
      'imageUrl': imageUrl,
      'imageUrls': imageUrls,
      'category': category,
      'brand': brand,
      'rating': rating,
      'reviewCount': reviewCount,
      'stock': stock,
      'isAvailable': isAvailable,
      'isFeatured': isFeatured,
      'attributes': attributes,
    };
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      originalPrice: json['originalPrice'] != null
          ? (json['originalPrice'] as num).toDouble()
          : null,
      imageUrl: json['imageUrl'] as String,
      imageUrls: json['imageUrls'] != null
          ? List<String>.from(json['imageUrls'] as List)
          : [],
      category: json['category'] as String,
      brand: json['brand'] as String,
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : 0.0,
      reviewCount: json['reviewCount'] != null ? json['reviewCount'] as int : 0,
      stock: json['stock'] != null ? json['stock'] as int : 0,
      isAvailable: json['isAvailable'] != null ? json['isAvailable'] as bool : true,
      isFeatured: json['isFeatured'] != null ? json['isFeatured'] as bool : false,
      attributes: json['attributes'] as Map<String, dynamic>?,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        price,
        originalPrice,
        imageUrl,
        imageUrls,
        category,
        brand,
        rating,
        reviewCount,
        stock,
        isAvailable,
        isFeatured,
        attributes,
      ];
}

