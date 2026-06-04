SELECT
    OIGN."DocNum" AS "Numero Documento",
    OIGN."DocDate" AS "Fecha Contabilizacion",
    OIGN."Ref2" AS "Referencia 2",
    OWOR."DocNum" AS "Numero de Orden",
    IGN1."ItemCode" AS "Numero de Articulo",
    IGN1."Dscription" AS "Descripcion del Articulo",
    IGN1."Quantity" AS "Cantidad",
    IGN1."Price" AS "Precio por Unidad",
    IGN1."LineTotal" AS "Total",
    IGN1."StockPrice" AS "Costo del Articulo",
    OWOR."PlannedQty" AS "Cantidad Planificada OWOR",
    OIGN."Comments" AS "Comentarios"
FROM OIGN
INNER JOIN IGN1    
    ON OIGN."DocEntry" = IGN1."DocEntry"
INNER JOIN OWOR    
    ON IGN1."BaseEntry" = OWOR."DocEntry"   
    AND IGN1."BaseType" = 202
 ORDER BY OIGN."DocNum";