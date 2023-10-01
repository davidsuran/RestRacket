#lang racket

(require db)

;(provide
; (rename-out [param-get get]
;             [param-put put]
;             [param-post post]
;             [param-delete delete])
; (except-out (all-from-out "main.rkt") get put post delete))


(display "Ïs sqlite3 available?: ")
(displayln (sqlite3-available?))

;(define connect
;   (virtual-connection
;   (lambda ()
;     (displayln "connecting!")
;     ((sqlite3-connect #:database "rest-requests.db" #:mode 'create)))))


(define c (sqlite3-connect #:database "rest-requests.db" #:mode 'create))

(query-exec c "CREATE TABLE IF NOT EXISTS Requests (Id integer, Url text, UrlParams text, Body text);")
(query-exec c "CREATE TABLE IF NOT EXISTS LastActiveRequests (Id integer, RequestId integer, LastOpen blob, FOREIGN KEY(RequestId) REFERENCES Requests(Id));")

;(query-exec pgc "SELECT * FROM information_schema.tables WHERE table_schema = 'yourdb' AND table_name = 'testtable' LIMIT 1;")
;(query-exec pgc "insert into the_numbers values (42, 'the answer')")
;(query-exec pgc "delete from the_numbers where n = $1" 42)

(disconnect c)