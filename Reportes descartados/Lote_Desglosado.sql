SELECT
    -- Almacen
    OWHS."WhsName" AS "Almacén",
    OBTQ."WhsCode" AS "Cod. Almacén",
    
    -- Articulo
    TO_DATE (OBTN."InDate") AS "Fecha",
    OBTN."DistNumber" AS "Lote",
    OBTQ."ItemCode" AS "Cod. Artículo",
    OITM."ItemName" AS "Descripción",
    
    -- Cantidad Ingresada
    COALESCE(
        (
            SELECT
                SUM(IBT1."Quantity")
            
            -- Lineas de lote
            FROM IBT1

            -- Filtros
            WHERE
                -- Filtramos con el numero de lote
                IBT1."BatchNum" = OBTN."DistNumber"

                -- Cuadramos el codigo del item
                AND IBT1."ItemCode" = OBTQ."ItemCode"

                -- Tomamos en cuenta unicamente entregas
                AND IBT1."Direction" = 0 -- 1 significa Entradas
        ),
        0
    ) AS "KG Recibidos",
    
    -- Cantidad Salida
    COALESCE(
        (
            SELECT
                SUM(IBT1."Quantity")
            
            -- Lineas de lote
            FROM IBT1

            -- Filtros
            WHERE
                -- Cuadramos con el numero de lote
                IBT1."BatchNum" = OBTN."DistNumber"

                -- Cuadramos el codigo del item
                AND IBT1."ItemCode" = OBTQ."ItemCode"

                -- Tomamos en cuenta unicamente salidas
                AND IBT1."Direction" = 1 -- 1 significa Salidas
        ),
        0
    ) AS "KG Facturados",
    
    -- Inventario KG
    SUM(OBTQ."Quantity") AS "Cantidad Disponible"

-- Lotes
FROM OBTN
    -- Cantidades por lote por almacen
    JOIN OBTQ ON OBTN."AbsEntry" = OBTQ."MdAbsEntry"
    -- Articulos
    JOIN OITM ON OBTQ."ItemCode" = OITM."ItemCode"
    -- Almacenes
    JOIN OWHS ON OBTQ."WhsCode" = OWHS."WhsCode"

WHERE
    /*
    Filtrar año en numero de lote
    Ejemplo: GU37125281
    Primeros dos digitos representan el almacen
    Siguientes 3 digitos representan numero juliano del año
    Siguientes 2 digitos el año
    */
    SUBSTRING(OBTN."DistNumber", 6, 1) = '2' AND 
    SUBSTRING(OBTN."DistNumber", 7, 1) = '5'

    -- Filtrado por numero de lote
    AND OBTN."DistNumber" = 'NO33425273'

-- Agrupado por:
GROUP BY
    -- Numero de lote
    OBTN."DistNumber",
    -- Numero de Almacen
    OBTQ."WhsCode",
    -- Nombre de almacen
    OWHS."WhsName",
    -- Numero de articulo
    OBTQ."ItemCode",
    -- Nombre de articulo
    OITM."ItemName",
    -- Fecha de enrada
    OBTN."InDate"
    
-- Filtro unicamente lotes con cantidad disponible
HAVING
    SUM(OBTQ."Quantity") > 0

ORDER BY
    -- Ordenado Por fecha mas reciente   
    OBTN."InDate" DESC

    -- Ordenado Por mayor cantidad disponible
    -- SUM(OBTQ."Quantity") DESC


