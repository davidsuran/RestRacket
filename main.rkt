#lang racket/gui

(require racket/gui
         request
         (for-syntax racket/struct-info)
         framework)

;(define-namespace-anchor here)
;(define ns (namespace-anchor->namespace here))

;(current-eventspace (make-eventspace))

(define (get-http-procedure verb-string)
  (cond
   [(equal? verb-string "POST") post]
   [(equal? verb-string "GET") get]
   [(equal? verb-string "PUT") put]
   [(equal? verb-string "DELETE") delete]
   [else (error (string-append "undefined http procedure: " verb-string))]))

(define keymap (keymap:get-editor))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


(define frame (new frame% [label "Rest"]
                   [width 600]
                   [height 600]))

(define options-panel (new panel% [parent frame][stretchable-height #f][min-height 60]))

(define url-panel (new horizontal-panel% [parent frame][stretchable-height #f][min-height 160]))

(define header-panel (new panel% [parent frame][stretchable-height #f][min-height 160]))

(define inputs-panel (new horizontal-panel% [parent frame][min-height 400]))

(define buttons-panel (new horizontal-panel% [parent frame][stretchable-height #t][min-height 60]))

(define *selected-verb* "POST")
(define (set-selected-verb! verb)
  (set! *selected-verb* verb))

(define http-verb-list-box (new list-box%
                           [parent options-panel]
                           [label "HTTP Verbs"]
                           [choices '("POST" "GET" "PUT" "DELETE")]
                           [selection 0]
                           [callback (λ (self event) (set-selected-verb! (send http-verb-list-box get-string (first (send http-verb-list-box get-selections)))))]
                           ))

(define message-header-canvas (new editor-canvas%
                           [parent header-panel]
                           [label "Editor Canvas"]
                           ))

(define message-header-text (new text%))
(send message-header-text insert "Authorization: Bearer OGE4Mjk0MTc0YjdlY2IyODAxNGI5Njk5MjIwMDE1Y2N8c3k2S0pzVDg=")
(send message-header-canvas set-editor message-header-text)
(send message-header-text set-keymap keymap)

(define message-body-canvas (new editor-canvas%
                           [parent inputs-panel]
                           [label "Editor Canvas"]
                           ))

(define message-body-text (new text%))
(send message-body-text insert "json")
(send message-body-canvas set-editor message-body-text)
(send message-body-text set-keymap keymap)

(define message-result-canvas (new editor-canvas%
                           [parent inputs-panel]
                           [label "Editor Canvas"]
                           ))

(define message-result-text (new text%))
(send message-result-text insert "result")
(send message-result-canvas set-editor message-result-text)
(send message-result-text set-keymap keymap)

(define url-canvas (new editor-canvas%
                           [parent url-panel]
                           [stretchable-width #t]
                           [label "Editor Canvas"]
                           ))

(define url-text (new text%))
(send url-text insert "eu-test.oppwa.com")
(send url-canvas set-editor url-text)
(send url-text set-keymap keymap)

(define url-params-canvas (new editor-canvas%
                           [parent url-panel]
                           [stretchable-width #t]
                           [label "Editor Canvas"]
                           ))

(define url-params-text (new text%))
(send url-params-text insert "v1/checkouts?entityId=8a8294174b7ecb28014b9699220015ca&amount=1.00&currency=EUR&paymentType=DB")
(send url-params-canvas set-editor url-params-text)
(send url-params-text set-keymap keymap)

(define (send-request-button-clicked)
  (send-request
   (get-http-procedure *selected-verb*)
   (send url-text get-text)
   (send url-params-text get-text)
   (send message-header-text get-text)
   (send message-body-text get-text)))

(define message
  (new message%
       [label "0"]
       [parent buttons-panel]
       [stretchable-width #t]))

(define send-button
  (new button%
       [label "Send"]
       [parent buttons-panel]
       [callback (λ (self event)
                   (send-request-button-clicked))]))

(define menu-bar (new menu-bar%
                      (parent frame)))
(define file-menu-bar (new menu%
     (label "&File")
     (parent menu-bar)))
(define edit-menu-bar (new menu%
     (label "&Edit")
     (parent menu-bar)))
(define help-menu-bar (new menu%
     (label "&Help")
     (parent menu-bar)))

(send frame show #t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (make-requester url)
  (make-domain-requester url (make-https-requester http-requester)))

(define body #"entityId=8a8294174b7ecb28014b9699220015ca&amount=1.00&currency=EUR&paymentType=DB")

(define entity-id "entityId=8a8294174b7ecb28014b9699220015ca")

(define (send-request verb-procedure base-url url-params header body)
  (let ([result (verb-procedure (make-requester base-url) url-params (string->bytes/utf-8 body) #:headers (list header))])
    ;(displayln result)
    (send message-result-text insert (http-response-body result))))
