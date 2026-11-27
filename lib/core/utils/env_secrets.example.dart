/// نموذج لإعداد المفاتيح السرية محلياً (انسخ هذا الملف إلى `env_secrets.dart`)
/// ملاحظة: ملف `env_secrets.dart` مستثنى في `.gitignore` لحماية مفاتيحك عند الرفع على GitHub.
class EnvSecrets {
  EnvSecrets._();

  static const String supabaseUrl = 'https://YOUR_PROJECT_ID.supabase.co';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
  static const String entrigApiKey = 'YOUR_ENTRIG_API_KEY';
}
