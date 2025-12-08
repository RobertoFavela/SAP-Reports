SELECT
    'Completa' AS "Consulta",
    OJDT."Number" AS "Asiento",
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

FROM
    JDT1
    INNER JOIN OJDT ON OJDT."TransId" = JDT1."TransId"
    LEFT JOIN OVPM ON OJDT."BaseRef" = OVPM."DocNum"
    LEFT JOIN OINV ON OJDT."BaseRef" = OINV."DocNum" -- TransType 13, Factura de cliente
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

    AND OJDT."TransType" = 14
    /*
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
        )*/

