#lang racket/gui

(require racket/gui
         request
         (for-syntax racket/struct-info)
         framework
         db
         json
         json/format/simple
         base64
         "sql.rkt")

;(define-namespace-anchor here)
;(define ns (namespace-anchor->namespace here))

;(current-eventspace (make-eventspace))

(define keymap (keymap:get-editor))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define frame (new frame% [label "Rest"]
                   [width 1000]
                   [height 600]))

(define options-panel (new panel% [parent frame][stretchable-height #f][min-height 60]))

(define url-panel (new horizontal-panel% [parent frame][stretchable-height #f][min-height 160]))

(define auth-panel (new horizontal-panel% [parent frame][stretchable-height #f][min-height 60]))

(define header-panel (new panel% [parent frame][stretchable-height #f][min-height 160]))

(define inputs-panel (new horizontal-panel% [parent frame][min-height 400]))

(define buttons-panel (new horizontal-panel% [parent frame][stretchable-height #t][min-height 60]))

(define *selected-verb* "POST")
(define (set-selected-verb! verb)
  (set! *selected-verb* verb))

; http verbs
(define http-verb-list-box (new list-box%
                           [parent options-panel]
                           [label "HTTP"]
                           [choices '("POST" "GET" "PUT" "DELETE")]
                           [selection 0]
                           [callback (λ (self event) (set-selected-verb! (send http-verb-list-box get-string (first (send http-verb-list-box get-selections)))))]
                           ))

; header
(define message-header-canvas (new editor-canvas%
                           [parent header-panel]
                           [label "Editor Canvas"]
                           ))

(define message-header-text (new text% [auto-wrap #t]))
(send message-header-canvas set-editor message-header-text)
(send message-header-text set-keymap keymap)

; auth
(define auth-name-canvas (new editor-canvas%
                           [parent auth-panel]
                           [stretchable-width #t]
                           [label "Editor Canvas"]
                           ))

(define auth-name-text (new text% [auto-wrap #t]))
(send auth-name-canvas set-editor auth-name-text)
(send auth-name-text set-keymap keymap)

(define auth-pass-canvas (new editor-canvas%
                           [parent auth-panel]
                           [stretchable-width #t]
                           [label "Editor Canvas"]
                           ))

(define auth-pass-text (new text% [auto-wrap #t]))
(send auth-pass-canvas set-editor auth-pass-text)
(send auth-pass-text set-keymap keymap)

(define generate-auth-button (new button%
                                  [label "Generate"]
                                  [parent auth-panel]
                                  [callback (λ (self event)
                                              (generate-auth-button-clicked))]))

; url
(define url-canvas (new editor-canvas%
                           [parent url-panel]
                           [stretchable-width #t]
                           [label "Editor Canvas"]
                           ))

(define url-text (new text% [auto-wrap #t]))
(send url-canvas set-editor url-text)
(send url-text set-keymap keymap)

(define url-params-canvas (new editor-canvas%
                           [parent url-panel]
                           [stretchable-width #t]
                           [label "Editor Canvas"]
                           ))

(define url-params-text (new text% [auto-wrap #t]))
(send url-params-canvas set-editor url-params-text)
(send url-params-text set-keymap keymap)

; body and result
(define message-body-canvas (new editor-canvas%
                           [parent inputs-panel]
                           [label "Editor Canvas"]
                           ))

(define message-body-text (new text% [auto-wrap #t]))
(send message-body-canvas set-editor message-body-text)
(send message-body-text set-keymap keymap)

(define message-result-canvas (new editor-canvas%
                           [parent inputs-panel]
                           [label "Editor Canvas"]
                           ))

(define message-result-text (new text% [auto-wrap #t]))
(send message-result-canvas set-editor message-result-text)
(send message-result-text set-keymap keymap)

(define (send-request-button-clicked)
  (send-request
   *selected-verb*
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

(define (generate-auth-button-clicked)
  (send message-header-text
        insert
        (basic-auth (send auth-name-text get-text) (send auth-pass-text get-text))))

(define (basic-auth name password)
  (string-append
         "Authorization: Basic "
         (bytes->string/utf-8
          (base64-encode
           (string->bytes/utf-8
            (string-append name ":" password))))))

(define set-texts
  (let ([result last-opened-request-safe])
    (send url-text insert (vector-ref result 1))
    (send url-params-text insert (vector-ref result 2))
    (send message-header-text insert (vector-ref result 3))
    (send message-body-text insert (vector-ref result 4))))

(define (make-requester url)
  (make-domain-requester url (make-https-requester http-requester)))

(define (send-request verb-string base-url url-params header body)
 (let ([result (cond
   [(equal? verb-string "POST")
    (post (make-requester base-url) url-params (string->bytes/utf-8 body) #:headers (list header))]
   [(equal? verb-string "GET")
    (get (make-requester base-url) url-params #:headers (list header))]
   [(equal? verb-string "PUT")
    (put (make-requester base-url) url-params (string->bytes/utf-8 body) #:headers (list header))]
   [(equal? verb-string "DELETE")
    (delete (make-requester base-url) url-params #:headers (list header))]
   [else (error (string-append "undefined http procedure: " verb-string))])])
   (let ([response-body (http-response-body result)])
     (send message-result-text insert
           (if (jsexpr? response-body)
               (jsexpr->pretty-json (string->jsexpr response-body))
               response-body)))))

(module+ test
  (require rackunit)
  (send frame show #f)
  (check-equal? (basic-auth "aaaa@cccc" "bbbb")
                "Authorization: Basic YWFhYUBjY2NjOmJiYmI"))
