import 'dart:async';
import 'package:http/http.dart' as http;

// const baseUrl = "http://localhost:5001";
const baseUrl = "https://cs530-beclawski.web.app/";

class API {
  static Future getCategories() {
    var url = baseUrl + "/categories";
    return http.get(Uri.parse(url));
  }

  
  static Future getNotificationHistory(String categories) {
    var url = baseUrl + "/notify/previousByCategory?category=$categories";
    return http.get(Uri.parse(url));
  }

  
  static Future getCalendarItems(String categories) {
    var url = baseUrl + "/api/calendar/list?category=$categories";
    return http.get(Uri.parse(url));
  }
}