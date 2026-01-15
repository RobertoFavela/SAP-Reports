SELECT 
    -- PROVEEDOR
    OCRD."CardCode" AS "Proveedor",
    OCRD."CardName" AS "Nombre",
    OCRD."LicTradNum" AS "RFC",
    
    -- FACTURA
    OPCH."DocNum" AS "No Factura",
    OPCH."DocDate" AS "Fecha Factura",
    
    -- LINEAS
    PCH1."LineNum",
    PCH1."ItemCode",
    OITM."ItmsGrpCod", 
    PCH1."Dscription",
    PCH1."LineTotal" AS "Subtotal",
    PCH1."VatSum" AS "IVA",
    PCH1."VatPrcnt" AS "Tasa IVA",

    -- RETENCIONES
    PCH5."WTAmnt" AS "Retencion",
    OWHT."WTName" AS "Tipo Retencion",

    -- PAGO
    OVPM."DocNum" AS "No Pago",
    OVPM."DocDate" AS "Fecha Pago",
    
    CASE 
        WHEN OVPM."Canceled" = 'Y' THEN 'Cancelado'
        ELSE ''
    END AS "Estado"


FROM OVPM
    
    -- DOCUMENTOS RELACIONADOS AL PAGO
    INNER JOIN VPM2 ON OVPM."DocEntry" = VPM2."DocNum"

    -- FACTURA PROVEEDOR SEGÚN EL DOCENTRY
    INNER JOIN OPCH ON VPM2."DocEntry" = OPCH."DocEntry"

    -- LINEAS DE LA FACTURA
    INNER JOIN PCH1 ON OPCH."DocEntry" = PCH1."DocEntry"

    -- RETENCIONES DE LA FACTURA
    LEFT JOIN PCH5 ON OPCH."DocEntry" = PCH5."AbsEntry"

    -- DESCRIPCIÓN DE RETENCIONES
    LEFT JOIN OWHT ON PCH5."WTCode" = OWHT."WTCode"

    LEFT JOIN OITM ON PCH1."ItemCode" = OITM."ItemCode"

    LEFT JOIN OITB ON OITM."ItmsGrpCod" = OITB."ItmsGrpCod"

    -- PROVEEDOR
    INNER JOIN OCRD ON OPCH."CardCode" = OCRD."CardCode"

ORDER BY 
    OVPM."DocDate" DESC