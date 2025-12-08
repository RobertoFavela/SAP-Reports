SELECT
    TO_DATE (ORCT."DocDate") AS "Fecha Poliza",
    NNM1."SeriesName" AS "Tipo poliza",
    ORCT."DocNum" AS "Numero Poliza",
    ECM2."ReportID" AS "Folio Fiscal",
    -- Factura
    OINV."DocEntry" AS "Ref. Factura",
    OINV."DocNum" AS "No. Factura",
    TO_DATE (OINV."DocDate") AS "Fecha",
    -- Cliente
    OINV."LicTradNum" AS "RFC",
    OINV."CardName" AS "Cliente",
    INV1."Dscription" AS "Concepto",

    CASE
        WHEN INV1."TaxCode" = 'A2' THEN '16%'
        WHEN INV1."TaxCode" = 'A1' THEN '8%'
        WHEN INV1."TaxCode" = 'A0' THEN '0%'
        WHEN INV1."TaxCode" = 'AE' THEN 'Exento'
    END AS "TASA",

    OINV."DocCur" AS "Moneda",

    -- PESOS MEXICANOS
    CASE
        WHEN ORCT."DocCurr" = 'USD' THEN TO_DECIMAL((RCT2."SumApplied" / OINV."DocRate") * ORCT."DocRate", 18, 4)
        ELSE NULL
    END AS "Monto Pesos",

    
    CASE
        WHEN INV1."TaxCode" = 'A2' THEN TO_DECIMAL (INV1."LineTotal" * 0.16, 18, 4)
        WHEN INV1."TaxCode" = 'A1' THEN TO_DECIMAL (INV1."LineTotal" * 0.08, 18, 4)
        ELSE NULL
    END AS "IVA MXP",

    INV1."LineTotal" AS "TOTAL MXP",

    CASE
        WHEN OINV."DocCur" = 'MXP' THEN TO_DECIMAL (ORTT."Rate", 18, 4)
        ELSE TO_DECIMAL (OINV."DocRate", 18, 4)
    END AS "TC",
    -- DOLARES AMERICANOS
    TO_DECIMAL (
        INV1."LineTotal" / CASE
            WHEN OINV."DocCur" = 'MXP' THEN ORTT."Rate"
            ELSE OINV."DocRate"
        END,
        18,
        4
    ) AS "Importe USD",
    CASE
        WHEN INV1."TaxCode" = 'A2' THEN (
            (
                TO_DECIMAL (
                    INV1."LineTotal" / CASE
                        WHEN OINV."DocCur" = 'MXP' THEN ORTT."Rate"
                        ELSE OINV."DocRate"
                    END,
                    18,
                    4
                )
            ) * 0.16
        )
        WHEN INV1."TaxCode" = 'A1' THEN (
            (
                TO_DECIMAL (
                    INV1."LineTotal" / CASE
                        WHEN OINV."DocCur" = 'MXP' THEN ORTT."Rate"
                        ELSE OINV."DocRate"
                    END,
                    18,
                    4
                )
            ) * 0.08
        )
        ELSE NULL
    END AS "IVA USD",
    TO_DATE (ORCT."DocDate") AS "Fecha de cobro",
    CASE
        WHEN ORCT."TrsfrSum" > 0 THEN 'Transferencia'
        WHEN ORCT."CredSumSy" > 0 THEN 'Crédito'
        WHEN ORCT."CheckSum" > 0 THEN 'Cheque'
        WHEN ORCT."CashSum" > 0 THEN 'Efectivo'
        ELSE NULL
    END AS "Forma de pago",
    TRIM(
        SUBSTRING(
            OACT."AcctName",
            1,
            INSTR (OACT."AcctName", 'CTA') - 1
        )
    ) AS "Banco",
    TRIM(
        SUBSTRING(
            OACT."AcctName",
            INSTR (OACT."AcctName", 'CTA') + 4,
            LENGTH (OACT."AcctName")
        )
    ) AS "Cuenta",
    ORCT."DocTotal" AS "Deposito Bancos"
FROM ORCT
    INNER JOIN RCT2 ON RCT2."DocNum" = ORCT."DocEntry"
    AND RCT2."InvType" = 13
    
    INNER JOIN OINV ON OINV."DocEntry" = RCT2."DocEntry"
    AND OINV."CANCELED" = 'N'
    INNER JOIN INV1 ON OINV."DocEntry" = INV1."DocEntry"
    
    LEFT JOIN ECM2 ON ECM2."ObjectID" = 'RF ' || TO_NVARCHAR (OINV."DocNum")
    
    LEFT JOIN OPYM ON OINV."PeyMethod" = OPYM."PayMethCod"
    
    LEFT JOIN ODSC ON OPYM."BnkDflt" = ODSC."BankCode"
    
    LEFT JOIN OACT ON ORCT."TrsfrAcct" = OACT."AcctCode"
    
    LEFT JOIN ORTT ON ORTT."RateDate" = OINV."DocDate"
    AND ORTT."Currency" = 'USD'
    
    INNER JOIN NNM1 ON ORCT."Series" = NNM1."Series"

WHERE
    ORCT."Canceled" = 'N'
    -- Filtro de fechas
    -- ORCT."DocDate" BETWEEN '2024-09-01' AND '2024-09-30'
    -- Pagos de referencia para prueba
    -- AND ORCT."DocNum" IN ('100', '101', '102')

GROUP BY
    ORCT."DocDate",
    NNM1."SeriesName",
    ORCT."DocNum",
    ECM2."ReportID",
    OINV."DocEntry",
    OINV."DocNum",
    OINV."DocDate",
    OINV."LicTradNum",
    OINV."CardName",
    INV1."Dscription",
    INV1."TaxCode",
    INV1."LineTotal",
    OINV."DocCur",
    OINV."DocRate",
    ORTT."Rate",
    ORCT."DocDate",
    ORCT."DocTotal",
    OACT."AcctName",
    ORCT."TrsfrSum",
    ORCT."CredSumSy",
    ORCT."CheckSum",
    ORCT."CashSum",
    ORCT."DocCurr",
    RCT2."SumApplied",
    ORCT."DocRate"

ORDER BY
    ORCT."DocNum" DESC;
