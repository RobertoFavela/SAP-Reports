SELECT
    -- Facturas
    OINV."DocEntry" AS "ID Factura",
    OINV."DocNum" AS "No Factura",

    -- Entregas
    ODLN."DocEntry" AS "ID Entrega",
    ODLN."DocNum" AS "No Entrega",

    -- Articulos
    INV1."ItemCode" AS "No. de Artículo",
    INV1."Dscription" AS "Descripción Artículo/Servicio",

    -- KGS Facturados (cliente C00131: libras a kilos - articulo VA24PUPV68: 200gr)
    -- convertido a decimal con 6 decimales
    TO_DECIMAL (
        CASE
            WHEN DLN1."BaseCard" = 'C00131'
            AND INV1."ItemCode" = 'VA24PUPV68' THEN TO_DECIMAL (INV1."Quantity", 18, 6) / TO_DECIMAL (5, 18, 6)
            WHEN DLN1."BaseCard" = 'C00131' THEN TO_DECIMAL (INV1."Quantity", 18, 6) * TO_DECIMAL (0.45359237, 18, 6)
            ELSE TO_DECIMAL (INV1."Quantity", 18, 6)
        END,
        18,
        4
    ) AS "KGS Facturados",
    
    DLN1."Quantity" AS "KGS Entregados",
    RIN1."Quantity" AS "KGS Crédito",
    
    -- Diferencia (cliente C00131: libras a kilos - articulo VA24PUPV68: 200gr)
    -- convertido a decimal con 6 decimales
    TO_DECIMAL (
        (
            CASE
                WHEN DLN1."BaseCard" = 'C00131'
                AND INV1."ItemCode" = 'VA24PUPV68' THEN TO_DECIMAL (INV1."Quantity", 18, 6) / TO_DECIMAL (5, 18, 6)
                WHEN DLN1."BaseCard" = 'C00131' THEN TO_DECIMAL (INV1."Quantity", 18, 6) * TO_DECIMAL (0.45359237, 18, 6)
                ELSE TO_DECIMAL (INV1."Quantity", 18, 6)
            END - COALESCE(TO_DECIMAL (DLN1."Quantity", 18, 6), 0) - COALESCE(TO_DECIMAL (RIN1."Quantity", 18, 6), 0)
        ),
        18,
        4
    ) AS "Diferencia",

    -- Fechas
    TO_DATE (ODLN."DocDate") AS "Fecha Entrega",
    TO_DATE (OINV."DocDate") AS "Fecha Factura",

    DLN1."WhsCode" AS "Código de Almacén",
    DLN1."DocDate" AS "Fecha Contabilización",
    DLN1."BaseCard" AS "Código Base SN",
    DLN1."OcrCode" AS "Norma de Reparto",
    DLN1."VatGroup" AS "Definición del Impuesto",
    DLN1."BaseDocNum" AS "Documento Base",
    DLN1."FinncPriod" AS "Período Contable",
    DLN1."ObjType" AS "Tipo de Objeto",
    DLN1."unitMsr" AS "Unidad",
    DLN1."StockSum",

    -- Costo del Artículo
    TO_DECIMAL (DLN1."StockPrice", 18, 4) AS "Costo del Artículo",
    
    -- Ingreso
    TO_DECIMAL (INV1."GTotal", 18, 6) AS "Ingreso",
    
    -- Costo de venta (Cantidad * Precio de stock)
    TO_DECIMAL (DLN1."Quantity", 18, 6) * TO_DECIMAL (DLN1."StockPrice", 18, 6) AS "Costo Venta",
    
    -- Importe Nota Crédito
    TO_DECIMAL (RIN1."Quantity", 18, 6) * TO_DECIMAL (RIN1."Price", 18, 6) + TO_DECIMAL (RIN1."VatSum", 18, 6) AS "Importe Nota Crédito",
    
    -- Utilidad (Ingreso - Costo de venta - Importe nota de credito)
    TO_DECIMAL (INV1."GTotal", 18, 6) - COALESCE(
        TO_DECIMAL (DLN1."Quantity", 18, 6) * TO_DECIMAL (DLN1."StockPrice", 18, 6),
        0
    ) - COALESCE(
        TO_DECIMAL (RIN1."Quantity", 18, 6) * TO_DECIMAL (RIN1."Price", 18, 6) + TO_DECIMAL (RIN1."VatSum", 18, 6),
        0
    ) AS "Utilidad",

    DLN1."LineStatus",
    DLN1."BaseType",
    DLN1."BaseEntry",
    DLN1."BaseAtCard",
    DLN1."CogsOcrCod",

    -- Sucursales
    DLN1."OcrCode2",
    DLN1."OcrCode3",
    
    -- Ciclos
    DLN1."OcrCode4",
    DLN1."OcrCode5",
    DLN1."U_SBO_MARCA",
    DLN1."U_SBO_PRESENTACION",
    DLN1."U_SBO_CICLO",
    DLN1."U_SBO_CALIDAD"
    
-- Lineas de Facturas
FROM INV1
    -- Cabeceras de Facturas
    INNER JOIN OINV ON OINV."DocEntry" = INV1."DocEntry"

    -- Lineas de Entregas
    LEFT JOIN DLN1 ON DLN1."BaseEntry" = OINV."DocEntry"
        AND DLN1."BaseLine" = INV1."LineNum"
        AND DLN1."BaseType" = 13

    -- Cabeceras de Entregas
    LEFT JOIN ODLN ON ODLN."DocEntry" = DLN1."DocEntry"

    -- Lineas de Notas de Crédito
    LEFT JOIN RIN1 ON RIN1."BaseEntry" = OINV."DocEntry"
        AND RIN1."BaseLine" = INV1."LineNum"
        AND RIN1."BaseType" = 13

    -- Cabeceras de Notas de Crédito
    LEFT JOIN ORIN ON ORIN."DocEntry" = RIN1."DocEntry"

    -- Maestro de artículos
    JOIN OITM ON OITM."ItemCode" = INV1."ItemCode"
    
    -- Grupos de artículos
    JOIN OITB ON OITB."ItmsGrpCod" = OITM."ItmsGrpCod"

WHERE
    OINV."CANCELED" = 'N'
    AND OITB."ItmsGrpNam" = 'PT CAMARON FRIZADO'

    AND OINV."DocDate" BETWEEN '2025-11-01' AND '2025-11-30'

ORDER BY
    OINV."DocNum" DESC