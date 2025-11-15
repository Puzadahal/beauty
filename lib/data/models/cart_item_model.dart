import 'package:equatable/equatable.dart';
import 'product_model.dart';

class CartItemModel extends Equatable {
  final String id;
  final ProductModel product;
  final int quantity;
  final String? selectedSize;
  final String? selectedColor;
  final bool isSelected;

  const CartItemModel({
    required this.id,
    required this.product,
    required this.quantity,
    this.selectedSize,
    this.selectedColor,
    this.isSelected = false,
  });

  double get totalPrice => product.price * quantity;

  CartItemModel copyWith({
    String? id,
    ProductModel? product,
    int? quantity,
    String? selectedSize,
    String? selectedColor,
    bool? isSelected,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      selectedSize: selectedSize ?? this.selectedSize,
      selectedColor: selectedColor ?? this.selectedColor,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product': product.toJson(),
      'quantity': quantity,
      'selectedSize': selectedSize,
      'selectedColor': selectedColor,
      'isSelected': isSelected,
    };
  }

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'] as String,
      product: ProductModel.fromJson(json['product'] as Map<String, dynamic>),
      quantity: json['quantity'] as int,
      selectedSize: json['selectedSize'] as String?,
      selectedColor: json['selectedColor'] as String?,
      isSelected: json['isSelected'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [id, product, quantity, selectedSize, selectedColor, isSelected];
}

