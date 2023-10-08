#lang racket/gui

(require "request-body-gui.rkt")


(define app-window (new frame% [label "Rest GUI"]
                   [width 1500]
                   [height 1000]))


(define menu-bar (new menu-bar%
                      (parent app-window)))
(define file-menu-bar (new menu%
     (label "&File")
     (parent menu-bar)))
(define edit-menu-bar (new menu%
     (label "&Edit")
     (parent menu-bar)))
(define help-menu-bar (new menu%
     (label "&Help")
     (parent menu-bar)))

(define request-tabs-panel (new tab-panel%
                                [choices '("Tab1")]
                                [parent app-window]))

(define options-panel (new panel% [parent app-window][stretchable-height #f][min-height 60]))




;(set-window-visibility #t)

;(get-request-frame app-window)
;(send options-panel reparent request-tabs-panel)

(send app-window show #t)

(make-request-tab app-window)

;(fill-tab-content tab-panel)


;(define frame
;  (new frame% [label "Tabs!"]))

;(define (change-tab tp event)
;  (when (eq? (send event get-event-type) 'tab-panel)
;    (fill-tab-content tp)))

;(define (fill-tab-content tp)
;  (define current-tab-name
;      (send tp get-item-label (send tp get-selection)))
;    (send tp change-children
;          (lambda (c*)
;            (list
;             (new message%
;                  [label (~a "You have selected: " current-tab-name)]
;                  [parent tp])))))

;(define tab-panel
;  (new tab-panel%
;       [parent frame]
;       [choices (list "Tab 0")]
;       [callback change-tab]))

;(send frame show #t)
;(fill-tab-content tab-panel)















