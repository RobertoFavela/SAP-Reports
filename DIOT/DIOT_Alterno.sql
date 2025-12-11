(
    SELECT
        'Consulta 1' AS "Consulta",
        OCRD."CardCode" AS "Proveedor",
        OCRD."CardName" AS "Nombre",
        OCRD."LicTradNum" AS "RFC",

        -- Asiento
        OJDT."Number" AS "No Asiento",
        OJDT."TransId" AS "Id Asiento",

        -- Pago
        OVPM."DocNum" AS "No Pago",

        CASE 
            WHEN OVPM."Canceled" = 'Y' THEN 'Cancelado'
            ELSE ''
        END AS "Estado",
        
        -- Cuenta
        JDT1."OrgAccName" AS "Cuenta mayor",
        JDT1."Account" AS "Cuenta",
        JDT1."Debit",
        JDT1."Credit",

        -- FACTURA
        OPCH."DocEntry" AS "Id Factura",
        OPCH."DocNum" AS "No Factura",
        OPCH."U_UDF_UUID" AS "UDF_UUID",
        -- RETENCIONES
        RET."Ret_1I",
        RET."Ret_1V",
        RET."Ret_2V",
        RET."Ret_3V",
        RET."Ret_4V",
        RET."Ret_FV",

        -- NOMBRE DEL BANCO
        CASE
            WHEN OVPM."TrsfrAcct" IS NOT NULL AND OVPM."TrsfrAcct" <> '' THEN OACT_Trsf."AcctName"
            WHEN OVPM."CheckAcct" IS NOT NULL AND OVPM."CheckAcct" <> '' THEN OACT_Chk."AcctName"
            WHEN OVPM."CashAcct"  IS NOT NULL AND OVPM."CashAcct" <> '' THEN OACT_Cash."AcctName"
        END AS "Banco"


    FROM OJDT
        INNER JOIN JDT1 ON JDT1."TransId" = OJDT."TransId"

        LEFT JOIN OVPM ON OJDT."BaseRef" = OVPM."DocNum" -- Pago efectuado
        LEFT JOIN VPM2 ON OVPM."DocEntry" = VPM2."DocNum" -- DOCUMENTOS RELACIONADOS AL PAGO
        LEFT JOIN OPCH ON VPM2."DocEntry" = OPCH."DocEntry" -- FACTURA PROVEEDOR SEGÚN EL DOCENTRY
        LEFT JOIN PCH1 ON OPCH."DocEntry" = PCH1."DocEntry" -- LINEAS DE LA FACTURA
        LEFT JOIN PCH5 ON OPCH."DocEntry" = PCH5."AbsEntry" -- RETENCIONES DE LA FACTURA
        LEFT JOIN OWHT ON PCH5."WTCode" = OWHT."WTCode" -- DESCRIPCIÓN DE RETENCIONES
        LEFT JOIN OCRD ON OPCH."CardCode" = OCRD."CardCode" -- PROVEEDOR

        LEFT JOIN OACT ON OVPM."TrsfrAcct" = OACT."AcctCode"

                LEFT JOIN OACT OACT_Trsf ON OVPM."TrsfrAcct" = OACT_Trsf."AcctCode"
        LEFT JOIN OACT OACT_Chk  ON OVPM."CheckAcct" = OACT_Chk."AcctCode"
        LEFT JOIN OACT OACT_Cash ON OVPM."CashAcct"  = OACT_Cash."AcctCode"

        LEFT JOIN (
            SELECT 
                PCH5."AbsEntry",
                SUM(CASE WHEN PCH5."WTCode" = '1I' THEN PCH5."WTAmnt" ELSE 0 END) AS "Ret_1I",
                SUM(CASE WHEN PCH5."WTCode" = '1V' THEN PCH5."WTAmnt" ELSE 0 END) AS "Ret_1V",
                SUM(CASE WHEN PCH5."WTCode" = '2V' THEN PCH5."WTAmnt" ELSE 0 END) AS "Ret_2V",
                SUM(CASE WHEN PCH5."WTCode" = '3V' THEN PCH5."WTAmnt" ELSE 0 END) AS "Ret_3V",
                SUM(CASE WHEN PCH5."WTCode" = '4V' THEN PCH5."WTAmnt" ELSE 0 END) AS "Ret_4V",
                SUM(CASE WHEN PCH5."WTCode" = 'FV' THEN PCH5."WTAmnt" ELSE 0 END) AS "Ret_FV"
            FROM PCH5
            GROUP BY PCH5."AbsEntry"
        ) AS RET ON RET."AbsEntry" = OPCH."DocEntry"


    WHERE 
        OJDT."RefDate" BETWEEN '2025-09-01' AND '2025-09-30'
        -- AND OVPM."DocNum" = '7499'
        
        AND (OJDT."TransType" = 46
        OR OJDT."TransId" IN (
            SELECT j."TransId"
            FROM JDT1 j
            WHERE j."Account" = '1118-001-000-00'
        ))

    ORDER BY
        OVPM."DocNum" DESC
)

