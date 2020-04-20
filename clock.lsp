; Main CLOCK function
(defun c:clock ()
  ; Setup
  (setup)

  ; Draw analog clock
  (analog)

  ; Draw digital clock
  (digital)

  ; Show properly
  (frame)

  ; Iterate forever
  (while
    ; Add 1 second per it, 1 minute per 60 it, 1 hour per 3600 it
    (setq s (rem (1+ s) 60))
    (if (eq s 0) (progn
      (setq m (rem (1+ m) 60))
      (if (eq m 0)
        (setq h (rem (1+ h) 24))
      )
    ))

    ;;; Modify blocks (already 90° oriented)
    ; Modify Hand-Second, changing the rotation property by second
    (change 50 hands (RAD(* -6 s)))
    ; Modify Hand-Minute, changing the rotation property by minute + seconds/10
    (change 50 handm (RAD(- (/ s -10) (* 6 m))))
    ; Modify Hand-Hour, changing the rotation property by hour and half minute
    (change 50 handh (RAD(* -0.5 (+ (* 60 h) m))))

    ; Modify Digital clock with the new values
    (change 1 digital (strcat (itoa h)  ":" (itoa m) ":" (itoa s)))
    
    ; Wait for a second
    (command "DELAY" 1000)
  )
)

(defun setup()
  ; Clean canvas
  (command "ERASE" "All" "")
  ; Set vars
  (setq 
    date (rtos(getvar "cdate") 2 6)
    y (atoi(substr date 1 4))
    mo (atoi(substr date 5 2))
    d (atoi(substr date 7 2))
    h (atoi(substr date 10 2))
    m (atoi(substr date 12 2))
    s (atoi(substr date 14 2))
    )
)

; Insert drawings as blocks
(defun analog()
  (command "INSERT" "./case.dwg"  "0,0" "1" "1" "0" "")
  (command "INSERT" "./handh.dwg" "0,0" "1" "1" "0" "")
  (setq handh (entget (entlast)))
  (command "INSERT" "./handm.dwg" "0,0" "1" "1" "0" "")
  (setq handm (entget (entlast)))
  (command "INSERT" "./hands.dwg" "0,0" "1" "1" "0" "")
  (setq hands (entget (entlast)))
)

; Draw text next to analog clock
(defun digital()
  (command "_text" "40,0" "8" "0" (strcat (itoa mo) "/" (itoa d) "/" (itoa y))"")
  (command "_text" "40,-10" "8" "0" (strcat (itoa h) ":" (itoa m) ":" (itoa s)) "")
  (setq digital (entget(entlast)))
)

; Show analog & digital clock
(defun frame()
  (command "ZOOM" "All" "")
)

; Modify property
(defun change (num entity prop)
  (entmod 
    (subst 
      (cons num prop)
      (assoc num entity)
      entity
  ))
)

; Aux function for Degrees to Radians conversion
(defun RAD (deg /) (* pi (/ deg 180.0)))
