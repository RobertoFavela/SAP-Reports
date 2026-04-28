SELECT 
    T0."RefDate" AS "Fecha Asiento Contable", 
    T0."TransId" AS "ID Transacción", 
    T5."SeriesName" AS "Tipo Poliza",
    -- T0."Number" AS "Número de Asiento", 
    
    -- Asiento con prefijo según el tipo
    CASE T0."TransType"
        WHEN '13' THEN 'RF ' || TO_NVARCHAR(T0."Number") -- Factura Clientes
        WHEN '18' THEN 'TT ' || TO_NVARCHAR(T0."Number") -- Factura Proveedores
        WHEN '24' THEN 'PR ' || TO_NVARCHAR(T0."Number") -- Pago Recibido
        WHEN '46' THEN 'PP ' || TO_NVARCHAR(T0."Number") -- Pago Efectuado
        WHEN '30' THEN 'AS ' || TO_NVARCHAR(T0."Number") -- Asiento Manual
        ELSE 'OT ' || TO_NVARCHAR(T0."Number")           -- Otro
    END AS "Número de Asiento",

    T0."BaseRef" AS "Referencia Base",
    
    -- tipo de documento
    CASE T0."TransType"
        WHEN '13' THEN 'Factura de Deudores'
        WHEN '18' THEN 'Factura de Proveedores'
        WHEN '24' THEN 'Pago Recibido'
        WHEN '46' THEN 'Pago Efectuado'
        WHEN '30' THEN 'Asiento Manual'
        ELSE 'Otro'
    END AS "Tipo Documento"
    
    -- DocNum y DocEntry de los documentos origen
    -- COALESCE(T1."DocNum", T2."DocNum", T3."DocNum", T4."DocNum") AS "DocNum", 
    -- COALESCE(T1."DocEntry", T2."DocEntry", T3."DocEntry", T4."DocEntry") AS "DocEntry"

FROM OJDT T0
-- Unión para traer el nombre de la serie (Tipo de Póliza)
INNER JOIN NNM1 T5 ON T0."Series" = T5."Series"

-- Proveedores (Facturas y Pagos Efectuados)
LEFT JOIN OPCH T1 ON T0."TransId" = T1."TransId" AND T0."TransType" = '18'
LEFT JOIN OVPM T2 ON T0."TransId" = T2."TransId" AND T0."TransType" = '46'

-- Deudores (Facturas y Pagos Recibidos)
LEFT JOIN OINV T3 ON T0."TransId" = T3."TransId" AND T0."TransType" = '13'
LEFT JOIN ORCT T4 ON T0."TransId" = T4."TransId" AND T0."TransType" = '24'

WHERE 
    T0."RefDate" BETWEEN '2024-01-01' AND '2024-12-31' 
    
    AND T0."TransType" IN ('13', '18', '24', '46', '30')

    -- AND T0."TransType" NOT IN ('13', '18', '24', '46', '30')

ORDER BY 
    T0."RefDate" ASC;