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
      directory = await getApplicationDocumentsDirectory(); // Public folder on iOS
    }

    if (!await directory!.exists()) {
      await directory.create(recursive: true);
    }

    final file = File('${directory.path}/NN_Logs.txt');

    // If file exists and is older than 2 days, delete it
    if (await file.exists()) {
      final stat = await file.stat();
      final now = DateTime.now();
      final diff = now.difference(stat.modified);

      if (diff.inDays > 2) {
        await file.delete();
        await file.create();
      }
    } else {
      await file.create();
    }

    return file;
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
    } else if (Platform.isIOS) {
      return true;
    }
    return false;
  }

  // static Future<void> shareLogFile() async {
  //   try {
  //     final file = await _getLogFile();
  //     if (await file.exists()) {
  //       await Share.shareXFiles([XFile(file.path)], text: 'Check out this API log file');
  //     } else {
  //       Fluttertoast.showToast(msg: 'Log file not found.');
  //     }
  //   } catch (e) {
  //     Fluttertoast.showToast(msg: 'Error sharing file: $e');
  //   }
  // }
}
