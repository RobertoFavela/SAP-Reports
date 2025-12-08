 SELECT 
    -- RFC
    OCRD."CardCode" AS "Nombre",
    OCRD."LicTradNum" AS "RFC",
    
    -- Numero de factura
    OPCH."DocNum" AS "No Factura",

    PCH1."LineTotal" AS "Sub TOTAL",

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
    OVPM."DocNum" AS "No. Pago"

-- Facturas de proveedor
FROM  OPCH

-- Cliente
INNER JOIN OCRD
    ON OPCH."CardCode" = OCRD."CardCode"

-- Lineas de factura
INNER JOIN PCH1
    ON OPCH."DocEntry" = PCH1."DocEntry"

INNER JOIN OSTA
    ON PCH1."VatGroup" = OSTA."Code"

-- Tipos de Retenciones
LEFT JOIN PCH5
    ON OPCH."DocEntry" = PCH5."AbsEntry"

-- Retenciones
LEFT JOIN OWHT
    ON PCH5."WTCode" = OWHT."WTCode"

-- Pagos realizados
LEFT JOIN VPM2 ON VPM2."DocEntry" = OPCH."DocEntry"
               AND VPM2."InvType" = 18 
LEFT JOIN OVPM ON OVPM."DocEntry" = VPM2."DocNum"


-- Relación hacia pedido
LEFT JOIN PDN1 
    ON PCH1."BaseEntry" = PDN1."DocEntry"
   AND PCH1."BaseType" = PDN1."ObjType"
   AND PCH1."BaseLine" = PDN1."LineNum"

LEFT JOIN POR1
    ON PDN1."BaseEntry" = POR1."DocEntry"
   AND PDN1."BaseType" = POR1."ObjType"
   AND PDN1."BaseLine" = POR1."LineNum"

-- Relacionar pedido → anticipo
LEFT JOIN DPO1
    ON POR1."DocEntry" = DPO1."BaseEntry"
   AND POR1."ObjType" = DPO1."BaseType"
   AND POR1."LineNum" = DPO1."BaseLine"

LEFT JOIN ODPO
    ON DPO1."DocEntry" = ODPO."DocEntry"
    AND VPM2."DocEntry" = ODPO."DocEntry"

WHERE
    OPCH."CANCELED" = 'N'
    AND OPCH."DocDate" BETWEEN '2025-01-01' AND '2025-12-31'


ORDER BY OPCH."DocNum" DESC
