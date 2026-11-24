extends GdUnitTestSuite
## Every visible HUD text exists in Spanish and English (GDD §12.5).

const KEYS: Array[StringName] = [
	&"HUD_DEFEAT",
	&"HUD_VICTORY",
	&"HUD_RETRY",
	&"TITLE_NEW_GAME",
	&"TITLE_CONTINUE",
	&"PAUSE_TO_TITLE",
	&"LOADING",
]


func after_test() -> void:
	TranslationServer.set_locale("es")


func test_keys_translate_in_both_languages() -> void:
	for locale: String in ["es", "en"]:
		TranslationServer.set_locale(locale)
		for key: StringName in KEYS:
			assert_str(tr(key)).is_not_equal(String(key))
			assert_str(tr(key)).is_not_empty()


func test_switching_language_changes_the_text() -> void:
	TranslationServer.set_locale("es")
	var es: String = tr(&"HUD_VICTORY")
	TranslationServer.set_locale("en")
	assert_str(tr(&"HUD_VICTORY")).is_not_equal(es)
	assert_str(tr(&"HUD_VICTORY")).is_equal("Victory")
