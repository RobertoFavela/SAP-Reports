/*
Consulta corregida a la que tenian en SAP

Tomaba los datos del proovedor desde la tabla de OVPM
Esto ocasionaba que en casos muy raros y especificos
No coincidiera el nombre y rfc del proovedor con el correcto

Ahora lo tomamos directamente desde OPCH para tener los datos correctos
*/

SELECT
    OJDT."RefDate"       AS "Fecha",
    OJDT."Number"        AS "Diario",
    OVPM."DocDate"       AS "Fecha de Pago",
    OVPM."TrsfrDate"     AS "Fecha Transferencia",
    OVPM."DocNum"        AS "Folio Pago",
    OVPM."TrsfrAcct"     AS "Cuenta Transferencia",
    OACT."AcctName"      AS "Banco",
    OVPM."DocTotalSy"    AS "Pago Total SC",
    OVPM."CardName"      AS "Proveedor",
    OCRD."LicTradNum"    AS "RFC",
    OPCH."NumAtCard"     AS "Folio Factura",
    OPCH."U_UDF_UUID"    AS "Folio Fiscal",
    VPM2."AppliedSys"    AS "Monto Pagado SC",
    VPM2."vatAppldSy"    AS "IVA SC",
    VPM2."WtAppldSC"     AS "Retención Aplicada SC",
    VPM2."WTSumSC"       AS "Retención SC",
    OVPM."DocCurr"       AS "Moneda",
    OVPM."DocRate"       AS "Tipo de Cambio",
    OVPM."TrsfrSum"      AS "Importe Transferido",
    OVPM."CashSum"      AS "Importe Efectivo",
    OVPM."CheckSum"     AS "Importe Cheque",
    OVPM."CreditSum"     AS "Importe Credito",
    VPM2."SumApplied"    AS "Pago Documento",
    VPM2."vatApplied"    AS "IVA ML"
FROM OVPM
INNER JOIN VPM2
    ON OVPM."DocEntry" = VPM2."DocNum"
   AND VPM2."InvType" = '18'
INNER JOIN OPCH
    ON VPM2."DocEntry" = OPCH."DocEntry"
INNER JOIN OCRD
    ON OVPM."CardCode" = OCRD."CardCode"
INNER JOIN OJDT
    ON OVPM."TransId" = OJDT."TransId"
LEFT JOIN OACT
    ON OVPM."TrsfrAcct" = OACT."AcctCode"
WHERE OVPM."Canceled" = 'N';