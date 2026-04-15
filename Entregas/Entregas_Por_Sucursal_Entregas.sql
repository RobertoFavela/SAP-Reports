SELECT
    -- Facturas
    CASE         
        WHEN OINV."DocEntry" IS NULL THEN ''      
        WHEN OINV."isIns" = 'Y' THEN 'Reserva'        
        ELSE 'Deudor'    
    END AS "Tipo Factura",
    OINV."DocEntry" AS "ID Factura",
    COALESCE(OINV."DocNum", DLN21."RefDocNum") AS "No. Factura",
    
    -- Entregas
    ODLN."DocEntry" AS "ID Entrega",
    ODLN."DocNum" AS "Entrega",
    CASE
        WHEN ODLN."CANCELED" = 'Y' THEN 'Cancelada'
        WHEN ODLN."CANCELED" = 'C' THEN 'Cerrada'
        ELSE 'Vigente'
    END AS "Estado entrega",
    
    -- Articulos
    DLN1."ItemCode" AS "Articulo",
    DLN1."Dscription" AS "Descripcion",

    -- KGS Facturados (cliente C00131: Libras a kilos - articulo VA24PUPV68: 200gr)
    TO_DECIMAL (
        CASE
            WHEN DLN1."BaseCard" = 'C00131'
            AND INV1."ItemCode" = 'VA24PUPV68' THEN TO_DECIMAL (INV1."Quantity", 18, 6) / TO_DECIMAL (5, 18, 6)
            WHEN DLN1."BaseCard" = 'C00131' THEN TO_DECIMAL (INV1."Quantity", 18, 6) * TO_DECIMAL (0.45359237, 18, 6)
            ELSE TO_DECIMAL (INV1."Quantity", 18, 6)
        END,
        18,
        4
    ) AS "KGS Facturados",

    CASE
        WHEN OINV."isIns" = 'Y' THEN DLN1."Quantity"
        ELSE INV1."Quantity"
    END AS "KGS Entrega",

    RIN1."Quantity" AS "KGS Crédito",

    -- Diferencia (cliente C00131: libras a kilos - articulo VA24PUPV68: 200gr)
    CASE
        WHEN OINV."isIns" = 'Y' THEN
            TO_DECIMAL (
                (
                    CASE
                        WHEN DLN1."BaseCard" = 'C00131'
                        AND INV1."ItemCode" = 'VA24PUPV68' THEN TO_DECIMAL (INV1."Quantity", 18, 6) / TO_DECIMAL (5, 18, 6)
                        WHEN DLN1."BaseCard" = 'C00131' THEN TO_DECIMAL (INV1."Quantity", 18, 6) * TO_DECIMAL (0.45359237, 18, 6)
                        ELSE TO_DECIMAL (INV1."Quantity", 18, 6)
                    END - COALESCE(TO_DECIMAL (DLN1."Quantity", 18, 6), 0) - COALESCE(TO_DECIMAL (RIN1."Quantity", 18, 6), 0)
                ),
                18,
                4
            )
        ELSE TO_DECIMAL(0, 18,4)
    END AS "Diferencia",

    -- Fechas
    TO_DATE (DLN1."ShipDate") AS "Fecha Entrega",
    TO_DATE (OINV."DocDate") AS "Fecha Factura",
    
    DLN1."WhsCode" AS "Almacen",
    DLN1."BaseCard" AS "Código Base SN",

    -- Costo del Articulo
    TO_VARCHAR(TO_DECIMAL(DLN1."StockPrice", 18, 4)) AS "Costo del Artículo",
    
    -- Ingreso
    TO_DECIMAL (INV1."GTotal", 18, 6) AS "Ingreso",
    
    -- Costo de venta 
    -- (Cantidad * Precio de stock)
    TO_VARCHAR((TO_DECIMAL (DLN1."Quantity", 18, 4) * TO_DECIMAL (DLN1."StockPrice", 18, 4))) AS "Costo Venta",
    
    -- Importe Nota Crédito
    TO_DECIMAL (RIN1."Quantity", 18, 6) * TO_DECIMAL (RIN1."Price", 18, 6) + TO_DECIMAL (RIN1."VatSum", 18, 6) AS "Importe Nota Crédito",
    
    -- Utilidad
    -- (Ingreso - Costo de venta - Importe nota de credito) 
    TO_DECIMAL (INV1."GTotal", 18, 6) - COALESCE(
        TO_DECIMAL (DLN1."Quantity", 18, 6) * TO_DECIMAL (DLN1."StockPrice", 18, 6),
        0
    ) - COALESCE(
        TO_DECIMAL (RIN1."Quantity", 18, 6) * TO_DECIMAL (RIN1."Price", 18, 6) + TO_DECIMAL (RIN1."VatSum", 18, 6),
        0
    ) AS "Utilidad",

    DLN1."CogsOcrCod",
    -- Sucursales
    DLN1."OcrCode2" AS "Sucursal",
    DLN1."OcrCode3",
    -- Ciclos
    DLN1."OcrCode4" AS "Ciclo",
    DLN1."U_SBO_MARCA",
    DLN1."U_SBO_PRESENTACION",
    DLN1."U_SBO_CICLO",
    DLN1."U_SBO_CALIDAD",

    CASE
        WHEN OITM."U_TIP_PRESENTACION" = 'K' 
            THEN TO_DECIMAL(DLN1."Quantity" / OITM."U_KILOS", 18, 4)
        WHEN OITM."U_TIP_PRESENTACION" = 'L'
            THEN TO_DECIMAL(DLN1."Quantity" / OITM."U_LIBRAS", 18, 4)
    END AS "Master"

