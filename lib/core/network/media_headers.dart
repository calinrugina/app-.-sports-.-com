import '../../features/asset/data/media_platform_client.dart';

/// Headers necesare pentru a accesa imaginile și videourile
/// servite de nginx (x_app_key).
const Map<String, String> mediaHeaders = {
  'x-app-key': 'mobile-sports-com',
};
MediaPlatformClient mediaPlatformClient = MediaPlatformClient(
  baseUrl: 'https://platforms.alpha.sports.com/api',
  apiKey: 'demo_api_key_a__',
);
