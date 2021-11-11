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

Future<File> get _mutedeventsFile async {
  final path = await _localPath;
  return File('$path/mutedevents.txt');
}

Future<String?> readContent(String fileName) async {
  final File file;
  try {
    switch (fileName.toLowerCase()) {
      case "categories":
        file = await _categoriesFile;
        break;
      case "mutedevents":
        file = await _mutedeventsFile;
        break;
      default:
        file = await _categoriesFile;
        break;
    }
    if(file.existsSync()){
      String contents = await file.readAsString();
      print("READING FROM FILE: $contents");
      // Returning the contents of the file
      return contents;
    }else{
      return null;
    }
   
  } catch (e) {
    // If encountering an error, return
    return 'Error!';
  }
}

Future<File> writeContent(String fileName, List<dynamic> object) async {
  final File file;
  switch (fileName.toLowerCase()) {
    case "categories":
      file = await _categoriesFile;
      break;
    case "mutedevents":
      file = await _mutedeventsFile;
      break;
    default:
      file = await _categoriesFile;
      break;
  }

  String jsonObject = jsonEncode(object);
    print("WRITING TO FILE: $jsonObject");
  // Write the file
  return file.writeAsString(jsonObject);
}
