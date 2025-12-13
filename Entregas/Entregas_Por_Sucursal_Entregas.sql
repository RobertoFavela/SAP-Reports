SELECT

    T1."DocEntry" AS "ID Interno",
    COALESCE(I0."DocNum", DLNREF."RefDocNum") AS "No. Factura",
    T0."DocNum" AS "Entrega",
    T1."ItemCode" AS "Articulo",
    T1."Dscription" AS "Descripcion",
    -- KGS Facturados (cliente C00131: Libras a kilos - articulo VA24PUPV68: 200gr)
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
    T1."Quantity" AS "KGS Entrega",
    R1."Quantity" AS "KGS Crédito",
    -- Diferencia (cliente C00131: libras a kilos - articulo VA24PUPV68: 200gr)
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
    TO_DATE (T1."ShipDate") AS "Fecha Entrega",
    TO_DATE (I0."DocDate") AS "Fecha Factura",
    T1."WhsCode" AS "Almacen",
    T1."BaseCard" AS "Código Base SN",
    T1."OcrCode" AS "Norma de Reparto",
    T1."VatGroup" AS "Definición del Impuesto",
    T1."BaseAtCard" AS "Documento Base",
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

    T1."CogsOcrCod",
    -- Sucursales
    T1."OcrCode2" AS "Sucursal",
    T1."OcrCode3",
    -- Ciclos
    T1."OcrCode4" AS "Ciclo",
    T1."OcrCode5",
    T1."U_SBO_MARCA",
    T1."U_SBO_PRESENTACION",
    T1."U_SBO_CICLO",
    T1."U_SBO_CALIDAD"

-- Entregas lineas
FROM DLN1 T1
    -- Entregas Cabecera
    INNER JOIN ODLN T0 ON T1."DocEntry" = T0."DocEntry"
    
    -- Relación opcional con factura
    LEFT JOIN INV1 I1 ON T1."BaseEntry" = I1."DocEntry"
    AND T1."BaseLine" = I1."LineNum"
    AND T1."BaseType" = 13
    
    -- Cabecera factura, si aplica
    LEFT JOIN OINV I0 ON I1."DocEntry" = I0."DocEntry"
    
    -- Líneas de notas de crédito
    LEFT JOIN RIN1 R1 ON R1."BaseEntry" = I0."DocEntry"
    AND R1."BaseLine" = I1."LineNum"
    AND R1."BaseType" = 13
    
    -- Cabecera de nota de crédito
    LEFT JOIN ORIN R0 ON R0."DocEntry" = R1."DocEntry"
    
    -- Maestro artículos
    LEFT JOIN OITM ITM ON ITM."ItemCode" = T1."ItemCode"
    
    -- Grupo artículos
    LEFT JOIN OITB ITG ON ITG."ItmsGrpCod" = ITM."ItmsGrpCod"
    LEFT JOIN DLN21 DLNREF ON DLNREF."DocEntry" = T1."DocEntry"
    
    -- Referencia a base
    AND DLNREF."LineNum" = T1."LineNum"
    AND DLNREF."RefObjType" = '13'

-- Filtros
WHERE
    -- Solo entregas no canceladas
    T0."CANCELED" = 'N'
    
    -- Solo entregas de camaron frizado
    AND ITG."ItmsGrpNam" = 'PT CAMARON FRIZADO'
    
    -- FILTRO DE SUCURSAL
    -- Colocar "--" antes de la linea para mostrar todas
    -- AND T1."OcrCode2" = 'S0502'
    
    -- FILTRO DE CICLO
    -- Colocar "--" antes de la linea para mostrar todos
    -- AND T1."OcrCode4" = 'C0005'
    
    -- Filtro de fechas
    AND T1."DocDate" BETWEEN '2025-08-01' AND '2025-08-31'


