import 'package:myshop/core/utils/env_secrets.dart';

/// مزود إعدادات التطبيق الآمن
/// يقرأ القيم الممررة عبر `--dart-define` في بيئات الإطلاق/CI أولاً،
/// ويعود تلقائياً إلى `EnvSecrets` المحلي أثناء التطوير.
class AppConfig {
  AppConfig._();

  static const String _envSupabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String _envSupabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
  );
  static const String _envEntrigApiKey = String.fromEnvironment(
    'ENTRIG_API_KEY',
  );

  static String get supabaseUrl =>
      _envSupabaseUrl.isNotEmpty ? _envSupabaseUrl : EnvSecrets.supabaseUrl;

  static String get supabaseAnonKey => _envSupabaseAnonKey.isNotEmpty
      ? _envSupabaseAnonKey
      : EnvSecrets.supabaseAnonKey;

  static String get entrigApiKey =>
      _envEntrigApiKey.isNotEmpty ? _envEntrigApiKey : EnvSecrets.entrigApiKey;
}
