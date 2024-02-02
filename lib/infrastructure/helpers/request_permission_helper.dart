import 'package:nutrenaissance_flutter/infrastructure/utils/permission_type.dart';
import 'package:permission_handler/permission_handler.dart';

class RequestPermissionManager {
  PermissionType? _permissionType;

  Function()? _onPermissionDenied;

  Function()? _onPermissionGranted;

  Function()? _onPermissionPermanentlyDenied;


  RequestPermissionManager(PermissionType permissionType) {
    _permissionType = permissionType;
  }

  RequestPermissionManager onPermissionDenied(Function()? onPermissionDenied) {
    _onPermissionDenied = onPermissionDenied;
    return this;
  }

  RequestPermissionManager onPermissionGranted(Function()? onPermissionGranted) {
    _onPermissionGranted = onPermissionGranted;
    return this;
  }

  RequestPermissionManager onPermissionPermanentlyDenied(Function()? onPermissionPermanentlyDenied) {
    _onPermissionPermanentlyDenied = onPermissionPermanentlyDenied;
    return this;
  }

  Permission _getPermissionFromType(PermissionType permissionType) {
    switch (permissionType) {
      case PermissionType.activityRecognition:
        return Permission.activityRecognition;

      default:
        throw Exception('Invalid permission type');
    }
  }

  void execute() async {
    Permission permission = _getPermissionFromType(_permissionType!);
    PermissionStatus status = await permission.request();

    if (status.isGranted) {
      if (_onPermissionGranted != null) {

        _onPermissionGranted!();
      }
    } else if (status.isDenied) {
      if (_onPermissionDenied != null) {

        _onPermissionDenied!();
      }
    } else if (status.isPermanentlyDenied) {
      if (_onPermissionPermanentlyDenied != null) {

        _onPermissionPermanentlyDenied!();
      }
    }
  }

}