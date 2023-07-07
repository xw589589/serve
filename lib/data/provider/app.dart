import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app.g.dart';

@riverpod
class AppProvider extends _$AppProvider {
  @override
  AppProvider build() => AppProvider();

  int? _newestBuild;
  int? get newestBuild => _newestBuild;

  bool _moveBg = true;
  bool get moveBg => _moveBg;

  void setNewestBuild(int build) {
    _newestBuild = build;
  }

  void setCanMoveBg(bool moveBg) {
    _moveBg = moveBg;
  }
}
