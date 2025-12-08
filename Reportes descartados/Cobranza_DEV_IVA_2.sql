SELECT
    -- Pago
    TO_DATE(ORCT."DocDate") AS "Fecha Poliza",
    NNM1."SeriesName" AS "Tipo Poliza",
    ORCT."DocNum" AS "Numero Poliza",

    ECM2."ReportID" AS "Folio Fiscal",
    OINV."DocEntry" AS "Ref. Factura",
    OINV."DocNum" AS "No. Factura",
    TO_DATE(OINV."DocDate") AS "Fecha Factura",

    -- Cliente
    OINV."LicTradNum" AS "RFC",
    OINV."CardName" AS "Cliente",

    ORCT."DocCurr" AS "Moneda",

/*
    CASE 
        WHEN OINV."DocRate" IS NULL THEN 
            CASE 
                WHEN ORCT."DocCurr" = 'MXP' THEN RCT2."SumApplied" 
                ELSE NULL 
            END 
        WHEN OINV."DocRate" IS NOT NULL THEN 
            CASE 
                WHEN ORCT."DocCurr" = 'USD' THEN TO_DECIMAL((RCT2."SumApplied" / OINV."DocRate") * ORCT."DocRate", 18, 4) 
                WHEN ORCT."DocCurr" = 'MXP' THEN RCT2."SumApplied" 
                ELSE NULL 
            END
    END AS "Importe MXP",



    -- IMPORTE MXP
    
    CASE
        WHEN ORCT."DocCurr" = 'USD' THEN TO_DECIMAL((RCT2."SumApplied" / OINV."DocRate") * ORCT."DocRate", 18, 4)
        WHEN ORCT."DocCurr" = 'MXP' THEN RCT2."SumApplied"
        ELSE NULL
    END AS "Importe MXP",
*/
    -- Tipo de cambio
    CASE
        WHEN ORCT."DocCurr" = 'MXP' THEN TO_DECIMAL(ORTT."Rate", 18, 4)
        WHEN ORCT."DocCurr" = 'USD' THEN TO_DECIMAL(ORCT."DocRate", 18, 4)
        ELSE NULL
    END AS "TC",

    TO_DATE(ORCT."DocDate") AS "Fecha de cobro",

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
            INSTR(OACT."AcctName", 'CTA') - 1
        )
    ) AS "Banco",

    TRIM(
        SUBSTRING(
            OACT."AcctName",
            INSTR(OACT."AcctName", 'CTA') + 4,
            LENGTH(OACT."AcctName")
        )
    ) AS "Cuenta",

    ORCT."DocTotal" AS "Deposito Bancos"

    

FROM ORCT
    LEFT JOIN RCT2 ON RCT2."DocNum" = ORCT."DocEntry"
    AND RCT2."InvType" = 13

    LEFT JOIN OINV ON RCT2."DocEntry" = OINV."DocEntry"
    AND OINV."CANCELED" = 'N'

    LEFT JOIN INV1 ON OINV."DocEntry" = INV1."DocEntry"
    LEFT JOIN ECM2 ON ECM2."ObjectID" = 'RF ' || TO_NVARCHAR(OINV."DocNum")

    LEFT JOIN OPYM ON OINV."PeyMethod" = OPYM."PayMethCod"
    LEFT JOIN ODSC ON OPYM."BnkDflt" = ODSC."BankCode"
    LEFT JOIN OACT ON ORCT."TrsfrAcct" = OACT."AcctCode"
    LEFT JOIN ORTT ON ORTT."RateDate" = OINV."DocDate"
    AND ORTT."Currency" = 'USD'

    INNER JOIN NNM1 ON ORCT."Series" = NNM1."Series"

WHERE
    ORCT."Canceled" = 'N'


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
    ORCT."DocCurr",
    ORTT."Rate",
    ORCT."DocRate",
    ORCT."DocTotal",
    RCT2."SumApplied",
    OACT."AcctName",
    ORCT."TrsfrSum",
    ORCT."CredSumSy",
    ORCT."CheckSum",
    ORCT."CashSum",
    OINV."DocRate"

ORDER BY
    ORCT."DocNum" DESC;
