package main

import "core:fmt"
import "core:unicode/utf8"

append_word :: proc(buffer:^[dynamic]rune, words:^[dynamic]string, lastRune:rune){
	pop(buffer)
	buffer_word:= ""
	buffer_word = utf8.runes_to_string(buffer[:])
	append(words,buffer_word)
	clear(buffer)

	//append the last rune that is used to split the sentence
	r:[]rune= {lastRune}
	buffer_word = utf8.runes_to_string(r)
	append(words,buffer_word)
	clear(buffer)
}

parse_sentence :: proc(text: string){

	buffer_katakana := make([dynamic]rune,context.temp_allocator)
	buffer_hiragana := make([dynamic]rune,context.temp_allocator)
	buffer_kanji := make([dynamic]rune,context.temp_allocator)

	parsing_katakana := false
	parsing_hiragana := false
	parsing_kana:= false
	parsing_kanji:= false

	words := make([dynamic]string,context.temp_allocator)

	for r in text {

		if is_kanji(r){
			parsing_kanji = true
		}
		if is_kana(r) {
			parsing_kana = true
			if is_katakana(r){
				parsing_katakana = true
			}
			if is_hiragana(r){
				parsing_hiragana = true
			}
		 }

		if parsing_kana {
			if parsing_katakana{
				append(&buffer_katakana,r)
			}
			if parsing_hiragana{
				append(&buffer_hiragana,r)
			}
		}

		if parsing_kanji {
			append(&buffer_kanji,r)
		}


		if len(buffer_katakana) > 3{
			append_word(&buffer_katakana,&words,'　')
			parsing_katakana = false
		}
		if len(buffer_hiragana) > 3{
			append_word(&buffer_hiragana,&words, '　')
			parsing_hiragana = false
		}

		switch r {
			case 'の':
				if parsing_kanji {
					append_word(&buffer_kanji,&words,'の')
					parsing_kanji = false
				}
				if parsing_hiragana {
					append_word(&buffer_hiragana,&words,'の')
					parsing_hiragana = false
				}
				if parsing_katakana {
					append_word(&buffer_katakana,&words,'の')
					parsing_katakana = false
				}
			case '　':
				if parsing_kanji {
					append_word(&buffer_kanji,&words,'　')
					parsing_kanji = false
				}
				if parsing_hiragana {
					append_word(&buffer_hiragana,&words,'　')
					parsing_hiragana = false
				}
				if parsing_katakana {
					append_word(&buffer_katakana,&words,'　')
					parsing_katakana = false
				}
		}
	}

	fmt.printfln("words: %s",words)
}


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
	text := "上野動物園のパンダ　見ることができるのは「あと1か月」東京の上野動物園の双子のパンダ「シャオシャオ」と「レイレイ」は、1月に中国に帰ります。"
	parse_sentence(text)

}
