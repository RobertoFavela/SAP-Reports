SELECT   
    -- Datos de la factura de proveedor
    TO_DATE(OPCH."DocDate") AS "Fecha de contabilizacion",
    OPCH."DocNum" AS "No Factura",
    OPCH."DocEntry" AS "ID Factura",

    -- Pedido
    OPOR."DocNum" AS "No. de pedido",
    OPOR."NumAtCard" AS "No. ref. del acreedor",
    OPOR."CardCode" AS "No. Proveedor",
    OPOR."CardName" AS "Proveedor",

    -- Entrada de mercancía
    OPDN."DocNum" AS "No Entrada",
    OPDN."DocEntry" AS "ID Entrada",

    -- Datos del artículo
    PDN1."ItemCode" AS "No. de articulo",
    PDN1."Dscription" AS "Descripcion de articulo",
    PDN1."Quantity" AS "Cantidad",
    PDN1."PriceAfVAT" AS "Precio por unidad",
    PDN1."LineTotal" AS "Total de linea",

    -- IVA
    TO_VARCHAR(TO_INT(PDN1."VatPrcnt")) || '%' AS "IVA",

    PDN1."VatSum" AS "Total IVA",

    -- Moneda
    OPDN."DocCur" AS "Moneda",

    CASE 
        WHEN OPDN."DocCur" = 'USD' THEN TO_DECIMAL(ORTT."Rate", 18, 4)
        ELSE NULL
    END AS "Tipo de cambio",

    CASE 
        WHEN OPDN."DocCur" = 'USD' THEN TO_DECIMAL(PDN1."LineTotal" / ORTT."Rate", 18, 4)
        ELSE NULL
    END AS "Conversion",

    -- Precio de entrega
    COALESCE(IPF1."TtlExpndLC", 0) AS "Precio de entrega",
    OIPF."DocNum" AS "No Precio Entrega",

    -- Costo total
    (PDN1."LineTotal" + COALESCE(IPF1."TtlExpndLC", 0) + COALESCE(PDN1."VatSum", 0)) AS "Costo total",

    -- UDF
    OPCH."U_UDF_UUID" AS "UDF_UUID",

    -- Comentarios del pedido
    OPOR."Comments" AS "Comentario del Pedido",

    -- Centros de costo
    PCH1."AcctCode" AS "Cuenta contable",
    PCH1."OcrCode" AS "Negocio",
    PCH1."OcrCode2" AS "Sucursal",
    PCH1."OcrCode3" AS "Area",
    PCH1."OcrCode4" AS "Negocio",
    PCH1."Project" AS "Proyecto"

-- Entrada de mercancia
FROM OPDN

-- Líneas de entrada
INNER JOIN PDN1 ON OPDN."DocEntry" = PDN1."DocEntry"

-- Cabecera de pedido ligado a la entrada
LEFT JOIN OPOR ON PDN1."BaseEntry" = OPOR."DocEntry"
    AND PDN1."BaseType" = OPOR."ObjType"

-- Lineas de Pedido
LEFT JOIN POR1 ON PDN1."BaseEntry" = POR1."DocEntry"
    AND PDN1."BaseLine" = POR1."LineNum"
    AND PDN1."BaseType" = POR1."ObjType"

-- Lineas de factura ligada a la entrada
LEFT JOIN PCH1 ON PDN1."DocEntry" = PCH1."BaseEntry"
    AND PDN1."LineNum"   = PCH1."BaseLine"
    AND PDN1."ObjType"   = PCH1."BaseType"

-- Cabecera de factura
LEFT JOIN OPCH ON PCH1."DocEntry" = OPCH."DocEntry"

-- Lineas de precio entrada
LEFT JOIN IPF1 ON PDN1."DocEntry" = IPF1."BaseEntry"
    AND PDN1."LineNum" = IPF1."OrigLine"
    AND PDN1."ObjType" = IPF1."BaseType"

-- Cabecera de precio entrada
LEFT JOIN OIPF ON IPF1."DocEntry" = OIPF."DocEntry"

-- Tipos de cambio
LEFT JOIN ORTT ON ORTT."RateDate" = OPDN."DocDate"
    AND ORTT."Currency" = 'USD'

-- Filtros
WHERE 
    -- Filtro de fechas de entradas
    OPDN."DocDate" BETWEEN '2025-01-01' AND '2025-12-31'
    AND OPDN."CANCELED" = 'N'

ORDER BY
    OPDN."DocNum" DESC