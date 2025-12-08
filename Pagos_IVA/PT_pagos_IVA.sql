/*
Consulta original que tenian en SAP

Toman los datos del proovedor desde la tabla de OVPM
Esto ocasionaba que en casos muy raros y especificos
No coincidiera el nombre y rfc del proovedor con el correcto

Guardo esta version meramente por convservacion de codigo
*/

SELECT
    OJDT."RefDate" AS "Fecha",
    OJDT."Number" AS "Diario",
    OVPM."TrsfrDate" AS "Fecha de Pago",
    OVPM."DocNum" AS "Folio Pago",
    OVPM."TrsfrAcct" AS "Cuenta",
    OACT."AcctName" AS "Banco",
    OVPM."TrsfrSumSy" AS "Pago Total",
    OVPM."CardName" AS "Proovedor",
    OCRD."LicTradNum" AS "RFC",
    OPCH."NumAtCard" AS "Folio Factura",
    OPCH."U_UDF_UUID" AS "Folio Fiscal",
    VPM2."AppliedSys" AS "Monto Pagado",
    VPM2."vatAppldSy" AS "IVA",
    VPM2."WtAppldSC" AS "Retención",
    VPM2."WTSumSC" AS "Retención2",
    OVPM."DocCurr" AS "Moneda",
    OVPM."DocRate" AS "Tipo de Cambio",
    OVPM."TrsfrSum" AS "Importe Transferido",
    VPM2."SumApplied" AS "Pago Documento",
    VPM2."vatApplied" AS "IVA MXP"
FROM 
    OVPM
    INNER JOIN VPM2 ON OVPM."DocEntry" = VPM2."DocNum"
    INNER JOIN OPCH ON VPM2."DocEntry" = OPCH."DocEntry"
    INNER JOIN OCRD ON OVPM."CardCode" = OCRD."CardCode"
    INNER JOIN OJDT ON OVPM."TransId" = OJDT."TransId"
    LEFT JOIN OACT ON OVPM."TrsfrAcct" = OACT."AcctCode"