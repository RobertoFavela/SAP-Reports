-- Calculo del tipo de cambio 
WITH tc_calculo AS (
    SELECT
        ORCT."DocEntry",
        CASE
            -- Cuando esta en pesos, SAP no muestra el tipo de cambio
            -- Asi que lo sacamos de la tabla ORTT, con la fecha del pago recibido
            WHEN ORCT."DocCurr" = 'MXP' THEN TO_DECIMAL(ORTT."Rate", 18, 4)

            -- Cuando esta en dolares, SAP si muestra el tipo de cambio
            -- Usamos ese mismo que se muestra en pago recibido
            WHEN ORCT."DocCurr" = 'USD' THEN TO_DECIMAL(ORCT."DocRate", 18, 4)
            ELSE NULL
        END AS "TC"

    -- Tabla de pagos recibidos
    FROM ORCT

    --Unimos igualando la fecha del pago, con la del tipo de cambio
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
    COALESCE(TO_DATE(OINV."DocDate"), TO_DATE(ORIN."DocDate")) AS "Fecha Documento Referenciado",

    -- Cliente
    OCRD."LicTradNum" AS "RFC",
    ORCT."CardName" AS "Cliente",

    -- Moneda
    ORCT."DocCurr" AS "Moneda",

    /*
    Monto en pasos

    SAP nunca guarda nada en dolares, unicamente lo muestra en dolares en el mismo SAP, porque hace la conversion
    Pero si haces una consulta directa a db, te muestra en pesos, que es como guarda todo SAP
    Por lo que si una factura esta en dolares, hay que convertirla, pero SAP tiene un error
    Usa el tipo de cambio del documento al que hace referencia, y no en el que se realizo el pago
    Ex:
    Factura TC: 18.62 
    Pago TC: 18.32 
    
    10 USD, en documento de pago recibido
    En consulta a db muestra 186.2
    Cuando el valor real fue 183.2
    Utiliza el tipo de cambio incorrecto

    Por lo que causa mucha variarion
    Toca revertir esa conversion que hizo, y hacerla manual con el tc correcto 
    */
    CASE
        -- Si esta en pesos asi la dejamos
        WHEN ORCT."DocCurr" = 'MXP' THEN RCT2."SumApplied"

        -- Si esta en dolares
        WHEN ORCT."DocCurr" = 'USD' THEN 
            CASE
                -- Si viene desde una factura
                WHEN RCT2."InvType" = '13' THEN
                    /*
                    Convertimos la cantidad con al tipo de cambio de su documento original
                    Y volvemos a sacar la conversion con el tipo de cambio del pago
                    */
                    TO_DECIMAL((RCT2."SumApplied" / OINV."DocRate") * ORCT."DocRate", 18, 4)
                
                -- Si viene desde una nota de credito de cliente
                WHEN RCT2."InvType" = '14' THEN
                    /*
                    Convertimos la cantidad con el tipo de cambio de su documento original
                    Y volvemos a sacar la conversion con el tipo de cambio del pago
                    */
                    TO_DECIMAL((RCT2."SumApplied" / ORIN."DocRate") * ORCT."DocRate", 18, 4)
            END
    END AS "Monto MXP", 
    
    -- Tipo de cambio (usando el CTE)
    tc_calculo."TC",
    
    CASE
        -- Cuanto esta en pesos, convertimos al tipo de cambio correcto
        WHEN ORCT."DocCurr" = 'MXP' THEN TO_DECIMAL(RCT2."SumApplied" / tc_calculo."TC", 18, 4)

        -- Cuando esta en dolares
        WHEN ORCT."DocCurr" = 'USD' THEN 
            CASE 
                -- Y viene de una factura
                WHEN RCT2."InvType" = '13' THEN
                    -- Convertirmos con el tipo de cambio de la factura 
                    TO_DECIMAL((RCT2."SumApplied" / OINV."DocRate"), 18, 4)

                -- Y viene de una nota de credito
                WHEN RCT2."InvType" = '14' THEN
                    -- Convertimos con el tipo de cambio de la nota de credito
                    TO_DECIMAL((RCT2."SumApplied" / ORIN."DocRate"), 18, 4)
            END
    END AS "Monto USD",

    -- Fecha del documento pago recibido
    TO_DATE(ORCT."DocDate") AS "Fecha de cobro",

    /*
    Forma de pago,
    Dependiendo de que columna de la tabla de pago recibido sea mayor a cero
    Sera el tipo de forma de pago utilziado, no agregue validacion de que solo
    se utilice un tipo de pago, porque no creo que ese caso sea posible
    Igualmente si sucede, solo entrara al primer caso que se cumpla y ya
    */
    CASE
        WHEN ORCT."TrsfrSum" > 0 THEN 'Transferencia'
        WHEN ORCT."CredSumSy" > 0 THEN 'Crédito'
        WHEN ORCT."CheckSum" > 0 THEN 'Cheque'
        WHEN ORCT."CashSum" > 0 THEN 'Efectivo'
        ELSE NULL
    END AS "Forma de pago",

    /*
    En SAP en cuenta mayor, guardaron el nombre del banco, y su numero de cuenta
    Pero estos dos datos en un mismo string, asi que hay que separarlos
    En este caso la "regla comun", que no siempre se cumple pero es la mas razonable
    Es que el string tiene la forma de:
    "nombre de banco + CTA + no. de cuenta"
    Asi que separamos estos dos campos segun si estan antes o despues de CTA
    */
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

    -- Total del documento de pago recibido
    ORCT."DocTotal" AS "Deposito Bancos"

-- Pagos recibidos
FROM ORCT
    INNER JOIN RCT2 ON ORCT."DocEntry" = RCT2."DocNum"

    -- Serie del pago recibido, Tipo de poliza
    INNER JOIN NNM1 ON ORCT."Series" = NNM1."Series"

    -- Factura relacionada
    LEFT JOIN OINV ON RCT2."DocEntry" = OINV."DocEntry" AND OINV."CANCELED" = 'N'

    -- Credito relacionado
    LEFT JOIN ORIN ON RCT2."DocEntry" = ORIN."DocEntry" AND ORIN."CANCELED" = 'N' 
    
    -- Folio fiscal
    -- De factura
    LEFT JOIN ECM2 ECM2_Factura ON ECM2_Factura."ObjectID" = 'RF ' || TO_NVARCHAR(OINV."DocNum")
    -- De nota de credito
    LEFT JOIN ECM2 ECM2_Credito ON ECM2_Credito."ObjectID" = 'RC ' || TO_NVARCHAR(ORIN."DocNum")
    
    -- Cliente
    INNER JOIN OCRD ON OCRD."CardCode" = ORCT."CardCode"

    -- Banco
    LEFT JOIN OACT ON ORCT."TrsfrAcct" = OACT."AcctCode"

    -- Tipo de cambio
    LEFT JOIN tc_calculo ON tc_calculo."DocEntry" = ORCT."DocEntry"

-- Filtros
WHERE 

    -- Solo pagos recibidos que no esten cancelados
    ORCT."Canceled" = 'N'

    -- Filtro por numero de documentos
    -- AND ORCT."DocNum" = '2524'

    -- Filtro por documento de referencia
    -- AND RCT2."InvType" = '13' -- Factura
    -- AND RCT2."InvType" = '14' -- Nota de credito

    -- Filtro de fechas
    -- AND ORCT."DocDate" BETWEEN '2025-01-01' AND '2025-12-31'

-- Ordenado por
ORDER BY

    -- Numero de pago recibido mas reciente
    ORCT."DocNum" DESC;
