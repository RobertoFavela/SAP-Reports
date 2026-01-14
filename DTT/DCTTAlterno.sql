    -- LINEAS DE PROVEEDOR DE FACTURA
    -- Traemos unicamente las lineas con JDT1."SourceLine" = 1, indican el proveedor
(
    SELECT
        'SRY' AS "Empresa",
        OJDT."TransId" AS "Asiento ID",
        OJDT."Number" AS "Asiento",
        TO_DATE(OJDT."RefDate") AS "Fecha",
        OJDT."TransType",
        OPCH."DocEntry" AS "Documento ID",
        OPCH."DocNum" AS "Documento Origen",
        JDT1."Account" AS "Cuenta",
        
        COALESCE(JDT1."Debit", 0)  AS "Debito del asiento",
        COALESCE(JDT1."Credit", 0) AS "Credito del asiento",

        jdt1."ProfitCode" as "Negocio",
        jdt1."OcrCode2" as "Sucursal",
        jdt1."OcrCode3" as "Area",
        jdt1."OcrCode4" as "Ciclo",
        jdt1."OcrCode5" as "Equipos",
        jdt1."Project" as "Proyecto",
        jdt1."LineMemo" as "Comentarios"
    FROM OJDT
        INNER JOIN JDT1 ON OJDT."TransId" = JDT1."TransId"
        left join OPCH ON ojdt."BaseRef" = opch."DocNum"

    WHERE
        OJDT."RefDate" BETWEEN '2025-01-01' AND '2025-12-31'
        
        -- TransType 18 para solo traer facturas
        AND OJDT."TransType" = '18'

        -- Sourceline 1 para solo traer la linea correspondiente al proveedor
        AND JDT1."SourceLine" = 1
)

UNION ALL

    -- LINEAS DE ANTICIPOS DE FACTURAS
    -- Traemos unicamente las lineas con JDT1."SourceLine" = -4, indican un anticipo
(
    SELECT
        -- 'Anticipos' As "Consulta",
        'SRY' AS "Empresa",
        OJDT."TransId" AS "Asiento ID",
        OJDT."Number" AS "Asiento",
        TO_DATE(OJDT."RefDate") AS "Fecha",
        OJDT."TransType",
        OPCH."DocEntry" AS "Documento ID",
        OPCH."DocNum" AS "Documento Origen",
        JDT1."Account" AS "Cuenta",
        
        COALESCE(JDT1."Debit", 0)  AS "Debito del asiento",
        COALESCE(JDT1."Credit", 0) AS "Credito del asiento",

        jdt1."ProfitCode" as "Negocio",
        jdt1."OcrCode2" as "Sucursal",
        jdt1."OcrCode3" as "Area",
        jdt1."OcrCode4" as "Ciclo",
        jdt1."OcrCode5" as "Equipos",
        jdt1."Project" as "Proyecto",
        jdt1."LineMemo" as "Comentarios"

    FROM OJDT
        INNER JOIN JDT1 ON OJDT."TransId" = JDT1."TransId"
        left join OPCH ON ojdt."BaseRef" = opch."DocNum"
    WHERE
        OJDT."RefDate" BETWEEN '2025-01-01' AND '2025-12-31'

        -- TransType 18 para solo traer facturas
        AND OJDT."TransType" = '18'

        -- Sourceline -4 para solo traer la linea correspondiente al anticipo
        AND JDT1."SourceLine" = -4
)

UNION ALL

    -- LINEAS DE IVA DE FACTURAS
    -- Traemos unicamente las lineas con JDT1."InterimTyp" = 5, indican impuestos
(
    SELECT
        -- 'IVA' As "Consulta",
        'SRY' AS "Empresa",
        OJDT."TransId" AS "Asiento ID",
        OJDT."Number" AS "Asiento",
        TO_DATE(OJDT."RefDate") AS "Fecha",
        OJDT."TransType",
        OPCH."DocEntry" AS "Documento ID",
        OPCH."DocNum" AS "Documento Origen",
        JDT1."Account" AS "Cuenta",
        
        COALESCE(JDT1."Debit", 0)  AS "Debito del asiento",
        COALESCE(JDT1."Credit", 0) AS "Credito del asiento",

        jdt1."ProfitCode" as "Negocio",
        jdt1."OcrCode2" as "Sucursal",
        jdt1."OcrCode3" as "Area",
        jdt1."OcrCode4" as "Ciclo",
        jdt1."OcrCode5" as "Equipos",
        jdt1."Project" as "Proyecto",
        jdt1."LineMemo" as "Comentarios"

    FROM OJDT
        INNER JOIN JDT1 ON OJDT."TransId" = JDT1."TransId"
        left join OPCH ON ojdt."BaseRef" = opch."DocNum"
    WHERE
        OJDT."RefDate" BETWEEN '2025-01-01' AND '2025-12-31'

        -- TransType 18 para solo traer facturas
        AND OJDT."TransType" = '18'

        AND JDT1."InterimTyp" = 5

        -- AND OJDT."Number" = '29701'
)

