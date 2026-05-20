import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // ==========================================
  // آدرس فایل‌های سرور
  // ==========================================
  static const String baseUrl = 'http://esalatcar.ir/api.php';
  static const String loginUrl = 'http://esalatcar.ir/app_login.php'; // فایل جدید لاگین
  
  static String? _sessionCookie;

  // ذخیره کوکی سشن
  static Future<void> saveSessionCookie(String cookie) async {
    _sessionCookie = cookie;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('session_cookie', cookie);
  }

  // خواندن کوکی هنگام باز شدن اپ
  static Future<void> loadSessionCookie() async {
    if (_sessionCookie != null) return;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _sessionCookie = prefs.getString('session_cookie');
  }

  // چک کردن وضعیت لاگین
  static bool get isLoggedIn => _sessionCookie != null;

  // تابع لاگین
  static Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(loginUrl));
      request.fields['username'] = username;
      request.fields['password'] = password;

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      // ذخیره کوکی سشن که سرور می‌فرستد
      String? rawCookie = response.headers['set-cookie'];
      if (rawCookie != null) {
        // استخراج فقط بخش PHPSESSID
        String sessionId = rawCookie.split(';').first;
        await saveSessionCookie(sessionId);
      }

      return jsonDecode(response.body);
    } on SocketException {
      return {'success': false, 'message': 'اتصال ناموفق. اینترنت خود را بررسی کنید.'};
    } catch (e) {
      return {'success': false, 'message': 'خطای ناشناخته در سرور: $e'};
    }
  }

  // تابع عمومی برای درخواست‌های GET (به api.php)
  static Future<Map<String, dynamic>> getRequest(String action, {Map<String, String>? extraParams}) async {
    await loadSessionCookie();
    
    Map<String, String> params = {'action': action};
    if (extraParams != null) params.addAll(extraParams);
    
    Uri url = Uri.parse(baseUrl).replace(queryParameters: params);
    
    try {
      var response = await http.get(url, headers: {
        if (_sessionCookie != null) 'Cookie': _sessionCookie!,
      });

      return jsonDecode(response.body);
    } on SocketException {
      return {'success': false, 'message': 'اتصال ناموفق. اینترنت خود را بررسی کنید.'};
    } catch (e) {
      return {'success': false, 'message': 'خطا در دریافت اطلاعات از سرور'};
    }
  }

  // تابع عمومی برای درخواست‌های POST (به api.php)
  static Future<Map<String, dynamic>> postRequest(String action, Map<String, String> fields) async {
    await loadSessionCookie();
    
    var request = http.MultipartRequest('POST', Uri.parse(baseUrl));
    request.fields['action'] = action;
    request.fields.addAll(fields);
    
    if (_sessionCookie != null) {
      request.headers['Cookie'] = _sessionCookie!;
    }

    try {
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      return jsonDecode(response.body);
    } on SocketException {
      return {'success': false, 'message': 'اتصال ناموفق. اینترنت خود را بررسی کنید.'};
    } catch (e) {
      return {'success': false, 'message': 'خطا در ارسال اطلاعات به سرور'};
    }
  }
}