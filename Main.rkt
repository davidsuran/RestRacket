#lang racket

(require racket/gui
         request
         (for-syntax racket/struct-info))

(define count 0)
(define (update-count! f)
  (set! count (f count))
  (send message set-label (~a count)))

(current-eventspace (make-eventspace))

(define frame (new frame% [label "Rest-post"]
                   [width 600]
                   [height 300]))

(define options-panel (new panel% [parent frame][stretchable-height #f][min-height 60]))

(define url-panel (new panel% [parent frame][stretchable-height #f][min-height 60]))

(define header-panel (new panel% [parent frame][stretchable-height #f][min-height 160]))

(define inputs-panel (new horizontal-panel% [parent frame][min-height 400]))

(define buttons-panel (new horizontal-panel% [parent frame][stretchable-height #t][min-height 60]))


(define http-verb-list-box (new list-box%
                           [parent options-panel]
                           [label "HTTP Verbs"]
                           [choices '("POST" "GET" "PUT" "DELETE")]                         
                           ))


(define message-header-canvas (new editor-canvas%
                           [parent header-panel]
                           [label "Editor Canvas"]
                           ))

(define message-header-text (new text%))
(send message-header-text insert "header")
(send message-header-canvas set-editor message-header-text)

(define message-body-canvas (new editor-canvas%
                           [parent inputs-panel]
                           [label "Editor Canvas"]
                           ))

(define message-body-text (new text%))
(send message-body-text insert "json")
(send message-body-canvas set-editor message-body-text)

(define message-result-canvas (new editor-canvas%
                           [parent inputs-panel]
                           [label "Editor Canvas"]
                           ))

(define message-result-text (new text%))
(send message-result-text insert "result")
(send message-result-canvas set-editor message-result-text)

(define url-canvas (new editor-canvas%
                           [parent url-panel]
                           [label "Editor Canvas"]
                           ))

(define url-text (new text%))
(send url-text insert "eu-test.oppwa.com")
(send url-canvas set-editor url-text)


(define (send-request-button-clicked! f)
  (set! count 111)
  ;(send url-text insert "url"))
  ;(send send-request-message (~a count)))
  (post-send-request
   (send url-text get-text)
   "v1/checkouts?entityId=8a8294174b7ecb28014b9699220015ca"
   '("Authorization: Bearer OGE4Mjk0MTc0YjdlY2IyODAxNGI5Njk5MjIwMDE1Y2N8c3k2S0pzVDg=")
   body))

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
                   (send-request-button-clicked! add1))]))


(define menu-bar (new menu-bar%
                      (parent frame)))
(new menu%
     (label "&File")
     (parent menu-bar))
(new menu%
     (label "&Edit")
     (parent menu-bar))
(new menu%
     (label "&Help")
     (parent menu-bar))


(send frame show #t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (make-requester url)
  (make-domain-requester url (make-https-requester http-requester)))

(define body #"entityId=8a8294174b7ecb28014b9699220015ca&amount=1.00&currency=EUR&paymentType=DB")

(define entity-id "entityId=8a8294174b7ecb28014b9699220015ca")

(define (slist->string slst)
  (string-join (map symbol->string slst) " "))

(define (post-send-request base-url url-params header body)
  (let ([result (post (make-requester base-url) url-params body #:headers '("Authorization: Bearer OGE4Mjk0MTc0YjdlY2IyODAxNGI5Njk5MjIwMDE1Y2N8c3k2S0pzVDg="))])
    (displayln result)
    (send message-result-text insert (http-response-body result))))

 
  ;(display (post payon-requester "v1/checkouts?entityId=8a8294174b7ecb28014b9699220015ca" (string->bytes/utf-8 entity-id) #:headers '("Authorization: Bearer OGE4Mjk0MTc0YjdlY2IyODAxNGI5Njk5MjIwMDE1Y2N8c3k2S0pzVDg=")))
  ;(display "after send"))


  
  ;(define post-requester (make-domain-requester url (make-https-requester http-requester)))

;(post payon-requester "v1/checkouts?entityId=8a8294174b7ecb28014b9699220015ca" (string->bytes/utf-8 entity-id) #:headers '("Authorization: Bearer OGE4Mjk0MTc0YjdlY2IyODAxNGI5Njk5MjIwMDE1Y2N8c3k2S0pzVDg="))

