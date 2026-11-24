class_name SupportText
extends RefCounted
## The Apoyo as text for the menus (F8 task 6): the total, then each ayllu won and its
## state. Every text goes through tr().

const LEVEL_KEYS: Array[StringName] = [&"SUPPORT_NEUTRAL", &"SUPPORT_SYMPATHIZER", &"SUPPORT_ALLY"]


static func summary(support: SupportLedger) -> String:
	var lines: PackedStringArray = PackedStringArray()
	lines.append(TranslationServer.translate(&"PAUSE_SUPPORT").format({"total": support.total()}))
	for a: AylluData in support.tuning.ayllus:
		var level: SupportLedger.Level = support.level(a.id)
		if level != SupportLedger.Level.NEUTRAL:
			lines.append(
				(
					"%s · %s"
					% [
						TranslationServer.translate(a.title),
						TranslationServer.translate(LEVEL_KEYS[level])
					]
				)
			)
	return "\n".join(lines)
