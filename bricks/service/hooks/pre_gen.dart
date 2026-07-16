import 'dart:convert';
import 'dart:io';

import 'package:mason/mason.dart';

/// Require the supported REST foundation before rendering service files.
void run(HookContext context) {
  final problem = _validateCapability();
  if (problem == null) return;
  final message =
      '$problem REST service generation requires dio_rest. '
      'Run `mason make dio_rest` from the project root and retry. No service '
      'files were generated.';
  context.logger.err(message);
  throw StateError(message);
}

String? _validateCapability() {
  final marker = File('.flutter_starter/capabilities/dio_rest.json');
  if (!marker.existsSync()) return 'The dio_rest capability marker is absent.';
  try {
    final value = jsonDecode(marker.readAsStringSync());
    if (value is! Map<String, dynamic> ||
        value['capability'] != 'dio_rest' ||
        value['version'] != 1) {
      return 'The dio_rest capability marker is unsupported.';
    }
  } on FormatException {
    return 'The dio_rest capability marker is malformed.';
  }
  if (!File('lib/core/http/dio_provider.dart').existsSync() ||
      !File('lib/core/http/dio_api_exception.dart').existsSync() ||
      !File('lib/core/http/rest_config.dart').existsSync()) {
    return 'The dio_rest foundation is incomplete.';
  }
  return null;
}
