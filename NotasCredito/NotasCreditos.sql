SELECT
    ORIN."DocEntry" AS "Id. Doc",
    ORIN."DocNum" AS "No. Doc",
    CASE         
        WHEN ORIN."CANCELED" = 'Y' THEN 'Cancelado'        
        WHEN ORIN."CANCELED" = 'C' THEN 'Cerrado'       
        ELSE 'Vigente'
    END AS "Cancelado",
    RIN1."ItemCode" AS "No. Articulo",
    RIN1."Dscription",
    RIN1."Quantity" AS "KGs",
    RIN1."LineTotal" AS "Subtotal",
    RIN1."VatSum" AS "IVA",
    RIN1."GTotal" AS "Total",
    OINV."DocDate" AS "Fecha Factura",
    ORIN."DocDate" AS "Fecha Contabilizacion",
    RIN1."WhsCode" AS "Almacen",
    RIN1."BaseCard" AS "Codigo Base SN",
    RIN1."OcrCode" AS "Norma de reparto",
    RIN1."CogsOcrCo2" AS "Sucursal",
    RIN1."CogsOcrCo3" AS "Area",
    RIN1."CogsOcrCo4" AS "Ciclo",
    RIN1."U_SBO_MARCA" AS "Marca",
    RIN1."U_SBO_PRESENTACION" AS "Presentacion",
    RIN1."U_SBO_CICLO" AS "Ciclo_U",
    RIN1."U_SBO_CALIDAD" AS "Calidad"

FROM ORIN
    INNER JOIN RIN1 ON RIN1."DocEntry" = ORIN."DocEntry"
    LEFT JOIN OINV ON RIN1."BaseEntry" = OINV."DocEntry" AND RIN1."BaseType" = 13

ORDER BY
    ORIN."DocNum" DESC