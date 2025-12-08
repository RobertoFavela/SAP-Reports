SELECT 
    -- Pedido
    OPOR."DocNum" AS "No. Pedido",
    TO_DATE(OPOR."DocDate") AS "Fecha Pedido",
    POR1."ItemCode" AS "No. Articulo",
    POR1."Dscription" AS "Descripcion",
    POR1."Quantity" AS "Cantidad Pedida",

    -- Entrada de Mercancía
    OPDN."DocNum" AS "No. Entrada",
    TO_DATE(OPDN."DocDate") AS "Fecha Entrada",
    PDN1."Quantity" AS "Cantidad Entrada"

-- Pedido
FROM OPOR
    -- Lineas pedido
    INNER JOIN POR1 ON OPOR."DocEntry" = POR1."DocEntry"

    -- Entradas de Mercancía (relacionadas con el pedido)
    LEFT JOIN PDN1 ON PDN1."BaseType" = 22
                  AND PDN1."BaseEntry" = POR1."DocEntry"
                  AND PDN1."BaseLine" = POR1."LineNum"

    LEFT JOIN OPDN ON OPDN."DocEntry" = PDN1."DocEntry"

    -- Maestro de articulos
    JOIN OITM ON POR1."ItemCode" = OITM."ItemCode"
    -- Grupo de articulos
    JOIN OITB ON OITM."ItmsGrpCod" = OITB."ItmsGrpCod"

-- FIltros
WHERE
    -- Solo pedidos no cancelados
    OPOR."CANCELED" = 'N'
    -- Solo pedidos con camaron en bordo
    AND OITB."ItmsGrpNam" = 'CAMARON EN BORDO'