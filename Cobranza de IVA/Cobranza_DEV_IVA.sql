WITH tc_calculo AS (
    SELECT
        ORCT."DocEntry",
        CASE
            WHEN ORCT."DocCurr" = 'MXP' THEN TO_DECIMAL(NULLIF(ORTT."Rate", 0), 18, 4)
            WHEN ORCT."DocCurr" = 'USD' THEN TO_DECIMAL(NULLIF(ORCT."DocRate", 0), 18, 4)
            ELSE NULL
        END AS "TC"
    FROM ORCT
    LEFT JOIN ORTT ON ORTT."RateDate" = ORCT."DocDate"
)

SELECT

    -- Poliza
    TO_DATE(ORCT."DocDate") AS "Fecha Poliza",
    NNM1."SeriesName" AS "Tipo Poliza",
    ORCT."DocNum" AS "Numero Poliza",

    -- Documento referenciado ( Factura / Nota de credito)
    COALESCE(ECM2_Factura."ReportID", ECM2_Credito."ReportID") AS "Folio Fiscal",
    COALESCE(OINV."DocNum", ORIN."DocNum") AS "No. Documento",

    CASE RCT2."InvType"
        WHEN 13 THEN 'Factura de cliente'
        WHEN 14 THEN 'Nota de crédito de cliente'
        ELSE 'Otro'
    END AS "Tipo Documento",

    COALESCE(TO_DATE(OINV."DocDate"), TO_DATE(ORIN."DocDate")) AS "Fecha Documento",

    -- Cliente
    OCRD."LicTradNum" AS "RFC",
    ORCT."CardName" AS "Cliente",

    -- Moneda
    ORCT."DocCurr" AS "Moneda",

    CASE
        WHEN ORCT."DocCurr" = 'MXP' THEN RCT2."SumApplied"
        WHEN ORCT."DocCurr" = 'USD' THEN 
            CASE
                WHEN RCT2."InvType" = '13' THEN
                    TO_DECIMAL((RCT2."SumApplied" / NULLIF(OINV."DocRate", 0)) * ORCT."DocRate", 18, 4)
                WHEN RCT2."InvType" = '14' THEN
                    TO_DECIMAL((RCT2."SumApplied" / NULLIF(ORIN."DocRate", 0)) * ORCT."DocRate", 18, 4)
            END
    END AS "Monto MXP", 

    -- Como texto para conservar los cuatro decimales, incluso cuando terminen en cero.
    TO_VARCHAR(TO_DECIMAL(tc_calculo."TC", 18, 4), '0.0000') AS "TC",

    CASE
        WHEN ORCT."DocCurr" = 'MXP' THEN TO_DECIMAL(RCT2."SumApplied" / NULLIF(tc_calculo."TC", 0), 18, 4)
        -- AppliedFC es el importe aplicado en moneda extranjera (USD),
        -- mientras que SumApplied está expresado en moneda local (MXP).
        WHEN ORCT."DocCurr" = 'USD' THEN TO_DECIMAL(RCT2."AppliedFC", 18, 4)
    END AS "Monto USD",

            
    

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

    -- Total
    ORCT."DocTotal" AS "Deposito Bancos"

FROM ORCT
    INNER JOIN RCT2 ON ORCT."DocEntry" = RCT2."DocNum"

    -- Serie del pago recibido, Tipo de poliza
    INNER JOIN NNM1 ON ORCT."Series" = NNM1."Series"

    -- Factura relacionada
    LEFT JOIN OINV ON RCT2."DocEntry" = OINV."DocEntry" AND OINV."CANCELED" = 'N'

    -- Credito relacionado
    LEFT JOIN ORIN ON RCT2."DocEntry" = ORIN."DocEntry" AND ORIN."CANCELED" = 'N' 
    
    -- Folio fiscal
    LEFT JOIN ECM2 ECM2_Factura ON ECM2_Factura."ObjectID" = 'RF ' || TO_NVARCHAR(OINV."DocNum")
    LEFT JOIN ECM2 ECM2_Credito ON ECM2_Credito."ObjectID" = 'RC ' || TO_NVARCHAR(ORIN."DocNum")

    -- Cliente
    INNER JOIN OCRD ON OCRD."CardCode" = ORCT."CardCode"

    -- Banco
    LEFT JOIN OACT ON ORCT."TrsfrAcct" = OACT."AcctCode"

    -- Tipo de cambio
    LEFT JOIN tc_calculo ON tc_calculo."DocEntry" = ORCT."DocEntry"

WHERE 
    ORCT."Canceled" = 'N'

ORDER BY
    ORCT."DocNum" DESC;
