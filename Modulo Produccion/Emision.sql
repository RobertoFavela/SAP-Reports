SELECT 
    T4."DocDate" AS "Fecha Emision",    
    T4."DocNum" AS "Num Emision",
    T4."Ref2",
    T0."DocNum" AS "Num Orden Produccion",

    -- Datos de la Cabecera de la Orden de Producción
    T0."ItemCode" AS "Articulo Padre OWOR",
    T0."ProdName" AS "Descripcion Padre OWOR",
    
    -- Datos de las Líneas (Componentes Planificados) de la Orden
    CASE T1."ItemType"
        WHEN 4 THEN 'Artículo'
        WHEN 290 THEN 'Recurso'
        WHEN -16 THEN 'Texto'
        WHEN 1 THEN 'Gasto Adicional'
        ELSE 'Otro'
    END AS "Tipo de Elemento",
    T1."ItemCode" AS "Componente Planificado",
    -- Buscamos la descripción en OITM para asegurar que aparezca aunque no haya emisión
    T3."ItemName" AS "Descripcion Componente Planificado", 
    
    -- Datos de la Emisión para Producción (Si existen, si no, aparecerán vacíos)
    T2."ItemCode" AS "Componente Emitido",
    T2."Dscription" AS "Descripcion Componente",
    T1."PlannedQty",
    T2."Quantity" AS "Cantidad Emitida",
    T2."LineTotal",
    T2."StockPrice",
    T0."Comments" AS "Comentarios Orden",
    T4."Comments" AS "Comentarios Emision"

FROM OWOR T0
INNER JOIN WOR1 T1 ON T0."DocEntry" = T1."DocEntry"
LEFT JOIN OITM T3 ON T1."ItemCode" = T3."ItemCode" 
LEFT JOIN IGE1 T2 ON T2."BaseEntry" = T0."DocEntry" 
                 AND T2."BaseLine" = T1."LineNum" 
                 AND T2."BaseType" = 202
LEFT JOIN OIGE T4 ON T2."DocEntry" = T4."DocEntry"
ORDER BY T0."DocNum", T1."LineNum";