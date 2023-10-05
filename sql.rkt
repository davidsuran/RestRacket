#lang racket

(require db)

(provide last-opened-request-safe)

;(provide
; (rename-out [param-get get]
;             [param-put put]
;             [param-post post]
;             [param-delete delete])
; (except-out (all-from-out "main.rkt") get put post delete))


;(display "Ïs sqlite3 available?: ")
;(displayln (sqlite3-available?))

(define (get-text-safe text)
  (if (sql-null? text) "" text))

(define c
    (virtual-connection
     (lambda ()
       ;(printf "connecting!\n")
       (sqlite3-connect #:database "rest-requests.db" #:mode 'create))))

(query-exec c "CREATE TABLE IF NOT EXISTS [Requests] ([Id] INTEGER, [Url] TEXT, [UrlParams] TEXT, [Header] TEXT, [Body] TEXT, UNIQUE([Id]));")
(query-exec c "CREATE TABLE IF NOT EXISTS [LastActiveRequests] ([Id] INTEGER, [RequestId] INTEGER, [LastOpen] BLOB, FOREIGN KEY([RequestId]) REFERENCES Requests([Id]), UNIQUE([Id]));")

(query-exec c "INSERT OR IGNORE INTO [Requests] ([Id], [Url], [UrlParams], [Header], [Body])
  VALUES (1, \"eu-test.oppwa.com\", \"v1/checkouts?entityId=8a8294174b7ecb28014b9699220015ca&amount=1.00&currency=EUR&paymentType=DB\", \"Authorization: Bearer OGE4Mjk0MTc0YjdlY2IyODAxNGI5Njk5MjIwMDE1Y2N8c3k2S0pzVDg=\", NULL)")
(query-exec c "INSERT OR IGNORE INTO [LastActiveRequests] ([Id], [RequestId], [LastOpen])
  VALUES (1, 1, 1)")

(define last-opened-request
  (query-row c "SELECT [Requests].[Id], [Requests].[Url], [Requests].[UrlParams], [Requests].[Header], [Requests].[Body] FROM [LastActiveRequests] INNER JOIN [Requests] ON [Requests].[Id] = [LastActiveRequests].[Id] WHERE [LastActiveRequests].[LastOpen] = $1" 1))

(define last-opened-request-safe
  (let ([row last-opened-request])
    (for/vector ([i (in-range (vector-length row))])
      (get-text-safe (vector-ref row i)))))


;(displayln last-opened-requests)
;(displayln (vector-ref last-opened-requests 0))
