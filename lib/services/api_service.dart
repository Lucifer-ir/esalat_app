import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // آدرس دامنه سایت خود را اینجا بگذارید
  static const String baseUrl = 'https://esalatcar.ir/api.php';
  
  // ذخیره کوکی سشن برای حفظ لاگین
  static String? _sessionCookie;

  // تابع ذخیره کوکی
  static Future<void> saveSessionCookie(String cookie) async {
    _sessionCookie = cookie;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('session_cookie', cookie);
  }

  // تابع خواندن کوکی هنگام باز شدن اپ
  static Future<void> loadSessionCookie() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _sessionCookie = prefs.getString('session_cookie');
  }

  // تابع لاگین
  static Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(baseUrl));
      request.fields['action'] = 'login';
      request.fields['username'] = username;
      request.fields['password'] = password;

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      // ذخیره کوکی سشن که سرور می‌فرستد
      String? rawCookie = response.headers['set-cookie'];
      if (rawCookie != null) {
        await saveSessionCookie(rawCookie.split(';').first); // فقط بخش PHPSESSID
      }

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'خطا در اتصال به سرور'};
    }
  }

  // تابع عمومی برای درخواست‌های GET (مثل گرفتن گروه‌ها)
  static Future<Map<String, dynamic>> getRequest(String action, {Map<String, String>? extraParams}) async {
    await loadSessionCookie();
    
    Map<String, String> params = {'action': action};
    if (extraParams != null) params.addAll(extraParams);
    
    Uri url = Uri.parse(baseUrl).replace(queryParameters: params);
    
    var response = await http.get(url, headers: {
      if (_sessionCookie != null) 'Cookie': _sessionCookie!,
    });

    return jsonDecode(response.body);
  }

  // تابع عمومی برای درخواست‌های POST (مثل ثبت خودرو)
  static Future<Map<String, dynamic>> postRequest(String action, Map<String, String> fields) async {
    await loadSessionCookie();
    
    var request = http.MultipartRequest('POST', Uri.parse(baseUrl));
    request.fields['action'] = action;
    request.fields.addAll(fields);
    
    if (_sessionCookie != null) {
      request.headers['Cookie'] = _sessionCookie!;
    }

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    return jsonDecode(response.body);
  }
}