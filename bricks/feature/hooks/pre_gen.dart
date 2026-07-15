import 'dart:convert';
import 'dart:io';

import 'package:mason/mason.dart';

const _installMessage =
    'REST-backed generation requires the supported '
    'Dio/Retrofit foundation. Run `mason make dio_rest` from the project root '
    'and retry. No feature files were generated.';

/// Stop REST generation before rendering when its foundation is not installed.
void run(HookContext context) {
  if (context.vars['dio'] != true) return;

  final problem = validateDioRestCapability();
  if (problem == null) return;

  final message = '$problem\n$_installMessage';
  context.logger.err(message);
  throw StateError(message);
}

/// Return a repair detail, or `null` when the REST capability is coherent.
String? validateDioRestCapability({Directory? root}) {
  final project = root ?? Directory.current;
  File inProject(String path) => File('${project.path}/$path');

  final marker = inProject('.flutter_starter/capabilities/dio_rest.json');
  if (!marker.existsSync()) return 'The dio_rest capability marker is absent.';

  try {
    final value = jsonDecode(marker.readAsStringSync());
    if (value is! Map<String, dynamic> ||
        value['capability'] != 'dio_rest' ||
        value['version'] != 1) {
      return 'The dio_rest capability marker is unsupported or malformed.';
    }
  } on FormatException {
    return 'The dio_rest capability marker is not valid JSON.';
  }

  for (final path in [
    'lib/core/http/dio_provider.dart',
    'lib/core/http/dio_api_exception.dart',
    'lib/core/http/rest_config.dart',
  ]) {
    if (!inProject(path).existsSync()) {
      return 'The dio_rest installation is incomplete: missing $path.';
    }
  }

  final pubspec = inProject('pubspec.yaml');
  if (!pubspec.existsSync()) return 'pubspec.yaml was not found.';
  final source = pubspec.readAsStringSync();
  if (!RegExp(r'^  dio:', multiLine: true).hasMatch(source) ||
      !RegExp(r'^  retrofit:', multiLine: true).hasMatch(source) ||
      !RegExp(r'^  retrofit_generator:', multiLine: true).hasMatch(source)) {
    return 'The dio_rest dependencies are incomplete in pubspec.yaml.';
  }
  return null;
}
