WITH
    Empaques AS (
        SELECT
            IGN1_MP."DocEntry",
            OITM_MP."ItemCode" AS "ItemCodeEmpaque",
            OITM_MP."ItemName" AS "NombreEmpaque",
            IGN1_MP."Price" AS "PrecioEmpaque",
            
            -- Extraer etiqueta dentro de paréntesis, ejemplo: "Caja (5kg)" → "5kg"
            SUBSTRING(
                OITM_MP."ItemName",
                INSTR (OITM_MP."ItemName", '(') + 1,
                INSTR (OITM_MP."ItemName", ')') - INSTR (OITM_MP."ItemName", '(') - 1
            ) AS "Etiqueta",

            /*
            Cantidad en KG por material de empaque
            Los nombres son muy inconsistentes, y es contraproducente intentar
            sacar de forma automatica todos los empaques siendo estos tan pocos

            En caso de que se creen nuevos articulos de material de empaque, se agregan aqui
            */ 
            CASE OITM_MP."ItemCode"
                WHEN 'AP00000001' THEN 20 -- 20 KG
                WHEN 'AP00000002' THEN 18.14 -- 40 LB
                WHEN 'AP00000003' THEN 6.804 -- 6.804 KG
                WHEN 'AP00000004' THEN 10 -- 10 KG
                WHEN 'AP00000005' THEN 18 -- 18 KG
                WHEN 'AP00000006' THEN 12 -- 12 KG
                WHEN 'AP00000007' THEN 14.514 -- 32 LB
                WHEN 'AP00000008' THEN 18.14 -- 40 LB
                WHEN 'AP00000009' THEN 18 -- 18 KG
                WHEN 'AP00000010' THEN 20 -- 20 KG
                WHEN 'AP00000011' THEN 18.14 -- 40 LB
                WHEN 'AP00000012' THEN 6.804 -- 6.804 KG
                WHEN 'AP00000013' THEN 6.804 -- 6.804 KG
                WHEN 'AP00000014' THEN 20 -- 20 KG
                WHEN 'AP00000015' THEN 18.14 -- 40 LB
                WHEN 'AP00000016' THEN 13.6 -- 30 LB
                WHEN 'AP00000017' THEN 18.14 -- 40 LB
                WHEN 'AP00000018' THEN 6.804 -- 6.804
                WHEN 'AP00000019' THEN 20 -- 44 LB
                WHEN 'AP00000020' THEN 18 -- 18 KG
                WHEN 'AP00000021' THEN 10 -- 10 KG
                ELSE 1
            END AS "CapacidadKG"

        -- Lineas de entrada de mercancia
        FROM IGN1 IGN1_MP
            
            -- Maestro de articulos
            INNER JOIN OITM OITM_MP ON IGN1_MP."ItemCode" = OITM_MP."ItemCode"
            INNER JOIN OITB OITB_MP ON OITM_MP."ItmsGrpCod" = OITB_MP."ItmsGrpCod"
            
        -- Filtro
        WHERE
            -- Solo items de material de empaque
            OITB_MP."ItmsGrpNam" = 'PT MATERIAL DE EMPAQUE'
    )

SELECT
    -- Documento
    TO_DATE (OIGN."DocDate") AS "Fecha",
    OIGN."Ref2" AS "Lote",
    OIGN."DocNum" AS "No. Entrada",

    -- Almacén
    IGN1."WhsCode" AS "No. Almacén",
    OWHS."WhsName" AS "Almacén",

    -- Artículo principal
    IGN1."ItemCode" AS "No. Artículo",
    OITM."ItemName" AS "Nombre de Artículo",

    -- Cantidades y costos
    SUM(IGN1."Quantity") AS "Cantidad KG",
    IGN1."Price" AS "Precio Unitario",
    IGN1."LineTotal" AS "Precio TOTAL",

    -- Información del material de empaque asociado
    E."ItemCodeEmpaque" AS "No. Artículo Empaque",

    -- Cantidad de Empaques
    CASE 
        WHEN E."ItemCodeEmpaque" IS NOT NULL
        THEN ROUND( SUM(IGN1."Quantity") / COALESCE(E."CapacidadKG", 1), 0 )
    END AS "Master",

    -- Precio unitario de empaque
    E."PrecioEmpaque" AS "Cto. un. ME PT",

    -- Costo total de empaque
    (
        E."PrecioEmpaque" * CEIL(
            SUM(IGN1."Quantity") / COALESCE(E."CapacidadKG", 1)
        )
    ) AS "Total Cto. ME PT",

    -- Total de articulo + total de empaque
    (
        IGN1."LineTotal" + (
            E."PrecioEmpaque" * CEIL(
                SUM(IGN1."Quantity") / COALESCE(E."CapacidadKG", 1)
            )
        )
    ) AS "Total art. + ME PT",

    (
        (
            IGN1."LineTotal" + (
                E."PrecioEmpaque" * CEIL(
                    SUM(IGN1."Quantity") / COALESCE(E."CapacidadKG", 1)
                )
            )
        ) 
        / SUM(IGN1."Quantity")
    ) AS "Cto. un. PT + ME"

-- Entrada de mercancia
FROM OIGN
    INNER JOIN IGN1 ON OIGN."DocEntry" = IGN1."DocEntry"

    -- Maestro de articulos
    INNER JOIN OITM ON IGN1."ItemCode" = OITM."ItemCode"
    INNER JOIN OITB ON OITM."ItmsGrpCod" = OITB."ItmsGrpCod"

    -- Almacen
    INNER JOIN OWHS ON IGN1."WhsCode" = OWHS."WhsCode"

    -- Asociar el empaque según el DocEntry y el texto entre paréntesis
    LEFT JOIN Empaques E ON E."DocEntry" = OIGN."DocEntry"

    AND E."Etiqueta" = SUBSTRING(
        OITM."ItemName",
        INSTR (OITM."ItemName", '(') + 1,
        INSTR (OITM."ItemName", ')') - INSTR (OITM."ItemName", '(') - 1
    )

-- FIltros
WHERE
    /* 
    Las entradas no se cancelan, se genera su documento contrario, una salida
    Pero mantengo el filtro por si acaso
     */
    OIGN."CANCELED" = 'N'

    -- Solo items de los grupos:
    AND OITB."ItmsGrpNam" IN (
        'CAMARON EN BORDO',
        'PT CAMARON FRIZADO',
        'MATERIA PRIMA'
    )

    -- Filtro de fechas
    -- AND OIGN."DocDate" BETWEEN '2025-01-01' AND '2025-12-31'

    -- Filtro de entradas
    -- AND OIGN."DocNum" = '3930'

    -- Filtro por lote
    -- AND OIGN."Ref2" = 'GU37825282'

-- Agrupado por
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
    E."ItemCodeEmpaque",
    E."PrecioEmpaque",
    E."CapacidadKG"

-- Ordenado por
ORDER BY

    -- Numero de entrada de mercancia mas reciente
    OIGN."DocNum" DESC;