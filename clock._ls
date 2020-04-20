; Main CLOCK function
(defun c:clock ()
	; init vars
	(setq 
    date (rtos(getvar "cdate")2 6)
    y (atoi(substr date 1 4))
    mo (atoi(substr date 5 2))
    d (atoi(substr date 7 2))
    h (atoi(substr date 10 2))
    m (atoi(substr date 12 2))
    s (atoi(substr date 14 2))
	)

	; Insert blocks for analog clock
  (command "_insert" "./hands.dwg" "0,0" "1" "1" "0" "")
  (setq hands (entget (entlast)))
  (command "_insert" "./handm.dwg" "0,0" "1" "1" "0" "")
  (setq handm (entget (entlast)))
  (command "_insert" "./handh.dwg" "0,0" "1" "1" "0" "")
  (setq handh (entget (entlast)))
  (command "_insert" "./case.dwg" "0,0" "1" "1" "0" "")


	; Draw text for digital clock
  (command "_text" "40,0" "8" "0" (strcat (itoa mo) "/" (itoa d) "/" (itoa y))"")
  (command "_text" "40,-10" "8" "0" (strcat (itoa h) ":" (itoa m) ":" (itoa s)) "")
  (setq digital (entget(entlast)))

	; iterate forever
  (while 
	   ; add 1 second per it, 1 minute per 60 it, 1 hour per 3600 it
		(setq s (rem (1+ s) 60))
		(if (eq s 0) (progn
			(setq m (rem (1+ m) 60))
			(if (eq m 0)
				(setq h (rem (1+ h) 24))
			)
		))
		
		; Modify blocks (already 90° oriented)
		; Modify Hand-Second, changing the rotation property by second
    (entmod 
      (subst 
        (cons 50 (RAD (* -6 s)))
        (assoc 50 hands)
        hands
    ))		

		; Modify Hand-Minute, changing the rotation property by minute + a tenth of second
    (entmod 
      (subst 
        (cons 50 (RAD (- (/ s -10) (* 6 m))))
        (assoc 50 handm)
        handm
		))

		; Modify Hand-Hour, changing the rotation property by hour and half minute
    (entmod 
      (subst 
        (cons 50 (RAD (* -0.5 (+ (* 60 h) m))))
        (assoc 50 handh)
        handh
		))

		; Modify Digital clock with the new values
		(entmod
	  		(subst
		 		(cons 1 (strcat (itoa h)  ":" (itoa m) ":" (itoa s)))
		 		(assoc 1 digital)
		 		digital
		))

		; Update the modified blocks // Doesn't seem to affect at all
		(entupd (cdr (assoc -1 hands)))
		;(entupd (cdr (assoc -1 handm)))
		;(entupd (cdr (assoc -1 handh)))
		;(entupd (cdr (assoc -1 digital)))

		; Wait for a second
	    (command "DELAY" 100)
	)
	
	;end function
  (princ)
)

; Aux function for Degrees to Radians conversion
(defun RAD (angdeg /) (* pi (/ angdeg 180.0)))
