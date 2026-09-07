class ApiConfig {
  ApiConfig._();

  /// Everything except /health lives under /api.
  static const String baseUrl = 'https://backend-fkpu.onrender.com/api';

  /// Outside /api — used only for the startup wake-up ping (Render free
  /// tier sleeps after inactivity; pinging this early reduces the chance
  /// the user's first real request times out).
  static const String healthCheckUrl = 'https://backend-fkpu.onrender.com/health';

  // Auth
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String getMe = '/auth/get-me';
  static const String verifyEmail = '/auth/verify-email';
  static const String refreshToken = '/auth/refresh-token'; // POST
  static const String logout = '/auth/logout'; // POST
  static const String logoutAll = '/auth/logout-all'; // POST

  // Conversations
  static const String conversations = '/conversations';
  static String conversationMessages(String conversationId) =>
      '/conversations/$conversationId/messages';

  // Chat
  static const String chat = '/chat';

  // Verification
  static const String verifyHuid = '/verify/huid';
  static const String verifyLicense = '/verify/license';

  // Feedback — base route mounted, exact contract TBD.
  // static const String feedback = '/feedback';
}
