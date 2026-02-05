       IDENTIFICATION DIVISION.
       PROGRAM-ID. MPBALQRY.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT INFILE  ASSIGN TO INFILE
               ORGANIZATION IS SEQUENTIAL.
           SELECT OUTFILE ASSIGN TO OUTFILE
               ORGANIZATION IS SEQUENTIAL.

       DATA DIVISION.
       FILE SECTION.

       FD  INFILE
           RECORD CONTAINS 12 CHARACTERS.
       01  INFILE-REC                PIC X(12).
           

       FD  OUTFILE
           RECORD CONTAINS 140 CHARACTERS.
       01  OUTFILE-REC               PIC X(140).

       WORKING-STORAGE SECTION.

       01  WS-FLAGS.
           05 WS-EOF                 PIC X VALUE 'N'.
           05 WS-HAS-ROWS            PIC X VALUE 'N'.  

       01  WS-OUT.
           COPY CPYBALIO.

       01  WS-FMT.
           05 WS-CURR-BAL-DISP       PIC -9(13).99.
           05 WS-AVAIL-BAL-DISP      PIC -9(13).99.
           05 WS-SQLCODE-DISP        PIC -9(9).

       EXEC SQL INCLUDE SQLCA END-EXEC.
       COPY CPYBALHV.

       ******************************************************************
       * CURSOR: ajusta aquí la tabla/columnas reales
       ******************************************************************
       EXEC SQL
          DECLARE C-SALDOS CURSOR FOR
              SELECT CHAR(BAL_DATE),
                     CCY,
                     CURR_BAL,
                     AVAIL_BAL
                FROM BANCO.TB_SALDOS_CTA
               WHERE ACCT_ID = :HV-ACCT-ID
               ORDER BY BAL_DATE DESC, CCY
       END-EXEC.

       PROCEDURE DIVISION.
       MAIN.
           PERFORM OPEN-FILES
           PERFORM UNTIL WS-EOF = 'Y'
               PERFORM READ-IN
               IF WS-EOF = 'N'
                   PERFORM PROCESS-ACCOUNT
               END-IF
           END-PERFORM
           PERFORM CLOSE-FILES
           GOBACK.

       OPEN-FILES.
           OPEN INPUT INFILE
                OUTPUT OUTFILE.

       READ-IN.
           READ INFILE INTO IN-REC
               AT END
                   MOVE 'Y' TO WS-EOF
           END-READ.

       PROCESS-ACCOUNT.
           MOVE IN-ACCT-ID TO HV-ACCT-ID
           MOVE 'N'        TO WS-HAS-ROWS

           *> Abrir cursor
           EXEC SQL
              OPEN C-SALDOS
           END-EXEC

           IF SQLCODE NOT = 0
              PERFORM WRITE-SQL-ERROR
              GO TO CLOSE-CURSOR
           END-IF

           *> Fetch loop
           PERFORM UNTIL SQLCODE NOT = 0
              EXEC SQL
                 FETCH C-SALDOS
                   INTO :HV-BAL-DATE-CHAR,
                        :HV-CCY,
                        :HV-CURR-BAL,
                        :HV-AVAIL-BAL
              END-EXEC

              IF SQLCODE = 0
                 MOVE 'Y' TO WS-HAS-ROWS
                 PERFORM BUILD-AND-WRITE-OK
              END-IF
           END-PERFORM

           *> Si no hubo filas (SQLCODE 100 al primer fetch)
           IF WS-HAS-ROWS = 'N'
              IF SQLCODE = 100
                 PERFORM WRITE-NO-FOUND
              ELSE
                 PERFORM WRITE-SQL-ERROR
              END-IF
           END-IF

       CLOSE-CURSOR.
           EXEC SQL
              CLOSE C-SALDOS
           END-EXEC.

       BUILD-AND-WRITE-OK.
           MOVE IN-ACCT-ID         TO OUT-ACCT-ID
           MOVE HV-BAL-DATE-CHAR   TO OUT-BAL-DATE
           MOVE HV-CCY             TO OUT-CCY

           MOVE HV-CURR-BAL        TO WS-CURR-BAL-DISP
           MOVE HV-AVAIL-BAL       TO WS-AVAIL-BAL-DISP
           MOVE WS-CURR-BAL-DISP   TO OUT-CURR-BAL
           MOVE WS-AVAIL-BAL-DISP  TO OUT-AVAIL-BAL

           MOVE 'OK'               TO OUT-STATUS
           MOVE 0                  TO OUT-SQLCODE

           MOVE OUT-REC            TO OUTFILE-REC
           WRITE OUTFILE-REC.

       WRITE-NO-FOUND.
           MOVE IN-ACCT-ID         TO OUT-ACCT-ID
           MOVE SPACES             TO OUT-BAL-DATE
           MOVE SPACES             TO OUT-CCY
           MOVE 0                  TO OUT-CURR-BAL
           MOVE 0                  TO OUT-AVAIL-BAL
           MOVE 'NO_ENCONTRADO'    TO OUT-STATUS
           MOVE 100                TO OUT-SQLCODE

           MOVE OUT-REC            TO OUTFILE-REC
           WRITE OUTFILE-REC.

       WRITE-SQL-ERROR.
           MOVE IN-ACCT-ID         TO OUT-ACCT-ID
           MOVE SPACES             TO OUT-BAL-DATE
           MOVE SPACES             TO OUT-CCY
           MOVE 0                  TO OUT-CURR-BAL
           MOVE 0                  TO OUT-AVAIL-BAL
           MOVE 'SQL_ERROR'        TO OUT-STATUS
           MOVE SQLCODE            TO OUT-SQLCODE

           MOVE OUT-REC            TO OUTFILE-REC
           WRITE OUTFILE-REC.

       CLOSE-FILES.
           CLOSE INFILE OUTFILE.
