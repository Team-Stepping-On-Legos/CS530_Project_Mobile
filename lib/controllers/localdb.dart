import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<String> get _localPath async {
  final directory = await getApplicationDocumentsDirectory();
  print(directory.path);
  return directory.path;
}

Future<File> get _categoriesFile async {
  final path = await _localPath;
  return File('$path/categories.txt');
}

Future<File> get _eventsFile async {
  final path = await _localPath;
  return File('$path/events.txt');
}

Future<String> readContent(String fileName) async {
  final File file;
  try {
    switch (fileName.toLowerCase()) {
      case "categories":
        file = await _categoriesFile;
        break;
      case "events":
        file = await _eventsFile;
        break;
      default:
        file = await _categoriesFile;
        break;
    }
    String contents = await file.readAsString();
    print("WRITING TO FILE: $contents");
    // Returning the contents of the file
    return contents;
  } catch (e) {
    // If encountering an error, return
    return 'Error!';
  }
}

Future<File> writeContent(String fileName, List<dynamic> categories) async {
  final File file;
  switch (fileName.toLowerCase()) {
    case "categories":
      file = await _categoriesFile;
      break;
    case "events":
      file = await _eventsFile;
      break;
    default:
      file = await _categoriesFile;
      break;
  }
  String jsonCategories = jsonEncode(categories);
  // Write the file
  return file.writeAsString(jsonCategories);
}
