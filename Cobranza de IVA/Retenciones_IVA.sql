SELECT
    'FACTURA' AS "TIPO DOCUMENTO",

    -- FACTURA
    OPCH."DocDate" AS "FECHA FACTURA",
    OPCH."DocNum" AS "FOLIO FACTURA",
    OPCH."DocEntry" AS "ID FACTURA",
    OPCH."U_UDF_UUID" AS "FOLIO FISCAL(UUID)",

    -- PROVEEDOR
    OCRD."LicTradNum" AS "RFC",
    OCRD."CardName" AS "PROVEEDOR",
    OPCH."Comments" AS "CONCEPTO",

    -- CALCULOS PROPORCIONALES AL PAGO
    ROUND(
        (
            OPCH."DocTotal" - COALESCE(OPCH."VatSum", 0)
            - (COALESCE(RET."Retencion 1", 0) + COALESCE(RET."Retencion 2", 0) + COALESCE(RET."Retencion 3", 0)
            + COALESCE(RET."Retencion 4", 0) + COALESCE(RET."Retencion 5", 0) + COALESCE(RET."Retencion 6", 0))
        )
        * (VPM2."SumApplied" / NULLIF(OPCH."DocTotal", 0)),
        2
    ) AS "IMPORTE SUBTOTAL",
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
    ROUND(COALESCE(RET."Retencion 6", 0) * (VPM2."SumApplied" / NULLIF(OPCH."DocTotal", 0)), 2) AS "IVA RETENIDO POR ARRENDAMIENTO",
   
    CASE
        WHEN COALESCE(RET."Retencion 1", 0) <> 0
          OR COALESCE(RET."Retencion 2", 0) <> 0
          OR COALESCE(RET."Retencion 3", 0) <> 0
          OR COALESCE(RET."Retencion 4", 0) <> 0
          OR COALESCE(RET."Retencion 5", 0) <> 0
          OR COALESCE(RET."Retencion 6", 0) <> 0
        THEN 'SI'
        ELSE 'NO'
    END AS "RETENCION"

FROM OPCH
    -- PAGOS DE FACTURAS DE PROVEEDOR (TIPO DE OBJETO 18)
    INNER JOIN VPM2 ON VPM2."DocEntry" = OPCH."DocEntry"
        AND VPM2."InvType" = '18'
    INNER JOIN OVPM ON OVPM."DocEntry" = VPM2."DocNum"
        AND OVPM."Canceled" = 'N'

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

    LEFT JOIN OCRD ON OCRD."CardCode" = OPCH."CardCode"

UNION ALL

