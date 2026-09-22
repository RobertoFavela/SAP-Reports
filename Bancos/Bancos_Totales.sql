/* SELECT FROM "OJDT" T0 WHERE T0."RefDate" >= [%0] AND T0."RefDate" <= [%1]; */

SELECT
    OACT."AcctCode" AS "Cuenta",
    OACT."AcctName" AS "Nombre de cuenta",
    IFNULL(SUM(Movimientos."Debit"), 0) AS "Debito",
    IFNULL(SUM(Movimientos."Credit"), 0) AS "Credito",
    IFNULL(SUM(Movimientos."Debit"), 0) - IFNULL(SUM(Movimientos."Credit"), 0) AS "Saldo",
    IFNULL(SUM(Movimientos."Debit"), 0) + IFNULL(SUM(Movimientos."Credit"), 0) AS "Total"
FROM OACT
LEFT JOIN (
    SELECT
        JDT1."Account",
        JDT1."Debit",
        JDT1."Credit"
    FROM JDT1
    INNER JOIN OJDT
        ON OJDT."TransId" = JDT1."TransId"
    WHERE OJDT."RefDate" BETWEEN '[%0]' AND '[%1]'
      AND OJDT."StornoToTr" IS NULL
      AND NOT EXISTS (
          SELECT 1
          FROM OJDT AS AsientoReversa
          WHERE AsientoReversa."StornoToTr" = OJDT."TransId"
      )
) AS Movimientos
    ON Movimientos."Account" = OACT."AcctCode"
WHERE OACT."AcctCode" LIKE '1102-001%'
GROUP BY
    OACT."AcctCode",
    OACT."AcctName"
ORDER BY
    OACT."AcctCode";
