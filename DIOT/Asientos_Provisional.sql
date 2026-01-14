SELECT
    -- Asiento contable
    NNM1."SeriesName" AS "Serie",
    OJDT."Number" AS "No Asiento",

    -- Pago
    OVPM."DocNum" AS "No Pago",
    TO_DATE(OVPM."DocDate") AS "Fecha Pago",
    CASE 
        WHEN OVPM."Canceled" = 'Y' THEN 'Cancelado'
        ELSE ''
    END AS "Estado",

    JDT1."OrgAccName" AS "Cuenta mayor",
    JDT1."Account" AS "Cuenta",
    JDT1."Debit" AS "Debito del asiento",
    JDT1."Credit" AS "Credito del asiento",

    -- Folio fiscal de factura
    OPCH."U_UDF_UUID" AS "UDF_UUID"

-- Asiento contable
FROM OJDT
    INNER JOIN JDT1 ON JDT1."TransId" = OJDT."TransId"

    -- Serie
    INNER JOIN NNM1 ON OJDT."Series" = NNM1."Series"

    -- Factura de proveedor
    INNER JOIN OPCH ON OJDT."BaseRef" = OPCH."DocNum"
    INNER JOIN PCH1 ON PCH1."DocEntry" = OPCH."DocEntry"

    -- Pagos realizados
    INNER JOIN VPM2 ON VPM2."DocEntry" = OPCH."DocEntry"
                AND VPM2."InvType" = 18 
    INNER JOIN OVPM ON OVPM."DocEntry" = VPM2."DocNum"

WHERE
    OJDT."RefDate" BETWEEN '2025-09-01' AND '2025-09-30'
    AND OJDT."TransType" = 46