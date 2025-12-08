/*
==============================================================================================
            REPORTE DE ENTREGAS POR SUCURSAL A PARTIR DE DOCUMENTOS DE FACTURAS
==============================================================================================
*/

SELECT
    -- Referencia de entrega
    T1."DocEntry" AS "ID Interno Documento",
    
    -- Numeros de documento
    I0."DocNum" AS "No. Factura",
    T0."DocNum" AS "No. Entrega",
    
    -- Articulo
    I1."ItemCode" AS "No. de Artículo",
    I1."Dscription" AS "Descripción Artículo/Servicio",
    -- KGS Facturados (cliente C00131: libras a kilos - articulo VA24PUPV68: 200gr)
    -- convertido a decimal con 6 decimales
    TO_DECIMAL (
        CASE
            WHEN T1."BaseCard" = 'C00131'
            AND I1."ItemCode" = 'VA24PUPV68' THEN TO_DECIMAL (I1."Quantity", 18, 6) / TO_DECIMAL (5, 18, 6)
            WHEN T1."BaseCard" = 'C00131' THEN TO_DECIMAL (I1."Quantity", 18, 6) * TO_DECIMAL (0.45359237, 18, 6)
            ELSE TO_DECIMAL (I1."Quantity", 18, 6)
        END,
        18,
        4
    ) AS "KGS Facturados",
    T1."Quantity" AS "KGS Entregados",
    R1."Quantity" AS "KGS Crédito",
    -- Diferencia (cliente C00131: libras a kilos - articulo VA24PUPV68: 200gr)
    -- convertido a decimal con 6 decimales
    TO_DECIMAL (
        (
            CASE
                WHEN T1."BaseCard" = 'C00131'
                AND I1."ItemCode" = 'VA24PUPV68' THEN TO_DECIMAL (I1."Quantity", 18, 6) / TO_DECIMAL (5, 18, 6)
                WHEN T1."BaseCard" = 'C00131' THEN TO_DECIMAL (I1."Quantity", 18, 6) * TO_DECIMAL (0.45359237, 18, 6)
                ELSE TO_DECIMAL (I1."Quantity", 18, 6)
            END - COALESCE(TO_DECIMAL (T1."Quantity", 18, 6), 0) - COALESCE(TO_DECIMAL (R1."Quantity", 18, 6), 0)
        ),
        18,
        4
    ) AS "Diferencia",
    T1."ShipDate" AS "Fecha Entrega Línea",
    TO_DATE (T0."DocDate") AS "Fecha Entrega",
    TO_DATE (I0."DocDate") AS "Fecha Factura",
    T1."WhsCode" AS "Código de Almacén",
    T1."DocDate" AS "Fecha Contabilización",
    T1."BaseCard" AS "Código Base SN",
    T1."OcrCode" AS "Norma de Reparto",
    T1."VatGroup" AS "Definición del Impuesto",
    T1."BaseDocNum" AS "Documento Base",
    T1."FinncPriod" AS "Período Contable",
    T1."ObjType" AS "Tipo de Objeto",
    T1."unitMsr" AS "Unidad",
    T1."StockSum",
    TO_DECIMAL (T1."StockPrice", 18, 4) AS "Costo del Artículo",
    
    -- Ingreso
    TO_DECIMAL (I1."GTotal", 18, 6) AS "Ingreso",
    
    -- Costo de venta 
    -- (Cantidad * Precio de stock)
    TO_DECIMAL (T1."Quantity", 18, 6) * TO_DECIMAL (T1."StockPrice", 18, 6) AS "Costo Venta",
    
    -- Importe Nota Crédito
    TO_DECIMAL (R1."Quantity", 18, 6) * TO_DECIMAL (R1."Price", 18, 6) + TO_DECIMAL (R1."VatSum", 18, 6) AS "Importe Nota Crédito",
    
    -- Utilidad
    -- (Ingreso - Costo de venta - Importe nota de credito)
    TO_DECIMAL (I1."GTotal", 18, 6) - COALESCE(
        TO_DECIMAL (T1."Quantity", 18, 6) * TO_DECIMAL (T1."StockPrice", 18, 6),
        0
    ) - COALESCE(
        TO_DECIMAL (R1."Quantity", 18, 6) * TO_DECIMAL (R1."Price", 18, 6) + TO_DECIMAL (R1."VatSum", 18, 6),
        0
    ) AS "Utilidad",

    T1."LineStatus",
    T1."BaseType",
    T1."BaseEntry",
    T1."BaseAtCard",
    T1."CogsOcrCod",

    -- Sucursales
    T1."OcrCode2",
    T1."OcrCode3",
    
    -- Ciclos
    T1."OcrCode4",
    T1."OcrCode5",
    T1."U_SBO_MARCA",
    T1."U_SBO_PRESENTACION",
    T1."U_SBO_CICLO",
    T1."U_SBO_CALIDAD"

-- Lineas de facturas
FROM INV1 I1
    -- Cabecera de facturas
    JOIN OINV I0 ON I0."DocEntry" = I1."DocEntry"

    -- Líneas de entrega
    LEFT JOIN DLN1 T1 ON T1."BaseEntry" = I0."DocEntry"
        AND T1."BaseLine" = I1."LineNum"
        AND T1."BaseType" = 13
        AND T1."ItemCode" = I1."ItemCode"

    -- Cabecera de entrega
    LEFT JOIN ODLN T0 ON T0."DocEntry" = T1."DocEntry"
    
    -- Líneas de notas de crédito
    LEFT JOIN RIN1 R1 ON R1."BaseEntry" = I0."DocEntry"
        AND R1."BaseLine" = I1."LineNum"
        AND R1."BaseType" = 13
    
    -- Cabecera de nota de crédito
    LEFT JOIN ORIN R0 ON R0."DocEntry" = R1."DocEntry"
    
    -- Maestro de artículos
    JOIN OITM ITM ON ITM."ItemCode" = I1."ItemCode"
    
    -- Grupos de artículos
    JOIN OITB ITG ON ITG."ItmsGrpCod" = ITM."ItmsGrpCod"

-- Filtros
WHERE

    -- Entregas no canceladas
    I0."CANCELED" = 'N'
    
    -- Facturas no canceladas
    AND (
        T0."CANCELED" = 'N'
        OR T0."CANCELED" IS NULL
    )
    
    -- Solo traemos articulos de camaron frizado
    AND ITG."ItmsGrpNam" = 'PT CAMARON FRIZADO'
    
    -- FILTRO DE SUCURSAL
    -- Colocar "--" antes de la linea para mostrar todas
    -- AND T1."OcrCode2" = 'S0502'
    
    -- FILTRO DE CICLO
    -- Colocar "--" antes de la linea para mostrar todos
    -- AND T1."OcrCode4" = 'C0005'
    
    -- FILTRO DE FECHAS PARA EL REPORTE
    AND (
        -- Caso 1: Si existe entrega, se usa su fecha para incluirla
        (
            T1."DocDate" BETWEEN '2025-09-01' AND '2025-09-30'
        )
        OR
        -- Caso 2: Si no hay entrega (es decir, solo hay factura), se usa la fecha de la factura
        (
            T1."DocDate" IS NULL
            AND I0."DocDate" BETWEEN '2025-09-01' AND '2025-08-30'
        )
    )

-- Ordenado por
ORDER BY

    -- Numero de facturas mas recientes
    I0."DocNum" DESC