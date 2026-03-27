SELECT 
    OCRD."CardCode" AS "Código Proveedor", 
    OCRD."CardName" AS "Nombre Proveedor", 
    OCRB."BankCode" AS "Código Banco", 
    ODSC."BankName" AS "Nombre Banco",
    OCRB."Account" AS "Número de Cuenta", 
    OCRB."AcctName" AS "Nombre cuenta",
    OCRB."MandateID" AS "Referencia", 
    OCRB."IBAN",
    OCRB."Country" AS "País Banco"
FROM OCRD
INNER JOIN OCRB ON OCRD."CardCode" = OCRB."CardCode"
LEFT JOIN ODSC ON OCRB."BankCode" = ODSC."BankCode" AND OCRB."Country" = ODSC."CountryCod"
WHERE OCRD."CardType" = 'S'
    -- AND OCRB."MandateID" IS NOT NULL
ORDER BY OCRD."CardCode"