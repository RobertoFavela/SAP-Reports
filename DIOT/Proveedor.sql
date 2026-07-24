SELECT 
    OJDT."RefDate" AS "Fecha de Asiento",
    OJDT."Number" AS "Número de Asiento",
    OJDT."TransId" AS "ID Asiento",
    JDT1."Account" AS "Cuenta de Mayor",
    JDT1."ShortName",
    JDT1."Credit" AS "Crédito",
    JDT1."Debit" AS "Débito",
    JDT1."ExpUUID" AS "UUID",
    OCRD."LicTradNum" AS "RFC"
FROM OJDT
INNER JOIN JDT1 ON OJDT."TransId" = JDT1."TransId"
LEFT JOIN OCRD ON JDT1."ShortName" = OCRD."CardCode"
WHERE OJDT."TransType" = 30
    AND (
        OCRD."LicTradNum" IS NOT NULL 
        OR JDT1."Account" LIKE '1118-001%'
    )
ORDER BY OJDT."Number" DESC