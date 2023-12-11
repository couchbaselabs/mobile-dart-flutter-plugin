import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'cbl_dart_plugin_method_channel.dart';

abstract class CblDartPluginPlatform extends PlatformInterface {
  /// Constructs a CblDartPluginPlatform.
  CblDartPluginPlatform() : super(token: _token);

  static final Object _token = Object();

  static CblDartPluginPlatform _instance = MethodChannelCblDartPlugin();

  /// The default instance of [CblDartPluginPlatform] to use.
  ///
  /// Defaults to [MethodChannelCblDartPlugin].
  static CblDartPluginPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [CblDartPluginPlatform] when
  /// they register themselves.
  static set instance(CblDartPluginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
