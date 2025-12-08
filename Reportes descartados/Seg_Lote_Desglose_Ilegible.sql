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
    
    -- Número de artículo del material de empaque
    (
        SELECT
            IGN1_MP."ItemCode"
        FROM
            IGN1 IGN1_MP
            INNER JOIN OITM OITM_MP ON IGN1_MP."ItemCode" = OITM_MP."ItemCode"
            INNER JOIN OITB OITB_MP ON OITM_MP."ItmsGrpCod" = OITB_MP."ItmsGrpCod"
        WHERE
            IGN1_MP."DocEntry" = OIGN."DocEntry"
            AND OITB_MP."ItmsGrpNam" = 'PT MATERIAL DE EMPAQUE'
            AND CASE
                WHEN INSTR (OITM_MP."ItemName", '(') > 0
                AND INSTR (OITM_MP."ItemName", ')') > INSTR (OITM_MP."ItemName", '(') THEN SUBSTRING(
                    OITM_MP."ItemName",
                    INSTR (OITM_MP."ItemName", '(') + 1,
                    INSTR (OITM_MP."ItemName", ')') - INSTR (OITM_MP."ItemName", '(') - 1
                )
                ELSE NULL
            END = CASE
                WHEN INSTR (OITM."ItemName", '(') > 0
                AND INSTR (OITM."ItemName", ')') > INSTR (OITM."ItemName", '(') THEN SUBSTRING(
                    OITM."ItemName",
                    INSTR (OITM."ItemName", '(') + 1,
                    INSTR (OITM."ItemName", ')') - INSTR (OITM."ItemName", '(') - 1
                )
                ELSE NULL
            END
    ) AS "No. Artículo Empaque",
    -- Cálculo de cantidad de empaques (redondeo hacia arriba)
    CASE
        WHEN COALESCE(
            TO_DECIMAL (
                NULLIF(
                    SUBSTRING(
                        (
                            SELECT
                                SUBSTRING(
                                    OITM_MP."ItemName",
                                    INSTR (OITM_MP."ItemName", '(') + 1,
                                    INSTR (OITM_MP."ItemName", ')') - INSTR (OITM_MP."ItemName", '(') - 1
                                )
                            FROM
                                IGN1 IGN1_MP
                                INNER JOIN OITM OITM_MP ON IGN1_MP."ItemCode" = OITM_MP."ItemCode"
                                INNER JOIN OITB OITB_MP ON OITM_MP."ItmsGrpCod" = OITB_MP."ItmsGrpCod"
                            WHERE
                                IGN1_MP."DocEntry" = OIGN."DocEntry"
                                AND OITB_MP."ItmsGrpNam" = 'PT MATERIAL DE EMPAQUE'
                                AND CASE
                                    WHEN INSTR (OITM_MP."ItemName", '(') > 0
                                    AND INSTR (OITM_MP."ItemName", ')') > INSTR (OITM_MP."ItemName", '(') THEN SUBSTRING(
                                        OITM_MP."ItemName",
                                        INSTR (OITM_MP."ItemName", '(') + 1,
                                        INSTR (OITM_MP."ItemName", ')') - INSTR (OITM_MP."ItemName", '(') - 1
                                    )
                                    ELSE NULL
                                END = CASE
                                    WHEN INSTR (OITM."ItemName", '(') > 0
                                    AND INSTR (OITM."ItemName", ')') > INSTR (OITM."ItemName", '(') THEN SUBSTRING(
                                        OITM."ItemName",
                                        INSTR (OITM."ItemName", '(') + 1,
                                        INSTR (OITM."ItemName", ')') - INSTR (OITM."ItemName", '(') - 1
                                    )
                                    ELSE NULL
                                END
                        ),
                        1,
                        INSTR (
                            (
                                SELECT
                                    SUBSTRING(
                                        OITM_MP."ItemName",
                                        INSTR (OITM_MP."ItemName", '(') + 1,
                                        INSTR (OITM_MP."ItemName", ')') - INSTR (OITM_MP."ItemName", '(') - 1
                                    )
                                FROM
                                    IGN1 IGN1_MP
                                    INNER JOIN OITM OITM_MP ON IGN1_MP."ItemCode" = OITM_MP."ItemCode"
                                    INNER JOIN OITB OITB_MP ON OITM_MP."ItmsGrpCod" = OITB_MP."ItmsGrpCod"
                                WHERE
                                    IGN1_MP."DocEntry" = OIGN."DocEntry"
                                    AND OITB_MP."ItmsGrpNam" = 'PT MATERIAL DE EMPAQUE'
                                    AND CASE
                                        WHEN INSTR (OITM_MP."ItemName", '(') > 0
                                        AND INSTR (OITM_MP."ItemName", ')') > INSTR (OITM_MP."ItemName", '(') THEN SUBSTRING(
                                            OITM_MP."ItemName",
                                            INSTR (OITM_MP."ItemName", '(') + 1,
                                            INSTR (OITM_MP."ItemName", ')') - INSTR (OITM_MP."ItemName", '(') - 1
                                        )
                                        ELSE NULL
                                    END = CASE
                                        WHEN INSTR (OITM."ItemName", '(') > 0
                                        AND INSTR (OITM."ItemName", ')') > INSTR (OITM."ItemName", '(') THEN SUBSTRING(
                                            OITM."ItemName",
                                            INSTR (OITM."ItemName", '(') + 1,
                                            INSTR (OITM."ItemName", ')') - INSTR (OITM."ItemName", '(') - 1
                                        )
                                        ELSE NULL
                                    END
                            ),
                            'kg'
                        ) - 1
                    ),
                    ''
                ),
                18,
                4
            ),
            0
        ) > 0 THEN CEIL(
            SUM(IGN1."Quantity") / COALESCE(
                TO_DECIMAL (
                    NULLIF(
                        SUBSTRING(
                            (
                                SELECT
                                    SUBSTRING(
                                        OITM_MP."ItemName",
                                        INSTR (OITM_MP."ItemName", '(') + 1,
                                        INSTR (OITM_MP."ItemName", ')') - INSTR (OITM_MP."ItemName", '(') - 1
                                    )
                                FROM
                                    IGN1 IGN1_MP
                                    INNER JOIN OITM OITM_MP ON IGN1_MP."ItemCode" = OITM_MP."ItemCode"
                                    INNER JOIN OITB OITB_MP ON OITM_MP."ItmsGrpCod" = OITB_MP."ItmsGrpCod"
                                WHERE
                                    IGN1_MP."DocEntry" = OIGN."DocEntry"
                                    AND OITB_MP."ItmsGrpNam" = 'PT MATERIAL DE EMPAQUE'
                                    AND CASE
                                        WHEN INSTR (OITM_MP."ItemName", '(') > 0
                                        AND INSTR (OITM_MP."ItemName", ')') > INSTR (OITM_MP."ItemName", '(') THEN SUBSTRING(
                                            OITM_MP."ItemName",
                                            INSTR (OITM_MP."ItemName", '(') + 1,
                                            INSTR (OITM_MP."ItemName", ')') - INSTR (OITM_MP."ItemName", '(') - 1
                                        )
                                        ELSE NULL
                                    END = CASE
                                        WHEN INSTR (OITM."ItemName", '(') > 0
                                        AND INSTR (OITM."ItemName", ')') > INSTR (OITM."ItemName", '(') THEN SUBSTRING(
                                            OITM."ItemName",
                                            INSTR (OITM."ItemName", '(') + 1,
                                            INSTR (OITM."ItemName", ')') - INSTR (OITM."ItemName", '(') - 1
                                        )
                                        ELSE NULL
                                    END
                            ),
                            1,
                            INSTR (
                                (
                                    SELECT
                                        SUBSTRING(
                                            OITM_MP."ItemName",
                                            INSTR (OITM_MP."ItemName", '(') + 1,
                                            INSTR (OITM_MP."ItemName", ')') - INSTR (OITM_MP."ItemName", '(') - 1
                                        )
                                    FROM
                                        IGN1 IGN1_MP
                                        INNER JOIN OITM OITM_MP ON IGN1_MP."ItemCode" = OITM_MP."ItemCode"
                                        INNER JOIN OITB OITB_MP ON OITM_MP."ItmsGrpCod" = OITB_MP."ItmsGrpCod"
                                    WHERE
                                        IGN1_MP."DocEntry" = OIGN."DocEntry"
                                        AND OITB_MP."ItmsGrpNam" = 'PT MATERIAL DE EMPAQUE'
                                        AND CASE
                                            WHEN INSTR (OITM_MP."ItemName", '(') > 0
                                            AND INSTR (OITM_MP."ItemName", ')') > INSTR (OITM_MP."ItemName", '(') THEN SUBSTRING(
                                                OITM_MP."ItemName",
                                                INSTR (OITM_MP."ItemName", '(') + 1,
                                                INSTR (OITM_MP."ItemName", ')') - INSTR (OITM_MP."ItemName", '(') - 1
                                            )
                                            ELSE NULL
                                        END = CASE
                                            WHEN INSTR (OITM."ItemName", '(') > 0
                                            AND INSTR (OITM."ItemName", ')') > INSTR (OITM."ItemName", '(') THEN SUBSTRING(
                                                OITM."ItemName",
                                                INSTR (OITM."ItemName", '(') + 1,
                                                INSTR (OITM."ItemName", ')') - INSTR (OITM."ItemName", '(') - 1
                                            )
                                            ELSE NULL
                                        END
                                ),
                                'kg'
                            ) - 1
                        ),
                        ''
                    ),
                    18,
                    4
                ),
                1
            )
        )
        ELSE NULL
    END AS "Master",
    -- Precio del material de empaque
    (
        SELECT
            IGN1_MP."Price"
        FROM
            IGN1 IGN1_MP
            INNER JOIN OITM OITM_MP ON IGN1_MP."ItemCode" = OITM_MP."ItemCode"
            INNER JOIN OITB OITB_MP ON OITM_MP."ItmsGrpCod" = OITB_MP."ItmsGrpCod"
        WHERE
            IGN1_MP."DocEntry" = OIGN."DocEntry"
            AND OITB_MP."ItmsGrpNam" = 'PT MATERIAL DE EMPAQUE'
            AND CASE
                WHEN INSTR (OITM_MP."ItemName", '(') > 0
                AND INSTR (OITM_MP."ItemName", ')') > INSTR (OITM_MP."ItemName", '(') THEN SUBSTRING(
                    OITM_MP."ItemName",
                    INSTR (OITM_MP."ItemName", '(') + 1,
                    INSTR (OITM_MP."ItemName", ')') - INSTR (OITM_MP."ItemName", '(') - 1
                )
                ELSE NULL
            END = CASE
                WHEN INSTR (OITM."ItemName", '(') > 0
                AND INSTR (OITM."ItemName", ')') > INSTR (OITM."ItemName", '(') THEN SUBSTRING(
                    OITM."ItemName",
                    INSTR (OITM."ItemName", '(') + 1,
                    INSTR (OITM."ItemName", ')') - INSTR (OITM."ItemName", '(') - 1
                )
                ELSE NULL
            END
    ) AS "Cto. un. ME PT",
    -- Total costo de material de empaque
    (
        (
            SELECT
                IGN1_MP."Price"
            FROM
                IGN1 IGN1_MP
                INNER JOIN OITM OITM_MP ON IGN1_MP."ItemCode" = OITM_MP."ItemCode"
                INNER JOIN OITB OITB_MP ON OITM_MP."ItmsGrpCod" = OITB_MP."ItmsGrpCod"
            WHERE
                IGN1_MP."DocEntry" = OIGN."DocEntry"
                AND OITB_MP."ItmsGrpNam" = 'PT MATERIAL DE EMPAQUE'
                AND CASE
                    WHEN INSTR (OITM_MP."ItemName", '(') > 0
                    AND INSTR (OITM_MP."ItemName", ')') > INSTR (OITM_MP."ItemName", '(') THEN SUBSTRING(
                        OITM_MP."ItemName",
                        INSTR (OITM_MP."ItemName", '(') + 1,
                        INSTR (OITM_MP."ItemName", ')') - INSTR (OITM_MP."ItemName", '(') - 1
                    )
                    ELSE NULL
                END = CASE
                    WHEN INSTR (OITM."ItemName", '(') > 0
                    AND INSTR (OITM."ItemName", ')') > INSTR (OITM."ItemName", '(') THEN SUBSTRING(
                        OITM."ItemName",
                        INSTR (OITM."ItemName", '(') + 1,
                        INSTR (OITM."ItemName", ')') - INSTR (OITM."ItemName", '(') - 1
                    )
                    ELSE NULL
                END
        ) * CEIL(
            SUM(IGN1."Quantity") / COALESCE(
                TO_DECIMAL (
                    NULLIF(
                        SUBSTRING(
                            (
                                SELECT
                                    SUBSTRING(
                                        OITM_MP."ItemName",
                                        INSTR (OITM_MP."ItemName", '(') + 1,
                                        INSTR (OITM_MP."ItemName", ')') - INSTR (OITM_MP."ItemName", '(') - 1
                                    )
                                FROM
                                    IGN1 IGN1_MP
                                    INNER JOIN OITM OITM_MP ON IGN1_MP."ItemCode" = OITM_MP."ItemCode"
                                    INNER JOIN OITB OITB_MP ON OITM_MP."ItmsGrpCod" = OITB_MP."ItmsGrpCod"
                                WHERE
                                    IGN1_MP."DocEntry" = OIGN."DocEntry"
                                    AND OITB_MP."ItmsGrpNam" = 'PT MATERIAL DE EMPAQUE'
                                    AND CASE
                                        WHEN INSTR (OITM_MP."ItemName", '(') > 0
                                        AND INSTR (OITM_MP."ItemName", ')') > INSTR (OITM_MP."ItemName", '(') THEN SUBSTRING(
                                            OITM_MP."ItemName",
                                            INSTR (OITM_MP."ItemName", '(') + 1,
                                            INSTR (OITM_MP."ItemName", ')') - INSTR (OITM_MP."ItemName", '(') - 1
                                        )
                                        ELSE NULL
                                    END = CASE
                                        WHEN INSTR (OITM."ItemName", '(') > 0
                                        AND INSTR (OITM."ItemName", ')') > INSTR (OITM."ItemName", '(') THEN SUBSTRING(
                                            OITM."ItemName",
                                            INSTR (OITM."ItemName", '(') + 1,
                                            INSTR (OITM."ItemName", ')') - INSTR (OITM."ItemName", '(') - 1
                                        )
                                        ELSE NULL
                                    END
                            ),
                            1,
                            INSTR (
                                (
                                    SELECT
                                        SUBSTRING(
                                            OITM_MP."ItemName",
                                            INSTR (OITM_MP."ItemName", '(') + 1,
                                            INSTR (OITM_MP."ItemName", ')') - INSTR (OITM_MP."ItemName", '(') - 1
                                        )
                                    FROM
                                        IGN1 IGN1_MP
                                        INNER JOIN OITM OITM_MP ON IGN1_MP."ItemCode" = OITM_MP."ItemCode"
                                        INNER JOIN OITB OITB_MP ON OITM_MP."ItmsGrpCod" = OITB_MP."ItmsGrpCod"
                                    WHERE
                                        IGN1_MP."DocEntry" = OIGN."DocEntry"
                                        AND OITB_MP."ItmsGrpNam" = 'PT MATERIAL DE EMPAQUE'
                                        AND CASE
                                            WHEN INSTR (OITM_MP."ItemName", '(') > 0
                                            AND INSTR (OITM_MP."ItemName", ')') > INSTR (OITM_MP."ItemName", '(') THEN SUBSTRING(
                                                OITM_MP."ItemName",
                                                INSTR (OITM_MP."ItemName", '(') + 1,
                                                INSTR (OITM_MP."ItemName", ')') - INSTR (OITM_MP."ItemName", '(') - 1
                                            )
                                            ELSE NULL
                                        END = CASE
                                            WHEN INSTR (OITM."ItemName", '(') > 0
                                            AND INSTR (OITM."ItemName", ')') > INSTR (OITM."ItemName", '(') THEN SUBSTRING(
                                                OITM."ItemName",
                                                INSTR (OITM."ItemName", '(') + 1,
                                                INSTR (OITM."ItemName", ')') - INSTR (OITM."ItemName", '(') - 1
                                            )
                                            ELSE NULL
                                        END
                                ),
                                'kg'
                            ) - 1
                        ),
                        ''
                    ),
                    18,
                    4
                ),
                1
            )
        )
    ) AS "Total Cto. ME PT",
    (
        IGN1."LineTotal" + (
            (
                SELECT
                    IGN1_MP."Price"
                FROM
                    IGN1 IGN1_MP
                    INNER JOIN OITM OITM_MP ON IGN1_MP."ItemCode" = OITM_MP."ItemCode"
                    INNER JOIN OITB OITB_MP ON OITM_MP."ItmsGrpCod" = OITB_MP."ItmsGrpCod"
                WHERE
                    IGN1_MP."DocEntry" = OIGN."DocEntry"
                    AND OITB_MP."ItmsGrpNam" = 'PT MATERIAL DE EMPAQUE'
                    AND CASE
                        WHEN INSTR (OITM_MP."ItemName", '(') > 0
                        AND INSTR (OITM_MP."ItemName", ')') > INSTR (OITM_MP."ItemName", '(') THEN SUBSTRING(
                            OITM_MP."ItemName",
                            INSTR (OITM_MP."ItemName", '(') + 1,
                            INSTR (OITM_MP."ItemName", ')') - INSTR (OITM_MP."ItemName", '(') - 1
                        )
                        ELSE NULL
                    END = CASE
                        WHEN INSTR (OITM."ItemName", '(') > 0
                        AND INSTR (OITM."ItemName", ')') > INSTR (OITM."ItemName", '(') THEN SUBSTRING(
                            OITM."ItemName",
                            INSTR (OITM."ItemName", '(') + 1,
                            INSTR (OITM."ItemName", ')') - INSTR (OITM."ItemName", '(') - 1
                        )
                        ELSE NULL
                    END
            ) * CEIL(
                SUM(IGN1."Quantity") / COALESCE(
                    TO_DECIMAL (
                        NULLIF(
                            SUBSTRING(
                                (
                                    SELECT
                                        SUBSTRING(
                                            OITM_MP."ItemName",
                                            INSTR (OITM_MP."ItemName", '(') + 1,
                                            INSTR (OITM_MP."ItemName", ')') - INSTR (OITM_MP."ItemName", '(') - 1
                                        )
                                    FROM
                                        IGN1 IGN1_MP
                                        INNER JOIN OITM OITM_MP ON IGN1_MP."ItemCode" = OITM_MP."ItemCode"
                                        INNER JOIN OITB OITB_MP ON OITM_MP."ItmsGrpCod" = OITB_MP."ItmsGrpCod"
                                    WHERE
                                        IGN1_MP."DocEntry" = OIGN."DocEntry"
                                        AND OITB_MP."ItmsGrpNam" = 'PT MATERIAL DE EMPAQUE'
                                        AND CASE
                                            WHEN INSTR (OITM_MP."ItemName", '(') > 0
                                            AND INSTR (OITM_MP."ItemName", ')') > INSTR (OITM_MP."ItemName", '(') THEN SUBSTRING(
                                                OITM_MP."ItemName",
                                                INSTR (OITM_MP."ItemName", '(') + 1,
                                                INSTR (OITM_MP."ItemName", ')') - INSTR (OITM_MP."ItemName", '(') - 1
                                            )
                                            ELSE NULL
                                        END = CASE
                                            WHEN INSTR (OITM."ItemName", '(') > 0
                                            AND INSTR (OITM."ItemName", ')') > INSTR (OITM."ItemName", '(') THEN SUBSTRING(
                                                OITM."ItemName",
                                                INSTR (OITM."ItemName", '(') + 1,
                                                INSTR (OITM."ItemName", ')') - INSTR (OITM."ItemName", '(') - 1
                                            )
                                            ELSE NULL
                                        END
                                ),
                                1,
                                INSTR (
                                    (
                                        SELECT
                                            SUBSTRING(
                                                OITM_MP."ItemName",
                                                INSTR (OITM_MP."ItemName", '(') + 1,
                                                INSTR (OITM_MP."ItemName", ')') - INSTR (OITM_MP."ItemName", '(') - 1
                                            )
                                        FROM
                                            IGN1 IGN1_MP
                                            INNER JOIN OITM OITM_MP ON IGN1_MP."ItemCode" = OITM_MP."ItemCode"
                                            INNER JOIN OITB OITB_MP ON OITM_MP."ItmsGrpCod" = OITB_MP."ItmsGrpCod"
                                        WHERE
                                            IGN1_MP."DocEntry" = OIGN."DocEntry"
                                            AND OITB_MP."ItmsGrpNam" = 'PT MATERIAL DE EMPAQUE'
                                            AND CASE
                                                WHEN INSTR (OITM_MP."ItemName", '(') > 0
                                                AND INSTR (OITM_MP."ItemName", ')') > INSTR (OITM_MP."ItemName", '(') THEN SUBSTRING(
                                                    OITM_MP."ItemName",
                                                    INSTR (OITM_MP."ItemName", '(') + 1,
                                                    INSTR (OITM_MP."ItemName", ')') - INSTR (OITM_MP."ItemName", '(') - 1
                                                )
                                                ELSE NULL
                                            END = CASE
                                                WHEN INSTR (OITM."ItemName", '(') > 0
                                                AND INSTR (OITM."ItemName", ')') > INSTR (OITM."ItemName", '(') THEN SUBSTRING(
                                                    OITM."ItemName",
                                                    INSTR (OITM."ItemName", '(') + 1,
                                                    INSTR (OITM."ItemName", ')') - INSTR (OITM."ItemName", '(') - 1
                                                )
                                                ELSE NULL
                                            END
                                    ),
                                    'kg'
                                ) - 1
                            ),
                            ''
                        ),
                        18,
                        4
                    ),
                    1
                )
            )
        )
    ) AS "Total art. + ME PT"
FROM
    OIGN
    INNER JOIN IGN1 ON OIGN."DocEntry" = IGN1."DocEntry"
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
    AND OIGN."DocDate" BETWEEN '2025-01-01' AND '2025-12-31'
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
    IGN1."LineTotal"
ORDER BY
    OIGN."DocNum" DESC;