import 'dart:ffi';

import 'package:loggy/loggy.dart';

import 'bridge_generated.dart';

// Re-export the bridge so it is only necessary to import this file.
export 'bridge_generated.dart';
import 'dart:io' as io;
import 'package:path/path.dart' as path;

const _base = 'intiface_engine_flutter_bridge';

// On MacOS, the dynamic library is not bundled with the binary,
// but rather directly **linked** against the binary.

final _dylib = io.Platform.isWindows
    ? '$_base.dll'
    : io.Platform.isLinux
        ? 'lib/lib$_base.so'
        : 'lib$_base.so';

// The late modifier delays initializing the value until it is actually needed,
// leaving precious little time for the program to quickly start up.
IntifaceEngineFlutterBridge? api;

void initializeApi() {
  if (api == null) {
    final useDylib = !io.Platform.isIOS && !io.Platform.isMacOS;

    String resolvedExecutable = io.Platform.resolvedExecutable;

    /// Workaround for https://github.com/dart-lang/sdk/issues/52309
    if (io.Platform.isWindows && resolvedExecutable.startsWith(r"UNC\")) {
      resolvedExecutable = resolvedExecutable.replaceFirst(r"UNC\", r"\\");
    }

    final String executableDir = path.dirname(resolvedExecutable);

    // Not sure about android or windows here, restricting to linux
    final dylibDir = (io.Platform.isLinux) ? executableDir : io.Directory.current.path;

    final dylibPath = path.join(dylibDir, _dylib);

    logInfo("Initializing API static via ${useDylib ? dylibPath : "executable"}");

    final impl = (useDylib) ? DynamicLibrary.open(dylibPath) : DynamicLibrary.executable();

    api = IntifaceEngineFlutterBridgeImpl(impl);
  } else {
    logWarning("API already initialized, should not need to initialize again.");
  }
}
