import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/cart_item_model.dart';
import '../models/order_model.dart';
import '../models/product_model.dart';

class ApiService {
  ApiService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const String productsCollection = 'products';
  static const String ordersCollection = 'orders';

  CollectionReference<Map<String, dynamic>> get _productsRef =>
      _firestore.collection(productsCollection);

  CollectionReference<Map<String, dynamic>> get _ordersRef =>
      _firestore.collection(ordersCollection);

  Future<List<ProductModel>> getProducts({
    String? category,
    String? search,
    bool? featured,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _productsRef;

      if (category != null && category.isNotEmpty) {
        query = query.where('category', isEqualTo: category);
      }
      if (featured != null) {
        query = query.where('isFeatured', isEqualTo: featured);
      }

      final snapshot = await query.get();

      var products = snapshot.docs.map(_productFromSnapshot).toList();

      if (search != null && search.isNotEmpty) {
        final lowerQuery = search.toLowerCase();
        products = products
            .where(
              (product) =>
                  product.name.toLowerCase().contains(lowerQuery) ||
                  product.description.toLowerCase().contains(lowerQuery),
            )
            .toList();
      }

      if (products.isEmpty) {
        return _mockProducts;
      }

      return products;
    } catch (_) {
      return _mockProducts;
    }
  }

  Future<ProductModel?> getProductById(String id) async {
    try {
      final doc = await _productsRef.doc(id).get();
      if (doc.exists) {
        return _productFromSnapshot(doc);
      }
    } catch (_) {
      // Fall through to mock fallback
    }

    try {
      return _mockProducts.firstWhere((product) => product.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<List<String>> getCategories() async {
    try {
      final snapshot = await _productsRef.get();
      if (snapshot.docs.isEmpty) {
        return _mockProducts
            .map((product) => product.category)
            .toSet()
            .toList();
      }
      return snapshot.docs
          .map((doc) => doc.data()['category'] as String?)
          .whereType<String>()
          .toSet()
          .toList();
    } catch (_) {
      return _mockProducts.map((product) => product.category).toSet().toList();
    }
  }

  Future<List<OrderModel>> getOrders(String userId) async {
    try {
      final snapshot = await _ordersRef
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      if (snapshot.docs.isEmpty) {
        return [];
      }

      return snapshot.docs.map(_orderFromSnapshot).toList();
    } catch (_) {
      return [];
    }
  }

  Future<OrderModel?> createOrder(OrderModel order) async {
    try {
      final docRef = order.id.isEmpty
          ? _ordersRef.doc()
          : _ordersRef.doc(order.id);
      final orderId = docRef.id;
      final orderToSave = order.copyWith(
        id: orderId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await docRef.set(_orderToFirestore(orderToSave));
      return orderToSave;
    } catch (_) {
      return null;
    }
  }

  Future<OrderModel?> updateOrderStatus(
    String orderId,
    OrderStatus status,
  ) async {
    try {
      await _ordersRef.doc(orderId).update({
        'status': status.name,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      final updatedDoc = await _ordersRef.doc(orderId).get();
      if (!updatedDoc.exists) return null;
      return _orderFromSnapshot(updatedDoc);
    } catch (_) {
      return null;
    }
  }

  ProductModel _productFromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? <String, dynamic>{};
    final imageUrlsDynamic = data['imageUrls'];
    final imageUrls = imageUrlsDynamic is List
        ? imageUrlsDynamic.map((value) => value.toString()).toList()
        : <String>[];

    return ProductModel.fromJson({
      'id': data['id'] ?? snapshot.id,
      'name': data['name'] ?? '',
      'description': data['description'] ?? '',
      'price': (data['price'] is num) ? (data['price'] as num).toDouble() : 0.0,
      'originalPrice': (data['originalPrice'] is num)
          ? (data['originalPrice'] as num).toDouble()
          : null,
      'imageUrl': data['imageUrl'] ?? '',
      'imageUrls': imageUrls,
      'category': data['category'] ?? 'Uncategorized',
      'brand': data['brand'] ?? 'Unknown',
      'rating': (data['rating'] is num)
          ? (data['rating'] as num).toDouble()
          : 0.0,
      'reviewCount': (data['reviewCount'] is num)
          ? (data['reviewCount'] as num).toInt()
          : 0,
      'stock': (data['stock'] is num) ? (data['stock'] as num).toInt() : 0,
      'isAvailable': data['isAvailable'] is bool
          ? data['isAvailable'] as bool
          : true,
      'isFeatured': data['isFeatured'] is bool
          ? data['isFeatured'] as bool
          : false,
      'attributes': data['attributes'] as Map<String, dynamic>?,
    });
  }

  OrderModel _orderFromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? <String, dynamic>{};

    final createdAtValue = data['createdAt'];
    final updatedAtValue = data['updatedAt'];

    DateTime createdAt = DateTime.now();
    if (createdAtValue is Timestamp) {
      createdAt = createdAtValue.toDate();
    }

    DateTime? updatedAt;
    if (updatedAtValue is Timestamp) {
      updatedAt = updatedAtValue.toDate();
    }

    final items = (data['items'] as List<dynamic>? ?? [])
        .map(
          (item) =>
              CartItemModel.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();

    final shippingAddressData = data['shippingAddress'];
    final shippingAddressMap = shippingAddressData is Map
        ? Map<String, dynamic>.from(shippingAddressData as Map)
        : <String, dynamic>{
            'fullName': '',
            'phone': '',
            'email': '',
            'addressLine1': '',
            'addressLine2': '',
            'city': '',
            'state': '',
            'zipCode': '',
            'country': '',
          };

    return OrderModel(
      id: data['id'] ?? snapshot.id,
      userId: data['userId'] as String? ?? '',
      items: items,
      subtotal: (data['subtotal'] ?? 0).toDouble(),
      shippingCost: (data['shippingCost'] ?? 0).toDouble(),
      tax: (data['tax'] ?? 0).toDouble(),
      total: (data['total'] ?? 0).toDouble(),
      status: OrderStatus.values.firstWhere(
        (status) => status.name == data['status'],
        orElse: () => OrderStatus.pending,
      ),
      paymentMethod: PaymentMethod.values.firstWhere(
        (method) => method.name == data['paymentMethod'],
        orElse: () => PaymentMethod.stripe,
      ),
      paymentStatus: PaymentStatus.values.firstWhere(
        (paymentStatus) => paymentStatus.name == data['paymentStatus'],
        orElse: () => PaymentStatus.pending,
      ),
      createdAt: createdAt,
      updatedAt: updatedAt,
      shippingAddress: ShippingAddress.fromJson(shippingAddressMap),
      trackingNumber: data['trackingNumber'] as String?,
      notes: data['notes'] as String?,
    );
  }

  Map<String, dynamic> _orderToFirestore(OrderModel order) {
    return {
      'id': order.id,
      'userId': order.userId,
      'items': order.items.map((item) => item.toJson()).toList(),
      'subtotal': order.subtotal,
      'shippingCost': order.shippingCost,
      'tax': order.tax,
      'total': order.total,
      'status': order.status.name,
      'paymentMethod': order.paymentMethod.name,
      'paymentStatus': order.paymentStatus.name,
      'createdAt': Timestamp.fromDate(order.createdAt),
      'updatedAt': order.updatedAt != null
          ? Timestamp.fromDate(order.updatedAt!)
          : Timestamp.fromDate(order.createdAt),
      'shippingAddress': order.shippingAddress.toJson(),
      'trackingNumber': order.trackingNumber,
      'notes': order.notes,
    };
  }

  // Mock Data fallback
  static final List<ProductModel> _mockProducts = [
    ProductModel(
      id: '1',
      name: 'The Liquid Matte Lipstick',
      description:
          'Long-lasting matte lipstick with a smooth finish. Perfect for everyday wear.',
      price: 29.99,
      originalPrice: 39.99,
      imageUrl:
          'https://images.unsplash.com/photo-1760860992755-c432351d47e9?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&q=80&w=880',
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
      description:
          'Intensive hydrating serum with hyaluronic acid for glowing skin.',
      price: 45.99,
      imageUrl:
          'https://images.unsplash.com/photo-1620916566398-39f1143ab7be?w=400',
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
      imageUrl:
          'https://www.muastore.co.uk/cdn/shop/files/Mascara-Volume-Lid-OFF---2024.jpg?v=1740471997',
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
      imageUrl:
          'https://images.unsplash.com/photo-1612817288484-6f916006741a?w=400',
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
      description:
          '12-color eyeshadow palette with matte and shimmer finishes.',
      price: 54.99,
      originalPrice: 69.99,
      imageUrl:
          'https://images.unsplash.com/photo-1512496015851-a90fb38ba796?w=400',
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
      imageUrl:
          'https://www.jiomart.com/images/product/original/492519488/cetaphil-sun-spf-50-high-protection-light-gel-50-ml-product-images-o492519488-p591211859-0-202205180431.jpg?im=Resize=(420,420)',
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
      imageUrl:
          'https://images.unsplash.com/photo-1604654894610-df63bc536371?w=400',
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
      imageUrl:
          'https://images.unsplash.com/photo-1620916566398-39f1143ab7be?w=400',
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
      imageUrl:
          'https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9?w=400',
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
      imageUrl:
          'https://images.unsplash.com/photo-1620916566398-39f1143ab7be?w=400',
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
      imageUrl:
          'https://images.unsplash.com/photo-1512496015851-a90fb38ba796?w=400',
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
      imageUrl:
          'https://images.unsplash.com/photo-1612817288484-6f916006741a?w=400',
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
      imageUrl:
          'https://images-cdn.ubuy.co.in/663dc1b2459b0b02e61e89f7-cosprof-liquid-eyeliner-stamp-waterproof.jpg',
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
      imageUrl:
          'https://images.unsplash.com/photo-1620916566398-39f1143ab7be?w=400',
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
      imageUrl:
          'https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9?w=400',
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
      imageUrl:
          'https://images.unsplash.com/photo-1612817288484-6f916006741a?w=400',
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
      imageUrl:
          'https://images.unsplash.com/photo-1512496015851-a90fb38ba796?w=400',
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
      imageUrl:
          'https://images.unsplash.com/photo-1620916566398-39f1143ab7be?w=400',
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
      imageUrl:
          'https://beautyscout.ph/wp-content/uploads/2021/11/Brow-Wow-Duo_Taupe.jpg',
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
      description:
          'Anti-aging eye cream to reduce fine lines and dark circles.',
      price: 44.99,
      imageUrl:
          'https://images.unsplash.com/photo-1612817288484-6f916006741a?w=400',
      category: 'Skincare',
      brand: 'Eye Care Pro',
      rating: 4.7,
      reviewCount: 389,
      stock: 31,
      isAvailable: true,
      isFeatured: true,
    ),
    ProductModel(
      id: '21',
      name: 'Glycolic Acid Toner',
      description:
          'Exfoliating toner with glycolic acid for clearer, smoother skin.',
      price: 28.99,
      imageUrl:
          'https://images.unsplash.com/photo-1556229010-703cf3f5ee2a?w=400',
      category: 'Skincare',
      brand: 'Glow Care',
      rating: 4.6,
      reviewCount: 245,
      stock: 50,
      isAvailable: true,
      isFeatured: false,
    ),
    ProductModel(
      id: '22',
      name: 'Niacinamide Serum',
      description:
          'Pore-minimizing serum with niacinamide for refined skin texture.',
      price: 36.99,
      imageUrl:
          'https://images.unsplash.com/photo-1556228578-7c8f27ec3c1b?w=400',
      category: 'Skincare',
      brand: 'Bright Skin',
      rating: 4.8,
      reviewCount: 412,
      stock: 38,
      isAvailable: true,
      isFeatured: true,
    ),
    ProductModel(
      id: '23',
      name: 'Peptide Moisturizer',
      description:
          'Anti-aging moisturizer with peptides for firmer, younger-looking skin.',
      price: 52.99,
      imageUrl:
          'https://images.unsplash.com/photo-1612817288484-6f916006741a?w=400',
      category: 'Skincare',
      brand: 'Age Defy',
      rating: 4.7,
      reviewCount: 356,
      stock: 29,
      isAvailable: true,
      isFeatured: true,
    ),
    ProductModel(
      id: '24',
      name: 'Clay Face Mask',
      description:
          'Deep cleansing clay mask to unclog pores and remove impurities.',
      price: 24.99,
      imageUrl:
          'https://images.unsplash.com/photo-1556228578-7c8f27ec3c1b?w=400',
      category: 'Skincare',
      brand: 'Pure Care',
      rating: 4.5,
      reviewCount: 278,
      stock: 62,
      isAvailable: true,
      isFeatured: false,
    ),
    ProductModel(
      id: '25',
      name: 'Hyaluronic Acid Essence',
      description:
          'Intensive hydrating essence with hyaluronic acid for plump skin.',
      price: 34.99,
      imageUrl:
          'https://images.unsplash.com/photo-1612817288484-6f916006741a?w=400',
      category: 'Skincare',
      brand: 'Glow Care',
      rating: 4.9,
      reviewCount: 523,
      stock: 41,
      isAvailable: true,
      isFeatured: true,
    ),
    ProductModel(
      id: '26',
      name: 'Collagen Boost Cream',
      description:
          'Firming cream with collagen peptides for lifted, youthful skin.',
      price: 48.99,
      originalPrice: 58.99,
      imageUrl:
          'https://images.unsplash.com/photo-1620916566398-39f1143ab7be?w=400',
      category: 'Skincare',
      brand: 'Age Defy',
      rating: 4.6,
      reviewCount: 387,
      stock: 33,
      isAvailable: true,
      isFeatured: true,
    ),
    ProductModel(
      id: '27',
      name: 'AHA BHA Exfoliating Serum',
      description:
          'Chemical exfoliant with AHA and BHA for smooth, radiant skin.',
      price: 42.99,
      imageUrl:
          'https://images.unsplash.com/photo-1556228578-7c8f27ec3c1b?w=400',
      category: 'Skincare',
      brand: 'Bright Skin',
      rating: 4.7,
      reviewCount: 445,
      stock: 27,
      isAvailable: true,
      isFeatured: true,
    ),
  ];

  static final List<OrderModel> _mockOrders = [];
}
