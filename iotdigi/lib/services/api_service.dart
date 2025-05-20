import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Cập nhật đường dẫn để trỏ đến thư mục chính xác
  static const String baseUrl = 'http://10.0.2.2/iotdigi-main';
  static const String streamUrl = 'http://10.0.2.2:81/stream';

  // Lưu trữ thông tin người dùng hiện tại
  int? currentUserId;
  String? currentUserName;

  Future<Map<String, dynamic>> getSensorData() async {
    try {
      print('Fetching sensor data from: $baseUrl/get.php');
      final response = await http.get(Uri.parse('$baseUrl/get.php'));
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load sensor data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting sensor data: $e');
      return {
        'temperature': 0.0,
        'humidity': 0.0,
        'water_usage': 0.0,
        'bill_amount': 0.0,
        'last_update': DateTime.now().toString()
      };
    }
  }

  Future<Map<String, dynamic>> validateAccessCode(String code, bool isUser) async {
    try {
      print('Validating code: $code for ${isUser ? "user" : "admin"}');
      print('Sending request to: $baseUrl/post.php');
      
      final response = await http.post(
        Uri.parse('$baseUrl/post.php'),
        body: {
          'action': 'validate_code',
          'code': code,
          'type': isUser ? 'user' : 'admin',
        },
      );
      
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['valid'] == true) {
          // Lưu thông tin người dùng khi xác thực thành công
          currentUserId = data['user_id'];
          currentUserName = data['name'];
        }
        return data;
      }
      return {'valid': false};
    } catch (e) {
      print('Error validating code: $e');
      throw Exception('Error validating code: $e');
    }
  }

  Future<bool> capturePhoto() async {
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/post.php'),
        body: {
          'action': 'capture_photo',
          'user_id': currentUserId.toString(),
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      throw Exception('Error capturing photo: $e');
    }
  }

  Future<Map<String, dynamic>> getWaterBills({
    String? userId,
    String? month,
    String? year,
  }) async {
    try {
      final queryParams = {
        'action': 'get_bills',
        if (userId != null) 'user_id': userId,
        if (month != null) 'month': month,
        if (year != null) 'year': year,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/post.php'),
        body: queryParams,
      );

      print('Get bills response: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load bills: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting bills: $e');
      return {'bills': []};  // Return empty list on error
    }
  }

  Future<void> updateBillStatus(int billId, String status) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/post.php'),
        body: {
          'action': 'update_bill_status',
          'bill_id': billId.toString(),
          'status': status,
        },
      );

      print('Update bill status response: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('Failed to update bill status: ${response.statusCode}');
      }

      final data = json.decode(response.body);
      if (data['success'] != true) {
        throw Exception(data['error'] ?? 'Unknown error');
      }
    } catch (e) {
      print('Error updating bill status: $e');
      throw Exception('Error updating bill status: $e');
    }
  }

  Future<double> calculateWaterBill(double usage) async {
    try {
      final sensorData = await getSensorData();
      return sensorData['bill_amount']?.toDouble() ?? 0.0;
    } catch (e) {
      print('Error calculating water bill: $e');
      return 0.0;
    }
  }
}