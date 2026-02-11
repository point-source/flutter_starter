///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

part of 'strings.g.dart';

// Path: <root>
typedef TranslationsEn = Translations; // ignore: unused_element
class Translations with BaseTranslations<AppLocale, Translations> {
	/// Returns the current translations of the given [context].
	///
	/// Usage:
	/// final t = Translations.of(context);
	static Translations of(BuildContext context) => InheritedLocaleData.of<AppLocale, Translations>(context).translations;

	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	Translations({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.en,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <en>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	dynamic operator[](String key) => $meta.getTranslation(key);

	late final Translations _root = this; // ignore: unused_field

	Translations $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => Translations(meta: meta ?? this.$meta);

	// Translations
	late final TranslationsCoreEn core = TranslationsCoreEn.internal(_root);
	late final TranslationsAuthEn auth = TranslationsAuthEn.internal(_root);
	late final TranslationsDashboardEn dashboard = TranslationsDashboardEn.internal(_root);
	late final TranslationsProfileEn profile = TranslationsProfileEn.internal(_root);
	late final TranslationsSettingsEn settings = TranslationsSettingsEn.internal(_root);
}

// Path: core
class TranslationsCoreEn {
	TranslationsCoreEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Flutter Starter'
	String get appName => 'Flutter Starter';

	late final TranslationsCoreErrorEn error = TranslationsCoreErrorEn.internal(_root);
	late final TranslationsCoreActionEn action = TranslationsCoreActionEn.internal(_root);
}

// Path: auth
class TranslationsAuthEn {
	TranslationsAuthEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Log In'
	String get login => 'Log In';

	/// en: 'Register'
	String get register => 'Register';

	/// en: 'Log Out'
	String get logout => 'Log Out';

	/// en: 'Email'
	String get email => 'Email';

	/// en: 'Password'
	String get password => 'Password';

	/// en: 'Name'
	String get name => 'Name';

	/// en: 'Forgot Password?'
	String get forgotPassword => 'Forgot Password?';

	/// en: 'Don't have an account?'
	String get noAccount => 'Don\'t have an account?';

	/// en: 'Already have an account?'
	String get hasAccount => 'Already have an account?';

	late final TranslationsAuthErrorEn error = TranslationsAuthErrorEn.internal(_root);
}

// Path: dashboard
class TranslationsDashboardEn {
	TranslationsDashboardEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Dashboard'
	String get title => 'Dashboard';

	/// en: 'Welcome, $name'
	String welcome({required Object name}) => 'Welcome, ${name}';
}

// Path: profile
class TranslationsProfileEn {
	TranslationsProfileEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Profile'
	String get title => 'Profile';

	/// en: 'Edit Profile'
	String get editProfile => 'Edit Profile';

	late final TranslationsProfileErrorEn error = TranslationsProfileErrorEn.internal(_root);
}

// Path: settings
class TranslationsSettingsEn {
	TranslationsSettingsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Settings'
	String get title => 'Settings';

	/// en: 'Theme'
	String get theme => 'Theme';

	/// en: 'System'
	String get themeSystem => 'System';

	/// en: 'Light'
	String get themeLight => 'Light';

	/// en: 'Dark'
	String get themeDark => 'Dark';

	/// en: 'Language'
	String get language => 'Language';
}

// Path: core.error
class TranslationsCoreErrorEn {
	TranslationsCoreErrorEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'An unexpected error occurred'
	String get unexpected => 'An unexpected error occurred';

	/// en: 'No internet connection'
	String get noConnection => 'No internet connection';

	/// en: 'Request timed out'
	String get timeout => 'Request timed out';

	/// en: 'Server error. Please try again later.'
	String get serverError => 'Server error. Please try again later.';
}

// Path: core.action
class TranslationsCoreActionEn {
	TranslationsCoreActionEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Retry'
	String get retry => 'Retry';

	/// en: 'Cancel'
	String get cancel => 'Cancel';

	/// en: 'Save'
	String get save => 'Save';

	/// en: 'Delete'
	String get delete => 'Delete';

	/// en: 'Edit'
	String get edit => 'Edit';

	/// en: 'OK'
	String get ok => 'OK';
}

// Path: auth.error
class TranslationsAuthErrorEn {
	TranslationsAuthErrorEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Invalid email or password'
	String get invalidCredentials => 'Invalid email or password';

	/// en: 'Email is already in use'
	String get emailTaken => 'Email is already in use';
}

// Path: profile.error
class TranslationsProfileErrorEn {
	TranslationsProfileErrorEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Failed to load profile'
	String get loadFailed => 'Failed to load profile';

	/// en: 'Failed to update profile'
	String get updateFailed => 'Failed to update profile';
}

/// The flat map containing all translations for locale <en>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on Translations {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'core.appName' => 'Flutter Starter',
			'core.error.unexpected' => 'An unexpected error occurred',
			'core.error.noConnection' => 'No internet connection',
			'core.error.timeout' => 'Request timed out',
			'core.error.serverError' => 'Server error. Please try again later.',
			'core.action.retry' => 'Retry',
			'core.action.cancel' => 'Cancel',
			'core.action.save' => 'Save',
			'core.action.delete' => 'Delete',
			'core.action.edit' => 'Edit',
			'core.action.ok' => 'OK',
			'auth.login' => 'Log In',
			'auth.register' => 'Register',
			'auth.logout' => 'Log Out',
			'auth.email' => 'Email',
			'auth.password' => 'Password',
			'auth.name' => 'Name',
			'auth.forgotPassword' => 'Forgot Password?',
			'auth.noAccount' => 'Don\'t have an account?',
			'auth.hasAccount' => 'Already have an account?',
			'auth.error.invalidCredentials' => 'Invalid email or password',
			'auth.error.emailTaken' => 'Email is already in use',
			'dashboard.title' => 'Dashboard',
			'dashboard.welcome' => ({required Object name}) => 'Welcome, ${name}',
			'profile.title' => 'Profile',
			'profile.editProfile' => 'Edit Profile',
			'profile.error.loadFailed' => 'Failed to load profile',
			'profile.error.updateFailed' => 'Failed to update profile',
			'settings.title' => 'Settings',
			'settings.theme' => 'Theme',
			'settings.themeSystem' => 'System',
			'settings.themeLight' => 'Light',
			'settings.themeDark' => 'Dark',
			'settings.language' => 'Language',
			_ => null,
		};
	}
}
