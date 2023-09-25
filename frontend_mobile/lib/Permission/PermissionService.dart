import 'package:flutter/material.dart';

abstract class PermissionService {
  Future requestPhotosPermission();

  Future<bool> handlePhotosPermission(BuildContext context);

  Future requestNotificationPermission();

  Future<bool> handleNotificationPermission(BuildContext context);
}
