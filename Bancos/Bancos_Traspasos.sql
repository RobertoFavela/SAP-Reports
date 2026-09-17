SELECT
    OJDT."Number" AS "Numero de asiento",
    OJDT."TransId" AS "ID de asiento",
    OJDT."RefDate" AS "Fecha de contabilizacion",
    JDT1."Account" AS "Cuenta bancaria",
    OACT."AcctName" AS "Nombre de cuenta",
    DSC1."BankCode" AS "Codigo de banco",
    ODSC."BankName" AS "Banco",
    DSC1."Branch" AS "Sucursal",
    DSC1."Account" AS "Numero de cuenta bancaria",
    DSC1."AcctName" AS "Nombre de cuenta bancaria",
    DSC1."IBAN" AS "IBAN",
    JDT1."Debit" AS "Debito",
    JDT1."Credit" AS "Credito",
    JDT1."LineMemo" AS "Comentarios del movimiento",
    OJDT."Memo" AS "Comentarios del asiento"
FROM OJDT
INNER JOIN JDT1
    ON JDT1."TransId" = OJDT."TransId"
INNER JOIN OACT
    ON OACT."AcctCode" = JDT1."Account"
LEFT JOIN DSC1
    ON DSC1."GLAccount" = JDT1."Account"
LEFT JOIN ODSC
    ON ODSC."BankCode" = DSC1."BankCode"
    AND ODSC."CountryCod" = DSC1."Country"
WHERE JDT1."Account" LIKE '1102-001%'
  AND EXISTS (
      SELECT 1
      FROM JDT1 AS Debito
      INNER JOIN JDT1 AS Credito
          ON Credito."TransId" = Debito."TransId"
      WHERE Debito."TransId" = OJDT."TransId"
        AND Debito."Account" LIKE '1102-001%'
        AND Credito."Account" LIKE '1102-001%'
        AND Debito."Debit" > 0
        AND Credito."Credit" > 0
        AND Debito."Account" <> Credito."Account"
  )
ORDER BY
    OJDT."RefDate",
    OJDT."Number",
    JDT1."Line_ID";
