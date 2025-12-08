SELECT 
    -- Proveedor
    OCRD."CardCode" AS "Nombre",
    OCRD."LicTradNum" AS "RFC",
    
    OPCH."DocNum" AS "No Factura",
    
    CASE 
        WHEN PCH1."TaxCode" = 'V2' THEN
            TO_DECIMAL(PCH1."LineTotal" * 0.16, 18, 4)
        WHEN PCH1."TaxCode" = 'V1' THEN
            TO_DECIMAL(PCH1."LineTotal" * 0.8, 18, 4)
        WHEN PCH1."TaxCode" = 'V0' THEN
            TO_DECIMAL(PCH1."LineTotal" * 0, 18, 4)
        WHEN PCH1."TaxCode" = 'VE' THEN
            TO_DECIMAL(PCH1."LineTotal" * 0, 18, 4)
    END AS "IVA",

    CASE 
        WHEN PCH1."TaxCode" = 'V2' THEN '16%'
        WHEN PCH1."TaxCode" = 'V1' THEN '8%'
        WHEN PCH1."TaxCode" = 'V0' THEN '0%'
        WHEN PCH1."TaxCode" = 'VE' THEN 'Exento'
    END AS "TASA",

    -- Retencion
    PCH5."WTAmnt" AS "Retencion",
    OWHT."WTName" AS "Tipo Retencion",
    
    TO_DATE(OVPM."DocDate") AS "Fecha Pago",
    OVPM."DocNum" AS "No Pago"

-- Pago efectuado
FROM OVPM  
    INNER JOIN VPM2 ON OVPM."DocEntry" = VPM2."DocNum"

    -- Factura Proveedor
    LEFT JOIN OPCH ON VPM2."DocEntry" = OPCH."DocNum"

    -- Lineas de factura
    INNER JOIN PCH1 ON OPCH."DocEntry" = PCH1."DocEntry"

    -- Tipos de Retenciones
    LEFT JOIN PCH5
        ON OPCH."DocEntry" = PCH5."AbsEntry"

    -- Retenciones
    LEFT JOIN OWHT
        ON PCH5."WTCode" = OWHT."WTCode"

    -- Proveedor
    INNER JOIN OCRD ON OPCH."CardCode" = OCRD."CardCode"

WHERE
    OVPM."Canceled" = 'N'

ORDER BY OPCH."DocNum" DESC