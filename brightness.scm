#! /usr/bin/csi -script
(require-extension shell)
(use posix)


(define (to-number string)
  (string->number 
   (car
    (string-split string))))


(define max-brightness-path
  "/sys/class/backlight/mba6x_backlight/max_brightness")
(define brightness-path
  "/sys/class/backlight/mba6x_backlight/brightness")

(define (brightness op)
  (let ((operation op)
	(max-brightness (to-number (read-all max-brightness-path)))
	(brightness (to-number (read-all brightness-path)))
	(change (lambda (x) (with-output-to-file brightness-path (lambda () (format #t "~A~%" x))))))
    (cond ((= brightness max-brightness) (if (eq? operation +)
					    'maximum
					    (change (operation brightness 10))))
	  ((= brightness 0) (if (eq? operation -)
				'minimum
				(change (operation brightness 10))))
	  (else (change (operation brightness 10))))))

(define (inc) (brightness +))
(define (dec) (brightness -))

((eval (with-input-from-string
	    (car (command-line-arguments))
	  read)))