UNION ALL

    -- PERDIDAS CAMBIARIAS DE FACTURAS
(
    SELECT
        -- 'Perdida cambiaria' AS "Consulta",
        'SRY' AS "Empresa",
        OJDT."TransId" AS "Asiento ID",
        OJDT."Number" AS "Asiento",
        TO_DATE(OJDT."RefDate") AS "Fecha",
        OJDT."TransType",
        OPCH."DocEntry" AS "Documento ID",
        OPCH."DocNum" AS "Documento Origen",
        JDT1."Account" AS "Cuenta",

        COALESCE(JDT1."Debit", 0)  AS "Debito del asiento",
        COALESCE(JDT1."Credit", 0) AS "Credito del asiento",

        JDT1."ProfitCode" AS "Negocio",
        JDT1."OcrCode2"   AS "Sucursal",
        JDT1."OcrCode3"   AS "Area",
        JDT1."OcrCode4"   AS "Ciclo",
        JDT1."OcrCode5"   AS "Equipos",
        JDT1."Project"    AS "Proyecto",
        JDT1."LineMemo"   AS "Comentarios"

    FROM OJDT
        INNER JOIN JDT1 ON OJDT."TransId" = JDT1."TransId"
            -- Traemos solo las lineas con perdida cambiaria
            AND JDT1."OrgAccName" = 'PERDIDA CAMBIARIA'

        LEFT JOIN OPCH ON OJDT."BaseRef" = OPCH."DocNum"

    WHERE 
        OJDT."RefDate" BETWEEN '2025-01-01' AND '2025-12-31'

        -- TransType 18 para solo traer facturas
        AND OJDT."TransType" = '18'
)

UNION ALL

    -- LINEAS DE FACTURAS
    -- Traemos todos los detalles de las lineas de la factura original del asiento
(
    SELECT
        -- 'Factura' As "Consulta",
        'SRY' AS "Empresa",
        OJDT."TransId" AS "Asiento ID",
        OJDT."Number" AS "Asiento",
        TO_DATE(OJDT."RefDate") AS "Fecha",
        OJDT."TransType",
        OPCH."DocEntry" AS "Documento ID",
        OPCH."DocNum" AS "Documento Origen",
        PCH1."AcctCode" AS "Cuenta",

        CASE
            WHEN JDTX."Debit" = 0 THEN PCH1."LineTotal"
            ELSE 0
        END AS "Credito del asiento",

        CASE
            WHEN JDTX."Credit" = 0 THEN PCH1."LineTotal"
            ELSE 0
        END AS "Debito del asiento",

        PCH1."OcrCode"  AS "Negocio",
        PCH1."OcrCode2" AS "Sucursal",
        PCH1."OcrCode3" AS "Area",
        PCH1."OcrCode4" AS "Ciclo",
        PCH1."OcrCode5" AS "Equipos",
        PCH1."Project"  AS "Proyecto",
        OPCH."Comments" AS "Comentarios"

    FROM OPCH
        INNER JOIN PCH1 ON PCH1."DocEntry" = OPCH."DocEntry"

        INNER JOIN OJDT ON OJDT."BaseRef" = OPCH."DocNum"
           AND OJDT."TransType" = '18'

        -- Verificamos si la linea del proveedor tiene cargo en Credito y Debito,
        -- Si ambos son ceros, verificamos el anticipo, solo pueden ser 0 si hay un anticipo
        INNER JOIN (
            SELECT *
            FROM (
                SELECT
                    "TransId",
                    "Debit",
                    "Credit",
                    "SourceLine",
                    ROW_NUMBER() OVER (
                        PARTITION BY "TransId"
                        ORDER BY CASE WHEN "SourceLine" = 1 THEN 1 ELSE 2 END
                    ) AS rn
                FROM JDT1
                WHERE (COALESCE("Debit",0) <> 0 OR COALESCE("Credit",0) <> 0)
                  AND "SourceLine" IN (1, -4)
            ) t
            WHERE rn = 1
        ) AS JDTX
            ON JDTX."TransId" = OJDT."TransId"
    WHERE
        OJDT."RefDate" BETWEEN '2025-01-01' AND '2025-12-31'
)

UNION ALL

    -- TODOS LOS OTROS DOCUMENTOS NO FACTURAS
