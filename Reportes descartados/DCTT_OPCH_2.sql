(
SELECT
    'Consulta 1' AS "Consulta",
    OJDT."Number" AS "Asiento", 
    TO_DATE(OJDT."RefDate") AS "Fecha", 

    COALESCE(
        OVPM."DocNum", 
        OINV."DocNum", 
        OIGN."DocNum", 
        OPDN."DocNum", 
        OIGE."DocNum", 
        ODLN."DocNum", 
        ORPC."DocNum", 
        ORIN."DocNum", 
        ORPD."DocNum", 
        OWTR."DocNum", 
        OACQ."DocNum", 
        ODPO."DocNum", 
        OJDT."BaseRef" 
    ) AS "Factura", 

    JDT1."Account" AS "Cuenta", 
    JDT1."Debit" AS "Debito del asiento", 
    JDT1."Credit" AS "Credito del asiento", 
    JDT1."ProfitCode" AS "Negocio", 
    JDT1."OcrCode2" AS "Sucursal", 
    JDT1."OcrCode3" AS "Area", 
    JDT1."OcrCode4" AS "Ciclo", 
    JDT1."OcrCode5" AS "Equipos", 
    JDT1."Project" AS "Proyecto", 

    COALESCE( 
        OVPM."Comments", 
        OINV."Comments", 
        OIGN."Comments", 
        OPDN."Comments", 
        OIGE."Comments", 
        ODLN."Comments", 
        ORPC."Comments", 
        ORIN."Comments", 
        ORPD."Comments", 
        OWTR."Comments", 
        OACQ."Comments", 
        ODPO."Comments", 
        OJDT."Memo" 
    ) AS "Comentarios"

FROM JDT1 
    INNER JOIN OJDT ON OJDT."TransId" = JDT1."TransId" 
    LEFT JOIN OVPM ON OJDT."BaseRef" = OVPM."DocNum" 
    LEFT JOIN OINV ON OJDT."BaseRef" = OINV."DocNum" 
    LEFT JOIN OIGN ON OJDT."BaseRef" = OIGN."DocNum" 
    LEFT JOIN OPDN ON OJDT."BaseRef" = OPDN."DocNum" 
    LEFT JOIN OIGE ON OJDT."BaseRef" = OIGE."DocNum" 
    LEFT JOIN ODLN ON OJDT."BaseRef" = ODLN."DocNum" 
    LEFT JOIN ORPC ON OJDT."BaseRef" = ORPC."DocNum" 
    LEFT JOIN ORIN ON OJDT."BaseRef" = ORIN."DocNum" 
    LEFT JOIN ORPD ON OJDT."BaseRef" = ORPD."DocNum" 
    LEFT JOIN OWTR ON OJDT."BaseRef" = OWTR."DocNum" 
    LEFT JOIN OACQ ON OJDT."BaseRef" = OACQ."DocNum" 
    LEFT JOIN ODPO ON OJDT."BaseRef" = ODPO."DocNum" 

WHERE  
    OJDT."RefDate" BETWEEN '2025-09-01' AND '2025-09-05'
    AND OJDT."TransType" = '18'
    
    AND JDT1."Cre"

    AND OJDT."Number" = '28395'
)

UNION ALL

(
    SELECT
        'Consulta 2' AS "Consulta",
        OJDT."Number" AS "Asiento",
        TO_DATE(OJDT."RefDate") AS "Fecha", 
        OPCH."DocNum" AS "Factura",

        PCH1."AcctCode" AS "Cuenta",
        PCH1."LineTotal" AS "Debito del asiento",
        '0' AS "Credito del asiento",

        PCH1."OcrCode" AS "Negocio",
        PCH1."OcrCode2" AS "Sucursal",
        PCH1."OcrCode3" AS "Area",
        PCH1."OcrCode4" AS "Ciclo",
        PCH1."OcrCode5" AS "Equipos",
        PCH1."Project" AS "Proyecto",

        OPCH."Comments"
    FROM OPCH
        INNER JOIN PCH1 ON PCH1."DocEntry" = OPCH."DocEntry"

        INNER JOIN OJDT ON OJDT."BaseRef" = OPCH."DocNum"
            AND OJDT."TransType" = '18'

    WHERE
        OJDT."RefDate" BETWEEN '2025-09-01' AND '2025-09-05'
        AND OJDT."Number" = '28395'
)

ORDER BY "Asiento" DESC