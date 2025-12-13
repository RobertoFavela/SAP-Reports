/*
Consulta corregida a la que tenian en SAP

Tomaba los datos del proovedor desde la tabla de OVPM
Esto ocasionaba que en casos muy raros y especificos
No coincidiera el nombre y rfc del proovedor con el correcto

Ahora lo tomamos directamente desde OPCH para tener los datos correctos
*/

SELECT
    OJDT."RefDate" AS "Fecha",
    OJDT."Number" AS "Diario",
    OVPM."TrsfrDate" AS "Fecha de Pago",
    OVPM."DocNum" AS "Folio Pago",
    OVPM."TrsfrAcct" AS "Cuenta",
    OACT."AcctName" AS "Banco",
    OVPM."TrsfrSumSy" AS "Pago Total",
    OCRD."CardName" AS "Proveedor",
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
-- Pagos efectuados a proveedores
FROM OVPM
    -- Detalles de aplicacion de pagos (facturas relacionadas con el pago)
    INNER JOIN VPM2 ON OVPM."DocEntry" = VPM2."DocNum"
    -- Facturas de proovedores
    INNER JOIN OPCH ON VPM2."DocEntry" = OPCH."DocEntry"
    -- Datos del proveedor
    INNER JOIN OCRD ON OPCH."CardCode" = OCRD."CardCode"
    -- Asientos contables
    INNER JOIN OJDT ON OVPM."TransId" = OJDT."TransId"
    -- Catalogo de cuentas contables ("nombre del banco o cuenta")
    LEFT JOIN OACT ON OVPM."TrsfrAcct" = OACT."AcctCode"