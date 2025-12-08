(
SELECT 
    OJDT."Number" AS "Asiento", 
    OJDT."TransId",
    TO_DATE(OJDT."RefDate") AS "Fecha", 
    OJDT."TransType", 

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
    ) AS "Documento Origen", 

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
    OJDT."RefDate" BETWEEN '2025-09-01' AND '2025-09-30'
    AND OJDT."TransType" = '18'
    AND (
            JDT1."SourceLine" IS NULL
            OR (JDT1."SourceLine" = 1 AND JDT1."Debit" = 0 AND JDT1."Credit" = 0)
            OR JDT1."SourceLine" = -4
            OR JDT1."SourceLine" = -99
            OR JDT1."SourceLine" = -10
            OR JDT1."SourceLine" = -7
            OR JDT1."SourceLine" = -2
            OR JDT1."SourceLine" = 0
            OR JDT1."SourceLine" = -1
        )
)

UNION ALL 

(
SELECT
    OJDT."Number" AS "Asiento",
    OJDT."TransId",
    TO_DATE(OJDT."RefDate") AS "Fecha",
    OJDT."TransType",

    OPCH."DocNum" AS "Documento Origen",

    /*(SELECT J."Account"
        FROM JDT1 J
        WHERE J."TransId" = OJDT."TransId"
          AND J."SourceLine" = 1
    )*/
    
    PCH1."AcctCode" AS "Cuenta",

    CASE 
        WHEN JDT1."Debit" <> 0 THEN (
            TO_DECIMAL(
                (PCH1."LineTotal" + PCH1."VatSum")
                -
                OPCH."DpmAmnt" / (
                    SELECT COUNT(*) FROM PCH1 L WHERE L."DocEntry" = OPCH."DocEntry"
                )
                -
                OPCH."DpmVat" / (
                    SELECT COUNT(*) FROM PCH1 L WHERE L."DocEntry" = OPCH."DocEntry"
                )
                -
                OPCH."WTSum" / (
                    SELECT COUNT(*) FROM PCH1 L WHERE L."DocEntry" = OPCH."DocEntry"
                )
            ,18,4)
        )
    END AS "Debito del asiento",

    CASE 
        WHEN JDT1."Credit" <> 0 THEN (
            TO_DECIMAL(
                (PCH1."LineTotal" + PCH1."VatSum")
                -
                OPCH."DpmAmnt" / (
                    SELECT COUNT(*) FROM PCH1 L WHERE L."DocEntry" = OPCH."DocEntry"
                )
                -
                OPCH."DpmVat" / (
                    SELECT COUNT(*) FROM PCH1 L WHERE L."DocEntry" = OPCH."DocEntry"
                )
                -
                OPCH."WTSum" / (
                    SELECT COUNT(*) FROM PCH1 L WHERE L."DocEntry" = OPCH."DocEntry"
                )
            ,18,4)
        )
    END AS "Credito del asiento",

    PCH1."OcrCode" AS "Negocio",
    PCH1."OcrCode2" AS "Sucursal",
    PCH1."OcrCode3" AS "Area",
    PCH1."OcrCode4" AS "Ciclo",
    PCH1."OcrCode5" AS "Equipos",
    PCH1."Project" AS "Proyecto",
    OPCH."Comments" AS "Comentarios"

FROM OPCH
    INNER JOIN PCH1 ON OPCH."DocEntry" = PCH1."DocEntry"
    INNER JOIN OJDT ON OJDT."BaseRef" = OPCH."DocNum"
        AND OJDT."TransType" = '18'
    INNER JOIN JDT1 ON JDT1."TransId" = OJDT."TransId"
        AND JDT1."SourceLine" = 1 
        AND (JDT1."Debit" <> 0 OR JDT1."Credit" <> 0)

WHERE 
    OJDT."RefDate" BETWEEN '2025-09-01' AND '2025-09-30'
)

ORDER BY "Asiento" DESC