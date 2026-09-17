SELECT
    OACT."AcctCode" AS "Cuenta",
    OACT."AcctName" AS "Nombre de cuenta",
    IFNULL(SUM(JDT1."Debit"), 0) AS "Debito",
    IFNULL(SUM(JDT1."Credit"), 0) AS "Credito",
    IFNULL(SUM(JDT1."Debit"), 0) - IFNULL(SUM(JDT1."Credit"), 0) AS "Saldo",
    IFNULL(SUM(JDT1."Debit"), 0) + IFNULL(SUM(JDT1."Credit"), 0) AS "Total"
FROM OACT
LEFT JOIN JDT1
    ON JDT1."Account" = OACT."AcctCode"
WHERE OACT."AcctCode" LIKE '1102-001%'
GROUP BY
    OACT."AcctCode",
    OACT."AcctName"
ORDER BY
    OACT."AcctCode";