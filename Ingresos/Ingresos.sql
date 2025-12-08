SELECT
    T0."DocNum",
    T0."CANCELED",
    T0."DocStatus",
    T0."DocDate",
    T0."CardCode",
    T0."CardName",
    T1."ItemCode",
    T1."Dscription",
    T1."Quantity",
    T1."Price",
    T1."LineTotal",
    T1."VatSum",
    T0."DocCur",
    T0."DocRate",
    T1."VatPrcnt",
    T0."PaidToDate",
    T1."AcctCode",
    E2."ReportID" AS "Folio Fiscal"
FROM
    OINV T0
    INNER JOIN INV1 T1 ON T0."DocEntry" = T1."DocEntry"
    LEFT JOIN ECM2 E2 ON E2."ObjectID" = 'RF ' || TO_NVARCHAR (T0."DocNum")