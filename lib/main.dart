import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logging/logging.dart';
import 'package:toolbox/data/model/ssh/virtual_key.dart';
import 'package:toolbox/providers.dart';

import 'app.dart';
import 'core/analysis.dart';
import 'core/utils/ui.dart';
import 'data/model/server/private_key_info.dart';
import 'data/model/server/server_private_info.dart';
import 'data/model/server/snippet.dart';
import 'data/provider/debug.dart';
import 'view/widget/rebuild.dart';

DebugProvider? _debug;

Future<void> main() async {
  runInZone(() async {
    await _initApp();
    runApp(
      ProviderScope(
        child: RebuildWidget(
          child: MyApp(),
        ),
      ),
    );
  });
}

void runInZone(dynamic Function() body) {
  final zoneSpec = ZoneSpecification(
    print: (Zone self, ZoneDelegate parent, Zone zone, String line) {
      parent.print(zone, line);
      // This is a hack to avoid
      // `setState() or markNeedsBuild() called during build`
      // error.
      Future.delayed(const Duration(milliseconds: 1), () {
        _debug?.addText(line);
      });
    },
  );

  runZonedGuarded(
    body,
    onError,
    zoneSpecification: zoneSpec,
  );
}

void onError(Object obj, StackTrace stack) {
  Analysis.recordException(obj);
  _debug?.addMultiline(obj, Colors.red);
  _debug?.addMultiline(stack, Colors.white);
}

Future<void> _initApp() async {
  await _initHive();
  await _setupStore();

  await loadFontFile(settingStore.fontPath.fetch());

  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    // ignore: avoid_print
    print('[${record.loggerName}][${record.level.name}]: ${record.message}');
  });
}

Future<void> _initHive() async {
  await Hive.initFlutter();
  // 以 typeId 为顺序
  Hive.registerAdapter(PrivateKeyInfoAdapter());
  Hive.registerAdapter(SnippetAdapter());
  Hive.registerAdapter(ServerPrivateInfoAdapter());
  Hive.registerAdapter(VirtKeyAdapter());
}

Future<void> _setupStore() async {
  await settingStore.init(boxName: 'setting');
  await serverStore.init(boxName: 'server');
  await privateKeyStore.init(boxName: 'key');
  await snippetStore.init(boxName: 'snippet');
  await dockerStore.init(boxName: 'docker');
}
