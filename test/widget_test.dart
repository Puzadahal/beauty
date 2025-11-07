import 'package:beauty_cosmetics/firebase_options.dart';
import 'package:beauty_cosmetics/data/services/api_service.dart';
import 'package:beauty_cosmetics/data/services/auth_service.dart';
import 'package:beauty_cosmetics/data/services/local_storage_service.dart';
import 'package:beauty_cosmetics/main.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ApiService apiService;
  late FirebaseAuthService authService;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    final prefs = await SharedPreferences.getInstance();
    final localStorage = LocalStorageService(prefs);

    apiService = ApiService();
    authService = FirebaseAuthService(localStorageService: localStorage);
  });

  testWidgets('App smoke test', (tester) async {
    await tester.pumpWidget(MyApp(
      apiService: apiService,
      authService: authService,
    ));

    await tester.pumpAndSettle();

    expect(find.byType(MyApp), findsOneWidget);
    // add meaningful expectations for your actual UI here
  });
}