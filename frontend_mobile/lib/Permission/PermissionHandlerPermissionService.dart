import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'PermissionService.dart';
import '../AppLocalizations.dart';

class PermissionHandlerPermissionService implements PermissionService {
  @override
  Future<PermissionStatus> requestPhotosPermission() async {
    return await Permission.photos.request();
  }

  @override
  Future<PermissionStatus> requestNotificationPermission() async {
    return await Permission.notification.request();
  }

  @override
  Future<bool> handlePhotosPermission(BuildContext context) async {
    PermissionStatus photosPermissionStatus = await requestPhotosPermission();

    if (photosPermissionStatus != PermissionStatus.granted) {
      return false;
    }
    return true;
  }

  @override
  Future<bool> handleNotificationPermission(BuildContext context) async {
    PermissionStatus permissionStatus = await requestNotificationPermission();
    bool permission = true;
    if (permissionStatus != PermissionStatus.granted) {
      await showDialog(
          context: context,
          builder: (_context) => AlertDialog(
                title:
                    Text(AppLocalizations.of(_context).translate('Permission')),
                content: Text(AppLocalizations.of(_context)
                    .translate('PermissionMessage')),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      openAppSettings().then((value) {
                        Navigator.pop(_context);
                      });
                    },
                    child: Text(
                        AppLocalizations.of(_context).translate('Confirm')),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      permission = false;
                      Navigator.of(_context).pop();
                    },
                    child:
                        Text(AppLocalizations.of(_context).translate('Cancel')),
                  ),
                ],
              ));
      return permission;
    }
    return true;
  }
}
