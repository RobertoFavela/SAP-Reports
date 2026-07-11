SELECT 
    -- DATOS GENERALES (Factura o Anticipo)
    OCRD."CardCode" AS "Proveedor",
    OCRD."CardName" AS "Nombre",
    OCRD."LicTradNum" AS "RFC",
    
    -- DOCUMENTO ORIGEN
    COALESCE(OPCH."DocNum", ODPO."DocNum") AS "No Doc",
    CASE 
        WHEN OPCH."DocNum" IS NOT NULL THEN 'Factura'
        WHEN ODPO."DocNum" IS NOT NULL THEN 'Anticipo'
        ELSE 'Otro'
    END AS "Tipo Doc",
    COALESCE(OPCH."U_UDF_UUID", ODPO."U_UDF_UUID") AS "UUID",
    COALESCE(OPCH."DocDate", ODPO."DocDate") AS "Fecha Doc",
    
    -- LINEAS
    COALESCE(PCH1."ItemCode", DPO1."ItemCode") AS "ItemCode",
    OITM."ItmsGrpCod", 
    COALESCE(PCH1."Dscription", DPO1."Dscription") AS "Descripcion",
    
    -- CALCULOS PROPORCIONALES (Por Porcentaje del Pago)
    ROUND(
        COALESCE(PCH1."LineTotal", DPO1."LineTotal") * (VPM2."SumApplied" / NULLIF(COALESCE(OPCH."DocTotal", ODPO."DocTotal"), 0))
    , 2) AS "Subtotal Proporcional",

    ROUND(
        COALESCE(PCH1."VatSum", DPO1."VatSum") * (VPM2."SumApplied" / NULLIF(COALESCE(OPCH."DocTotal", ODPO."DocTotal"), 0))
    , 2) AS "IVA Proporcional",

    COALESCE(PCH1."VatPrcnt", DPO1."VatPrcnt") AS "Tasa IVA",

    -- RETENCIONES
    ROUND(
        COALESCE(PCH5."WTAmnt", DPO5."WTAmnt") * (VPM2."SumApplied" / NULLIF(COALESCE(OPCH."DocTotal", ODPO."DocTotal"), 0))
    , 2) AS "Retencion Proporcional",
    OWHT."WTName" AS "Tipo Retencion",

    -- PAGO
    OVPM."DocNum" AS "No Pago",
    OVPM."DocDate" AS "Fecha Pago",
    VPM2."SumApplied" AS "Monto Aplicado al Doc",
    
    CASE 
        WHEN OVPM."Canceled" = 'Y' THEN 'Cancelado'
        ELSE 'Asentado'
    END AS "Estado"

FROM OVPM
    INNER JOIN VPM2 ON OVPM."DocEntry" = VPM2."DocNum"
    -- Unión con Facturas
    LEFT JOIN OPCH ON VPM2."DocEntry" = OPCH."DocEntry" AND VPM2."InvType" = '18'
    LEFT JOIN PCH1 ON OPCH."DocEntry" = PCH1."DocEntry"
    LEFT JOIN PCH5 ON OPCH."DocEntry" = PCH5."AbsEntry"
    
    -- Unión con Anticipos
    LEFT JOIN ODPO ON VPM2."DocEntry" = ODPO."DocEntry" AND VPM2."InvType" = '204'
    LEFT JOIN DPO1 ON ODPO."DocEntry" = DPO1."DocEntry"
    LEFT JOIN DPO5 ON ODPO."DocEntry" = DPO5."AbsEntry"

    -- Catálogos comunes
    LEFT JOIN OWHT ON (PCH5."WTCode" = OWHT."WTCode" OR DPO5."WTCode" = OWHT."WTCode")
    INNER JOIN OCRD ON OVPM."CardCode" = OCRD."CardCode"
    
    -- Items
    LEFT JOIN OITM ON PCH1."ItemCode" = OITM."ItemCode"

    LEFT JOIN OITB ON OITM."ItmsGrpCod" = OITB."ItmsGrpCod"

WHERE VPM2."InvType" IN ('18', '204') -- Filtra solo Facturas y Anticipos

ORDER BY OVPM."DocDate" DESC;