/*
==============================================================================================
            REPORTE DE COBRANZA DEV IVA A PARTIR DE LOS DOCUMENTOS DE FACTURAS
==============================================================================================
*/

SELECT
    -- Poliza
    TO_DATE (ORCT."DocDate") AS "Fecha Poliza",
    NNM1."SeriesName" AS "Tipo poliza",
    ORCT."DocNum" AS "Numero Poliza",
    
    -- Factura
    ECM2."ReportID" AS "Folio Fiscal",
    OINV."DocEntry" AS "Ref. Factura",
    OINV."DocNum" AS "No. Factura",
    TO_DATE (OINV."DocDate") AS "Fecha",
    
    -- Cliente
    OINV."LicTradNum" AS "RFC",
    OINV."CardName" AS "Cliente",
    
    -- Concepto de linea de factura
    INV1."Dscription" AS "Concepto",
    
    -- IVA
    CASE
        WHEN INV1."TaxCode" = 'A2' THEN '16%'
        WHEN INV1."TaxCode" = 'A1' THEN '8%'
        WHEN INV1."TaxCode" = 'A0' THEN '0%'
        WHEN INV1."TaxCode" = 'AE' THEN 'Exento'
    END AS "TASA",
    
    -- Moneda de documento
    OINV."DocCur" AS "Moneda",
    
    -- PESOS MEXICANOS
    INV1."LineTotal" AS "Importe MXP",
    
    -- Cantidad de IVA por linea
    CASE
        WHEN INV1."TaxCode" = 'A2' THEN TO_DECIMAL (INV1."LineTotal" * 0.16, 18, 4)
        WHEN INV1."TaxCode" = 'A1' THEN TO_DECIMAL (INV1."LineTotal" * 0.08, 18, 4)
        ELSE NULL
    END AS "IVA MXP",
    
    -- Total por linea
    INV1."LineTotal" AS "TOTAL MXP",
    
    -- Tipo de cambio del documento
    CASE
        -- Si esta en pesos, la factura no tiene OINV."DocRate"
        -- Lo buscamos directo desde ORTT con la fecha de la factura
        WHEN OINV."DocCur" = 'MXP' THEN TO_DECIMAL (ORTT."Rate", 18, 4)
        
        -- Cualquier otro DocCur, tomamos el tipo de cambio que nos da
        ELSE TO_DECIMAL (OINV."DocRate", 18, 4)
    END AS "TC",

    -- DOLARES AMERICANOS
    TO_DECIMAL (
        -- Dividimos el total de la linea, por
        INV1."LineTotal" / CASE
            -- El tipo de cambio de ORTT cuando la factura esta en pesos y no tiene DocCur
            WHEN OINV."DocCur" = 'MXP' THEN ORTT."Rate"

            -- Por el tipo de cambio de la factura cuando es cualquier otro DocCur
            ELSE OINV."DocRate"
        END,
        18,
        4 -- Cuatro decimales porque si no da variaciones, especialmente esta columna
    ) AS "Importe USD",
    
    -- Cantidad de IVA por linea en USD
    CASE
        -- Cuando es A2 (16%)
        WHEN INV1."TaxCode" = 'A2' THEN (
            (
                TO_DECIMAL (
                    -- Dividimos el total de la linea, por
                    INV1."LineTotal" / CASE
                        -- El tipo de cambio de ORTT cuando la factura esta en pesos y no tiene DocCur
                        WHEN OINV."DocCur" = 'MXP' THEN ORTT."Rate"

                        -- Por el tipo de cambio de la factura cuando es cualquier otro DocCur
                        ELSE OINV."DocRate"
                    END,
                    18,
                    4 -- Cuatro decimales porque si no da variaciones, especialmente esta columna
                )
            -- Y sacamos el 16% de esta cantidad
            ) * 0.16 
        )

        -- Cuando es A1 (8%)
        WHEN INV1."TaxCode" = 'A1' THEN (
            (
                TO_DECIMAL (
                    -- Dividimos el total de la linea por
                    INV1."LineTotal" / CASE
                        -- El tipo de cambio de ORTT cuando la factura esta en pesos y no tiene DocCur
                        WHEN OINV."DocCur" = 'MXP' THEN ORTT."Rate"

                        -- Por el tipo de cambio de la factura cuando es cualquier otro DocCur
                        ELSE OINV."DocRate"
                    END,
                    18,
                    4 -- Cuatro decimales porque si no da variaciones, especialmente esta columna
                )
            -- Y sacamos el 8% de esta cantidad
            ) * 0.08
        )
        ELSE NULL
    END AS "IVA USD",
    
    -- Fecha de documento de pago recibido
    TO_DATE (ORCT."DocDate") AS "Fecha de cobro",
    
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

    -- Total del documento de pago recibido
    ORCT."DocTotal" AS "Deposito Bancos"

-- Tabla de facturas
FROM OINV
    INNER JOIN INV1 ON OINV."DocEntry" = INV1."DocEntry"
    
    -- Contenido de pago recibido
    LEFT JOIN RCT2 ON RCT2."DocEntry" = OINV."DocEntry"
    -- Pagos recibidos provenientes de una factura
    AND RCT2."InvType" = 13

    -- Tabla de pagos recibidos
    LEFT JOIN ORCT ON ORCT."DocEntry" = RCT2."DocNum"
    -- Pagos recibidos no cancelados
    AND ORCT."Canceled" = 'N'

    -- Folio fiscal de la factura
    LEFT JOIN ECM2 ON ECM2."ObjectID" = 'RF ' || TO_NVARCHAR (OINV."DocNum")
    
    -- Metodo de pago
    LEFT JOIN OPYM ON OINV."PeyMethod" = OPYM."PayMethCod"
    
    -- Nombre y cuanta de bancos
    LEFT JOIN ODSC ON OPYM."BnkDflt" = ODSC."BankCode"
    LEFT JOIN OACT ON ORCT."TrsfrAcct" = OACT."AcctCode"
    
    -- Tabla de tipos de cambio, unidas por la fecha de la factura
    LEFT JOIN ORTT ON ORTT."RateDate" = OINV."DocDate"
    -- Solo traemos el tipo de cambio a dolares, por si acaso
    AND ORTT."Currency" = 'USD'

    -- Serie del pago, tipo de poliza
    INNER JOIN NNM1 ON ORCT."Series" = NNM1."Series"

-- Filtros
WHERE

    -- Solo facturas no canceladas
    OINV."CANCELED" = 'N'

    -- Filtro por numero de documento
    -- AND OINV."DocNum" = '1923'
    
    -- Filtro de fechas
    -- OINV."DocDate" BETWEEN '2024-09-01' AND '2024-09-30'

    -- Facturas de referencia para prueba basadas en excel: VALOR DE ACTOS GRAVADOS Y EXENTOS SEP-24
    -- AND OINV."DocNum" IN ('1923', '1923', '1951', '1990', '2013', '2057', '2084', '2111', '2112', '1925' ,'1926')

-- Agrupado por:
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
    ORCT."CashSum"

-- Ordenado por
ORDER BY

    -- Numero de factura mas recientes
    OINV."DocNum" DESC;
