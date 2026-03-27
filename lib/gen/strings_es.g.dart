///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:slang/generated.dart';
import 'strings.g.dart';

// Path: <root>
class TranslationsEs extends Translations with BaseTranslations<AppLocale, Translations> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsEs({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.es,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		super.$meta.setFlatMapFunction($meta.getTranslation); // copy base translations to super.$meta
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <es>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	@override dynamic operator[](String key) => $meta.getTranslation(key) ?? super.$meta.getTranslation(key);

	late final TranslationsEs _root = this; // ignore: unused_field

	@override 
	TranslationsEs $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsEs(meta: meta ?? this.$meta);

	// Translations
	@override late final _TranslationsCoreEs core = _TranslationsCoreEs._(_root);
	@override late final _TranslationsAuthEs auth = _TranslationsAuthEs._(_root);
	@override late final _TranslationsDashboardEs dashboard = _TranslationsDashboardEs._(_root);
	@override late final _TranslationsProfileEs profile = _TranslationsProfileEs._(_root);
	@override late final _TranslationsSettingsEs settings = _TranslationsSettingsEs._(_root);
}

// Path: core
class _TranslationsCoreEs extends TranslationsCoreEn {
	_TranslationsCoreEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get appName => 'Flutter Starter';
	@override late final _TranslationsCoreErrorEs error = _TranslationsCoreErrorEs._(_root);
	@override late final _TranslationsCoreActionEs action = _TranslationsCoreActionEs._(_root);
	@override late final _TranslationsCoreNavEs nav = _TranslationsCoreNavEs._(_root);
}

// Path: auth
class _TranslationsAuthEs extends TranslationsAuthEn {
	_TranslationsAuthEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get login => 'Iniciar sesión';
	@override String get register => 'Registrarse';
	@override String get logout => 'Cerrar sesión';
	@override String get email => 'Correo electrónico';
	@override String get password => 'Contraseña';
	@override String get name => 'Nombre';
	@override String get forgotPassword => '¿Olvidaste tu contraseña?';
	@override String get noAccount => '¿No tienes cuenta?';
	@override String get hasAccount => '¿Ya tienes cuenta?';
	@override String get welcomeBack => 'Bienvenido de nuevo';
	@override String get signInSubtitle => 'Inicia sesión en tu cuenta';
	@override String get createAccount => 'Crear cuenta';
	@override String get signUpSubtitle => 'Regístrate para comenzar';
	@override String get noAccountRegister => '¿No tienes cuenta? Regístrate';
	@override String get hasAccountLogin => '¿Ya tienes cuenta? Inicia sesión';
	@override late final _TranslationsAuthErrorEs error = _TranslationsAuthErrorEs._(_root);
	@override late final _TranslationsAuthValidationEs validation = _TranslationsAuthValidationEs._(_root);
}

// Path: dashboard
class _TranslationsDashboardEs extends TranslationsDashboardEn {
	_TranslationsDashboardEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Panel';
	@override String welcome({required Object name}) => 'Bienvenido, ${name}';
}

// Path: profile
class _TranslationsProfileEs extends TranslationsProfileEn {
	_TranslationsProfileEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Perfil';
	@override String get editProfile => 'Editar perfil';
	@override late final _TranslationsProfileFormEs form = _TranslationsProfileFormEs._(_root);
	@override late final _TranslationsProfileErrorEs error = _TranslationsProfileErrorEs._(_root);
}

// Path: settings
class _TranslationsSettingsEs extends TranslationsSettingsEn {
	_TranslationsSettingsEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Ajustes';
	@override String get theme => 'Tema';
	@override String get themeSystem => 'Sistema';
	@override String get themeLight => 'Claro';
	@override String get themeDark => 'Oscuro';
	@override String get language => 'Idioma';
	@override String get localeSystem => 'Sistema';
	@override String get localeEnglish => 'English';
	@override String get localeSpanish => 'Español';
}

// Path: core.error
class _TranslationsCoreErrorEs extends TranslationsCoreErrorEn {
	_TranslationsCoreErrorEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get unexpected => 'Ocurrió un error inesperado';
	@override String get noConnection => 'Sin conexión a internet';
	@override String get timeout => 'La solicitud ha expirado';
	@override String get serverError => 'Error del servidor. Inténtelo de nuevo más tarde.';
}

// Path: core.action
class _TranslationsCoreActionEs extends TranslationsCoreActionEn {
	_TranslationsCoreActionEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get retry => 'Reintentar';
	@override String get cancel => 'Cancelar';
	@override String get save => 'Guardar';
	@override String get delete => 'Eliminar';
	@override String get edit => 'Editar';
	@override String get ok => 'Aceptar';
}

// Path: core.nav
class _TranslationsCoreNavEs extends TranslationsCoreNavEn {
	_TranslationsCoreNavEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get dashboard => 'Panel';
	@override String get profile => 'Perfil';
	@override String get settings => 'Ajustes';
}

// Path: auth.error
class _TranslationsAuthErrorEs extends TranslationsAuthErrorEn {
	_TranslationsAuthErrorEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get invalidCredentials => 'Correo electrónico o contraseña inválidos';
	@override String get emailTaken => 'El correo electrónico ya está en uso';
	@override String get sessionExpired => 'Tu sesión ha expirado. Inicia sesión de nuevo.';
	@override String get serverError => 'Error de autenticación. Inténtelo de nuevo más tarde.';
}

// Path: auth.validation
class _TranslationsAuthValidationEs extends TranslationsAuthValidationEn {
	_TranslationsAuthValidationEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get emailRequired => 'Ingresa tu correo electrónico';
	@override String get passwordRequired => 'Ingresa tu contraseña';
	@override String get passwordTooShort => 'La contraseña debe tener al menos 8 caracteres';
	@override String get nameRequired => 'Ingresa tu nombre';
}

// Path: profile.form
class _TranslationsProfileFormEs extends TranslationsProfileFormEn {
	_TranslationsProfileFormEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get name => 'Nombre';
	@override String get bio => 'Biografía';
	@override String get phone => 'Teléfono';
	@override String get nameRequired => 'El nombre es obligatorio';
}

// Path: profile.error
class _TranslationsProfileErrorEs extends TranslationsProfileErrorEn {
	_TranslationsProfileErrorEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get loadFailed => 'No se pudo cargar el perfil';
	@override String get updateFailed => 'No se pudo actualizar el perfil';
}

/// The flat map containing all translations for locale <es>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on TranslationsEs {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'core.appName' => 'Flutter Starter',
			'core.error.unexpected' => 'Ocurrió un error inesperado',
			'core.error.noConnection' => 'Sin conexión a internet',
			'core.error.timeout' => 'La solicitud ha expirado',
			'core.error.serverError' => 'Error del servidor. Inténtelo de nuevo más tarde.',
			'core.action.retry' => 'Reintentar',
			'core.action.cancel' => 'Cancelar',
			'core.action.save' => 'Guardar',
			'core.action.delete' => 'Eliminar',
			'core.action.edit' => 'Editar',
			'core.action.ok' => 'Aceptar',
			'core.nav.dashboard' => 'Panel',
			'core.nav.profile' => 'Perfil',
			'core.nav.settings' => 'Ajustes',
			'auth.login' => 'Iniciar sesión',
			'auth.register' => 'Registrarse',
			'auth.logout' => 'Cerrar sesión',
			'auth.email' => 'Correo electrónico',
			'auth.password' => 'Contraseña',
			'auth.name' => 'Nombre',
			'auth.forgotPassword' => '¿Olvidaste tu contraseña?',
			'auth.noAccount' => '¿No tienes cuenta?',
			'auth.hasAccount' => '¿Ya tienes cuenta?',
			'auth.welcomeBack' => 'Bienvenido de nuevo',
			'auth.signInSubtitle' => 'Inicia sesión en tu cuenta',
			'auth.createAccount' => 'Crear cuenta',
			'auth.signUpSubtitle' => 'Regístrate para comenzar',
			'auth.noAccountRegister' => '¿No tienes cuenta? Regístrate',
			'auth.hasAccountLogin' => '¿Ya tienes cuenta? Inicia sesión',
			'auth.error.invalidCredentials' => 'Correo electrónico o contraseña inválidos',
			'auth.error.emailTaken' => 'El correo electrónico ya está en uso',
			'auth.error.sessionExpired' => 'Tu sesión ha expirado. Inicia sesión de nuevo.',
			'auth.error.serverError' => 'Error de autenticación. Inténtelo de nuevo más tarde.',
			'auth.validation.emailRequired' => 'Ingresa tu correo electrónico',
			'auth.validation.passwordRequired' => 'Ingresa tu contraseña',
			'auth.validation.passwordTooShort' => 'La contraseña debe tener al menos 8 caracteres',
			'auth.validation.nameRequired' => 'Ingresa tu nombre',
			'dashboard.title' => 'Panel',
			'dashboard.welcome' => ({required Object name}) => 'Bienvenido, ${name}',
			'profile.title' => 'Perfil',
			'profile.editProfile' => 'Editar perfil',
			'profile.form.name' => 'Nombre',
			'profile.form.bio' => 'Biografía',
			'profile.form.phone' => 'Teléfono',
			'profile.form.nameRequired' => 'El nombre es obligatorio',
			'profile.error.loadFailed' => 'No se pudo cargar el perfil',
			'profile.error.updateFailed' => 'No se pudo actualizar el perfil',
			'settings.title' => 'Ajustes',
			'settings.theme' => 'Tema',
			'settings.themeSystem' => 'Sistema',
			'settings.themeLight' => 'Claro',
			'settings.themeDark' => 'Oscuro',
			'settings.language' => 'Idioma',
			'settings.localeSystem' => 'Sistema',
			'settings.localeEnglish' => 'English',
			'settings.localeSpanish' => 'Español',
			_ => null,
		};
	}
}
