// lib/app/data/providers/api_provider.dart
import 'package:get/get.dart';

class ApiProvider extends GetConnect {
  @override
  void onInit() {
    // Configuration for API endpoints would go here
    httpClient.baseUrl = 'YOUR_API_BASE_URL';
    httpClient.addRequestModifier<dynamic>((request) {
      // Add any headers or authentication tokens here
      return request;
    });
  }

  // Define API methods here if needed for future expansion
}