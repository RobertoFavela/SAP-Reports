/* SELECT FROM "ODLN" T0 WHERE T0."DocDate" >= [%0] AND T0."DocDate" <= [%1]; */

SELECT
    -- ENTREGA
    ODLN."DocEntry" AS "Id. Entrega",
    ODLN."DocNum" AS "No. Entrega",
    ODLN."DocDate" AS "Fecha Entrega",
    
    -- FACTURA
    CASE 
        WHEN OINV."isIns" = 'Y' THEN 'Reserva'
        WHEN OINV."isIns" = 'N' THEN 'Deudor'
        ELSE 'Sin Factura'
    END AS "Tipo Factura",
    OINV."DocEntry" AS "Id. Factura",
    OINV."DocNum" AS "No. Factura",
    OINV."DocDate" AS "Fecha Factura",

    -- ARTICULO
    DLN1."ItemCode" AS "No. Articulo",
    DLN1."Dscription" AS "Articulo",
    DLN1."Quantity" AS "Cantidad Entrega",
    TO_DECIMAL(DLN1."StockPrice" * DLN1."Quantity", 18, 6) AS "Linea Total",
    INV1."Quantity" AS "Cantidad Factura",
    INV1."LineTotal"

FROM ODLN
    INNER JOIN DLN1 ON ODLN."DocEntry" = DLN1."DocEntry"

    -- FACTURAS (Cubre Deudor Estándar y Reserva)
    LEFT JOIN INV1 ON DLN1."BaseEntry" = INV1."DocEntry"
    AND DLN1."BaseLine" = INV1."LineNum"
    AND DLN1."BaseType" = 13
    OR DLN1."BaseType" = 15
    LEFT JOIN OINV ON INV1."DocEntry" = OINV."DocEntry"

WHERE
    ODLN."DocDate" BETWEEN '[%0]' AND '[%1]'
    AND ODLN."CANCELED" = 'N'
    AND OINV."CANCELED" = 'N'

ORDER BY
    ODLN."DocNum" DESC