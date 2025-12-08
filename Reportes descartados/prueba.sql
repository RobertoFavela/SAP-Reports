SELECT
    Procesados."Almacen",
    Procesados."Fecha",
    Procesados."Lote",
    COALESCE(Recibidos."DocNum", Recibidos2."DocNum") AS "No. Entrada",
    COALESCE(Recibidos."Cantidad", Recibidos2."Cantidad") AS "Cantidad (KG)",
    Salidas."No. Salida",
    Salidas."KG Recibidos",
    Procesados."No. Entrada",
    Procesados."KG Procesados",
    CASE
        WHEN Salidas."KG Recibidos" > 0 THEN ROUND(
            (
                Procesados."KG Procesados" / Salidas."KG Recibidos"
            ) * 100,
            2
        )
        ELSE NULL
    END AS "Rendimiento (%)",
    CASE
        WHEN Salidas."KG Recibidos" > 0 THEN ROUND(
            Salidas."KG Recibidos" - Procesados."KG Procesados"
        )
        ELSE NULL
    END AS "Merma (KG)",
    Inventario."KG Facturados",
    Inventario."KG Disponibles"
FROM
    (
        SELECT
            TO_DATE (OIGN."DocDate") AS "Fecha",
            OIGN."Ref2" AS "Lote",
            OIGN."DocNum" AS "No. Entrada",
            SUM(IGN1."Quantity") AS "KG Procesados",
            IGN21."RefDocNum" AS "Referencia",
            IGN1."WhsCode" AS "No. Almacen",
            OWHS."WhsName" AS "Almacen"
        FROM
            OIGN
            INNER JOIN IGN1 ON OIGN."DocEntry" = IGN1."DocEntry"
            LEFT JOIN IGN21 ON OIGN."DocEntry" = IGN21."DocEntry" -- Importante LEFT JOIN
            INNER JOIN OITM ON IGN1."ItemCode" = OITM."ItemCode"
            INNER JOIN OITB ON OITM."ItmsGrpCod" = OITB."ItmsGrpCod"
            INNER JOIN OWHS ON IGN1."WhsCode" = OWHS."WhsCode"
        WHERE
            OIGN."CANCELED" = 'N'
            AND OITB."ItmsGrpNam" IN (
                'CAMARON EN BORDO',
                'PT CAMARON FRIZADO',
                'MATERIA PRIMA'
            )
        GROUP BY
            OIGN."DocNum",
            OIGN."DocDate",
            OIGN."Ref2",
            IGN21."RefDocNum",
            IGN1."WhsCode",
            OWHS."WhsName"
    ) AS Procesados
    LEFT JOIN (
        SELECT
            OIGE."DocNum" AS "No. Salida",
            SUM(IGE1."Quantity") AS "KG Recibidos",
            IGE21."RefDocNum" AS "Referencia"
        FROM
            OIGE
            INNER JOIN IGE1 ON OIGE."DocEntry" = IGE1."DocEntry"
            INNER JOIN IGE21 ON OIGE."DocEntry" = IGE21."DocEntry"
            INNER JOIN OITM ON IGE1."ItemCode" = OITM."ItemCode"
            INNER JOIN OITB ON OITM."ItmsGrpCod" = OITB."ItmsGrpCod"
        WHERE
            OIGE."CANCELED" = 'N'
            AND OITB."ItmsGrpNam" IN (
                'CAMARON EN BORDO',
                'PT CAMARON FRIZADO',
                'MATERIA PRIMA'
            )
        GROUP BY
            OIGE."DocNum",
            IGE21."RefDocNum"
    ) Salidas ON Salidas."No. Salida" = Procesados."Referencia"
    LEFT JOIN (
        SELECT
            OPDN."DocNum",
            SUM(PDN1."Quantity") AS "Cantidad"
        FROM
            OPDN
            INNER JOIN PDN1 ON PDN1."DocEntry" = OPDN."DocEntry"
            INNER JOIN OITM ON PDN1."ItemCode" = OITM."ItemCode"
            INNER JOIN OITB ON OITM."ItmsGrpCod" = OITB."ItmsGrpCod"
        WHERE
            OPDN."CANCELED" = 'N'
            AND OITB."ItmsGrpNam" IN (
                'CAMARON EN BORDO',
                'PT CAMARON FRIZADO',
                'MATERIA PRIMA'
            )
        GROUP BY
            OPDN."DocNum"
    ) Recibidos ON Recibidos."DocNum" = Salidas."Referencia"
    LEFT JOIN (
        SELECT
            OIGN."DocNum",
            SUM(IGN1."Quantity") AS "Cantidad"
        FROM
            OIGN
            INNER JOIN IGN1 ON OIGN."DocEntry" = IGN1."DocEntry"
            INNER JOIN OITM ON IGN1."ItemCode" = OITM."ItemCode"
            INNER JOIN OITB ON OITM."ItmsGrpCod" = OITB."ItmsGrpCod"
        WHERE
            OIGN."CANCELED" = 'N'
            AND OITB."ItmsGrpNam" IN (
                'CAMARON EN BORDO',
                'PT CAMARON FRIZADO',
                'MATERIA PRIMA'
            )
        GROUP BY
            OIGN."DocNum"
    ) Recibidos2 ON Recibidos2."DocNum" = Salidas."Referencia"
    LEFT JOIN (
        SELECT
            OBTN."DistNumber" AS "Lote",
            COALESCE(
                (
                    SELECT
                        SUM(IBT1."Quantity")
                    FROM
                        IBT1
                    WHERE
                        IBT1."BatchNum" = OBTN."DistNumber"
                        AND IBT1."Direction" = 1
                ),
                0
            ) AS "KG Facturados",
            SUM(OBTQ."Quantity") AS "KG Disponibles"
        FROM
            OBTN
            INNER JOIN OBTQ ON OBTN."AbsEntry" = OBTQ."MdAbsEntry"
        GROUP BY
            OBTN."DistNumber"
    ) Inventario ON Inventario."Lote" = Procesados."Lote"
WHERE
    Procesados."Fecha" BETWEEN '2025-01-01' AND '2025-12-31'
    -- AND Procesados."Lote" = 'NO33425273'
ORDER BY
    -- Procesados."No. Entrada" DESC
    Inventario."KG Disponibles"