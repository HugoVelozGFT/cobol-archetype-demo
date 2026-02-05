      ******************************************************************
      * CPYBALIO - Layout para consulta de saldos (CURSOR)
      ******************************************************************

      * ----------- Entrada: cuenta a consultar (12 chars) ------------
       01  IN-REC.
           05 IN-ACCT-ID              PIC X(12).

      * ----------- Salida: un registro por fila devuelta -------------
       01  OUT-REC.
           05 OUT-ACCT-ID             PIC X(12).
           05 OUT-SEP-1               PIC X       VALUE '|'.
           05 OUT-BAL-DATE            PIC X(10).        *> YYYY-MM-DD
           05 OUT-SEP-2               PIC X       VALUE '|'.
           05 OUT-CCY                 PIC X(3).
           05 OUT-SEP-3               PIC X       VALUE '|'.
           05 OUT-CURR-BAL            PIC -9(13).99.
           05 OUT-SEP-4               PIC X       VALUE '|'.
           05 OUT-AVAIL-BAL           PIC -9(13).99.
           05 OUT-SEP-5               PIC X       VALUE '|'.
           05 OUT-STATUS              PIC X(12).        *> OK / NO_ENCONTRADO / SQL_ERROR
           05 OUT-SEP-6               PIC X       VALUE '|'.
           05 OUT-SQLCODE             PIC -9(9).
