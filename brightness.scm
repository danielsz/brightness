#! /usr/bin/chicken-csi -script
(require-extension shell)
(import (chicken file posix)
	(chicken process-context)
	(chicken port)
	(chicken io)
	(chicken string)
	(chicken format)
	args)

(define (to-number string)
  (string->number 
   (car
    (string-split string))))

(define (read-all file)
  (call-with-input-file file (lambda (port) (read-string #f port))))

(define max-brightness-path
  "/sys/class/backlight/intel_backlight/max_brightness")
(define brightness-path
  "/sys/class/backlight/intel_backlight/brightness")

(define (brightness op)
  (let ((lumen 500)
	(max-brightness (to-number (read-all max-brightness-path)))
	(brightness (to-number (read-all brightness-path)))
	(change (lambda (x) (with-output-to-file brightness-path (lambda () (format #t "~A~%" x))))))
    (cond ((= brightness max-brightness) (if (eq? op +)
					    'maximum
					    (change (op brightness lumen))))
	  ((= brightness 0) (if (eq? op -)
				'minimum
				(change (op brightness lumen))))
	  (else (change (op brightness lumen))))))

(define (inc) (brightness +))
(define (dec) (brightness -))

((eval (with-input-from-string
	    (car (command-line-arguments))
	  read)))
