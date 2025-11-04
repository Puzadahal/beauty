import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/models/user_model.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<CheckAuthStatus>(_onCheckAuthStatus);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      // Mock authentication - In production, call actual auth service
      await Future.delayed(const Duration(seconds: 1));
      
      final user = UserModel(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        email: event.email,
        name: event.email.split('@')[0],
        role: event.email.contains('admin') ? UserRole.admin : UserRole.customer,
        createdAt: DateTime.now(),
        isEmailVerified: true,
      );

      emit(AuthAuthenticated(user: user));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthUnauthenticated());
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    // Mock - In production, check token/authentication status
    emit(AuthUnauthenticated());
  }
}

