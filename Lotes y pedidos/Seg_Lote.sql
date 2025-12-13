SELECT
    -- Datos de lote
    Procesados."Almacen",
    Procesados."Fecha",
    Procesados."Lote",

    /*
    KG Pedidos (compras o inventario)
    Salida puede referenciar a una entrada de compras (OPDN, Recibidos)
    O referenciar a una entrada de inventario (OIGN, Recibidos2)
    */
    COALESCE(Recibidos."DocNum", Recibidos2."DocNum") AS "No. Entrada",
    COALESCE(Recibidos."Cantidad", Recibidos2."Cantidad") AS "Cantidad (KG)",
    
    -- KG Recibidos (Salidas)
    Salidas."No. Salida",
    Salidas."KG Recibidos",

    -- KG Procesados (Entradas de inventario)
    Procesados."No. Entrada",
    Procesados."KG Procesados",
    
    /*
    Rendimiento (%)
    Que porcentaje de la salida de mercancia, se proceso, y volvio a entrar
    */
    CASE
        WHEN Salidas."KG Recibidos" > 0 THEN ROUND(
            (Procesados."KG Procesados" / Salidas."KG Recibidos") * 100, 2
        )
        ELSE NULL
    END AS "Rendimiento (%)",
    
    /*
    Merma (KG)
    Que cantidad se perdio en el procesado
    */
    CASE
        WHEN Salidas."KG Recibidos" > 0 THEN ROUND(
            Salidas."KG Recibidos" - Procesados."KG Procesados"
        )
        ELSE NULL
    END AS "Merma (KG)",
    
    -- Datos de inventario
    Inventario."KG Facturados",
    Inventario."KG Disponibles"

