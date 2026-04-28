SELECT 
    T0."RefDate" AS "Fecha Asiento Contable", 
    T0."Number" AS "Número de Asiento", 
    T0."TransId" AS "ID Transacción", 
    T0."BaseRef" AS "Referencia Base",
    
    -- tipo de documento
    CASE T0."TransType"
        WHEN '13' THEN 'Factura de Deudores (Clientes)'
        WHEN '18' THEN 'Factura de Proveedores'
        WHEN '24' THEN 'Pago Recibido (Clientes)'
        WHEN '46' THEN 'Pago Efectuado (Proveedores)'
        ELSE 'Otro'
    END AS "Tipo Documento",
    
    -- DocNum y DocEntry
    COALESCE(T1."DocNum", T2."DocNum", T3."DocNum", T4."DocNum") AS "DocNum", 
    COALESCE(T1."DocEntry", T2."DocEntry", T3."DocEntry", T4."DocEntry") AS "DocEntry",
    
    -- tipo Contable
    IFNULL((
        SELECT MAX(
            CASE
                 WHEN A."Account" LIKE '4%' THEN 'Ingreso'
                 WHEN A."Account" LIKE '5%' OR A."Account" LIKE '6%' THEN 'Egreso'
                 WHEN A."Account" LIKE '7001%' THEN 'Interes'
                 WHEN A."Account" LIKE '7002%' THEN '7002'
            END
        )
        FROM JDT1 A
        WHERE A."TransId" = T0."TransId"
    ), 'Otro') AS "Tipo Contable" 
    
FROM OJDT T0
-- Proveedores
LEFT JOIN OPCH T1 ON T0."TransId" = T1."TransId" AND T0."TransType" = '18'
LEFT JOIN OVPM T2 ON T0."TransId" = T2."TransId" AND T0."TransType" = '46'

-- deudores
LEFT JOIN OINV T3 ON T0."TransId" = T3."TransId" AND T0."TransType" = '13'
LEFT JOIN ORCT T4 ON T0."TransId" = T4."TransId" AND T0."TransType" = '24'

WHERE 
    T0."RefDate" BETWEEN '2024-01-01' AND '2024-12-31' 
    
    AND T0."TransType" IN ('13', '18', '24', '46')
ORDER BY 
    T0."RefDate" ASC;