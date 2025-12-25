package main

import "core:fmt"

is_hiragana :: proc(r: rune) -> bool {
	return r >= 0x3040 && r <= 0x309F
}

is_katakana :: proc(r: rune) -> bool {
	return (r >= 0x30A0 && r <= 0x30FF) || (r >= 0xFF61 && r <= 0xFF9F) // Includes full-width and half-width katakana
}

is_kana :: proc(r: rune) -> bool {
	return is_hiragana(r) || is_katakana(r)
}

is_kanji :: proc(r: rune) -> bool {
	// Basic CJK Unified Ideographs (covers most common kanji)
	if r >= 0x4E00 && r <= 0x9FFF { return true }
	// Extension A
	if r >= 0x3400 && r <= 0x4DBF { return true }
	// CJK Radicals/Kangxi Radicals (optional, for components)
	if (r >= 0x2E80 && r <= 0x2EFF) || (r >= 0x2F00 && r <= 0x2FDF) { return true }
	// Add more extensions if needed (e.g., Ext B: 0x20000-0x2A6DF), but these are rarer
	return false
}

main :: proc() {
	text := "こんにちは世界！カナ andrey"

	for r in text {
		if is_kana(r) {
			fmt.printf("%r is kana (hiragana: %v, katakana: %v)\n", r, is_hiragana(r), is_katakana(r))
		} else if is_kanji(r) {
			fmt.printf("%r is kanji\n", r)
		} else {
			fmt.printf("%r is other (e.g., punctuation or non-Japanese)\n", r)
		}
	}
}
