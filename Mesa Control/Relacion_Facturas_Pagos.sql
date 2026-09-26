SELECT DISTINCT
    -- Proveedor
    OCRD."CardCode" AS "No. Proveedor",
    OCRD."CardName" AS "Proveedor",

    -- Entrada de mercancías
    OPDN."DocEntry" AS "Entrada de mercancias",
    OPDN."DocNum" AS "No. Entrada de mercancias",
    TO_DATE(OPDN."DocDate") AS "Fecha Entrada de mercancias",

    -- Factura
    OPCH."DocEntry" AS "ID De Factura",
    OPCH."DocNum" AS "No. Factura EN SAP",
    OPCH."NumAtCard" AS "No. Factura REAL",
    OPCH."DocTotal" AS "Monto Facturado",
    TO_DATE(OPCH."DocDate") AS "Fecha Factura",

    -- Pago 
    OVPM."DocNum" AS "Pago efectuado",
    TO_DATE(OVPM."DocDate") AS "Fecha Pago",
    CASE
        WHEN OVPM."DocEntry" IS NOT NULL THEN VPM2."SumApplied"
        ELSE NULL
    END AS "Monto Pagado"

-- Consulta a entradas de mercancías de proveedores
FROM OPDN
    -- Datos del proveedor
    INNER JOIN OCRD ON OPDN."CardCode" = OCRD."CardCode"

    -- Líneas de la entrada de mercancías
    INNER JOIN PDN1 ON PDN1."DocEntry" = OPDN."DocEntry"

    -- Relación con facturas copiadas desde la entrada de mercancías
    LEFT JOIN PCH1 ON PCH1."BaseEntry" = PDN1."DocEntry"
        AND PCH1."BaseLine" = PDN1."LineNum"
        AND PCH1."BaseType" = 20
    LEFT JOIN OPCH ON OPCH."DocEntry" = PCH1."DocEntry"
        AND OPCH."CANCELED" = 'N'

    -- Relación con pagos efectuados aplicados a la factura
    LEFT JOIN VPM2 ON VPM2."DocEntry" = OPCH."DocEntry"
        AND VPM2."InvType" = 18
    LEFT JOIN OVPM ON OVPM."DocEntry" = VPM2."DocNum"
        AND OVPM."Canceled" = 'N'

-- Filtros
WHERE
    -- Solo entradas de mercancías no canceladas
    OPDN."CANCELED" = 'N'

    -- FILTRO DE PROVEEDOR, REEMPLAZAR POR EL CODIGO DESEADO
    -- AND OCRD."CardCode" = 'P00001'

-- Ordenado por número de entrada de mercancías
ORDER BY
    OPDN."DocNum" DESC