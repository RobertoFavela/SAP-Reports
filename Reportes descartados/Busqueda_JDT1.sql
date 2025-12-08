SELECT
    JDT1."Account",
    JDT1."Debit",
    JDT1."Credit",
    JDT1."SourceLine",
    JDT1."InterimTyp" AS "IVA",
    JDT1."InitRef3Ln" AS "Proveedor",
    JDT1."ExpOPType" AS "Factura"

FROM JDT1 
    INNER JOIN OJDT ON OJDT."TransId" = JDT1."TransId" 

WHERE 
    OJDT."Number" = '15167'