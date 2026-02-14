import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../entity/Employee.dart';

enum DirectoryType {
  temporary,
  applicationSupport,
  applicationLibrary,
  applicationDocuments,
  applicationCache,
  externalStorage,
  externalCache,
  externalStorageDirectories,
  downloads,
}

class FileService {
  static final FileService instance = FileService._internal();
  FileService._internal();

  Future<String?> getDirectoryPath(DirectoryType type) async {
    try {
      switch (type) {
        case DirectoryType.temporary:
          final dir = await getTemporaryDirectory();
          return dir.path;

        case DirectoryType.applicationSupport:
          final dir = await getApplicationSupportDirectory();
          return dir.path;

        case DirectoryType.applicationLibrary:
          if (Platform.isIOS) {
            final dir = await getLibraryDirectory();
            return dir.path;
          }
          throw UnsupportedError('Application Library directory is only supported on iOS');

        case DirectoryType.applicationDocuments:
          final dir = await getApplicationDocumentsDirectory();
          return dir.path;

        case DirectoryType.applicationCache:
          final dir = await getApplicationCacheDirectory();
          return dir.path;

        case DirectoryType.externalStorage:
          if (Platform.isAndroid) {
            final dir = await getExternalStorageDirectory();
            return dir?.path;
          }
          throw UnsupportedError('External Storage directory is only supported on Android');

        case DirectoryType.externalCache:
          if (Platform.isAndroid) {
            try {
              final externalDir = await getExternalStorageDirectory();
              if (externalDir != null) {
                final cacheDir = Directory(path.join(externalDir.parent.path, 'cache'));
                if (!await cacheDir.exists()) {
                  await cacheDir.create(recursive: true);
                }
                return cacheDir.path;
              }
              final appCacheDir = await getApplicationCacheDirectory();
              return appCacheDir.path;
            } catch (e) {
              final appCacheDir = await getApplicationCacheDirectory();
              return appCacheDir.path;
            }
          }
          throw UnsupportedError('External Cache directory is only supported on Android');

        case DirectoryType.externalStorageDirectories:
          if (Platform.isAndroid) {
            final dirs = await getExternalStorageDirectories();
            return dirs?.isNotEmpty == true ? dirs!.first.path : null;
          }
          throw UnsupportedError('External Storage Directories are only supported on Android');

        case DirectoryType.downloads:
          if (Platform.isAndroid) {
            try {
              final externalDir = await getExternalStorageDirectory();
              if (externalDir != null) {
                final downloadsDir = Directory(path.join(externalDir.parent.path, 'Download'));
                if (await downloadsDir.exists()) {
                  return downloadsDir.path;
                }
                final altPath = '/storage/emulated/0/Download';
                final altDir = Directory(altPath);
                if (await altDir.exists()) {
                  return altPath;
                }
              }
              return null;
            } catch (e) {
              return null;
            }
          }
          throw UnsupportedError('Downloads directory is only supported on Android');

        default:
          return null;
      }
    } catch (e) {
      rethrow;
    }
  }

  String getPlatformError(DirectoryType type) {
    switch (type) {
      case DirectoryType.applicationLibrary:
        return 'Application Library directory is not supported on Android. Only iOS supports this directory.';
      case DirectoryType.externalStorage:
      case DirectoryType.externalCache:
      case DirectoryType.externalStorageDirectories:
      case DirectoryType.downloads:
        return '${type.name} is not supported on iOS. Only Android supports this directory.';
      default:
        return 'Directory type ${type.name} is not supported on this platform.';
    }
  }

  Future<String> saveEmployeeToFile(Employee employee, DirectoryType directoryType, String fileName) async {
    try {
      final dirPath = await getDirectoryPath(directoryType);
      if (dirPath == null) {
        throw Exception(getPlatformError(directoryType));
      }

      final file = File(path.join(dirPath, fileName));
      final jsonString = jsonEncode(employee.toJson());
      await file.writeAsString(jsonString);
      return file.path;
    } catch (e) {
      if (e is UnsupportedError) {
        throw Exception('${getPlatformError(directoryType)} Error: ${e.message}');
      }
      rethrow;
    }
  }

  Future<Employee?> readEmployeeFromFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return null;
      }
      final jsonString = await file.readAsString();
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return Employee.fromJson(json);
    } catch (e) {
      throw Exception('Error reading file: $e');
    }
  }

  Future<String> saveEmployeesToFile(List<Employee> employees, DirectoryType directoryType, String fileName) async {
    try {
      final dirPath = await getDirectoryPath(directoryType);
      if (dirPath == null) {
        throw Exception(getPlatformError(directoryType));
      }

      final file = File(path.join(dirPath, fileName));
      final jsonList = employees.map((e) => e.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      await file.writeAsString(jsonString);
      return file.path;
    } catch (e) {
      if (e is UnsupportedError) {
        throw Exception('${getPlatformError(directoryType)} Error: ${e.message}');
      }
      rethrow;
    }
  }

  Future<List<Employee>> readEmployeesFromFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return [];
      }
      final jsonString = await file.readAsString();
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList.map((json) => Employee.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Error reading file: $e');
    }
  }

  Future<Map<DirectoryType, String?>> getAllFilePaths() async {
    final Map<DirectoryType, String?> paths = {};
    for (var type in DirectoryType.values) {
      try {
        paths[type] = await getDirectoryPath(type);
      } catch (e) {
        paths[type] = null;
      }
    }
    return paths;
  }

  Future<bool> fileExists(String filePath) async {
    final file = File(filePath);
    return await file.exists();
  }
}

