SELECT
    -- Documento
    TO_DATE (OIGN."DocDate") AS "Fecha",
    OIGN."Ref2" AS "Lote",
    OIGN."DocNum" AS "No. Entrada",

    -- Almacen
    IGN1."WhsCode" AS "No. Almacen",
    OWHS."WhsName" AS "Almacen",

    -- Articulo (costos y cantidades)
    IGN1."ItemCode" AS "No. Articulo",
    OITM."ItemName" AS "Nombre de articulo",
    SUBSTRING(OITM."ItemName", '(', ')') AS "Parentesis",

    SUM(IGN1."Quantity") AS "Cantidad KG",
    IGN1."Price" AS "Precio Unitario",
    IGN1."LineTotal" AS "Precio TOTAL",

    -- Cantidad Salida
    COALESCE(
        (
            SELECT
                SUM(IBT1."Quantity")
            
            -- Lineas de lote
            FROM IBT1

            -- Filtros
            WHERE
                -- Filtramos con el lote de la entrega
                IBT1."BatchNum" = OIGN."Ref2"

                -- Cuadramos con el codigo del item
                AND IBT1."ItemCode" = IGN1."ItemCode"

                -- Tomamos en cuenta unicamente las salidas del almacen
                AND IBT1."Direction" = 1 -- Salidas (1=salida, 0=entrada)
        ),
        0
    ) AS "KG Facturados"

-- Entrada de mercancia en inventario
FROM OIGN
    INNER JOIN IGN1 ON OIGN."DocEntry" = IGN1."DocEntry"
    
    -- Maestro de articulos
    INNER JOIN OITM ON IGN1."ItemCode" = OITM."ItemCode"
    INNER JOIN OITB ON OITM."ItmsGrpCod" = OITB."ItmsGrpCod"
    
    -- Almacen
    INNER JOIN OWHS ON IGN1."WhsCode" = OWHS."WhsCode"
    
-- Filtros
WHERE
    /*
    Las entradas NO se cancelan
    Se genera su documento contrario, una salida
    Pero por si acaso
     */
    OIGN."CANCELED" = 'N'
    -- Solo contamos cantidades de los siguientes grupos de articulos
    AND OITB."ItmsGrpNam" IN (
        'CAMARON EN BORDO',
        'PT CAMARON FRIZADO',
        'MATERIA PRIMA'
    )
    
    -- Filtro de fechas
    AND OIGN."DocDate" BETWEEN '2025-01-01' AND '2025-12-31'
    
    -- Filtrar por lote
    AND OIGN."Ref2" = 'NO33425273'

-- Agrupado por
GROUP BY
    -- Documento
    OIGN."DocDate",
    OIGN."Ref2",
    OIGN."DocNum",
    OIGN."DocEntry",
    
    --Almacen
    IGN1."WhsCode",
    OWHS."WhsName",
    
    -- Articulo
    IGN1."ItemCode",
    OITM."ItemName",
    IGN1."Price",
    IGN1."LineTotal"

-- Ordenado por
ORDER BY
    OIGN."DocNum" DESC