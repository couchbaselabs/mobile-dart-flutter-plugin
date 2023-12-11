import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'cbl_dart_plugin_platform_interface.dart';

/// An implementation of [CblDartPluginPlatform] that uses method channels.
class MethodChannelCblDartPlugin extends CblDartPluginPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('cbl_dart_plugin');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
