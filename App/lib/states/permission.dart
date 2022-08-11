import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

final cameraPermissionProvider =
    FutureProvider((ref) => Permission.camera.request());
