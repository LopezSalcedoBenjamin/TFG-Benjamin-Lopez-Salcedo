import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {

  static Future<int> _getSDKVersion() async{
    final android = await DeviceInfoPlugin().androidInfo;
    return android.version.sdkInt;
  }

  static Future<bool> hasStoragePermission() async{
    if (!Platform.isAndroid) return true;
    final sdk = await _getSDKVersion();
    if(sdk >= 33){
      return await Permission.manageExternalStorage.isGranted;
    }
    return await Permission.storage.isGranted;
  }

  static Future<bool> requestStoragePermission() async{
    if (!Platform.isAndroid) return true;
    final sdk = await _getSDKVersion();
    if(sdk >= 33){
      return (await Permission.manageExternalStorage.request()).isGranted;
    }
    return (await Permission.storage.request()).isGranted;
  }

  static Future<bool> isPermanentlyDenied() async{
    if (!Platform.isAndroid) return true;
    final sdk = await _getSDKVersion();
    if(sdk >= 33){
      return await Permission.manageExternalStorage.isPermanentlyDenied;
    }
    return Permission.storage.isPermanentlyDenied;
  }

}