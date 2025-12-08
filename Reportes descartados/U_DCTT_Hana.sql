SELECT
    OJDT."Number",
    TO_DATE (OJDT."RefDate") AS "Fecha",
    OJDT."TransType",
    COALESCE(
        OPCH."DocNum",
        ORPC."DocNum",
        OINV."DocNum",
        OJDT."BaseRef"
    ) AS "Documento Origen",
    JDT1."Account" AS "Cuenta",
    -- Cargo
    CASE
        WHEN OACT."U_CodAgrup" = '115.03'
        AND JDT1."Credit" = 0 THEN JDT1."Debit"
        ELSE JDT1."Debit"
    END AS "Cargo",
    -- Abono
    CASE
        WHEN OACT."U_CodAgrup" = '115.03'
        AND JDT1."Debit" = 0 THEN JDT1."Credit"
        ELSE JDT1."Credit"
    END AS "Abono",
    JDT1."ProfitCode" AS "Negocio",
    JDT1."OcrCode2" AS "Sucursal",
    JDT1."OcrCode3" AS "Area",
    JDT1."OcrCode4" AS "Ciclo",
    JDT1."OcrCode5" AS "Equipos",
    JDT1."Project" AS "Proyecto",
    -- Comentario
    COALESCE(
        OPCH."Comments",
        ORPC."Comments",
        OINV."Comments",
        OJDT."Memo",
        JDT1."LineMemo"
    ) AS "Comentario"
FROM
    OJDT
    INNER JOIN JDT1 ON OJDT."TransId" = JDT1."TransId"
    -- Cuentas
    INNER JOIN OACT ON JDT1."Account" = OACT."AcctCode"
    -- Facturas proveedor
    LEFT JOIN OPCH ON OJDT."BaseRef" = CAST(OPCH."DocNum" AS NVARCHAR)
    AND OJDT."TransType" = 18
    -- Créditos cliente
    LEFT JOIN ORPC ON OJDT."BaseRef" = CAST(ORPC."DocNum" AS NVARCHAR)
    AND OJDT."TransType" = 24
    LEFT JOIN OINV ON OJDT."BaseRef" = CAST(OINV."DocNum" AS NVARCHAR)
    AND OJDT."TransType" IN (13, 14)
    LEFT JOIN INV1 ON OINV."DocEntry" = INV1."DocEntry"
    -- Filtros
WHERE
    OJDT."RefDate" BETWEEN '2025-09-01' AND '2025-09-30'
    -- Ordenado por fecha descendente
    
ORDER BY
    OJDT."RefDate" DESC;



-- Para saber a cuales y cuantos tipos de documentos distintos hacen referencia los asientos
SELECT 
    "TransType",
    COUNT(*) AS "Cantidad_Asientos"
FROM "OJDT"
GROUP BY "TransType"
ORDER BY "Cantidad_Asientos" DESC;


-- Para comparar unos asientos con los otros
SELECT *
FROM "OJDT"
join jdt1 on ojdt."TransId" = jdt1."TransId"
WHERE OJDT."RefDate" BETWEEN '2025-09-01' AND '2025-09-30'
ORDER BY 
    CASE 
        WHEN "Number" IN ('56452','51794') THEN 0 
        ELSE 1 
    END,
    "Number";



/*
    CASE
        WHEN OJDT."TransType" = 18 THEN 'Factura de proveedor'
        WHEN OJDT."TransType" = 46 THEN 'Pago efectuado'
        WHEN OJDT."TransType" = 13 THEN 'Factura de cliente'
        WHEN OJDT."TransType" = 59 THEN 'Entrada de mercancías'
        WHEN OJDT."TransType" = 20 THEN 'Entrada de mercancías por compra'
        WHEN OJDT."TransType" = 60 THEN 'Salida de mercancías'
        WHEN OJDT."TransType" = 15 THEN 'Entrega'
        WHEN OJDT."TransType" = 24 THEN 'Crédito/Transferencia'
        WHEN OJDT."TransType" = 14 THEN 'Nota de crédito de cliente'
        WHEN OJDT."TransType" = 203 THEN 'Devolución de proveedor'
        WHEN OJDT."TransType" = 30 THEN 'Asiento manual'
        WHEN OJDT."TransType" = 321 THEN 'Reconciliación interna'
        WHEN OJDT."TransType" = 204 THEN 'Factura anticipo de proveedores'
        WHEN OJDT."TransType" = 1470000049 THEN 'Capitalizacion'
        ELSE 'Otro / Sin clasificar'
    END AS "Origen",


    JDT1."SourceLine" IS NULL
            OR (JDT1."SourceLine" = 1 AND JDT1."Debit" = 0 AND JDT1."Credit" = 0)
            OR JDT1."SourceLine" = -4
            OR JDT1."SourceLine" = -99
            OR JDT1."SourceLine" = -10
            OR JDT1."SourceLine" = -7
            OR JDT1."SourceLine" = -2
            OR JDT1."SourceLine" = 0
            OR JDT1."SourceLine" = -1
    */