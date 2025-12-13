SELECT 
    -- Cliente
    OCRD."CardCode" AS "No. Cliente",
    OCRD."CardName" AS "Cliente",
    
    -- Factura
    OINV."DocNum" AS "No. Factura",
    OINV."DocTotal" AS "Monto Facturado",
    TO_DATE(OINV."DocDate") AS "Fecha Factura",
    
    -- Entrega
    ODLN."DocNum" AS "No. Entrega",
    TO_DATE(ODLN."DocDate") AS "Fecha Entrega",
    
    -- Pago 
    ORCT."DocNum" AS "No. Pago",
    TO_DATE(ORCT."DocDate") AS "Fecha Pago",
    RCT2."SumApplied" AS "Monto Pagado"

-- Consulta a clientes
FROM OINV 
    JOIN OCRD ON OINV."CardCode" = OCRD."CardCode"

    -- Relación entregas
    LEFT JOIN DLN1 ON DLN1."BaseType" = 13 AND DLN1."BaseEntry" = OINV."DocEntry"
    LEFT JOIN ODLN ON ODLN."DocEntry" = DLN1."DocEntry"

    -- Relación de pagos
    LEFT JOIN RCT2 ON RCT2."DocEntry" = OINV."DocEntry" AND RCT2."InvType" = 13
    LEFT JOIN ORCT ON ORCT."DocEntry" = RCT2."DocNum" AND ORCT."Canceled" = 'N'

-- Filtros
WHERE
    -- Solo facturas no canceladas
    OINV."CANCELED" = 'N'

    -- Excluye filas que no tengan simultaneamente
    AND NOT (
        -- Numero de pago
        ORCT."DocNum" IS NULL AND 
        -- Fecha de pago
        ORCT."DocDate" IS NULL AND 
        -- Monto pagado
        RCT2."SumApplied" IS NOT NULL
    ) AND 
    
    -- FILTRO DE CLIENTE, REEMPLAZAR POR EL CODIGO DESEADO
    OCRD."CardCode" = 'C00127'
     
-- Ordenado por     
ORDER BY
    -- Numero de documento de factura
    OINV."DocNum" DESC