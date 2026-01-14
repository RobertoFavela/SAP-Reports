SELECT
    -- Factura
    OINV."DocDate" AS "Fecha Factura",
    OINV."CardCode" AS "Codigo Cliente",
    OINV."CardName" AS "Nombre Cliente",
    OINV."DocEntry" AS "Id Facrtura",
    OINV."DocNum" AS "No Factura",
    
    -- Tipo de cambio
    ORTT."Rate" AS "Tipo de Cambio",

    -- Articulo
    INV1."U_SBO_CICLO" AS "Ciclo",
    INV1."Dscription" AS "Descripcion",
    OITM."U_SBO_PRESENTACION" AS "Presentacion",

    -- Cantidades
    INV1."Quantity" AS "Cantidad KG",
    TO_DECIMAL(INV1."Quantity" * 2.20462262, 18, 4) AS "Cantidad LB",

    -- Cajas (FIXED CASE)
    CASE 
        WHEN OITM."U_TIP_PRESENTACION" = 'L' THEN
            TO_DECIMAL(((INV1."Quantity" * 2.20462262) / NULLIF(OITM."U_LIBRAS", 0)), 18, 4)
        WHEN OITM."U_TIP_PRESENTACION" = 'K' THEN
            TO_DECIMAL((INV1."Quantity" / NULLIF(OITM."U_KILOS", 0)), 18, 4)
        ELSE 0
    END AS "Cajas",

    
    CASE
        WHEN OINV."DocCur" = 'MXP' THEN
            INV1."Price"
        WHEN OINV."DocCur" = 'USD' THEN
            TO_DECIMAL((INV1."Price" / ORTT."Rate"), 18, 4)
        ELSE 0
    END AS "Precio Unitario MXP",
    INV1."LineTotal" AS "Precio Total MXP",

    -- Totales
    OINV."DocTotal" AS "Total MXP",
    TO_DECIMAL(OINV."DocTotal" / ORTT."Rate", 18, 4) AS "Total USD",
    
    -- Información adicional
    INV1."WhsCode" AS "Almacen",
    INV1."OcrCode2" AS "Sucursal",
    INV1."OcrCode" AS "Negocio"

FROM OINV
    INNER JOIN INV1 ON OINV."DocEntry" = INV1."DocEntry"
    LEFT JOIN ORTT ON ORTT."RateDate" = OINV."DocDate" 
        AND ORTT."Currency" = 'USD'
    INNER JOIN OITM ON OITM."ItemCode" = INV1."ItemCode"
    -- Grupos de artículos
    JOIN OITB ON OITB."ItmsGrpCod" = OITM."ItmsGrpCod"

WHERE
    -- Solo Facturas no canceladas
    OINV."CANCELED" = 'N'

    AND OINV."DocNum" = '4125'

    -- Solo traemos articulos de camaron frizado
    AND OITB."ItmsGrpNam" = 'PT CAMARON FRIZADO'

    -- Filtro de fechas
    -- AND OINV."DocDate" BETWEEN '2025-11-01' AND '2025-11-30'

ORDER BY 
    OINV."DocNum" DESC