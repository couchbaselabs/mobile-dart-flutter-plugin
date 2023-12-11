import 'package:flutter_test/flutter_test.dart';
import 'package:cbl_dart_plugin/cbl_dart_plugin.dart';
import 'package:cbl_dart_plugin/cbl_dart_plugin_platform_interface.dart';
import 'package:cbl_dart_plugin/cbl_dart_plugin_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockCblDartPluginPlatform
    with MockPlatformInterfaceMixin
    implements CblDartPluginPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final CblDartPluginPlatform initialPlatform = CblDartPluginPlatform.instance;

  test('$MethodChannelCblDartPlugin is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelCblDartPlugin>());
  });

  test('getPlatformVersion', () async {
    CblDartPlugin cblDartPlugin = CblDartPlugin();
    MockCblDartPluginPlatform fakePlatform = MockCblDartPluginPlatform();
    CblDartPluginPlatform.instance = fakePlatform;

    expect(await cblDartPlugin.getPlatformVersion(), '42');
  });
}
