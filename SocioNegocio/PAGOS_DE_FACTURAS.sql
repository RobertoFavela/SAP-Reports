/* SELECT FROM "OPCH" T0 WHERE T0."DocDate" >= [%0] AND T0."DocDate" <= [%1] */
/* SELECT FROM "OCRD" T1 WHERE T1."CardCode" = '[%2]' */

SELECT 
    -- SOCIO DE NEGOCIO
    OCRD."CardCode" AS "No. Proveedor",
    OCRD."CardName" AS "Proveedor",

    -- DATOS DE LA FACTURA
    TO_DATE(OPCH."DocDate") AS "Fecha Factura",
    OPCH."DocEntry" AS "Id. Factura",
    OPCH."DocNum" AS "No. Factura",
    OPCH."NumAtCard" AS "Factura Proveedor",
    
    -- MONTOS
    CASE 
        WHEN OPCH."DocCur" = 'MXP' THEN OPCH."DocTotal"
        WHEN OPCH."DocCur" = 'USD' THEN TO_DECIMAL(OPCH."DocTotal" * OPCH."DocRate", 18, 2)
        ELSE OPCH."DocTotal"
    END AS "Total Factura MXN",
    CASE
        WHEN OPCH."DocCur" = 'USD' THEN OPCH."DocTotal"
        WHEN OPCH."DocCur" = 'MXP' THEN TO_DECIMAL(OPCH."DocTotal" / ORTT."Rate", 18, 6)
    END AS "Total Factura USD",
    OPCH."DocCur" AS "Moneda Factura",
    
    -- DATOS DEL PAGO (SI EXISTE)
    IFNULL(CAST(OVPM."DocNum" AS VARCHAR), 'Sin Pago') AS "Pago Efectuado",
    TO_DATE(OVPM."DocDate") AS "Fecha Pago",
    IFNULL(VPM2."SumApplied", 0) AS "Monto Pagado",
    
    -- MONTOS
    CASE 
        WHEN OVPM."DocCurr" = 'MXP' THEN VPM2."SumApplied"
        WHEN OVPM."DocCurr" = 'USD' THEN TO_DECIMAL(VPM2."SumApplied" * ORTT."Rate", 18, 2)
    END AS "Total Pago MXN",
    CASE 
        WHEN OVPM."DocCurr" = 'USD' THEN VPM2."SumApplied"
        WHEN OVPM."DocCurr" = 'MXP' THEN TO_DECIMAL(VPM2."SumApplied" / ORTT."Rate", 18, 2)
    END AS "Total Pago USD",
    IFNULL(OVPM."DocCurr", '-') AS "Moneda Pago"

FROM OPCH
    INNER JOIN OCRD ON OPCH."CardCode" = OCRD."CardCode"

    -- Tipo de cambio diario de la tabla ORTT para USD a la fecha de la factura
    LEFT JOIN ORTT ON ORTT."RateDate" = OPCH."DocDate" 
        AND ORTT."Currency" = 'USD'

    -- Detalle de pagos y pagos efectuados
    LEFT JOIN VPM2 ON VPM2."DocEntry" = OPCH."DocEntry" 
        AND VPM2."InvType" = 18
    LEFT JOIN OVPM ON OVPM."DocEntry" = VPM2."DocNum" 
        AND OVPM."Canceled" = 'N'

WHERE 
   OPCH."DocDate" BETWEEN [%0] AND [%1]
    AND (OCRD."CardCode" = '[%2]' OR '[%2]' = '' OR '[%2]' = '0')

ORDER BY 
    OPCH."DocNum" DESC