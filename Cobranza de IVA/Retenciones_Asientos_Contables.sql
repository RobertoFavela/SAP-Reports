SELECT
    -- Asiento
    OJDT."RefDate" AS "FECHA ASIENTO",
    OJDT."Number" AS "FOLIO ASIENTO",
    OJDT."TransId" AS "ID ASIENTO",
    UUID_ASIENTO."UUID" AS "FOLIO FISCAL(UUID)",

    -- Datos Proveedor
    SOCIO."RFC" AS "RFC",
    SOCIO."PROVEEDOR" AS "PROVEEDOR",
    OJDT."Memo" AS "CONCEPTO",

    -- Lineas Asiento
    JDT1."Account" AS "CUENTA CONTABLE",
    OACT."AcctName" AS "NOMBRE CUENTA",
    JDT1."ShortName" AS "CODIGO ASOCIADO",
    JDT1."LineMemo" AS "CONCEPTO LINEA",
    JDT1."Debit" AS "DEBITO",
    JDT1."Credit" AS "CREDITO"

    --,CASE
    --    WHEN JDT1."Account" LIKE '2116%' THEN 'SI'
    --    ELSE 'NO'
    --END AS "ES CUENTA RETENCION"

FROM OJDT
    INNER JOIN JDT1
        ON JDT1."TransId" = OJDT."TransId"

    -- El filtro se aplica al asiento, no a sus lineas, para conservarlo completo.
    INNER JOIN (
        SELECT DISTINCT
            "TransId"
        FROM JDT1
        WHERE "Account" LIKE '2116%'
    ) ASIENTOS_RETENCION
        ON ASIENTOS_RETENCION."TransId" = OJDT."TransId"

    LEFT JOIN OACT
        ON OACT."AcctCode" = JDT1."Account"

    -- Recupera el socio de negocios desde cualquiera de las lineas del asiento.
    LEFT JOIN (
        SELECT
            LINEA_SOCIO."TransId",
            MAX(OCRD."LicTradNum") AS "RFC",
            MAX(OCRD."CardName") AS "PROVEEDOR"
        FROM JDT1 LINEA_SOCIO
            INNER JOIN OCRD
                ON OCRD."CardCode" = LINEA_SOCIO."ShortName"
        GROUP BY LINEA_SOCIO."TransId"
    ) SOCIO
        ON SOCIO."TransId" = OJDT."TransId"

    -- El UUID puede estar capturado en cualquiera de las lineas del asiento.
    LEFT JOIN (
        SELECT
            "TransId",
            MAX(NULLIF("ExpUUID", '')) AS "UUID"
        FROM JDT1
        GROUP BY "TransId"
    ) UUID_ASIENTO
        ON UUID_ASIENTO."TransId" = OJDT."TransId"

ORDER BY
    OJDT."RefDate" DESC,
    OJDT."Number" DESC,
    JDT1."Line_ID";