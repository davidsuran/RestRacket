#lang racket

(require db
         racket/file
         racket/runtime-path)

(provide last-opened-request-safe)

(define-runtime-path db-init-file "sql/db-init.sql")

;(display "Ïs sqlite3 available?: ")
;(displayln (sqlite3-available?))

(define (get-text-safe text)
  (if (sql-null? text) "" text))

(define c
    (virtual-connection
     (lambda ()
       ;(printf "connecting!\n")
       (sqlite3-connect #:database "rest-requests.db" #:mode 'create))))

(define/contract (sql->statements sql)
  (-> string? (listof string?))
  (regexp-split #px"\\s*;\\s*" sql))

(define (query-exec* connection . stmts)
  (for ([stmt stmts])
    ;(displayln stmt)
    ;(displayln "-------")
    (if (not (regexp-match-exact? #px"\\s*" stmt))
        (query-exec connection stmt)
        #t)))

;(define (query-exec-file connection path file)
;  (apply query-exec* connection
;         (call-with-input-file path file)))


;(query-exec-file c "sql" db-init-file)

(define (split-file-statements stmts)
  (define (splitter stmts)
     (string-split stmts "\\n\\n"))

  (displayln "\\n\\n\\n\\n\\n\\n")
  (for ([s stmts])
    (displayln s)
    (displayln ""))
  
  (splitter stmts))
  
  ;(map string (string->list stmts)))

(apply query-exec* c (sql->statements (file->string db-init-file)))


(define last-opened-request
  (query-row c "SELECT [Requests].[Id], [Requests].[Url], [Requests].[UrlParams], [Requests].[Header], [Requests].[Body] FROM [LastActiveRequests] INNER JOIN [Requests] ON [Requests].[Id] = [LastActiveRequests].[Id] WHERE [LastActiveRequests].[LastOpen] = $1" 1))

(define last-opened-request-safe
  (let ([row last-opened-request])
    (for/vector ([i (in-range (vector-length row))])
      (get-text-safe (vector-ref row i)))))


;(displayln last-opened-requests)
;(displayln (vector-ref last-opened-requests 0))