FROM
    -- ENTRADAS DE MERCANCÍA (Procesados)
    (
        SELECT
            TO_DATE(OIGN."DocDate") AS "Fecha",
            OIGN."Ref2" AS "Lote",
            OIGN."DocNum" AS "No. Entrada",
            SUM(IGN1."Quantity") AS "KG Procesados",
            /*
            Documentos a los que hace referencia.
            Deberia hacerlo a una salida (no siempre lo hace)
            */
            IGN21."RefDocNum" AS "Referencia", 

            -- Almacen
            IGN1."WhsCode" AS "No. Almacen",
            OWHS."WhsName" AS "Almacen"
        FROM OIGN
            INNER JOIN IGN1 ON OIGN."DocEntry" = IGN1."DocEntry"
            LEFT JOIN IGN21 ON OIGN."DocEntry" = IGN21."DocEntry" -- Importante LEFT JOIN

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
                'CAMARON EN BORDO', 'PT CAMARON FRIZADO', 'MATERIA PRIMA'
            )
        GROUP BY
            OIGN."DocNum",
            OIGN."DocDate",
            OIGN."Ref2",
            IGN21."RefDocNum",
            IGN1."WhsCode",
            OWHS."WhsName"
    ) AS Procesados

    -- SALIDAS DE MERCANCÍA (Recibidos previos)
    LEFT JOIN (
        SELECT
            OIGE."DocNum" AS "No. Salida",
            SUM(IGE1."Quantity") AS "KG Recibidos",

            /*
            Documentos a los que hace referencia
            Deberia referenciar a una entrada de compras (OPDN)
            Puede referenciar a una entrada de inventario (OIGN) 
            */
            IGE21."RefDocNum" AS "Referencia"

        FROM OIGE
            INNER JOIN IGE1 ON OIGE."DocEntry" = IGE1."DocEntry"
            LEFT JOIN IGE21 ON OIGE."DocEntry" = IGE21."DocEntry" -- Importante LEFT JOIN

            -- Maestro de articulos
            INNER JOIN OITM ON IGE1."ItemCode" = OITM."ItemCode"
            INNER JOIN OITB ON OITM."ItmsGrpCod" = OITB."ItmsGrpCod"
        
        -- Filtros
        WHERE
            /*
            Las salidas NO se cancelan
            Se genera su documento contrario, una entrada
            Pero por si acaso
            */
            OIGE."CANCELED" = 'N'

            -- Solo tomamos en cuenta los siguientes grupos de articulos
            AND OITB."ItmsGrpNam" IN (
                'CAMARON EN BORDO', 'PT CAMARON FRIZADO', 'MATERIA PRIMA'
            )
        GROUP BY
            OIGE."DocNum",
            IGE21."RefDocNum"
    ) Salidas ON Salidas."No. Salida" = Procesados."Referencia"

    -- ENTRADAS DE MERCANCÍA DE COMPRAS (OPDN)
    LEFT JOIN (
        SELECT
            OPDN."DocNum",
            SUM(PDN1."Quantity") AS "Cantidad"
        FROM OPDN
            INNER JOIN PDN1 ON PDN1."DocEntry" = OPDN."DocEntry"

            -- Maestro de articulos
            INNER JOIN OITM ON PDN1."ItemCode" = OITM."ItemCode"
            INNER JOIN OITB ON OITM."ItmsGrpCod" = OITB."ItmsGrpCod"
        
        -- Filtros
        WHERE
            /*
            Las entradas NO se cancelan
            Se genera su documento contrario, una salida
            Pero por si acaso
            */
            OPDN."CANCELED" = 'N'

            -- Solo tomamos en cuenta los siguientes grupos de articulos
            AND OITB."ItmsGrpNam" IN (
                'CAMARON EN BORDO', 'PT CAMARON FRIZADO', 'MATERIA PRIMA'
            )
        GROUP BY 
            OPDN."DocNum"
    ) Recibidos ON Recibidos."DocNum" = Salidas."Referencia"

    -- ENTRADAS DE MERCANCÍA DE INVENTARIO (OIGN)
    LEFT JOIN (
        SELECT
            OIGN."DocNum",
            SUM(IGN1."Quantity") AS "Cantidad"
        FROM OIGN
            INNER JOIN IGN1 ON OIGN."DocEntry" = IGN1."DocEntry"

            -- Maestro de articulos
            INNER JOIN OITM ON IGN1."ItemCode" = OITM."ItemCode"
            INNER JOIN OITB ON OITM."ItmsGrpCod" = OITB."ItmsGrpCod"
            
        -- Filtros
        WHERE
            /*
            Las entradas NO se cancelan
            Se genera su documento contrario, una salida
            Pero por si acaso
            */
            OIGN."CANCELED" = 'N'

            -- Solo tomamos en cuenta los siguientes grupos de articulos
            AND OITB."ItmsGrpNam" IN (
                'CAMARON EN BORDO', 'PT CAMARON FRIZADO', 'MATERIA PRIMA'
            )
        GROUP BY
            OIGN."DocNum"
    ) Recibidos2 ON Recibidos2."DocNum" = Salidas."Referencia"

    -- INVENTARIO (OBTN / OBTQ)
    LEFT JOIN (
        SELECT
            OBTN."DistNumber" AS "Lote",
            COALESCE(
                (
                    SELECT SUM(IBT1."Quantity")
                    FROM IBT1
                    WHERE
                        IBT1."BatchNum" = OBTN."DistNumber"
                        AND IBT1."Direction" = 1
                ), 0
            ) AS "KG Facturados",
            SUM(OBTQ."Quantity") AS "KG Disponibles"
        FROM OBTN
            INNER JOIN OBTQ ON OBTN."AbsEntry" = OBTQ."MdAbsEntry"
        GROUP BY
            OBTN."DistNumber"
    ) Inventario ON Inventario."Lote" = Procesados."Lote"

-- FILTROS
WHERE
    -- Filtro de fechas
    Procesados."Fecha" BETWEEN '2025-01-01' AND '2025-12-31'

    -- Filtro por numero de lote
    -- AND Procesados."Lote" = 'NO33425273'

-- Ordenado por
ORDER BY
    
    -- Numero de entrada
    Procesados."No. Entrada" DESC

    -- Cantidad disponible en almacen
    -- Inventario."KG Disponibles"