/*UNION ALL
(
    SELECT
        'Consulta 2' AS "Consulta",
        
        -- Asiento
        OJDT."Number" AS "No Asiento",
        OJDT."TransId" AS "Id Asiento",
        OJDT."TransType",

        -- Pago
        OVPM."DocNum" AS "No Pago",

        CASE 
            WHEN OVPM."Canceled" = 'Y' THEN 'Cancelado'
            ELSE ''
        END AS "Estado",
        
        -- Cuenta
        JDT1."OrgAccName" AS "Cuenta mayor",
        JDT1."Account" AS "Cuenta",

        CASE
            WHEN JDT1."Credit" = 0 THEN 
                TO_DECIMAL(
                    (PCH1."LineTotal" + PCH1."VatSum")
                    - CASE WHEN PCH_COUNT."TotalLineas" > 0
                        THEN ( (COALESCE(OPCH."DpmAmnt",0) + COALESCE(OPCH."DpmVat",0)) / PCH_COUNT."TotalLineas" )
                        ELSE 0
                    END
                    + CASE WHEN PCH_COUNT."TotalLineas" > 0
                        THEN ( COALESCE(OVPM."NoDocSum",0) / PCH_COUNT."TotalLineas" )
                        ELSE 0
                    END,
                    18, 4
                )
        END AS "Debito del asiento",

        CASE
            WHEN JDT1."Debit" = 0 THEN 
                TO_DECIMAL(
                    (PCH1."LineTotal" + PCH1."VatSum")
                    - CASE WHEN PCH_COUNT."TotalLineas" > 0
                        THEN ( (COALESCE(OPCH."DpmAmnt",0) + COALESCE(OPCH."DpmVat",0)) / PCH_COUNT."TotalLineas" )
                        ELSE 0
                    END
                    + CASE WHEN PCH_COUNT."TotalLineas" > 0
                        THEN ( COALESCE(OVPM."NoDocSum",0) / PCH_COUNT."TotalLineas" )
                        ELSE 0
                    END,
                    18, 4
                )
        END AS "Credito del asiento",

        -- FACTURA
        OPCH."DocEntry" AS "Id Factura",
        OPCH."DocNum" AS "No Factura",
        OPCH."U_UDF_UUID" AS "UDF_UUID"

    FROM OJDT
        INNER JOIN JDT1 ON JDT1."TransId" = OJDT."TransId"

        LEFT JOIN OVPM ON OJDT."BaseRef" = OVPM."DocNum"
        LEFT JOIN VPM2 ON OVPM."DocEntry" = VPM2."DocNum"
        LEFT JOIN OPCH ON VPM2."DocEntry" = OPCH."DocEntry"
        LEFT JOIN PCH1 ON OPCH."DocEntry" = PCH1."DocEntry"

        LEFT JOIN (
            SELECT "DocEntry", COUNT(*) AS "TotalLineas"
            FROM PCH1
            GROUP BY "DocEntry"
        ) AS PCH_COUNT ON PCH_COUNT."DocEntry" = OPCH."DocEntry"

        LEFT JOIN PCH5 ON OPCH."DocEntry" = PCH5."AbsEntry"
        LEFT JOIN OWHT ON PCH5."WTCode" = OWHT."WTCode"
        LEFT JOIN OCRD ON OPCH."CardCode" = OCRD."CardCode"

    WHERE 
        JDT1."SourceLine" IN (-1, -2)
        AND OJDT."RefDate" BETWEEN '2025-09-01' AND '2025-09-30'
        -- AND OVPM."DocNum" = '7499'
        AND (
            OJDT."TransType" = 46
            OR OJDT."TransId" IN (
                SELECT j."TransId"
                FROM JDT1 j
                WHERE j."Account" = '1118-001-000-00'
            )
        )
)
ORDER BY "No Asiento" DESC*/