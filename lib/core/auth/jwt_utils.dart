import 'dart:convert';

class JwtUtils {
  static Map<String, dynamic>? decodePayload(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        throw const FormatException('Token không hợp lệ');
      }
      final payload = _decodeBase64(parts[1]);
      final Map<String, dynamic> data = json.decode(payload);
      return data;
    } catch (e) {
      print("Decode JWT error: $e");
      return null;
    }
  }

  static String _decodeBase64(String str) {
    String output = str.replaceAll('-', '+').replaceAll('_', '/');
    switch (output.length % 4) {
      case 0:
        break;
      case 2:
        output += '==';
        break;
      case 3:
        output += '=';
        break;
      default:
        throw const FormatException('Chuỗi base64 không hợp lệ');
    }
    return utf8.decode(base64Url.decode(output));
  }

  static String? getUserId(String token) {
    final payload = decodePayload(token);
    return payload?['_id'] as String?;
  }

  static String? getEmail(String token) {
    final payload = decodePayload(token);
    return payload?['email'] as String?;
  }
}
