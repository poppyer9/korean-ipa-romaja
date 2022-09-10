;;; korean-ipa-romaja.el --- An IPA enhanced romanization korean input method

;; * Header
;; Copyright (c) 2022, Poppyer

;; Author: Poppyer <poppyer@gmail.com>
;; Keywords: korean, IME

;; This file is not part of GNU Emacs.

;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License
;; as published by the Free Software Foundation; either version 3
;; of the License, or (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.

;;; Commentary:

;; This is an IPA enhanced romanization korean input method, notably:

;; - Focus on IPA(International Phonetic Alphabet) instead of Revised Romaja.
;; - Monophthongs are mapped to single key.
;; - Diphthongs starts with either [y] or [w].
;; - Auto insert initial empty sound(ㅇ) if possible, for example, [y]=위 [zy]=ㅟ.

;; |----+-----+---------+-----------+---------+------------------------------------------------------|
;; |    | Key | IPA     | Key       | Revised | Notes                                                |
;; |    |     |         | (Alter.)  | Romaja  |                                                      |
;; |----+-----+---------+-----------+---------+------------------------------------------------------|
;; | ㅓ | v   | /ʌ/     | O         | eo      | unrounded-/ɔ/; [v] looks like upside down /ʌ/        |
;; | ㅔ | e   | /e/     |           | e       |                                                      |
;; | ㅐ | f   | /ɛ/     | E         | ae      | [f] is a unused key and close to [e] key             |
;; | ㅟ | y   | /y, ɥi/ | ui^1      | wi      | rounded-/i/                                          |
;; | ㅚ | q   | /ø/     | oe^1      | oe      | rounded-/e/; [q] and /ø/ both look like modified [o] |
;; | ㅡ | w   | /ɯ/     |           | eu      | [w] looks like /ɯ/                                   |
;; |----+-----+---------+-----------+---------+------------------------------------------------------|
;; | ㅢ | wi  | /ɰi/    |           | ui      |                                                      |
;; | ㅘ | wa  | /wa/    |           | wa      |                                                      |
;; | ㅝ | wv  | /wʌ/    | wO / wo   | wo      |                                                      |
;; | ㅙ | wf  | /wɛ/    | wE        | wae     |                                                      |
;; | ㅞ | we  | /we/    |           | we      |                                                      |
;; |----+-----+---------+-----------+---------+------------------------------------------------------|
;; | ㅖ | ye  |         | ie^1      | ye      |                                                      |
;; | ㅒ | yf  |         | yE / iE^1 | yae     |                                                      |
;; |----+-----+---------+-----------+---------+------------------------------------------------------|
;; | ㄹ | r   |         | l         | r/l     |                                                      |
;; | ㅊ | c   |         |           | ch      |                                                      |
;; | ㅆ | S   |         |           |         |                                                      |
;; | ㅉ | J   |         |           |         |                                                      |
;; | ㅃ | B   |         | P         |         |                                                      |
;; | ㄲ | G   |         | K         |         |                                                      |
;; | ㄸ | D   |         | T         |         |                                                      |
;; | ㅇ | x   |         |           | ng      | Example: 오이  oxi; 외  oi; 우유  uxyu               |
;; |----+-----+---------+-----------+---------+------------------------------------------------------|
;; |    | z   |         |           |         | force jungseong only, don't auto insert empty ㅇ     |
;; |----+-----+---------+-----------+---------+------------------------------------------------------|
;; - ^0 IPA can be refered from https://en.wiktionary.org/wiki
;; - ^1 If |hangul-ipa-romaja-enable-compatible-double-chars| is set to |t|

;; Example:
;; - 서울 = svul OR sOul
;; - 한국어 = han gug xo
;; - 안녕하세요 = an nyvx ha se yo
;;             OR an nyOx ha se yo     
;; - 감사합니다 = gam sa hab ni da


;;; Code

;; (require 'hangul)

;; Enable merging compatible double chars, such as oe/ui/ie, etc.
;; Note that setting this to |t| means you will need to type [x] the empty ㅇ more often.
(defvar hangul-ipa-romaja-enable-compatible-double-chars nil)

;; Hangul IPA Romaja keymap.
;; It converts an ASCII code a-z, to the corresponding hangul Jamo
;; index. https://en.wikipedia.org/wiki/Hangul_Compatibility_Jamo
;;
;; Inspired from the original hangul 2-Bulsik mappings
;; a  b  c  d  e  f  g  h  i  j  k  l  m  n  o  p  q  r  s  t  u  v  w  x  y  z
;; 17 48 26 23 07 09 30 39 33 35 31 51 49 44 32 36 18 01 04 21 37 29 24 28 43 27
;; ㅁ ㅠ ㅊ ㅇ ㄷ ㄹ ㅎ ㅗ ㅑ ㅓ ㅏ ㅣ ㅡ ㅜ ㅐ ㅔ ㅂ ㄱ ㄴ ㅅ ㅕ ㅍ ㅈ ㅌ ㅛ ㅋ
;;             08                            34 38 19 02    22       25
;;             ㄸ                            ㅒ ㅖ ㅃ ㄲ    ㅆ       ㅉ
;;
(defconst hangul-ipa-romaja-keymap
  [31 18 26 07 36 32 01 30 51 24 27 09 17 04 39 29 42 09 21 28 44 35 49 23 47 -2])

(defun hangul-ipa-romaja-input-key (key)
  (let ((char (cond ((= key ?O) 35) ;; ㅓ
                    ((= key ?E) 32) ;; ㅐ
                    ((= key ?S) 22) ;; ㅆ
                    ((= key ?J) 25) ;; ㅉ 
		    ((or (= key ?B) (= key ?P)) 19) ;; ㅃ
		    ((or (= key ?G) (= key ?K)) 02) ;; ㄲ
		    ((or (= key ?D) (= key ?T)) 08) ;; ㄸ
                    (t (aref hangul-ipa-romaja-keymap (1- (% key 32)))))))
    (cond ((> char 0)
	   (if (< char 31)
            (hangul-ipa-romaja-input-cho-jong char)
	    (hangul-ipa-romaja-input-jung char)))
	  ((= char -2)
	   (quail-setup-overlays nil)
	   (setq hangul-queue (vector -2 0 0 0 0 0))
	   )
	  (t
	   (quail-setup-overlays nil)
	   (setq hangul-queue (make-vector 6 0))))))



(defsubst hangul-ipa-romaja-input-cho-jong (char)
  "Input for a Choseong position or a Jongseong position.
Unless the function inserts CHAR to `hangul-queue',
commit current `hangul-queue' and then set a new `hangul-queue',
and insert CHAR to new `hangul-queue'."
  (if (cond ((<= (aref hangul-queue 0) 0)
             (aset hangul-queue 0 char))
            ((and (zerop (aref hangul-queue 1))
                  (zerop (aref hangul-queue 2))
                  (notzerop (hangul-djamo 'cho (aref hangul-queue 0) char)))
             (aset hangul-queue 1 char))
            ((and (zerop (aref hangul-queue 4))
                  (notzerop (aref hangul-queue 2))
                  (numberp
                   (hangul-character
                    (+ (aref hangul-queue 0)
                       (hangul-djamo
                        'cho
                        (aref hangul-queue 0)
                        (aref hangul-queue 1)))
                    (+ (aref hangul-queue 2)
                       (hangul-djamo
                        'jung
                        (aref hangul-queue 2)
                        (aref hangul-queue 3)))
                    char)))
             (aset hangul-queue 4 char))
            ((and (zerop (aref hangul-queue 5))
                  (notzerop (hangul-djamo 'jong (aref hangul-queue 4) char))
                  (numberp
                   (hangul-character
                    (+ (aref hangul-queue 0)
                       (hangul-djamo
                        'cho
                        (aref hangul-queue 0)
                        (aref hangul-queue 1)))
                    (+ (aref hangul-queue 2)
                       (hangul-djamo
                        'jung
                        (aref hangul-queue 2)
                        (aref hangul-queue 3)))
                    (+ (aref hangul-queue 4)
                       (hangul-djamo
                        'jong
                        (aref hangul-queue 4)
                        char)))))
             (aset hangul-queue 5 char)))
      (hangul-insert-character hangul-queue)
    ;; Else finish the prev char and start a new char
    (hangul-insert-character hangul-queue
			     (setq hangul-queue (vector char 0 0 0 0 0)))))


(defsubst hangul-ipa-romaja-input-jung (char)
  "Input for a Jungseong position."
  (if (cond ((zerop (aref hangul-queue 2))
	     (if (zerop (aref hangul-queue 0))
		 (aset hangul-queue 0 23)) ;;ㅇ
	     (if (= -2 (aref hangul-queue 0))  ;; z
		 (aset hangul-queue 0 0))
             (aset hangul-queue 2 char))
            ((and (zerop (aref hangul-queue 3))
                  (zerop (aref hangul-queue 4)))
	     (cond
	      ;; ㅘㅙㅝㅞㅢ
	      ((= (aref hangul-queue 2) 49)  ;; ㅡ[w]
	       (cond ((memq char '(31 32))  ;;ㅏㅐ
		      (aset hangul-queue 2 39) ;; ㅗ
		      (aset hangul-queue 3 char)) 
		     ((memq char '(35 36))  ;;ㅓㅔ
		      (aset hangul-queue 2 44)  ;; ㅜ
		      (aset hangul-queue 3 char)) 
		     ((= char 51)  ;;ㅣ
		      (aset hangul-queue 3 char))
		     ((= char 39)  ;;ㅗ
		      (aset hangul-queue 2 44)   ;; ㅜ
		      (aset hangul-queue 3 35))  ;; ㅓ
		     )
	       )
	      ;; ㅑㅕㅖㅒㅛㅠ
	      ((or (= (aref hangul-queue 2) 47) ;; ㅟ[y]
		   (and hangul-ipa-romaja-enable-compatible-double-chars
			(= (aref hangul-queue 2) 51))) ;; ㅣ[i]
	       (cond ((memq char '(31 32 35 36))  
		      (aset hangul-queue 2 (+ char 2))
		      (aset hangul-queue 3 -1))
		     ((memq char '(39 44))  
		      (aset hangul-queue 2 (+ char 4))
		      (aset hangul-queue 3 -1))
		     )
	       )
	      ;; additional oe=ㅚ
	      ((and hangul-ipa-romaja-enable-compatible-double-chars
		    (= char 36)                   ;; ㅔ
		    (= (aref hangul-queue 2) 39)) ;; ㅗ
	       (aset hangul-queue 3 51))  ;; ㅣ
	      )
	     (if (notzerop (aref hangul-queue 3))
		 (if (= (aref hangul-queue 3) -1)
		     (aset hangul-queue 3 0)
		   t)
               (if (and hangul-ipa-romaja-enable-compatible-double-chars
		       (notzerop (hangul-djamo 'jung (aref hangul-queue 2) char)))
		   (aset hangul-queue 3 char))
               ))
	    )
      (hangul-insert-character hangul-queue)
    ;; Else finish the prev char and start a new char
    (let ((next-char (vector 23 0 char 0 0 0)))
      (cond ((notzerop (aref hangul-queue 5))
	     (aset next-char 0 (aref hangul-queue 5))
	     (aset hangul-queue 5 0))
	    ((notzerop (aref hangul-queue 4))
	     (aset next-char 0 (aref hangul-queue 4))
	     (aset hangul-queue 4 0)))
      (hangul-insert-character hangul-queue
			       (setq hangul-queue next-char))))
  )


(defun hangul-ipa-romaja-input-method (key)
  "Romaja-Extended input method."
  (if (or buffer-read-only (not (alphabetp key)))
      (list key)
    (quail-setup-overlays nil)
    (let ((input-method-function nil)
	  (echo-keystrokes 0)
	  (help-char nil))
      (setq hangul-queue (make-vector 6 0))
      (hangul-ipa-romaja-input-key key)
      (unwind-protect
	  (catch 'exit-input-loop
	    (while t
	      (let* ((seq (read-key-sequence nil))
		     (cmd (lookup-key hangul-im-keymap seq))
		     key)
		(cond ((and (stringp seq)
			    (= 1 (length seq))
			    (setq key (aref seq 0))
			    (alphabetp key))
		       (hangul-ipa-romaja-input-key key))
		      ((commandp cmd)
		       (call-interactively cmd))
		      (t
		       (setq unread-command-events
                             (nconc (listify-key-sequence seq)
                                    unread-command-events))
		       (throw 'exit-input-loop nil))))))
	(quail-delete-overlays)))))

(register-input-method
 "korean-ipa-romaja"
 "UTF-8"
 #'hangul-input-method-activate
 "한R"
 "Hangul IPA Romaja Input"
 'hangul-ipa-romaja-input-method
 "Input method: korean-ipa-romaja (mode line indicator:한R)\n\nHangul IPA Romaja input method.")

;; * Footer
(provide 'korean-ipa-romaja)
