;; This is an IPA enhanced romanization korean input method, notably:

;; * Focus on IPA(International Phonetic Alphabet) instead of Revised Romaja.
;; * Monophthongs are mapped to single key.
;; * Diphthongs starts with either [y] or [w].
;; * Auto insert initial empty sound(ㅇ) if possible, for example, [y]=위 [zy]=ㅟ.

;; |----+------------+---------+---------------+---------+------------------------------------------------------|
;; |    | Input Key  | IPA     | Input Key     | Revised | Notes                                                |
;; |    | (Prefered) |         | (Alternative) | Romaja  |                                                      |
;; |----+------------+---------+---------------+---------+------------------------------------------------------|
;; | ㅓ | v          | /ʌ/     | O             | eo      | unrounded-/ɔ/; [v] looks like upside down /ʌ/        |
;; | ㅔ | e          | /e/     |               | e       |                                                      |
;; | ㅐ | f          | /ɛ/     | E             | ae      | [f] is a unused key and close to [e] key             |
;; | ㅟ | y          | /y, ɥi/ | ui^1          | wi      | rounded-/i/                                          |
;; | ㅚ | q          | /ø/     | oe^1          | oe      | rounded-/e/; [q] and /ø/ both look like modified [o] |
;; | ㅡ | w          | /ɯ/     |               | eu      | [w] looks like /ɯ/                                   |
;; |----+------------+---------+---------------+---------+------------------------------------------------------|
;; | ㅢ | *wi*       | /ɰi/    |               | ui      |                                                      |
;; | ㅘ | wa         | /wa/    |               | wa      |                                                      |
;; | ㅝ | wv         | /wʌ/    | wO / wo       | wo      |                                                      |
;; | ㅙ | wf         | /wɛ/    | wE            | wae     |                                                      |
;; | ㅞ | we         | /we/    |               | we      |                                                      |
;; |----+------------+---------+---------------+---------+------------------------------------------------------|
;; | ㅖ | ye         |         | ie^1          | ye      |                                                      |
;; | ㅒ | yf         |         | yE / iE^1     | yae     |                                                      |
;; |----+------------+---------+---------------+---------+------------------------------------------------------|
;; | ㄹ | r          |         | l             | r/l     |                                                      |
;; | ㅊ | c          |         |               | ch      |                                                      |
;; | ㅆ | S          |         |               |         |                                                      |
;; | ㅉ | J          |         |               |         |                                                      |
;; | ㅃ | B          |         | P             |         |                                                      |
;; | ㄲ | G          |         | K             |         |                                                      |
;; | ㄸ | D          |         | T             |         |                                                      |
;; | ㅇ | x          |         |               | ng      | Example: 오이  oxi; 외  oi; 우유  uxyu               |
;; |----+------------+---------+---------------+---------+------------------------------------------------------|
;; |    | z          |         |               |         | force jungseong only, don't auto insert empty ㅇ     |
;; |----+------------+---------+---------------+---------+------------------------------------------------------|
;;
;; * ^0 IPA can be refered from https://en.wiktionary.org/wiki
;; * ^1 If |hangul-ipa-romaja-enable-compatible-double-chars| is set to |t|

;; Example:
;; * 서울 = svul OR sOul  
;; * 한국어 = han gug xo
;; * 안녕하세요 = an nyvx ha se yo
;;             OR an nyOx ha se yo     
;; * 감사합니다 = gam sa hab ni da
