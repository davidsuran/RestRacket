#lang racket

(require base64)

(provide basic-auth)

(define (basic-auth name password)
  (string-append
         "Authorization: Basic "
         (bytes->string/utf-8
          (base64-encode
           (string->bytes/utf-8
            (string-append name ":" password))))))

(module+ test
  (require rackunit)
  (check-equal? (basic-auth "aaaa@cccc" "bbbb")
                "Authorization: Basic YWFhYUBjY2NjOmJiYmI"))
