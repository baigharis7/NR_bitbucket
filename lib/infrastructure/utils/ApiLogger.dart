import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class ApiLogger {
  static Future<File> _getLogFile() async {
    Directory? directory;

    if (Platform.isAndroid) {
      directory = Directory('/storage/emulated/0/Download'); // Public Downloads Folder
    } else if (Platform.isIOS) {
      directory = await getApplicationSupportDirectory(); // Safe iOS Directory
    }

    if (!await directory!.exists()) {
      await directory.create(recursive: true);
    }

    return File('${directory.path}/NN_Logs.txt');
  }

  static Future<void> logRequest(String url, String method, {String? body}) async {
    String log = '[$method] $url\nBody: $body\nTimestamp: ${DateTime.now()}\n\n';
    await _writeLog(log);
  }

  static Future<void> logResponse(String url, int statusCode, String response) async {
    String log = '[Response] $url\nStatus: $statusCode\nResponse: $response\nTimestamp: ${DateTime.now()}\n\n';
    await _writeLog(log);
  }

  static Future<void> _writeLog(String log) async {
    if (!await _requestStoragePermission()) {
      Fluttertoast.showToast(msg: 'Storage permission denied');
      return;
    }

    final file = await _getLogFile();
    await file.writeAsString(log, mode: FileMode.append);

    // Optionally store in Hive
    // var box = await Hive.openBox('apiLogs');
    // box.add(log);
  }

  static Future<String> readLogs() async {
    final file = await _getLogFile();
    return file.readAsString();
  }

  // Function to request storage permissions properly
  static Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      if (await Permission.storage.request().isGranted) {
        return true;
      } else if (await Permission.manageExternalStorage.request().isGranted) {
        return true;
      }
    }
    return false;
  }
}
