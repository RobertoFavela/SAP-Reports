SELECT 
    T0."DocNum" AS "Pedido_Compra",
    T0."DocDate" AS "Fecha_Pedido",
    T1."ItemCode" AS "Articulo",
    T1."Dscription" AS "Descripcion",
    T1."Quantity" AS "Cant_Pedida",
    T3."DocEntry" AS "Entrada_Mercancia",
    T3."DocNum",
    T2."Quantity" AS "Cant_Recibida",
    TO_DECIMAL(T1."Quantity" - T2."Quantity", 18, 4) AS "Diferencia"
    
FROM OPOR T0
INNER JOIN POR1 T1 ON T0."DocEntry" = T1."DocEntry"

-- Enlace con las Entradas de Mercancía (BaseType 22 = Pedido de Compra)
LEFT JOIN PDN1 T2 ON T1."DocEntry" = T2."BaseEntry" AND T1."LineNum" = T2."BaseLine" AND T2."BaseType" = 22
LEFT JOIN OPDN T3 ON T2."DocEntry" = T3."DocEntry"

-- Ordenamos del pedido más reciente al más antiguo
ORDER BY T0."DocNum" DESC