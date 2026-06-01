SELECT 
    T0."DocNum" AS "Numero Documento",
    T0."DocDate" AS "Fecha Contabilizacion",
    T0."Ref2" AS "Referencia 2",
    T2."DocNum" AS "Numero de Orden",
    CASE T1."ItemType"
        WHEN 4 THEN 'Artículo'
        WHEN 290 THEN 'Recurso'
        WHEN -16 THEN 'Texto'
        WHEN 1 THEN 'Gasto Adicional'
        ELSE 'Otro (' || CAST(T1."ItemType" AS VARCHAR) || ')'
    END AS "Tipo de Elemento", -- <- Aquí se hace la traducción automática
    T1."ItemCode" AS "Numero de Articulo",
    T1."Dscription" AS "Descripcion del Articulo",
    T1."Quantity" AS "Cantidad",
    T1."Price" AS "Precio por Unidad",
    T1."LineTotal" AS "Total",
    T1."StockPrice" AS "Costo del Articulo",
    T2."PlannedQty" AS "Cantidad Planificada OWOR",
    T0."Comments" AS "Comentarios"
FROM OIGN T0
INNER JOIN IGN1 T1 ON T0."DocEntry" = T1."DocEntry"
INNER JOIN OWOR T2 ON T1."BaseEntry" = T2."DocEntry" AND T1."BaseType" = 202
ORDER BY T0."DocNum", T1."LineNum";