(
    SELECT
        'SRY' AS "Empresa",
        OJDT."TransId" AS "Asiento ID",
        OJDT."Number" AS "Asiento",
        TO_DATE(OJDT."RefDate") AS "Fecha",
        OJDT."TransType",

        COALESCE(
            OVPM."DocEntry",
            OINV."DocEntry",
            OIGN."DocEntry",
            OPDN."DocEntry",
            OIGE."DocEntry",
            ODLN."DocEntry",
            ORPC."DocEntry",
            ORIN."DocEntry",
            ORPD."DocEntry",
            OWTR."DocEntry",
            OACQ."DocEntry",
            ODPO."DocEntry",
            OJDT."BaseRef"
        ) AS "Documento ID",

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

        COALESCE(JDT1."Debit", 0)  AS "Debito del asiento",
        COALESCE(JDT1."Credit", 0) AS "Credito del asiento",

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
        INNER JOIN OJDT ON OJDT."TransId" = JDT1."TransId" -- TransType 30, Asiento manual

        -- LEFT JOIN OPCH ON OJDT."BaseRef" = OPCH."DocNum" -- TransType 18, Factura de proveedor

        LEFT JOIN OVPM ON OJDT."BaseRef" = OVPM."DocNum" -- TransType 46, Pago Efectuado
        LEFT JOIN OINV ON OJDT."BaseRef" = OINV."DocNum" -- TransType 13, Factura de cliente
        LEFT JOIN OIGN ON OJDT."BaseRef" = OIGN."DocNum" -- TransType 59, Entrada de mercancias
        LEFT JOIN OPDN ON OJDT."BaseRef" = OPDN."DocNum" -- TransType 20, Entrada de mercancias por compra
        LEFT JOIN OIGE ON OJDT."BaseRef" = OIGE."DocNum" -- TransType 60, Salida de mercancia
        LEFT JOIN ODLN ON OJDT."BaseRef" = ODLN."DocNum" -- TransType 15, Entrega
        LEFT JOIN ORPC ON OJDT."BaseRef" = ORPC."DocNum" -- TransType 24, Credito / Transferencia
        LEFT JOIN ORIN ON OJDT."BaseRef" = ORIN."DocNum" -- TransType 14, Nota de credito de cliente
        LEFT JOIN ORPD ON OJDT."BaseRef" = ORPD."DocNum" -- TransType 203, Devolucion de proveedor
        LEFT JOIN OWTR ON OJDT."BaseRef" = OWTR."DocNum" -- TransType 321, Reconciliacion interna
        LEFT JOIN OACQ ON OJDT."BaseRef" = OACQ."DocNum" -- TransType 1470000049, Capitalizacion
        LEFT JOIN ODPO ON OJDT."BaseRef" = ODPO."DocNum" -- TransType 204, Factura anticipo de proveedores

    WHERE
        OJDT."RefDate" BETWEEN '2025-01-01' AND '2025-12-31'

        -- Excluimos las facturas de proveedor
        AND OJDT."TransType" NOT IN (18, 60)
)

UNION ALL

(
    SELECT
        'SRY' AS "Empresa",
        OJDT."TransId"        AS "Asiento ID",
        OJDT."Number"         AS "Asiento",
        TO_DATE(OJDT."RefDate") AS "Fecha",
        OJDT."TransType",

        OIGE."DocEntry"       AS "Documento ID",
        OIGE."DocNum"         AS "Documento Origen",

        IGE1."AcctCode"       AS "Cuenta",
        TO_DECIMAL(IGE1."StockPrice" * IGE1."Quantity", 18, 4)
                               AS "Debito del asiento",
        0 AS "Credito del asiento",

        IGE1."OcrCode"        AS "Negocio",
        IGE1."OcrCode2"       AS "Sucursal",
        IGE1."OcrCode3"       AS "Area",
        IGE1."OcrCode4"       AS "Ciclo",
        IGE1."OcrCode5"       AS "Equipos",
        IGE1."Project"        AS "Proyecto",

        OIGE."Comments"       AS "Comentarios"

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
        'SRY' AS "Empresa",
        OJDT."TransId" AS "Asiento ID",
        OJDT."Number" AS "Asiento",
        TO_DATE(OJDT."RefDate") AS "Fecha",
        OJDT."TransType",

        OIGE."DocEntry" AS "Documento ID",
        OIGE."DocNum" AS "Documento Origen",

        JDT1."Account" AS "Cuenta",
        
        COALESCE(JDT1."Debit", 0)  AS "Debito del asiento",
        COALESCE(JDT1."Credit", 0) AS "Credito del asiento",

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


ORDER BY "Asiento" DESC