-- Entregas lineas
FROM DLN1
    -- Entregas Cabecera
    INNER JOIN ODLN ON DLN1."DocEntry" = ODLN."DocEntry"
    
    -- Relación opcional con factura
    LEFT JOIN INV1 ON DLN1."BaseEntry" = INV1."DocEntry"
    AND DLN1."BaseLine" = INV1."LineNum"
    AND DLN1."BaseType" = 13
    
    -- Cabecera factura, si aplica
    LEFT JOIN OINV ON INV1."DocEntry" = OINV."DocEntry"
    
    -- Líneas de notas de crédito
    LEFT JOIN RIN1 ON RIN1."BaseEntry" = OINV."DocEntry"
    AND RIN1."BaseLine" = INV1."LineNum"
    AND RIN1."BaseType" = 13
    
    -- Cabecera de nota de crédito
    LEFT JOIN ORIN ON ORIN."DocEntry" = RIN1."DocEntry"
    
    -- Maestro artículos
    LEFT JOIN OITM ON OITM."ItemCode" = DLN1."ItemCode"
    
    -- Grupo artículos
    LEFT JOIN OITB ON OITB."ItmsGrpCod" = OITM."ItmsGrpCod"
    /*
    LEFT JOIN DLN21 DLNREF ON DLNREF."DocEntry" = DLN1."DocEntry"
    
    -- Referencia a base
    AND DLNREF."LineNum" = DLN1."LineNum"
    AND DLNREF."RefObjType" = '13'
*/
    LEFT JOIN DLN21 ON DLN21."DocEntry" = DLN1."DocEntry"

-- Filtros
WHERE
    -- Solo entregas no canceladas
    ODLN."CANCELED" = 'N'
    
    -- Solo entregas de camaron frizado
    AND OITB."ItmsGrpNam" = 'PT CAMARON FRIZADO'
    
    -- FILTRO DE SUCURSAL
    -- Colocar "--" antes de la linea para mostrar todas
    -- AND DLN1."OcrCode2" = 'S0502'
    
    -- FILTRO DE CICLO
    -- Colocar "--" antes de la linea para mostrar todos
    -- AND DLN1."OcrCode4" = 'C0005'
    
ORDER BY 
    ODLN."DocNum" DESC