SELECT
    'ANTICIPO' AS "TIPO DOCUMENTO",

    -- FACTURA DE ANTICIPO
    ODPO."DocDate" AS "FECHA FACTURA",
    ODPO."DocNum" AS "FOLIO FACTURA",
    ODPO."DocEntry" AS "ID FACTURA",
    ODPO."U_UDF_UUID" AS "FOLIO FISCAL(UUID)",

    -- PROVEEDOR
    OCRD."LicTradNum" AS "RFC",
    OCRD."CardName" AS "PROVEEDOR",
    ODPO."Comments" AS "CONCEPTO",

    -- CALCULOS PROPORCIONALES AL PAGO
    ROUND(
        (
            ODPO."DocTotal" - COALESCE(ODPO."VatSum", 0)
            - (COALESCE(RET."Retencion 1", 0) + COALESCE(RET."Retencion 2", 0) + COALESCE(RET."Retencion 3", 0)
            + COALESCE(RET."Retencion 4", 0) + COALESCE(RET."Retencion 5", 0) + COALESCE(RET."Retencion 6", 0))
        )
        * (VPM2."SumApplied" / NULLIF(ODPO."DocTotal", 0)),
        2
    ) AS "IMPORTE SUBTOTAL",
    ROUND(ODPO."VatSum" * (VPM2."SumApplied" / NULLIF(ODPO."DocTotal", 0)), 2) AS "IVA",
    ROUND(ODPO."DocTotal" * (VPM2."SumApplied" / NULLIF(ODPO."DocTotal", 0)), 2) AS "TOTAL",
    OVPM."DocNum" AS "FOLIO PAGO",
    OVPM."DocDate" AS "FECHA PAGO",

    -- RETENCIONES
    ROUND(COALESCE(RET."Retencion 1", 0) * (VPM2."SumApplied" / NULLIF(ODPO."DocTotal", 0)), 2) AS "ISR SERVICIOS PROFESIONALES (HONORARIOS)",
    ROUND(COALESCE(RET."Retencion 2", 0) * (VPM2."SumApplied" / NULLIF(ODPO."DocTotal", 0)), 2) AS "ISR RESICO",
    ROUND(COALESCE(RET."Retencion 3", 0) * (VPM2."SumApplied" / NULLIF(ODPO."DocTotal", 0)), 2) AS "ISR POR ARRENDAMIENTO",
    ROUND(COALESCE(RET."Retencion 4", 0) * (VPM2."SumApplied" / NULLIF(ODPO."DocTotal", 0)), 2) AS "IVA RETENIDO FLETES",
    ROUND(COALESCE(RET."Retencion 5", 0) * (VPM2."SumApplied" / NULLIF(ODPO."DocTotal", 0)), 2) AS "IVA RETENIDO SERVICIOS PROFESIONALES",
    ROUND(COALESCE(RET."Retencion 6", 0) * (VPM2."SumApplied" / NULLIF(ODPO."DocTotal", 0)), 2) AS "IVA RETENIDO POR ARRENDAMIENTO",
  
    CASE
        WHEN COALESCE(RET."Retencion 1", 0) <> 0
          OR COALESCE(RET."Retencion 2", 0) <> 0
          OR COALESCE(RET."Retencion 3", 0) <> 0
          OR COALESCE(RET."Retencion 4", 0) <> 0
          OR COALESCE(RET."Retencion 5", 0) <> 0
          OR COALESCE(RET."Retencion 6", 0) <> 0
        THEN 'SI'
        ELSE 'NO'
    END AS "RETENCION"

FROM ODPO
    -- PAGOS DE FACTURAS DE ANTICIPO DE PROVEEDOR (TIPO DE OBJETO 204)
    INNER JOIN VPM2 ON VPM2."DocEntry" = ODPO."DocEntry"
        AND VPM2."InvType" = '204'
    INNER JOIN OVPM ON OVPM."DocEntry" = VPM2."DocNum"
        AND OVPM."Canceled" = 'N'

    LEFT JOIN (
        SELECT
            DPO5."AbsEntry",
            SUM(CASE WHEN DPO5."WTCode" = '2V' THEN DPO5."WTAmnt" ELSE 0 END) AS "Retencion 1",
            SUM(CASE WHEN DPO5."WTCode" = '1I' THEN DPO5."WTAmnt" ELSE 0 END) AS "Retencion 2",
            SUM(CASE WHEN DPO5."WTCode" = '1V' THEN DPO5."WTAmnt" ELSE 0 END) AS "Retencion 3",
            SUM(CASE WHEN DPO5."WTCode" = 'FV' THEN DPO5."WTAmnt" ELSE 0 END) AS "Retencion 4",
            SUM(CASE WHEN DPO5."WTCode" = '4V' THEN DPO5."WTAmnt" ELSE 0 END) AS "Retencion 5",
            SUM(CASE WHEN DPO5."WTCode" = '3V' THEN DPO5."WTAmnt" ELSE 0 END) AS "Retencion 6"
        FROM DPO5
        GROUP BY DPO5."AbsEntry"
    ) RET ON ODPO."DocEntry" = RET."AbsEntry"

    LEFT JOIN OCRD ON OCRD."CardCode" = ODPO."CardCode"

ORDER BY "FECHA FACTURA" DESC;