/* SELECT FROM OJDT T0 WHERE T0."RefDate" >= [%0] AND T0."RefDate" <= [%1] */

WITH "CuentasAnticipo" AS
(
    SELECT
        A."AcctCode",
        A."FormatCode"
    FROM OACT A
    WHERE REPLACE(
        IFNULL(NULLIF(A."FormatCode", ''), A."AcctCode"),
        '-',
        ''
    ) IN (
        '112000100000',
        '112000200000',
        '112000300000',
        '112000400000'
    )
),
"MovimientosCuenta" AS
(
    -- Todos los movimientos de las cuatro cuentas.
    SELECT
        H."TransId",
        H."RefDate",
        J."Account",
        SUM(J."Debit" - J."Credit") AS "MovimientoML"
    FROM OJDT H
    INNER JOIN JDT1 J
        ON J."TransId" = H."TransId"
    INNER JOIN "CuentasAnticipo" A
        ON A."AcctCode" = J."Account"
    GROUP BY
        H."TransId",
        H."RefDate",
        J."Account"
),
"SaldosCuenta" AS
(
    SELECT
        M."TransId",
        M."Account",
        SUM(M."MovimientoML") OVER
        (
            PARTITION BY M."Account"
            ORDER BY M."RefDate", M."TransId"
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS "SaldoAcumulado"
    FROM "MovimientosCuenta" M
),
"SaldoPorAsiento" AS
(
    -- Conserva una fila por asiento.
    -- Si afecta varias cuentas de anticipo, requiere revisión.
    SELECT
        S."TransId",
        COUNT(*) AS "CantidadCuentas",
        CASE
            WHEN COUNT(*) = 1 THEN MAX(S."Account")
        END AS "Cuenta",
        CASE
            WHEN COUNT(*) = 1 THEN MAX(S."SaldoAcumulado")
        END AS "SaldoAcumulado"
    FROM "SaldosCuenta" S
    GROUP BY
        S."TransId"
),
"ImportesAnticipo" AS
(
    SELECT
        D."DocEntry",
        SUM(D."LineTotal") AS "ImporteSinImpuestosML"
    FROM DPO1 D
    GROUP BY
        D."DocEntry"
),
"PagosAnticipo" AS
(
    SELECT
        D."DocEntry",
        MAX(P."DocDate") AS "FechaPago",
        SUM(D."SumApplied") AS "ImportePagadoML"
    FROM VPM2 D
    INNER JOIN OVPM P
        ON P."DocEntry" = D."DocNum"
    WHERE D."InvType" = '204'
      AND P."Canceled" = 'N'
    GROUP BY
        D."DocEntry"
)
SELECT
    H."RefDate"                  AS "Fecha de asiento",
    H."TransId"                  AS "Numero de transaccion",
    'AN'                          AS "Origen",
    H."BaseRef"                  AS "Numero de origen",
    P."FechaPago"                AS "Fecha de pago",
    C."CardCode"                 AS "Cuenta de contrapartida",
    H."Memo"                     AS "Info detallada",
    I."ImporteSinImpuestosML"    AS "C/D (ML)",

    NULLIF(
        D."DocTotal"
        - IFNULL(P."ImportePagadoML", 0),
        0
    ) AS "CONSOLIDADO",

    S."SaldoAcumulado"           AS "Saldo acumulado",

    CASE
        WHEN S."CantidadCuentas" > 1
            THEN 'REVISAR: VARIAS CUENTAS'
        ELSE IFNULL(
            NULLIF(A."FormatCode", ''),
            IFNULL(A."AcctCode", 'SIN CUENTA IDENTIFICADA')
        )
    END AS "Cuenta de mayor"

FROM OJDT H
INNER JOIN ODPO D
    ON D."TransId" = H."TransId"
INNER JOIN OCRD C
    ON C."CardCode" = D."CardCode"
LEFT JOIN "ImportesAnticipo" I
    ON I."DocEntry" = D."DocEntry"
LEFT JOIN "PagosAnticipo" P
    ON P."DocEntry" = D."DocEntry"
LEFT JOIN "SaldoPorAsiento" S
    ON S."TransId" = H."TransId"
LEFT JOIN "CuentasAnticipo" A
    ON A."AcctCode" = S."Cuenta"

WHERE H."TransType" = '204'
    AND H."RefDate" BETWEEN '[%0]' AND '[%1]'

ORDER BY
    H."RefDate",
    H."TransId";