SELECT
    -- Documento
    TO_DATE(OIGN."DocDate") AS "Fecha",
    OIGN."Ref2" AS "Lote",
    OIGN."DocNum" AS "No. Entrada",

    -- Almacén
    IGN1."WhsCode" AS "No. Almacen",
    OWHS."WhsName" AS "Almacen",

    -- Artículo de camarón
    IGN1."ItemCode" AS "No. Articulo",
    OITM."ItemName" AS "Nombre de articulo",

    SUM(IGN1."Quantity") AS "Cantidad KG",
    IGN1."Price" AS "Precio Unitario",
    IGN1."LineTotal" AS "Precio TOTAL",

    -- Cantidad Salida
    COALESCE(
        (
            SELECT SUM(IBT1."Quantity")
            FROM IBT1
            WHERE IBT1."BatchNum" = OIGN."Ref2"
              AND IBT1."ItemCode" = IGN1."ItemCode"
              AND IBT1."Direction" = 1
        ), 0
    ) AS "KG Facturados",

    -- Nueva columna: Artículo de caja (PT MATERIAL DE EMPAQUE)
    (
        SELECT MIN(E."ItemCode")
        FROM IGN1 E
        INNER JOIN OITM I ON E."ItemCode" = I."ItemCode"
        INNER JOIN OITB G ON I."ItmsGrpCod" = G."ItmsGrpCod"
        WHERE E."DocEntry" = OIGN."DocEntry"
          AND G."ItmsGrpCod" = 'PT MATERIAL DE EMPAQUE'
          AND RIGHT(UPPER(E."Dscription"), 4) = RIGHT(UPPER(IGN1."Dscription"), 4)
    ) AS "No. Articulo Caja",

    -- Nueva columna: Cantidad de cajas
    (
        SELECT SUM(E."Quantity")
        FROM IGN1 E
        INNER JOIN OITM I ON E."ItemCode" = I."ItemCode"
        INNER JOIN OITB G ON I."ItmsGrpCod" = G."ItmsGrpCod"
        WHERE E."DocEntry" = OIGN."DocEntry"
          AND G."ItmsGrpCod" = 'PT MATERIAL DE EMPAQUE'
          AND RIGHT(UPPER(E."Dscription"), 4) = RIGHT(UPPER(IGN1."Dscription"), 4)
    ) AS "Cantidad de Cajas"

FROM OIGN
    INNER JOIN IGN1 ON OIGN."DocEntry" = IGN1."DocEntry"
    INNER JOIN OITM ON IGN1."ItemCode" = OITM."ItemCode"
    INNER JOIN OITB ON OITM."ItmsGrpCod" = OITB."ItmsGrpCod"
    INNER JOIN OWHS ON IGN1."WhsCode" = OWHS."WhsCode"

WHERE
    OIGN."CANCELED" = 'N'
    AND OITB."ItmsGrpNam" IN ('CAMARON EN BORDO', 'PT CAMARON FRIZADO', 'MATERIA PRIMA')
    AND OIGN."DocDate" BETWEEN '2025-01-01' AND '2025-12-31'
    AND OIGN."Ref2" = 'NO33425273'

GROUP BY
    OIGN."DocDate",
    OIGN."Ref2",
    OIGN."DocNum",
    OIGN."DocEntry",
    IGN1."WhsCode",
    OWHS."WhsName",
    IGN1."ItemCode",
    OITM."ItemName",
    IGN1."Price",
    IGN1."LineTotal",
    IGN1."Dscription"

ORDER BY
    OIGN."DocNum";
