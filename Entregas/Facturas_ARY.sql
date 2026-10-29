/* SELECT FROM OINV T0 WHERE T0."DocDate" >= [%0] AND T0."DocDate" <= [%1] */

SELECT
    -- FACTURA
    CASE 
        WHEN OINV."isIns" = 'Y' THEN 'Reserva'
        WHEN OINV."isIns" = 'N' THEN 'Deudor'
        ELSE 'Otro'
    END AS "Tipo Factura",
    OINV."DocEntry" AS "Id. Factura",
    OINV."DocNum" AS "No. Factura",
    OINV."DocDate" AS "Fecha Factura",

    -- ENTREGA
    ODLN."DocEntry" AS "Id. Entrega",
    ODLN."DocNum" AS "No. Entrega",
    ODLN."DocDate" AS "Fecha Entrega",

    -- ARTICULO
    INV1."ItemCode" AS "No. Articulo",
    INV1."Dscription" AS "Articulo",
    INV1."Quantity" AS "Cantidad Factura",
    INV1."LineTotal" AS "Monto Linea Factura",
    DLN1."Quantity" AS "Cantidad Entrega",
    TO_DECIMAL(DLN1."StockPrice" * DLN1."Quantity", 18, 6) AS "Costo Total Entrega"

FROM OINV
    INNER JOIN INV1 ON OINV."DocEntry" = INV1."DocEntry"

    -- CRUCE A ENTREGAS (Cubre Factura Estándar y Factura de Reserva)
    LEFT JOIN DLN1 ON (
        -- Caso 1: Factura Estándar basada en Entrega (INV1 apunta a DLN1)
        (INV1."BaseType" = 15 AND INV1."BaseEntry" = DLN1."DocEntry" AND INV1."BaseLine" = DLN1."LineNum")
        OR
        -- Caso 2: Entrega basada en Factura de Reserva (DLN1 apunta a INV1)
        (DLN1."BaseType" = 13 AND DLN1."BaseEntry" = INV1."DocEntry" AND DLN1."BaseLine" = INV1."LineNum")
    )
    LEFT JOIN ODLN ON DLN1."DocEntry" = ODLN."DocEntry" AND ODLN."CANCELED" = 'N'

WHERE
    OINV."DocDate" BETWEEN '[%0]' AND '[%1]'
    AND OINV."CANCELED" = 'N'

ORDER BY
    OINV."DocNum" DESC,
    INV1."LineNum" ASC;