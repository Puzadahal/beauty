# Beauty & Cosmetics - E-commerce Flutter Application

A complete, production-ready e-commerce mobile and web application for beauty and cosmetics products, built with Flutter and BLoC state management.

## Features

### User Features
- 🛍️ **Product Browsing**: Browse products with category filtering and search
- 🔍 **Product Details**: View detailed product information with image carousel
- 🛒 **Shopping Cart**: Add, remove, and update quantities in cart
- 💳 **Checkout**: Complete checkout flow with multiple payment options
- 📱 **Responsive Design**: Optimized for mobile, tablet, and desktop
- ⭐ **Product Ratings**: View product ratings and reviews
- 🎨 **Modern UI**: Beautiful, accessible, and intuitive interface

### Admin Features
- 📊 **Admin Dashboard**: Overview of store management
- 📦 **Product Management**: Add, edit, and delete products
- 📋 **Order Management**: View and update order statuses
- 🔐 **Role-Based Access**: Separate admin and customer roles

### Payment Integration
- 💳 **Stripe**: Credit/Debit card payments
- 💰 **PayPal**: PayPal payment integration
- 🇳🇵 **eSewa**: Nepal payment gateway
- 🇳🇵 **Khalti**: Nepal payment gateway

## Technology Stack

- **Framework**: Flutter 3.9.2+
- **State Management**: BLoC (flutter_bloc)
- **Navigation**: go_router
- **HTTP Client**: http, dio
- **Local Storage**: shared_preferences, hive
- **UI Components**: Material Design 3
- **Image Loading**: cached_network_image
- **Payment**: flutter_stripe (with mock implementations for others)

## Project Structure

```
lib/
├── core/
│   ├── router/          # App routing configuration
│   ├── theme/           # Theme, colors, text styles
│   └── utils/           # Utility functions
├── data/
│   ├── models/          # Data models
│   └── services/        # API and payment services
├── presentation/
│   ├── bloc/            # BLoC state management
│   │   ├── products/
│   │   ├── cart/
│   │   ├── auth/
│   │   └── orders/
│   ├── screens/         # UI screens
│   │   ├── home/
│   │   ├── product/
│   │   ├── cart/
│   │   ├── checkout/
│   │   ├── auth/
│   │   └── admin/
│   └── widgets/         # Reusable widgets
└── main.dart            # App entry point
```

## Getting Started

### Prerequisites

- Flutter SDK 3.9.2 or higher
- Dart SDK 3.9.2 or higher
- Android Studio / VS Code with Flutter extensions
- For iOS: Xcode (macOS only)
- For Android: Android SDK

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd beauty_cosmetics
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Running on Different Platforms

- **Android**: `flutter run -d android`
- **iOS**: `flutter run -d ios`
- **Web**: `flutter run -d chrome`
- **Desktop**: `flutter run -d windows` (or `macos`, `linux`)

## Configuration

### Payment Gateways

The app includes mock implementations for all payment gateways. To integrate real payment services:

1. **Stripe**: 
   - Add your Stripe publishable key to the payment service
   - Configure Stripe SDK in `lib/data/services/payment_service.dart`

2. **PayPal**:
   - Integrate PayPal SDK
   - Update `PayPalPaymentService` in payment_service.dart

3. **eSewa**:
   - Add eSewa SDK configuration
   - Update `EsewaPaymentService` in payment_service.dart

4. **Khalti**:
   - Add Khalti SDK configuration
   - Update `KhaltiPaymentService` in payment_service.dart

### API Configuration

The app uses a mock API service. To connect to a real backend:

1. Update `baseUrl` in `lib/data/services/api_service.dart`
2. Implement real API endpoints
3. Handle authentication tokens
4. Update error handling

## Mock API

The app includes a mock API service that simulates API calls with delays. Sample products are included for testing.

### Sample Products Include:
- Makeup products (lipstick, mascara, eyeshadow)
- Skincare products (serum, cream, cleanser)
- Nail products

## Testing

### Run Tests
```bash
flutter test
```

### Run with Coverage
```bash
flutter test --coverage
```

## Building for Production

### Android
```bash
flutter build apk --release
# or
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

## Features Implementation

### User Authentication
- Mock authentication system
- Login with email/password
- Guest mode support
- Admin role detection (email containing "admin")

### Product Management
- Product listing with grid/list views
- Category filtering
- Search functionality
- Product detail pages with image carousel
- Product ratings and reviews

### Shopping Cart
- Add/remove products
- Quantity management
- Real-time price calculation
- Persistent cart state

### Checkout Process
- Shipping information form
- Payment method selection
- Order summary
- Order confirmation

### Admin Panel
- Product CRUD operations
- Order status management
- Order tracking

## Architecture

### State Management
The app uses BLoC pattern for state management:
- **ProductsBloc**: Manages product data and filtering
- **CartBloc**: Manages shopping cart state
- **AuthBloc**: Handles authentication
- **OrdersBloc**: Manages order processing

### Design Patterns
- **Repository Pattern**: Data layer abstraction
- **BLoC Pattern**: State management
- **Singleton Pattern**: Service instances
- **Factory Pattern**: Payment service creation

## Code Style

- Follows Flutter/Dart style guidelines
- Uses context-based text styles from ThemeData
- No hardcoded colors or text
- Clean component architecture
- Reusable widgets

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

This project is licensed under the MIT License.

## Support

For issues and questions:
- Create an issue in the repository
- Contact the development team

## Roadmap

- [ ] Real API integration
- [ ] Payment gateway full implementation
- [ ] User profile management
- [ ] Order history
- [ ] Wishlist functionality
- [ ] Product reviews and ratings
- [ ] Push notifications
- [ ] Analytics dashboard
- [ ] Multi-language support
- [ ] Dark mode improvements

## Acknowledgments

- Flutter team for the amazing framework
- BLoC library maintainers
- All package contributors

---

**Built with ❤️ using Flutter**
