# Dio REST capability

This project deliberately selected the starter's Dio and Retrofit capability
with:

```bash
mason make dio_rest
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

The opt-in owns the files under `lib/core/http/`, the `dio` and `retrofit`
dependencies, the Retrofit generator configuration, and the
`.flutter_starter/capabilities/dio_rest.json` marker. Removing the capability
means removing those additions together; application repositories continue to
expose `Result<T>` rather than Dio exceptions.

## Required configuration

Set `REST_API_URL` to the absolute HTTP(S) base URL for each environment in
`config/<environment>.json`. The opt-in adds example values under
`config/examples/`; run `./scripts/setup.sh` to copy them when needed.

Run the app with the selected file:

```bash
flutter run --dart-define-from-file=config/development.json
```

The shared client validates this value when it is first read. A missing, blank,
or non-HTTP(S) value throws a setup error naming `REST_API_URL` before any
request is sent.

## Generate a REST-backed feature

```bash
mason make feature --feature_name orders --dio true
dart run build_runner build --delete-conflicting-outputs
```

Generated repositories catch transport exceptions and return feature failures
through the same public `Result<T>` contract used by mock repositories. Dio
types stay inside the data layer.

This capability relies on the platform's normal TLS validation. It does not add
a certificate-pinning setting or implementation.
