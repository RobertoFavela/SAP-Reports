-- Paréntesis del artículo
    CASE
        WHEN INSTR(OITM."ItemName", '(') > 0 
         AND INSTR(OITM."ItemName", ')') > INSTR(OITM."ItemName", '(')
        THEN SUBSTRING(
                OITM."ItemName",
                INSTR(OITM."ItemName", '(') + 1,
                INSTR(OITM."ItemName", ')') - INSTR(OITM."ItemName", '(') - 1
             )
        ELSE NULL
    END AS "Etiqueta_Parentesis",

-- Cantidad salida (facturado)
    /*
    COALESCE((
        SELECT SUM(IBT1."Quantity")
        FROM IBT1
        WHERE IBT1."BatchNum" = OIGN."Ref2"
          AND IBT1."ItemCode" = IGN1."ItemCode"
          AND IBT1."Direction" = 1
    ), 0) AS "KG Facturados",
    */


     -- Nombre del material de empaque
    /*
    (
        SELECT OITM_MP."ItemName"
        FROM IGN1 IGN1_MP
        INNER JOIN OITM OITM_MP ON IGN1_MP."ItemCode" = OITM_MP."ItemCode"
        INNER JOIN OITB OITB_MP ON OITM_MP."ItmsGrpCod" = OITB_MP."ItmsGrpCod"
        WHERE
            IGN1_MP."DocEntry" = OIGN."DocEntry"
            AND OITB_MP."ItmsGrpNam" = 'PT MATERIAL DE EMPAQUE'
            AND CASE
                    WHEN INSTR(OITM_MP."ItemName", '(') > 0 
                     AND INSTR(OITM_MP."ItemName", ')') > INSTR(OITM_MP."ItemName", '(')
                    THEN SUBSTRING(
                            OITM_MP."ItemName",
                            INSTR(OITM_MP."ItemName", '(') + 1,
                            INSTR(OITM_MP."ItemName", ')') - INSTR(OITM_MP."ItemName", '(') - 1
                         )
                    ELSE NULL
                END = 
                CASE
                    WHEN INSTR(OITM."ItemName", '(') > 0 
                     AND INSTR(OITM."ItemName", ')') > INSTR(OITM."ItemName", '(')
                    THEN SUBSTRING(
                            OITM."ItemName",
                            INSTR(OITM."ItemName", '(') + 1,
                            INSTR(OITM."ItemName", ')') - INSTR(OITM."ItemName", '(') - 1
                         )
                    ELSE NULL
                END
    ) AS "Material de Empaque",

    

 -- Subquery: capacidad (número antes de 'kg')
 
COALESCE(
    TO_DECIMAL(
        NULLIF(
            SUBSTRING(
                (
                    SELECT 
                        SUBSTRING(
                            OITM_MP."ItemName",
                            INSTR(OITM_MP."ItemName", '(') + 1,
                            INSTR(OITM_MP."ItemName", ')') - INSTR(OITM_MP."ItemName", '(') - 1
                        )
                    FROM IGN1 IGN1_MP
                    INNER JOIN OITM OITM_MP ON IGN1_MP."ItemCode" = OITM_MP."ItemCode"
                    INNER JOIN OITB OITB_MP ON OITM_MP."ItmsGrpCod" = OITB_MP."ItmsGrpCod"
                    WHERE
                        IGN1_MP."DocEntry" = OIGN."DocEntry"
                        AND OITB_MP."ItmsGrpNam" = 'PT MATERIAL DE EMPAQUE'
                        AND CASE
                                WHEN INSTR(OITM_MP."ItemName", '(') > 0 
                                 AND INSTR(OITM_MP."ItemName", ')') > INSTR(OITM_MP."ItemName", '(')
                                THEN SUBSTRING(
                                        OITM_MP."ItemName",
                                        INSTR(OITM_MP."ItemName", '(') + 1,
                                        INSTR(OITM_MP."ItemName", ')') - INSTR(OITM_MP."ItemName", '(') - 1
                                     )
                                ELSE NULL
                            END = 
                            CASE
                                WHEN INSTR(OITM."ItemName", '(') > 0 
                                 AND INSTR(OITM."ItemName", ')') > INSTR(OITM."ItemName", '(')
                                THEN SUBSTRING(
                                        OITM."ItemName",
                                        INSTR(OITM."ItemName", '(') + 1,
                                        INSTR(OITM."ItemName", ')') - INSTR(OITM."ItemName", '(') - 1
                                     )
                                ELSE NULL
                            END
                ),
                1,
                INSTR(
                    (
                        SELECT 
                            SUBSTRING(
                                OITM_MP."ItemName",
                                INSTR(OITM_MP."ItemName", '(') + 1,
                                INSTR(OITM_MP."ItemName", ')') - INSTR(OITM_MP."ItemName", '(') - 1
                            )
                        FROM IGN1 IGN1_MP
                        INNER JOIN OITM OITM_MP ON IGN1_MP."ItemCode" = OITM_MP."ItemCode"
                        INNER JOIN OITB OITB_MP ON OITM_MP."ItmsGrpCod" = OITB_MP."ItmsGrpCod"
                        WHERE
                            IGN1_MP."DocEntry" = OIGN."DocEntry"
                            AND OITB_MP."ItmsGrpNam" = 'PT MATERIAL DE EMPAQUE'
                            AND CASE
                                    WHEN INSTR(OITM_MP."ItemName", '(') > 0 
                                     AND INSTR(OITM_MP."ItemName", ')') > INSTR(OITM_MP."ItemName", '(')
                                    THEN SUBSTRING(
                                            OITM_MP."ItemName",
                                            INSTR(OITM_MP."ItemName", '(') + 1,
                                            INSTR(OITM_MP."ItemName", ')') - INSTR(OITM_MP."ItemName", '(') - 1
                                         )
                                    ELSE NULL
                                END = 
                                CASE
                                    WHEN INSTR(OITM."ItemName", '(') > 0 
                                     AND INSTR(OITM."ItemName", ')') > INSTR(OITM."ItemName", '(')
                                    THEN SUBSTRING(
                                            OITM."ItemName",
                                            INSTR(OITM."ItemName", '(') + 1,
                                            INSTR(OITM."ItemName", ')') - INSTR(OITM."ItemName", '(') - 1
                                         )
                                    ELSE NULL
                                END
                    ),
                    'kg'
                ) - 1
            )
        , '')
    )
, 0) AS "Capacidad Empaque",
*/