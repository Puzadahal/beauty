import '../models/product_model.dart';
import '../models/order_model.dart';

class ApiService {
  static const String baseUrl = 'https://api.beautycosmetics.com/api/v1';
  
  // Mock API - In production, replace with actual API endpoints
  static const String mockBaseUrl = 'http://localhost:3000/api';

  // Products
  Future<List<ProductModel>> getProducts({
    String? category,
    String? search,
    bool? featured,
  }) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Mock data - In production, replace with actual API call
    return _mockProducts.where((product) {
      if (category != null && product.category != category) return false;
      if (search != null && !product.name.toLowerCase().contains(search.toLowerCase())) return false;
      if (featured != null && product.isFeatured != featured) return false;
      return true;
    }).toList();
  }

  Future<ProductModel?> getProductById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _mockProducts.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<List<String>> getCategories() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _mockProducts.map((p) => p.category).toSet().toList();
  }

  // Orders
  Future<List<OrderModel>> getOrders(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockOrders.where((order) => order.userId == userId).toList();
  }

  Future<OrderModel?> createOrder(OrderModel order) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return order.copyWith(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      createdAt: DateTime.now(),
    );
  }

  Future<OrderModel?> updateOrderStatus(String orderId, OrderStatus status) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final order = _mockOrders.firstWhere((o) => o.id == orderId);
    return order.copyWith(
      status: status,
      updatedAt: DateTime.now(),
    );
  }

  // Admin - Products
  Future<ProductModel> createProduct(ProductModel product) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return product;
  }

  Future<ProductModel> updateProduct(ProductModel product) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return product;
  }

  Future<bool> deleteProduct(String id) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return true;
  }

  // Mock Data
  static final List<ProductModel> _mockProducts = [
    ProductModel(
      id: '1',
      name: 'Rose Gold Lipstick',
      description: 'Long-lasting matte lipstick with a smooth finish. Perfect for everyday wear.',
      price: 29.99,
      originalPrice: 39.99,
      imageUrl: 'https://images.unsplash.com/photo-1586495777744-4413f21062fa?w=400',
      category: 'Makeup',
      brand: 'Beauty Luxe',
      rating: 4.5,
      reviewCount: 128,
      stock: 50,
      isAvailable: true,
      isFeatured: true,
    ),
    ProductModel(
      id: '2',
      name: 'Hydrating Face Serum',
      description: 'Intensive hydrating serum with hyaluronic acid for glowing skin.',
      price: 45.99,
      imageUrl: 'https://images.unsplash.com/photo-1620916566398-39f1143ab7be?w=400',
      category: 'Skincare',
      brand: 'Glow Care',
      rating: 4.8,
      reviewCount: 256,
      stock: 30,
      isAvailable: true,
      isFeatured: true,
    ),
    ProductModel(
      id: '3',
      name: 'Volume Mascara',
      description: 'Lengthening and volumizing mascara for dramatic lashes.',
      price: 24.99,
      originalPrice: 34.99,
      imageUrl: 'https://images.unsplash.com/photo-1631217868264-e5b90bb7e133?w=400',
      category: 'Makeup',
      brand: 'Lash Pro',
      rating: 4.3,
      reviewCount: 89,
      stock: 75,
      isAvailable: true,
      isFeatured: false,
    ),
    ProductModel(
      id: '4',
      name: 'Vitamin C Brightening Cream',
      description: 'Brightening face cream with vitamin C for even skin tone.',
      price: 39.99,
      imageUrl: 'https://images.unsplash.com/photo-1612817288484-6f916006741a?w=400',
      category: 'Skincare',
      brand: 'Bright Skin',
      rating: 4.6,
      reviewCount: 192,
      stock: 40,
      isAvailable: true,
      isFeatured: true,
    ),
    ProductModel(
      id: '5',
      name: 'Eyeshadow Palette',
      description: '12-color eyeshadow palette with matte and shimmer finishes.',
      price: 54.99,
      originalPrice: 69.99,
      imageUrl: 'https://images.unsplash.com/photo-1512496015851-a90fb38ba796?w=400',
      category: 'Makeup',
      brand: 'Color Pop',
      rating: 4.7,
      reviewCount: 312,
      stock: 25,
      isAvailable: true,
      isFeatured: true,
    ),
    ProductModel(
      id: '6',
      name: 'Sunscreen SPF 50',
      description: 'Broad spectrum sunscreen for daily protection.',
      price: 32.99,
      imageUrl: 'https://images.unsplash.com/photo-1556228578-7c8f27ec3c1b?w=400',
      category: 'Skincare',
      brand: 'Sun Shield',
      rating: 4.4,
      reviewCount: 167,
      stock: 60,
      isAvailable: true,
      isFeatured: false,
    ),
    ProductModel(
      id: '7',
      name: 'Nail Polish Set',
      description: 'Set of 6 long-lasting nail polishes in trending colors.',
      price: 19.99,
      originalPrice: 29.99,
      imageUrl: 'https://images.unsplash.com/photo-1604654894610-df63bc536371?w=400',
      category: 'Nails',
      brand: 'Nail Art',
      rating: 4.2,
      reviewCount: 94,
      stock: 45,
      isAvailable: true,
      isFeatured: false,
    ),
    ProductModel(
      id: '8',
      name: 'Facial Cleanser',
      description: 'Gentle foaming cleanser for all skin types.',
      price: 22.99,
      imageUrl: 'https://images.unsplash.com/photo-1620916566398-39f1143ab7be?w=400',
      category: 'Skincare',
      brand: 'Pure Care',
      rating: 4.5,
      reviewCount: 203,
      stock: 80,
      isAvailable: true,
      isFeatured: false,
    ),
    ProductModel(
      id: '9',
      name: 'Matte Foundation',
      description: 'Full coverage matte foundation for all-day wear.',
      price: 42.99,
      originalPrice: 52.99,
      imageUrl: 'https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9?w=400',
      category: 'Makeup',
      brand: 'Flawless Base',
      rating: 4.6,
      reviewCount: 445,
      stock: 35,
      isAvailable: true,
      isFeatured: true,
    ),
    ProductModel(
      id: '10',
      name: 'Retinol Night Serum',
      description: 'Anti-aging serum with retinol for smoother skin.',
      price: 59.99,
      imageUrl: 'https://images.unsplash.com/photo-1620916566398-39f1143ab7be?w=400',
      category: 'Skincare',
      brand: 'Age Defy',
      rating: 4.7,
      reviewCount: 328,
      stock: 28,
      isAvailable: true,
      isFeatured: true,
    ),
    ProductModel(
      id: '11',
      name: 'Blush Palette',
      description: '6-shade blush palette for natural to bold looks.',
      price: 34.99,
      originalPrice: 44.99,
      imageUrl: 'https://images.unsplash.com/photo-1512496015851-a90fb38ba796?w=400',
      category: 'Makeup',
      brand: 'Cheek Charm',
      rating: 4.4,
      reviewCount: 189,
      stock: 42,
      isAvailable: true,
      isFeatured: false,
    ),
    ProductModel(
      id: '12',
      name: 'Moisturizing Face Mask',
      description: 'Hydrating face mask with aloe vera and hyaluronic acid.',
      price: 28.99,
      imageUrl: 'https://images.unsplash.com/photo-1612817288484-6f916006741a?w=400',
      category: 'Skincare',
      brand: 'Hydrate Plus',
      rating: 4.5,
      reviewCount: 267,
      stock: 55,
      isAvailable: true,
      isFeatured: false,
    ),
    ProductModel(
      id: '13',
      name: 'Eyeliner Set',
      description: 'Set of 3 waterproof eyeliners in black, brown, and navy.',
      price: 27.99,
      originalPrice: 37.99,
      imageUrl: 'https://images.unsplash.com/photo-1631217868264-e5b90bb7e133?w=400',
      category: 'Makeup',
      brand: 'Line Perfect',
      rating: 4.3,
      reviewCount: 156,
      stock: 68,
      isAvailable: true,
      isFeatured: false,
    ),
    ProductModel(
      id: '14',
      name: 'Toner with Rose Water',
      description: 'Refreshing toner with rose water for balanced skin.',
      price: 24.99,
      imageUrl: 'https://images.unsplash.com/photo-1620916566398-39f1143ab7be?w=400',
      category: 'Skincare',
      brand: 'Rose Essence',
      rating: 4.6,
      reviewCount: 298,
      stock: 47,
      isAvailable: true,
      isFeatured: true,
    ),
    ProductModel(
      id: '15',
      name: 'Concealer Stick',
      description: 'Full coverage concealer for dark circles and blemishes.',
      price: 21.99,
      imageUrl: 'https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9?w=400',
      category: 'Makeup',
      brand: 'Cover Up',
      rating: 4.5,
      reviewCount: 412,
      stock: 38,
      isAvailable: true,
      isFeatured: false,
    ),
    ProductModel(
      id: '16',
      name: 'Face Oil Blend',
      description: 'Nourishing face oil with argan and jojoba oils.',
      price: 49.99,
      imageUrl: 'https://images.unsplash.com/photo-1612817288484-6f916006741a?w=400',
      category: 'Skincare',
      brand: 'Nature Glow',
      rating: 4.8,
      reviewCount: 521,
      stock: 33,
      isAvailable: true,
      isFeatured: true,
    ),
    ProductModel(
      id: '17',
      name: 'Highlighter Palette',
      description: '3-shade highlighter palette for glowing complexion.',
      price: 38.99,
      originalPrice: 48.99,
      imageUrl: 'https://images.unsplash.com/photo-1512496015851-a90fb38ba796?w=400',
      category: 'Makeup',
      brand: 'Glow Up',
      rating: 4.7,
      reviewCount: 234,
      stock: 29,
      isAvailable: true,
      isFeatured: true,
    ),
    ProductModel(
      id: '18',
      name: 'Exfoliating Scrub',
      description: 'Gentle exfoliating scrub with natural ingredients.',
      price: 26.99,
      imageUrl: 'https://images.unsplash.com/photo-1620916566398-39f1143ab7be?w=400',
      category: 'Skincare',
      brand: 'Smooth Skin',
      rating: 4.4,
      reviewCount: 187,
      stock: 52,
      isAvailable: true,
      isFeatured: false,
    ),
    ProductModel(
      id: '19',
      name: 'Brow Pencil & Gel Set',
      description: 'Complete brow kit with pencil and clear gel.',
      price: 23.99,
      imageUrl: 'https://images.unsplash.com/photo-1631217868264-e5b90bb7e133?w=400',
      category: 'Makeup',
      brand: 'Brow Pro',
      rating: 4.6,
      reviewCount: 345,
      stock: 44,
      isAvailable: true,
      isFeatured: false,
    ),
    ProductModel(
      id: '20',
      name: 'Eye Cream',
      description: 'Anti-aging eye cream to reduce fine lines and dark circles.',
      price: 44.99,
      imageUrl: 'https://images.unsplash.com/photo-1612817288484-6f916006741a?w=400',
      category: 'Skincare',
      brand: 'Eye Care Pro',
      rating: 4.7,
      reviewCount: 389,
      stock: 31,
      isAvailable: true,
      isFeatured: true,
    ),
  ];

  static final List<OrderModel> _mockOrders = [];
}

