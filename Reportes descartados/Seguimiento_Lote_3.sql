SELECT
    OIGN."Ref2" AS "Lote",
    
    -- Pedido
    TO_DATE(OPOR."DocDate") AS "Fecha Pedido",
    OPOR."DocNum",
    SUM(POR1."Quantity") AS "KG Pedidos",

    -- Entrada mercancia fresca
    TO_DATE(OPDN."DocDate") AS "Fecha Recibidos",
    OPDN."DocNum",
    SUM(PDN1."Quantity") AS "KG Recibidos",
    
    -- Salida mercancia fresca
    TO_DATE(OIGE."DocDate") AS "Fecha Salida",
    OIGE."DocNum",
    SUM(IGE1."Quantity") AS "KG Recibidos Salida",
    
    -- Entrada procesada
    TO_DATE(OIGN."DocDate") AS "Fecha Entrada",
    OIGN."DocNum",
    SUM(IGN1."Quantity") AS "KG Procesados"
    
-- Cabecera Entrada Friz 
FROM OIGN
    -- Línea de entrada Friz
    INNER JOIN IGN1 ON OIGN."DocEntry" = IGN1."DocEntry"

    -- Referencia Entrada Friz - Salida Fresco
    LEFT JOIN IGN21 ON IGN21."DocEntry" = IGN1."DocEntry" 
                   AND IGN21."LineNum" = IGN1."LineNum"

    -- Salida Fresco
    INNER JOIN OIGE ON IGN21."RefDocNum" = OIGE."DocNum"
    INNER JOIN IGE1 ON OIGE."DocEntry" = IGE1."DocEntry"

    -- Referencia de Salida Fresco - Entrada Fresco
    LEFT JOIN IGE21 ON IGE21."DocEntry" = IGE1."DocEntry"
                   AND IGE21."LineNum" = IGE1."LineNum"

    -- Entrada fresco
    INNER JOIN OPDN ON IGE21."RefDocNum" = OPDN."DocNum"
    INNER JOIN PDN1 ON OPDN."DocEntry" = PDN1."DocEntry"

    -- Detalle del pedido de compra
    INNER JOIN POR1 ON PDN1."BaseType" = 22
                    AND PDN1."BaseEntry" = POR1."DocEntry"
                    AND PDN1."BaseLine" = POR1."LineNum"
    INNER JOIN OPOR ON POR1."DocEntry" = OPOR."DocEntry"

    -- Maestro de artículos
    JOIN OITM ON IGN1."ItemCode" = OITM."ItemCode"
    -- Grupo de artículos
    JOIN OITB ON OITM."ItmsGrpCod" = OITB."ItmsGrpCod"

WHERE
    -- Solo entradas no canceladas
    OIGN."CANCELED" = 'N'

    -- Solo grupos válidos
    AND (
        OITB."ItmsGrpNam" = 'CAMARON EN BORDO'
        OR OITB."ItmsGrpNam" = 'PT CAMARON FRIZADO'
    )

    -- Entrada específica
    AND OIGN."DocNum" = '3872'

GROUP BY
    --Pedido
    OPOR."DocDate",
    OPOR."DocNum",

    -- Mercancia fresca entrada
    OPDN."DocDate",
    OPDN."DocNum",

    -- Mercancia fresca salida
    OIGE."DocDate",
    OIGE."DocNum",

    -- Mercancia friz entrada
    OIGN."DocDate",
    OIGN."DocNum",
    
    -- Lote
    OIGN."Ref2"
