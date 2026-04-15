SELECT
    -- Facturas
    CASE 
        WHEN OINV."isIns" = 'Y' THEN 'Reserva' 
        ELSE 'Deudor' 
    END AS "Tipo_Factura",
    OINV."DocEntry" AS "ID Factura",
    OINV."DocNum" AS "No Factura",

    -- Entregas
    ODLN."DocEntry" AS "ID Entrega",
    ODLN."DocNum" AS "No Entrega",
    CASE         
        WHEN ODLN."CANCELED" = 'Y' THEN 'Cancelada'        
        WHEN ODLN."CANCELED" = 'C' THEN 'Cerrada'       
        ELSE 'Vigente'
    END AS "Estado de entrega",
    -- Articulos
    INV1."ItemCode" AS "No. de Artículo",
    INV1."Dscription" AS "Descripción Artículo/Servicio",

    -- KGS Facturados (cliente C00131: libras a kilos - articulo VA24PUPV68: 200gr)
    -- convertido a decimal con 6 decimales
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
    END AS "KGS Entregados",
    
    RIN1."Quantity" AS "KGS Crédito",
    
    -- Diferencia (cliente C00131: libras a kilos - articulo VA24PUPV68: 200gr)
    -- convertido a decimal con 6 decimales
    -- Si es Deudor = 0. Si es Reserva = Kgs Facturados - Entregados - Notas de Crédito
    CASE 
        WHEN OINV."isIns" = 'Y' THEN
            TO_DECIMAL (
                (
                    CASE
                        WHEN OINV."CardCode" = 'C00131' AND INV1."ItemCode" = 'VA24PUPV68' 
                            THEN TO_DECIMAL (INV1."Quantity", 18, 6) / TO_DECIMAL (5, 18, 6)
                        WHEN OINV."CardCode" = 'C00131' 
                            THEN TO_DECIMAL (INV1."Quantity", 18, 6) * TO_DECIMAL (0.45359237, 18, 6)
                        ELSE TO_DECIMAL (INV1."Quantity", 18, 6)
                    END 
                    - COALESCE(TO_DECIMAL (DLN1."Quantity", 18, 6), 0) 
                    - COALESCE(TO_DECIMAL (RIN1."Quantity", 18, 6), 0)
                ),
                18,
                4
            )
        ELSE TO_DECIMAL(0, 18, 4) -- Sin diferencia para Facturas de Deudor
    END AS "Diferencia",

    -- Fechas
    TO_DATE (ODLN."DocDate") AS "Fecha Entrega",
    TO_DATE (OINV."DocDate") AS "Fecha Factura",

    INV1."WhsCode" AS "Código de Almacén",
    OINV."DocDate" AS "Fecha Contabilización",
    INV1."BaseCard" AS "Código Base SN",

    -- Costo del Artículo
    CASE 
        WHEN OINV."isIns" = 'Y' THEN TO_DECIMAL (DLN1."StockPrice", 18, 4) 
        ELSE TO_DECIMAL(INV1."StockPrice",18,4)
    END AS "Costo del Artículo",
    
    -- Ingreso
    TO_DECIMAL (INV1."GTotal", 18, 6) AS "Ingreso",
    
    -- Costo de venta (Cantidad * Precio de stock)
    CASE 
        WHEN OINV."isIns" = 'Y' THEN (TO_DECIMAL (DLN1."Quantity", 18, 6) * TO_DECIMAL (DLN1."StockPrice", 18, 6))
        ELSE TO_DECIMAL (INV1."Quantity", 18, 6) * TO_DECIMAL(INV1."StockPrice", 18, 6)
    END AS "Costo Venta",
    
    -- Importe Nota Crédito
    TO_DECIMAL (RIN1."Quantity", 18, 6) * TO_DECIMAL (RIN1."Price", 18, 6) + TO_DECIMAL (RIN1."VatSum", 18, 6) AS "Importe Nota Crédito",
    
    -- Utilidad (Ingreso - Costo de venta - Importe nota de credito)
    TO_DECIMAL (INV1."GTotal", 18, 6) - COALESCE(
        TO_DECIMAL (DLN1."Quantity", 18, 6) * TO_DECIMAL (DLN1."StockPrice", 18, 6),
        0
    ) - COALESCE(
        TO_DECIMAL (RIN1."Quantity", 18, 6) * TO_DECIMAL (RIN1."Price", 18, 6) + TO_DECIMAL (RIN1."VatSum", 18, 6),
        0
    ) AS "Utilidad",

    INV1."CogsOcrCod",
    -- Sucursales
    INV1."OcrCode2",
    INV1."OcrCode3",
    -- Ciclos
    INV1."OcrCode4",
    INV1."U_SBO_MARCA",
    INV1."U_SBO_PRESENTACION",
    INV1."U_SBO_CICLO",
    INV1."U_SBO_CALIDAD",

    CASE 
        WHEN OINV."isIns" = 'Y' THEN 'Reserva' 
        ELSE 'Deudor' 
    END AS "Tipo_Factura",

    CASE 
    /* Cuando ES Factura de Reserva (Usa DLN1 - Entrega) */
    WHEN OINV."isIns" = 'Y' THEN
        CASE
            WHEN OITM."U_TIP_PRESENTACION" = 'K' 
                THEN TO_DECIMAL(DLN1."Quantity" / OITM."U_KILOS", 18, 4)
            WHEN OITM."U_TIP_PRESENTACION" = 'L'
                THEN TO_DECIMAL(DLN1."Quantity" / OITM."U_LIBRAS", 18, 4)
        END
    /* Cuando NO ES Factura de Reserva (Usa INV1 - Factura) */
    ELSE
        CASE
            WHEN OITM."U_TIP_PRESENTACION" = 'K' 
                THEN TO_DECIMAL(INV1."Quantity" / OITM."U_KILOS", 18, 4)
            WHEN OITM."U_TIP_PRESENTACION" = 'L'
                THEN TO_DECIMAL(INV1."Quantity" / OITM."U_LIBRAS", 18, 4)
        END
    END AS "Master"
    
-- Lineas de Facturas
FROM INV1
    -- Cabeceras de Facturas
    INNER JOIN OINV ON OINV."DocEntry" = INV1."DocEntry"

    -- Lineas de Entregas
    LEFT JOIN DLN1 ON DLN1."BaseEntry" = OINV."DocEntry"
        AND DLN1."BaseLine" = INV1."LineNum"
        AND DLN1."BaseType" = 13

    -- Cabeceras de Entregas
    LEFT JOIN ODLN ON ODLN."DocEntry" = DLN1."DocEntry"

    -- Lineas de Notas de Crédito
    LEFT JOIN RIN1 ON RIN1."BaseEntry" = OINV."DocEntry"
        AND RIN1."BaseLine" = INV1."LineNum"
        AND RIN1."BaseType" = 13

    -- Cabeceras de Notas de Crédito
    LEFT JOIN ORIN ON ORIN."DocEntry" = RIN1."DocEntry"

    -- Maestro de artículos
    JOIN OITM ON OITM."ItemCode" = INV1."ItemCode"
    
    -- Grupos de artículos
    JOIN OITB ON OITB."ItmsGrpCod" = OITM."ItmsGrpCod"

WHERE
    OINV."CANCELED" = 'N'
    AND OITB."ItmsGrpNam" = 'PT CAMARON FRIZADO'

ORDER BY
    OINV."DocNum" DESC