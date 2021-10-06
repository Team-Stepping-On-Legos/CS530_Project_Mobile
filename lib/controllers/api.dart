import 'dart:async';
import 'package:http/http.dart' as http;

// const baseUrl = "http://localhost:5001";
const baseUrl = "https://cs530-beclawski.web.app/";

class API {
  static Future getCategories() {
    var url = baseUrl + "/api/categories";
    return http.get(Uri.parse(url));
  }
}