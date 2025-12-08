/*
==============================================================================================
                        REPORTE DE COMPRAS DE FACTURA DE PROVEEDOR
==============================================================================================
*/
SELECT
    -- Datos de la factura de proveedor
    TO_DATE(OPCH."DocDate") AS "Fecha de contabilizacion",
    OPCH."DocNum" AS "No Factura",
    OPCH."DocEntry" AS "ID Factura",

    -- Datos del pedido original
    OPOR."DocNum" AS "No. de pedido",
    OPOR."NumAtCard" AS "No. ref. del acreedor",
    OPOR."CardCode" AS "No. Proveedor",
    OPOR."CardName" AS "Proveedor",

    -- Datos del artículo en factura de proveedor
    PCH1."ItemCode" AS "No. de articulo",
    PCH1."Dscription" AS "Descripcion de articulo",
    PCH1."Quantity" AS "Cantidad",
    PCH1."Price" AS "Precio por unidad",

    PCH1."LineTotal" AS "Total de linea",

    -- IVA
    TO_VARCHAR(TO_INT(PCH1."VatPrcnt")) || '%' AS "IVA",
    PCH1."VatSum" AS "Total IVA",

    -- Moneda
    OPCH."DocCur" AS "Moneda",

    CASE 
        WHEN OPCH."DocCur" = 'USD' THEN ORTT."Rate"
        ELSE NULL
    END AS "Tipo de cambio",

    -- Conversión
    CASE 
        WHEN OPCH."DocCur" = 'USD' THEN TO_DECIMAL(PCH1."LineTotal" / ORTT."Rate", 18, 4)
        ELSE NULL
    END AS "Conversion",

    -- Costo total
    (PCH1."LineTotal" + COALESCE(PCH1."VatSum", 0)) AS "Costo total",

    -- Campos definidos por el usuario
    OPCH."U_UDF_UUID" AS "UDF_UUID",

    OPOR."Comments" AS "Comentario del Pedido",

    PCH1."AcctCode" AS "Cuenta contable",

    PCH1."OcrCode" AS "Negocio",
    PCH1."OcrCode2" AS "Sucursal",
    PCH1."OcrCode3" AS "Area",
    PCH1."OcrCode4" AS "Negocio",
    PCH1."Project" AS "Proyecto"

-- Cabecera de factura de proveedor
FROM OPCH  
    -- Líneas de factura de proveedor
    INNER JOIN PCH1 ON OPCH."DocEntry" = PCH1."DocEntry"

    -- Relación con líneas de entrada de mercancía
    LEFT JOIN PDN1 ON PDN1."DocEntry" = PCH1."BaseEntry"
        AND PDN1."LineNum" = PCH1."BaseLine"
        AND PCH1."BaseType" = 20  -- Entrada de mercancía

    -- Cabecera de la entrada de mercancía
    LEFT JOIN OPDN ON OPDN."DocEntry" = PDN1."DocEntry"

    -- Relación con líneas del pedido original
    LEFT JOIN POR1 ON POR1."DocEntry" = PDN1."BaseEntry"
        AND POR1."LineNum" = PDN1."BaseLine"
        AND PDN1."BaseType" = 22  -- Pedido de compra

    -- Cabecera del pedido
    LEFT JOIN OPOR ON OPOR."DocEntry" = POR1."DocEntry"

    -- Tipos de cambio
    LEFT JOIN ORTT ON ORTT."RateDate" = OPCH."DocDate"
        AND ORTT."Currency" = 'USD'

-- Filtro
WHERE 
    OPCH."CANCELED" = 'N'

    -- Filtro de fechas
    AND OPCH."DocDate" BETWEEN '2025-01-01' AND '2025-12-31'

ORDER BY 
    OPCH."DocNum" DESC
