import 'package:flutter/foundation.dart';

@immutable
sealed class SignUpCubitState {}

final class SignUpCubitInitial extends SignUpCubitState {}

final class SignUpCubitLoading extends SignUpCubitState {}

/// نجاح التسجيل مع الدخول المباشر للتطبيق (بدون OTP)
final class SignUpDirectLoginSuccess extends SignUpCubitState {
  final String message;
  final String role;
  SignUpDirectLoginSuccess({required this.message, required this.role});
}

/// نجاح إنشاء الحساب (في حال تطلب المشروع تسجيل دخول يدوي)
final class SignUpCubitSucsess extends SignUpCubitState {
  final String message;
  SignUpCubitSucsess(this.message);
}

final class SignUpCubitFailure extends SignUpCubitState {
  final String error;
  SignUpCubitFailure(this.error);
}
