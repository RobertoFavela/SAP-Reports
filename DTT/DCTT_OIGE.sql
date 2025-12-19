(
    SELECT
        OJDT."TransId" AS "Asiento ID",
        OJDT."Number" AS "Asiento",
        TO_DATE(OJDT."RefDate") AS "Fecha",
        OJDT."TransType",
        OIGE."DocEntry" AS "Documento ID",
        OIGE."DocNum" AS "Documento Origen",

        IGE1."AcctCode" AS "Cuenta",
        TO_DECIMAL(IGE1."StockPrice" * IGE1."Quantity", 18, 4) AS "Debito del asiento",
        0 AS "Credito del asiento",

        IGE1."OcrCode" AS "Negocio",
        IGE1."OcrCode2" AS "Sucursal",
        IGE1."OcrCode3" AS "Area",
        IGE1."OcrCode4" AS "Ciclo",
        IGE1."OcrCode5" AS "Equipos",
        IGE1."Project" AS "Proyecto",

        OIGE."Comments" AS "Comentarios"

    FROM
        OIGE
        INNER JOIN IGE1
            ON OIGE."DocEntry" = IGE1."DocEntry"

        INNER JOIN OJDT
            ON OJDT."BaseRef" = OIGE."DocNum"
           AND OJDT."TransType" = 60

    WHERE
        OJDT."RefDate" BETWEEN '2025-01-01' AND '2025-12-31'
)

UNION ALL

(
    SELECT
        OJDT."TransId" AS "Asiento ID",
        OJDT."Number" AS "Asiento",
        TO_DATE(OJDT."RefDate") AS "Fecha",
        OJDT."TransType",

        OIGE."DocEntry" AS "Documento ID",
        OIGE."DocNum" AS "Documento Origen",

        JDT1."Account" AS "Cuenta",
        JDT1."Debit" AS "Debito del asiento",
        JDT1."Credit" AS "Credito del asiento",

        JDT1."ProfitCode" AS "Negocio",
        JDT1."OcrCode2" AS "Sucursal",
        JDT1."OcrCode3" AS "Area",
        JDT1."OcrCode4" AS "Ciclo",
        JDT1."OcrCode5" AS "Equipos",
        JDT1."Project" AS "Proyecto",

        OIGE."Comments" AS "Comentarios"

    FROM
        JDT1
        INNER JOIN OJDT
            ON OJDT."TransId" = JDT1."TransId"

        LEFT JOIN OIGE
            ON OJDT."BaseRef" = OIGE."DocNum"

    WHERE
        OJDT."RefDate" BETWEEN '2025-01-01' AND '2025-12-31'
        AND OJDT."TransType" = 60
        AND JDT1."Credit" <> 0
)


