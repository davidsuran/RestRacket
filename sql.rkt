#lang racket

(require db)

;(provide
; (rename-out [param-get get]
;             [param-put put]
;             [param-post post]
;             [param-delete delete])
; (except-out (all-from-out "main.rkt") get put post delete))


(sqlite3-available?)

(define connection
  (virtual-connection
   (lambda ()
     (displayln "connecting!")
     ((sqlite3-connect #:database "rest-requests.db" #:mode 'create)))))

;(query-exec pgc "CREATE TABLE [IF NOT EXISTS] TABLE_NAME (column_name datatype, column_name datatype);")
;(query-exec pgc "SELECT * FROM information_schema.tables WHERE table_schema = 'yourdb' AND table_name = 'testtable' LIMIT 1;")
;(query-exec pgc "insert into the_numbers values (42, 'the answer')")
;(query-exec pgc "delete from the_numbers where n = $1" 42)

(disconnect connection)