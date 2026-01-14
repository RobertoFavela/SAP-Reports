SELECT
    OPCH."DocEntry" AS "ID Factura",
    OPCH."DocNum" AS "No Factura",
    OPCH."CANCELED" AS "Cancelado",
    OPCH."DocStatus" AS "Estado del documento",
    OPCH."DocDate" AS "Fecha de contabilizacion",
    OPCH."CardCode" AS "Codigo de proveedor",
    OPCH."CardName" AS "Nombre de proveedor",
    OPCH."NumAtCard" AS "Numero de referencia de deudor",
    OPCH."DocCur" AS "Moneda del documento",
    PCH1."ItemCode" AS "Numero del articulo",
    PCH1."Dscription" AS "Descripcion",
    PCH1."LegalText" AS "Texto legal",
    PCH1."LineTotal",
    PCH1."TotalFrgn",
    PCH1."AcctCode",
    PCH1."VatSum",
    PCH1."VatSumFrgn",
    OPCH."PaidToDate",
    OPCH."PaidFC",
    DPO1."LineTotal",
    ODPO."DocTotal",
    ODPO."DocEntry" AS "ID Anticipo",
    ODPO."DocNum" AS "No Anticipo",
    OPCH."U_UDF_UUID"

-- Facturas
FROM OPCH
    -- Lineas de Facturas
    INNER JOIN PCH1 ON OPCH."DocEntry" = PCH1."DocEntry"
    
    -- Anticipos de Factura
    INNER JOIN PCH11 ON OPCH."DocEntry" = PCH11."DocEntry"
    
    -- Anticipos
    LEFT JOIN ODPO ON PCH11."BaseAbs" = ODPO."DocEntry"
    -- Lineas de Anticipos
    LEFT JOIN DPO1 ON ODPO."DocEntry" = DPO1."DocEntry"

ORDER BY 
    OPCH."DocNum" DESC