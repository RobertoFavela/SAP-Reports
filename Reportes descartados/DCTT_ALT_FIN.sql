WITH Retenciones AS (
    SELECT 
        PCH5."AbsEntry",
        SUM(COALESCE(OWHT."Rate", 0)) AS "TotalRetencion"
    FROM PCH5
    LEFT JOIN OWHT ON PCH5."WTCode" = OWHT."WTCode"
    GROUP BY PCH5."AbsEntry"
)

(
SELECT
    'Consulta 1' AS "Consulta",
    OJDT."Number" AS "Asiento",
    TO_DATE(OJDT."RefDate") AS "Fecha",
    OJDT."TransType",

    COALESCE(
        OVPM."DocNum", OINV."DocNum", OIGN."DocNum", OPDN."DocNum", OIGE."DocNum", ODLN."DocNum", ORPC."DocNum", ORIN."DocNum", ORPD."DocNum", OWTR."DocNum", OACQ."DocNum", ODPO."DocNum", OJDT."BaseRef"
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
        OVPM."Comments", OINV."Comments", OIGN."Comments", OPDN."Comments", OIGE."Comments", ODLN."Comments", ORPC."Comments", ORIN."Comments", ORPD."Comments", OWTR."Comments", OACQ."Comments", ODPO."Comments", OJDT."Memo"
    ) AS "Comentarios"

FROM
    JDT1
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
    JDT1."RefDate" BETWEEN '2025-09-01' AND '2025-09-30'
    AND OJDT."TransType" = 18
    AND JDT1."SourceLine" IS NULL
        OR (JDT1."SourceLine" = 1 AND JDT1."Debit" = 0 AND JDT1."Credit" = 0)
        OR JDT1."SourceLine" IN (-4, -99, -10, -7, -2, 0, -1)
    AND OJDT."Number" = '30195'
    
)

UNION ALL

(
SELECT
    'Consulta 2' AS "Consulta",
    OJDT."Number" AS "Asiento",
    TO_DATE(OJDT."RefDate") AS "Fecha",
    OJDT."TransType",

    OPCH."DocNum" AS "Documento Origen",

    (SELECT J."Account"
        FROM JDT1 J
        WHERE J."TransId" = OJDT."TransId"
          AND J."SourceLine" = 1
    ) AS "Cuenta",

    CASE 
        WHEN JDT1."Debit" <> 0 AND JDT1."SourceLine" = 1 THEN
            (
                -- BASE + IVA
                CASE
                    WHEN PCH1."TaxCode" = 'V2' THEN TO_DECIMAL(PCH1."LineTotal" * 1.16, 18, 4)
                    WHEN PCH1."TaxCode" = 'V1' THEN TO_DECIMAL(PCH1."LineTotal" * 1.08, 18, 4)
                    ELSE PCH1."LineTotal"
                END
                --
                -- MENOS RETENCIONES
                -
                (
                    COALESCE(R."TotalRetencion", 0) / 100   -- convertir % a factor
                    * PCH1."LineTotal"
                )
            )
    END AS "Debito del asiento",

    0 AS "Cargo del asiento",

    -- Dimensiones
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
    INNER JOIN JDT1 ON JDT1."TransId" = OJDT."TransId"
        AND JDT1."SourceLine" = 1 
        AND (JDT1."Debit" <> 0 OR JDT1."Credit" <> 0)

    -- SUMA TOTAL DE RETENCIONES POR FACTURA (SIN DUPLICAR)
    LEFT JOIN Retenciones R
        ON R."AbsEntry" = OPCH."DocEntry"

WHERE   
    OJDT."Number" = '30195'

)

ORDER BY "Asiento" DESC