SELECT
    -- FACTURA
    OPCH."DocDate" AS "FECHA FACTURA",
    OPCH."DocNum" AS "FOLIO FACTURA",
    OPCH."DocEntry" AS "ID FACTURA",
    OPCH."U_UDF_UUID" AS "FOLIO FISCAL(UUID)",
    
    -- PROVEEODR
    OCRD."LicTradNum" AS "RFC",
    OCRD."CardName" AS "PROVEEDOR",
    OPCH."Comments" AS "CONCEPTO",
    
    -- CALCULOS PROPORCIONALES AL PAGO
    ROUND((OPCH."DocTotal" - OPCH."VatSum") * (VPM2."SumApplied" / NULLIF(OPCH."DocTotal", 0)), 2) AS "IMPORTE SUBTOTAL",
    ROUND(OPCH."VatSum" * (VPM2."SumApplied" / NULLIF(OPCH."DocTotal", 0)), 2) AS "IVA",
    ROUND(OPCH."DocTotal" * (VPM2."SumApplied" / NULLIF(OPCH."DocTotal", 0)), 2) AS "TOTAL",
    OVPM."DocNum" AS "FOLIO PAGO",
    OVPM."DocDate" AS "FECHA PAGO",

    -- RETENCIONES
    ROUND(COALESCE(RET."Retencion 1", 0) * (VPM2."SumApplied" / NULLIF(OPCH."DocTotal", 0)), 2) AS "ISR SERVICIOS PROFESIONALES (HONORARIOS)",
    ROUND(COALESCE(RET."Retencion 2", 0) * (VPM2."SumApplied" / NULLIF(OPCH."DocTotal", 0)), 2) AS "ISR RESICO",
    ROUND(COALESCE(RET."Retencion 3", 0) * (VPM2."SumApplied" / NULLIF(OPCH."DocTotal", 0)), 2) AS "ISR POR ARRENDAMIENTO",
    ROUND(COALESCE(RET."Retencion 4", 0) * (VPM2."SumApplied" / NULLIF(OPCH."DocTotal", 0)), 2) AS "IVA RETENIDO FLETES",
    ROUND(COALESCE(RET."Retencion 5", 0) * (VPM2."SumApplied" / NULLIF(OPCH."DocTotal", 0)), 2) AS "IVA RETENIDO SERVICIOS PROFESIONALES",
    ROUND(COALESCE(RET."Retencion 6", 0) * (VPM2."SumApplied" / NULLIF(OPCH."DocTotal", 0)), 2) AS "IVA RETENIDO POR ARRENDAMIENTO"

-- FACTURA PROVEEDOR
FROM OPCH
    -- JOIN CON PAGOS
    INNER JOIN VPM2 ON VPM2."DocEntry" = OPCH."DocEntry"
        AND VPM2."InvType" = '18'
    INNER JOIN OVPM ON OVPM."DocEntry" = VPM2."DocNum"
        AND OVPM."Canceled" = 'N'
    
    -- SUBCONSULTA RETENCIONES
    LEFT JOIN (
        SELECT
            PCH5."AbsEntry",
            SUM(CASE WHEN PCH5."WTCode" = '2V' THEN PCH5."WTAmnt" ELSE 0 END) AS "Retencion 1",
            SUM(CASE WHEN PCH5."WTCode" = '1I' THEN PCH5."WTAmnt" ELSE 0 END) AS "Retencion 2",
            SUM(CASE WHEN PCH5."WTCode" = '1V' THEN PCH5."WTAmnt" ELSE 0 END) AS "Retencion 3",
            SUM(CASE WHEN PCH5."WTCode" = 'FV' THEN PCH5."WTAmnt" ELSE 0 END) AS "Retencion 4",
            SUM(CASE WHEN PCH5."WTCode" = '4V' THEN PCH5."WTAmnt" ELSE 0 END) AS "Retencion 5",
            SUM(CASE WHEN PCH5."WTCode" = '3V' THEN PCH5."WTAmnt" ELSE 0 END) AS "Retencion 6"
        FROM PCH5
        GROUP BY PCH5."AbsEntry"
    ) RET ON OPCH."DocEntry" = RET."AbsEntry"
    
    -- SOCIO DE NEGOCIOS
    LEFT JOIN OCRD ON OCRD."CardCode" = OPCH."CardCode"

ORDER BY OPCH."DocDate" DESC;
