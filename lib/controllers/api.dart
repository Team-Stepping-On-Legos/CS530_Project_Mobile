import 'dart:async';
import 'package:http/http.dart' as http;

const baseUrl = "http://10.0.2.2:5001";

class API {
  static Future getCategories() {
    var url = baseUrl + "/categories";
    return http.get(Uri.parse(url));
  }
}