import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/user_model.dart';
import 'local_storage_service.dart';

class FirebaseAuthService {
  FirebaseAuthService({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
    required LocalStorageService localStorageService,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _googleSignIn =
            kIsWeb ? null : (googleSignIn ?? GoogleSignIn.instance),
        _localStorageService = localStorageService;

  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn? _googleSignIn;
  final LocalStorageService _localStorageService;
  bool _googleSignInInitialized = false;

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final firebaseUser = credential.user;
    if (firebaseUser == null) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'Unable to sign in with the provided credentials.',
      );
    }

    final userModel = await _loadOrCreateUserDocument(firebaseUser);
    await _localStorageService.saveUser(userModel);
    return userModel;
  }

  Future<UserModel> signUpWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final firebaseUser = credential.user;
    if (firebaseUser == null) {
      throw FirebaseAuthException(
        code: 'user-creation-failed',
        message: 'Failed to create user account.',
      );
    }

    await firebaseUser.updateDisplayName(name);

    final newUser = UserModel(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? email,
      name: name,
      avatarUrl: firebaseUser.photoURL,
      role: UserRole.customer,
      createdAt: DateTime.now(),
      isEmailVerified: firebaseUser.emailVerified,
    );

    await _usersCollection.doc(firebaseUser.uid).set(_userToFirestore(newUser));
    await _localStorageService.saveUser(newUser);
    return newUser;
  }

  Future<UserModel> signInWithGoogle() async {
    User? firebaseUser;
    String? displayNameFallback;
    String? photoUrlFallback;

    if (kIsWeb) {
      final provider = GoogleAuthProvider();
      final userCredential = await _firebaseAuth.signInWithPopup(provider);
      firebaseUser = userCredential.user;
    } else {
      final googleSignIn = _googleSignIn;
      if (googleSignIn == null) {
        throw FirebaseAuthException(
          code: 'google-sign-in-unavailable',
          message: 'Google sign-in is not available on this platform.',
        );
      }

      if (!_googleSignInInitialized) {
        await googleSignIn.initialize();
        _googleSignInInitialized = true;
      }

      if (!googleSignIn.supportsAuthenticate()) {
        throw FirebaseAuthException(
          code: 'google-sign-in-unsupported',
          message:
              'Google interactive sign-in is not supported on this platform.',
        );
      }

      final googleAccount = await googleSignIn.authenticate();
      final idToken = googleAccount.authentication.idToken;

      if (idToken == null) {
        throw FirebaseAuthException(
          code: 'sign_in_aborted',
          message: 'Google sign-in was cancelled.',
        );
      }

      final credential = GoogleAuthProvider.credential(
        idToken: idToken,
      );

      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      firebaseUser = userCredential.user;
      displayNameFallback = googleAccount.displayName;
      photoUrlFallback = googleAccount.photoUrl;
    }

    if (firebaseUser == null) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'Unable to sign in with Google credentials.',
      );
    }

    final userModel = await _loadOrCreateUserDocument(
      firebaseUser,
      displayNameFallback: displayNameFallback,
      photoUrlFallback: photoUrlFallback,
    );
    await _localStorageService.saveUser(userModel);
    return userModel;
  }

  Future<void> signOut() async {
    final futures = <Future<void>>[
      _firebaseAuth.signOut(),
      _localStorageService.clearUser(),
    ];

    if (!kIsWeb && _googleSignIn != null) {
      futures.add(_googleSignIn.signOut());
    }

    await Future.wait(futures);
  }

  Future<UserModel?> getCurrentUser() async {
    final localUser = _localStorageService.getUser();
    final firebaseUser = _firebaseAuth.currentUser;

    if (firebaseUser == null) {
      return localUser;
    }

    try {
      final userDoc = await _usersCollection.doc(firebaseUser.uid).get();
      if (userDoc.exists) {
        final data = userDoc.data();
        if (data != null) {
          final userModel = _userFromFirestore(firebaseUser, data);
          await _localStorageService.saveUser(userModel);
          return userModel;
        }
      }

      final createdUser = await _createUserDocument(firebaseUser);
      await _localStorageService.saveUser(createdUser);
      return createdUser;
    } catch (_) {
      return localUser;
    }
  }

  Future<UserModel> _loadOrCreateUserDocument(
    User firebaseUser, {
    String? displayNameFallback,
    String? photoUrlFallback,
  }) async {
    final userDoc = await _usersCollection.doc(firebaseUser.uid).get();

    if (userDoc.exists) {
      final data = userDoc.data();
      if (data != null) {
        return _userFromFirestore(
          firebaseUser,
          data,
          displayNameFallback: displayNameFallback,
          photoUrlFallback: photoUrlFallback,
        );
      }
    }

    final newUser = await _createUserDocument(
      firebaseUser,
      displayNameFallback: displayNameFallback,
      photoUrlFallback: photoUrlFallback,
    );

    return newUser;
  }

  Future<UserModel> _createUserDocument(
    User firebaseUser, {
    String? displayNameFallback,
    String? photoUrlFallback,
  }) async {
    final userModel = UserModel(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      name: firebaseUser.displayName ?? displayNameFallback,
      avatarUrl: firebaseUser.photoURL ?? photoUrlFallback,
      role: UserRole.customer,
      createdAt: DateTime.now(),
      isEmailVerified: firebaseUser.emailVerified,
    );

    await _usersCollection
        .doc(firebaseUser.uid)
        .set(_userToFirestore(userModel), SetOptions(merge: true));
    return userModel;
  }

  UserModel _userFromFirestore(
    User firebaseUser,
    Map<String, dynamic> data, {
    String? displayNameFallback,
    String? photoUrlFallback,
  }) {
    final createdAtValue = data['createdAt'];
    DateTime createdAt;
    if (createdAtValue is Timestamp) {
      createdAt = createdAtValue.toDate();
    } else if (createdAtValue is String) {
      createdAt =
          DateTime.tryParse(createdAtValue) ??
          (firebaseUser.metadata.creationTime ?? DateTime.now());
    } else {
      createdAt = firebaseUser.metadata.creationTime ?? DateTime.now();
    }

    final roleValue = data['role'];
    final role = UserRole.values.firstWhere(
      (element) => element.name == roleValue,
      orElse: () => UserRole.customer,
    );

    return UserModel(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? data['email'] as String? ?? '',
      name:
          data['name'] as String? ??
          firebaseUser.displayName ??
          displayNameFallback,
      phone: data['phone'] as String?,
      avatarUrl:
          data['avatarUrl'] as String? ??
          firebaseUser.photoURL ??
          photoUrlFallback,
      role: role,
      createdAt: createdAt,
      isEmailVerified: firebaseUser.emailVerified,
    );
  }

  Map<String, dynamic> _userToFirestore(UserModel user) {
    return {
      'id': user.id,
      'email': user.email,
      'name': user.name,
      'phone': user.phone,
      'avatarUrl': user.avatarUrl,
      'role': user.role.name,
      'createdAt': Timestamp.fromDate(user.createdAt),
      'isEmailVerified': user.isEmailVerified,
    };
  }
}
