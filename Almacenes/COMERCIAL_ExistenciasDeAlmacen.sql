SELECT
    -- Almacen
    OWHS."WhsCode" AS "Código Almacén",
    OWHS."WhsName" AS "Nombre Almacén",

    -- Articulo
    OINM."ItemCode" AS "Código Artículo",
    OITM."ItemName" AS "Nombre Artículo",
    CASE OITM."U_TIP_PRESENTACION"
        WHEN 'K' THEN 'KG'
        WHEN 'L' THEN 'LB'
    END AS "Unidad de Medida",

    OITM."U_TIP_PRESENTACION",

    -- Movimiento de inventario
    OINM."DocDate" AS "Fecha Contabilización",

    -- Nombre del tipo de documento
    CASE OINM."TransType"
        WHEN 59 THEN 'Entrada de Mercancías (OC)'
        WHEN 60 THEN 'Salida de Inventario'
        WHEN 67 THEN 'Transferencia de Inventario'
        WHEN 13 THEN 'Factura de Clientes'
        WHEN 15 THEN 'Entrega a Clientes'
        WHEN 16 THEN 'Devolución de Clientes'
        WHEN 69 THEN 'Entrada de Inventario'
        ELSE 'Otro Movimiento'
    END AS "Tipo de Documento",

    -- Cantidades
    OINM."InQty"  AS "Cantidad Entrada",
    OINM."OutQty" AS "Cantidad Salida",
    OITW."OnHand"     AS "Existencia",
    OITW."IsCommited" AS "Comprometido"

FROM OINM

/* Relación con maestro de artículos */
INNER JOIN OITM
    ON OITM."ItemCode" = OINM."ItemCode"

/* Relación con maestro de almacenes */
INNER JOIN OWHS
    ON OWHS."WhsCode" = OINM."Warehouse"

/* Existencias por artículo y almacén */
INNER JOIN OITW
    ON OITW."ItemCode" = OINM."ItemCode"
   AND OITW."WhsCode"  = OINM."Warehouse"

LEFT JOIN OITB
    ON OITB."ItmsGrpCod" = OITM."ItmsGrpCod"

WHERE 
    AND OITB."ItmsGrpNam" = 'PT CAMARON FRIZADO'