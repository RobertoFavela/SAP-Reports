SELECT
    -- Pedido
    TO_DATE (OPOR."DocDate") AS "Fecha Pedido",
    OPOR."DocNum" AS "N° Pedido",
    
    -- Número de entrega relacionado con esta línea de pedido
    (
        SELECT MAX(OPDN."DocNum")
        FROM PDN1
        JOIN OPDN ON OPDN."DocEntry" = PDN1."DocEntry"
        WHERE PDN1."BaseEntry" = POR1."DocEntry"
          AND PDN1."BaseLine" = POR1."LineNum"
          AND PDN1."BaseType" = 22
    ) AS "No. de entrega",
    
    -- Articulo
    POR1."ItemCode" AS "Código Artículo",
    OITM."ItemName" AS "Descripción Artículo",
    
    -- Almacen
    POR1."WhsCode" AS "Cod. Almacén",
    OWHS."WhsName" AS "Nombre Almacén",
    
    POR1."Quantity" AS "Cantidad Pedida",
    
    -- Total de entradas relacionadas a esta línea
    (
        SELECT
            SUM(PDN1."Quantity")
        FROM
            PDN1
        WHERE
            PDN1."BaseEntry" = POR1."DocEntry"
            AND PDN1."BaseLine" = POR1."LineNum"
            AND PDN1."BaseType" = 22
    ) AS "Cantidad Recibida",
    
    -- Costo invididual del articulo
    POR1."Price" AS "Precio unitario",

    -- Costo total de linea
    POR1."LineTotal" AS "Costo total",

    -- Fecha de la última entrada (si hay)
    (
        SELECT
            TO_DATE(MAX(OPDN."DocDate"))
        FROM
            PDN1
            JOIN OPDN ON OPDN."DocEntry" = PDN1."DocEntry"
        WHERE
            PDN1."BaseEntry" = POR1."DocEntry"
            AND PDN1."BaseLine" = POR1."LineNum"
            AND PDN1."BaseType" = 22
    ) AS "Última Fecha Entrada"

-- cabecera de Orden de compra 
FROM OPOR
    -- linea de Orden de compra
    JOIN POR1 ON OPOR."DocEntry" = POR1."DocEntry"
    -- Maestro de articulos
    JOIN OITM ON POR1."ItemCode" = OITM."ItemCode"
    -- Grupo de articulos
    JOIN OITB ON OITM."ItmsGrpCod" = OITB."ItmsGrpCod"
    -- Almacenes
    JOIN OWHS ON POR1."WhsCode" = OWHS."WhsCode"

-- Filtros
WHERE
    -- Solo pedidos no cancelados
    OPOR."CANCELED" = 'N'
    -- Solo pedidos con camaron en bordo
    AND OITB."ItmsGrpNam" = 'CAMARON EN BORDO'

    -- Filtro de fechas
    -- AND OPOR."DocDate" BETWEEN '2025-09-01' AND 2025-09-30'

ORDER BY
    -- Numero de pedido
    OPOR."DocNum" DESC,
    -- Linea de pedido
    POR1."LineNum"

