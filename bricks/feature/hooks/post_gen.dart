import 'dart:io';

import 'package:mason/mason.dart';

/// Clean up empty files left by conditional Mustache blocks.
///
/// When `dio: false`, the service, DTO, mapper, and Dio repository
/// templates render to empty strings. This hook removes those empty
/// files and any directories that become empty as a result.
void run(HookContext context) {
  final featureName = _toSnakeCase(context.vars['feature_name'] as String);
  for (final featureDir in [
    Directory('lib/features/$featureName'),
    Directory('test/features/$featureName'),
  ]) {
    if (!featureDir.existsSync()) continue;

    // Remove empty .dart files within generated feature output.
    for (final entity in featureDir.listSync(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        final contents = entity.readAsStringSync();
        if (contents.trim().isEmpty) {
          entity.deleteSync();
        } else {
          entity.writeAsStringSync('${contents.trimRight()}\n');
        }
      }
    }

    // Remove empty directories (depth-first).
    _removeEmptyDirs(featureDir);
    _formatDartFiles(featureDir, context);
    _normalizeEndOfFiles(featureDir);
  }
}

void _formatDartFiles(Directory root, HookContext context) {
  final files = root
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'))
      .map((file) => file.path)
      .toList();
  if (files.isEmpty) return;

  final result = Process.runSync(Platform.resolvedExecutable, [
    'format',
    '--line-length=80',
    ...files,
  ]);
  if (result.exitCode != 0) {
    context.logger.warn(
      'Generated the feature, but Dart formatting failed. Run '
      '`dart format lib test` before commit.',
    );
  }
}

void _normalizeEndOfFiles(Directory root) {
  for (final file
      in root
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.dart'))) {
    file.writeAsStringSync('${file.readAsStringSync().trimRight()}\n');
  }
}

void _removeEmptyDirs(Directory dir) {
  for (final entity in dir.listSync()) {
    if (entity is Directory) {
      _removeEmptyDirs(entity);
      if (entity.listSync().isEmpty) {
        entity.deleteSync();
      }
    }
  }
}

String _toSnakeCase(String input) => input
    .replaceAllMapped(RegExp(r'[A-Z]'), (m) => '_${m[0]!.toLowerCase()}')
    .replaceAll(RegExp(r'[-\s]'), '_')
    .replaceAll(RegExp(r'_+'), '_')
    .replaceAll(RegExp(r'^_'), '');
