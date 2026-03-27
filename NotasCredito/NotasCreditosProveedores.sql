SELECT
    ORPC."DocEntry" AS "Id. Doc",
    ORPC."DocNum" AS "No. Doc",
    CASE         
        WHEN ORPC."CANCELED" = 'Y' THEN 'Cancelado'         
        WHEN ORPC."CANCELED" = 'C' THEN 'Cerrado'       
        ELSE 'Vigente'
    END AS "Cancelado",
    RPC1."ItemCode" AS "No. Articulo",
    RPC1."Dscription",
    RPC1."Quantity" AS "KGs",
    RPC1."LineTotal" AS "Subtotal",
    RPC1."VatSum" AS "IVA",
    RPC1."GTotal" AS "Total",
    OPCH."DocDate" AS "Fecha Factura Prov",
    ORPC."DocDate" AS "Fecha Contabilizacion",
    RPC1."WhsCode" AS "Almacen",
    RPC1."BaseCard" AS "Codigo Base SN",
    RPC1."OcrCode" AS "Norma de reparto",
    RPC1."CogsOcrCo2" AS "Sucursal",
    RPC1."CogsOcrCo3" AS "Area",
    RPC1."CogsOcrCo4" AS "Ciclo"

FROM ORPC
    INNER JOIN RPC1 ON RPC1."DocEntry" = ORPC."DocEntry"
    LEFT JOIN OPCH ON RPC1."BaseEntry" = OPCH."DocEntry" AND RPC1."BaseType" = 18

ORDER BY
    ORPC."DocNum" DESC