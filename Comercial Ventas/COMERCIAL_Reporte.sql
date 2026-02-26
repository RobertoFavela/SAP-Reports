SELECT 
    -- Factura
    T0."DocEntry" AS "Id. Factura", 
    T0."DocNum" AS "No. Factura", 
    T0."DocDate" AS "Fecha", 

    OCRD."CardCode" AS "Id. Cliente",
    T0."CardName" AS "Cliente", 
    T0."DocTotal" AS "Importe",
    CASE 
        WHEN T0."DocStatus" = 'C' THEN 'Pagado' 
        ELSE 'Abierto' 
    END AS "Vencimiento",

    -- Abono (Pagos Recibidos)
    T3."DocEntry" AS "Id. Abono",
    T3."DocDate" AS "Fecha Abono", 
    T2."SumApplied" AS "Importe Abono",
    CASE         
        WHEN T3."Canceled" = 'Y' THEN 'Cancelado'         
        WHEN T3."Canceled" = 'N' THEN ''        
        ELSE ''     
    END AS "Estado Abono",

    -- Nota de Crédito
    T5."DocNum" || ' / ' || T5."DocEntry" AS "Folio NC",
    T5."DocDate" AS "Fecha NC", 
    T4."LineTotal" AS "Importe NC",

    -- Saldo y Vencimiento
    (T0."DocTotal" - T0."PaidToDate") AS "Saldo",
    T0."DocDueDate" AS "Vencimiento"

FROM OINV T0
    -- Unión con Pagos Recibidos
    LEFT JOIN RCT2 T2 ON T0."DocEntry" = T2."DocEntry" AND T2."InvType" = '13'
    LEFT JOIN ORCT T3 ON T2."DocNum" = T3."DocEntry"

    -- Unión con Notas de Crédito
    LEFT JOIN RIN1 T4 ON T0."DocEntry" = T4."BaseEntry" AND T4."BaseType" = '13'
    LEFT JOIN ORIN T5 ON T4."DocEntry" = T5."DocEntry"

    LEFT JOIN OCRD ON OCRD."CardCode" = T0."CardCode"

ORDER BY T0."DocDate" DESC;