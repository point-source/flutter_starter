import 'dart:io';
import 'dart:convert';

import 'package:mason/mason.dart';

const _pubspecDependencies = '''  # REST networking (installed by dio_rest)
  dio: ^5.7.0
  retrofit: ^4.9.2

''';

const _pubspecDevDependency = '  retrofit_generator: ^10.2.1\n';

const _retrofitBuilder =
    '''      # Retrofit code generation (installed by dio_rest)
      retrofit_generator:
        enabled: true
        generate_for:
          include:
            - lib/features/**/data/services/**

''';

/// Add the dependency and generator declarations consumed by the REST brick.
///
/// Existing declarations are left alone, making a repeated opt-in safe. If a
/// supported insertion point is missing, both metadata files are restored and
/// the generated capability files are removed.
void run(HookContext context) {
  final pubspec = File('pubspec.yaml');
  final build = File('build.yaml');
  final configFiles = <File>[
    File('config/examples/development.json'),
    File('config/examples/staging.json'),
    File('config/examples/production.json'),
  ];

  if (!pubspec.existsSync() ||
      !build.existsSync() ||
      configFiles.any((file) => !file.existsSync())) {
    _abort(context, 'dio_rest must run from the Flutter project root.');
  }

  final originalPubspec = pubspec.readAsStringSync();
  final originalBuild = build.readAsStringSync();
  final originalConfigs = {
    for (final file in configFiles) file.path: file.readAsStringSync(),
  };

  try {
    final updatedPubspec = _updatePubspec(originalPubspec);
    final updatedBuild = _updateBuild(originalBuild);
    pubspec.writeAsStringSync(updatedPubspec);
    build.writeAsStringSync(updatedBuild);
    _updateConfigExamples(configFiles);
    context.logger.success(
      'REST capability installed. Set REST_API_URL in config/examples/*.json, '
      'then run flutter pub get and build_runner.',
    );
  } on FormatException catch (error) {
    pubspec.writeAsStringSync(originalPubspec);
    build.writeAsStringSync(originalBuild);
    for (final entry in originalConfigs.entries) {
      File(entry.key).writeAsStringSync(entry.value);
    }
    _removeGeneratedCapability();
    _abort(context, error.message);
  }
}

void _updateConfigExamples(List<File> files) {
  const exampleUrls = {
    'development': 'http://localhost:3000',
    'staging': 'https://api-staging.example.com',
    'production': 'https://api.example.com',
  };

  for (final file in files) {
    final decoded = jsonDecode(file.readAsStringSync());
    if (decoded is! Map<String, dynamic>) {
      throw FormatException('${file.path} must contain a JSON object.');
    }
    final environment = decoded['ENVIRONMENT'];
    if (environment is! String || !exampleUrls.containsKey(environment)) {
      throw FormatException(
        '${file.path} must declare a supported ENVIRONMENT before dio_rest '
        'can add its endpoint.',
      );
    }
    decoded.putIfAbsent('REST_API_URL', () => exampleUrls[environment]!);
    file.writeAsStringSync(
      '${const JsonEncoder.withIndent('  ').convert(decoded)}\n',
    );
  }
}

String _updatePubspec(String source) {
  var result = source;
  if (!RegExp(r'^  dio:', multiLine: true).hasMatch(result)) {
    const anchor = '  # Connectivity\n';
    if (!result.contains(anchor)) {
      throw const FormatException(
        'Could not locate the Connectivity section in pubspec.yaml. No '
        'changes were kept; add the REST dependencies manually or update the '
        'starter before retrying.',
      );
    }
    result = result.replaceFirst(anchor, '$_pubspecDependencies$anchor');
  }

  if (!RegExp(r'^  retrofit_generator:', multiLine: true).hasMatch(result)) {
    const anchor = '  dart_mappable_builder:';
    if (!result.contains(anchor)) {
      throw const FormatException(
        'Could not locate dart_mappable_builder in pubspec.yaml. No changes '
        'were kept.',
      );
    }
    result = result.replaceFirst(anchor, '$_pubspecDevDependency$anchor');
  }
  return result;
}

String _updateBuild(String source) {
  if (RegExp(r'^      retrofit_generator:', multiLine: true).hasMatch(source)) {
    return source;
  }
  const anchor = '      # dart_mappable code generation\n';
  if (!source.contains(anchor)) {
    throw const FormatException(
      'Could not locate the dart_mappable builder in build.yaml. No changes '
      'were kept.',
    );
  }
  return source.replaceFirst(anchor, '$_retrofitBuilder$anchor');
}

Never _abort(HookContext context, String message) {
  context.logger.err(message);
  throw StateError(message);
}

void _removeGeneratedCapability() {
  for (final path in [
    '.flutter_starter/capabilities/dio_rest.json',
    'lib/core/http/dio_api_exception.dart',
    'lib/core/http/dio_provider.dart',
    'lib/core/http/rest_config.dart',
    'lib/core/http/interceptors/error_interceptor.dart',
    'lib/core/http/interceptors/logging_interceptor.dart',
  ]) {
    final file = File(path);
    if (file.existsSync()) file.deleteSync();
  }
}
