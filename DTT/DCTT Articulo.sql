/* SELECT FROM OJDT T0 WHERE T0."RefDate" >= [%0] AND T0."RefDate" <= [%1] */

WITH "Asientos" AS
(
    SELECT "TransId", "Number", "RefDate", "TransType", "BaseRef", "Memo"
    FROM OJDT
    WHERE "RefDate" BETWEEN '[%0]' AND '[%1]'
),
"Documentos" AS
(
    -- Factura de proveedor
    SELECT A."TransId", A."TransType", H."DocEntry", H."DocNum", H."Comments"
    FROM "Asientos" A
    INNER JOIN OPCH H ON H."TransId" = A."TransId"
    WHERE A."TransType" = '18'
    UNION ALL
    -- Factura de cliente
    SELECT A."TransId", A."TransType", H."DocEntry", H."DocNum", H."Comments"
    FROM "Asientos" A
    INNER JOIN OINV H ON H."TransId" = A."TransId"
    WHERE A."TransType" = '13'
    UNION ALL
    -- Nota de credito de proveedor
    SELECT A."TransId", A."TransType", H."DocEntry", H."DocNum", H."Comments"
    FROM "Asientos" A
    INNER JOIN ORPC H ON H."TransId" = A."TransId"
    WHERE A."TransType" = '19'
    UNION ALL
    -- Nota de credito de cliente
    SELECT A."TransId", A."TransType", H."DocEntry", H."DocNum", H."Comments"
    FROM "Asientos" A
    INNER JOIN ORIN H ON H."TransId" = A."TransId"
    WHERE A."TransType" = '14'
    UNION ALL
    -- Entrega
    SELECT A."TransId", A."TransType", H."DocEntry", H."DocNum", H."Comments"
    FROM "Asientos" A
    INNER JOIN ODLN H ON H."TransId" = A."TransId"
    WHERE A."TransType" = '15'
    UNION ALL
    -- Devolucion de cliente
    SELECT A."TransId", A."TransType", H."DocEntry", H."DocNum", H."Comments"
    FROM "Asientos" A
    INNER JOIN ORDN H ON H."TransId" = A."TransId"
    WHERE A."TransType" = '16'
    UNION ALL
    -- Entrada por compra
    SELECT A."TransId", A."TransType", H."DocEntry", H."DocNum", H."Comments"
    FROM "Asientos" A
    INNER JOIN OPDN H ON H."TransId" = A."TransId"
    WHERE A."TransType" = '20'
    UNION ALL
    -- Devolucion de proveedor
    SELECT A."TransId", A."TransType", H."DocEntry", H."DocNum", H."Comments"
    FROM "Asientos" A
    INNER JOIN ORPD H ON H."TransId" = A."TransId"
    WHERE A."TransType" = '21'
    UNION ALL
    -- Entrada de mercancias
    SELECT A."TransId", A."TransType", H."DocEntry", H."DocNum", H."Comments"
    FROM "Asientos" A
    INNER JOIN OIGN H ON H."TransId" = A."TransId"
    WHERE A."TransType" = '59'
    UNION ALL
    -- Salida de mercancias
    SELECT A."TransId", A."TransType", H."DocEntry", H."DocNum", H."Comments"
    FROM "Asientos" A
    INNER JOIN OIGE H ON H."TransId" = A."TransId"
    WHERE A."TransType" = '60'
    UNION ALL
    -- Traslado de inventario
    SELECT A."TransId", A."TransType", H."DocEntry", H."DocNum", H."Comments"
    FROM "Asientos" A
    INNER JOIN OWTR H ON H."TransId" = A."TransId"
    WHERE A."TransType" = '67'
    UNION ALL
    -- Anticipo de proveedor
    SELECT A."TransId", A."TransType", H."DocEntry", H."DocNum", H."Comments"
    FROM "Asientos" A
    INNER JOIN ODPO H ON H."TransId" = A."TransId"
    WHERE A."TransType" = '204'
    UNION ALL
    -- Anticipo de cliente
    SELECT A."TransId", A."TransType", H."DocEntry", H."DocNum", H."Comments"
    FROM "Asientos" A
    INNER JOIN ODPI H ON H."TransId" = A."TransId"
    WHERE A."TransType" = '203'
    UNION ALL
    -- Pago efectuado
    SELECT A."TransId", A."TransType", H."DocEntry", H."DocNum", H."Comments"
    FROM "Asientos" A
    INNER JOIN OVPM H ON H."TransId" = A."TransId"
    WHERE A."TransType" = '46'
    UNION ALL
    -- Pago recibido
    SELECT A."TransId", A."TransType", H."DocEntry", H."DocNum", H."Comments"
    FROM "Asientos" A
    INNER JOIN ORCT H ON H."TransId" = A."TransId"
    WHERE A."TransType" = '24'
    UNION ALL
    -- Capitalizacion
    SELECT A."TransId", A."TransType", H."DocEntry", H."DocNum", H."Comments"
    FROM "Asientos" A
    INNER JOIN OACQ H ON H."TransId" = A."TransId"
    WHERE A."TransType" = '1470000049'
),
"LineasDocumento" AS
(
    -- Factura de proveedor
    SELECT D."TransId", D."TransType", D."DocEntry", L."LineNum",
           L."ItemCode", L."Dscription", L."AcctCode", L."LineTotal",
           L."OcrCode", L."OcrCode2", L."OcrCode3", L."OcrCode4", L."OcrCode5",
           L."Project", L."CogsOcrCod", L."CogsOcrCo2", L."CogsOcrCo3",
           L."CogsOcrCo4", L."CogsOcrCo5"
    FROM "Documentos" D
    INNER JOIN PCH1 L ON L."DocEntry" = D."DocEntry"
    WHERE D."TransType" = '18'
    UNION ALL
    -- Factura de cliente
    SELECT D."TransId", D."TransType", D."DocEntry", L."LineNum",
           L."ItemCode", L."Dscription", L."AcctCode", L."LineTotal",
           L."OcrCode", L."OcrCode2", L."OcrCode3", L."OcrCode4", L."OcrCode5",
           L."Project", L."CogsOcrCod", L."CogsOcrCo2", L."CogsOcrCo3",
           L."CogsOcrCo4", L."CogsOcrCo5"
    FROM "Documentos" D
    INNER JOIN INV1 L ON L."DocEntry" = D."DocEntry"
    WHERE D."TransType" = '13'
    UNION ALL
    -- Nota de credito de proveedor
    SELECT D."TransId", D."TransType", D."DocEntry", L."LineNum",
           L."ItemCode", L."Dscription", L."AcctCode", L."LineTotal",
           L."OcrCode", L."OcrCode2", L."OcrCode3", L."OcrCode4", L."OcrCode5",
           L."Project", L."CogsOcrCod", L."CogsOcrCo2", L."CogsOcrCo3",
           L."CogsOcrCo4", L."CogsOcrCo5"
    FROM "Documentos" D
    INNER JOIN RPC1 L ON L."DocEntry" = D."DocEntry"
    WHERE D."TransType" = '19'
    UNION ALL
    -- Nota de credito de cliente
    SELECT D."TransId", D."TransType", D."DocEntry", L."LineNum",
           L."ItemCode", L."Dscription", L."AcctCode", L."LineTotal",
           L."OcrCode", L."OcrCode2", L."OcrCode3", L."OcrCode4", L."OcrCode5",
           L."Project", L."CogsOcrCod", L."CogsOcrCo2", L."CogsOcrCo3",
           L."CogsOcrCo4", L."CogsOcrCo5"
    FROM "Documentos" D
    INNER JOIN RIN1 L ON L."DocEntry" = D."DocEntry"
    WHERE D."TransType" = '14'
    UNION ALL
    -- Entrega
    SELECT D."TransId", D."TransType", D."DocEntry", L."LineNum",
           L."ItemCode", L."Dscription", L."AcctCode", L."LineTotal",
           L."OcrCode", L."OcrCode2", L."OcrCode3", L."OcrCode4", L."OcrCode5",
           L."Project", L."CogsOcrCod", L."CogsOcrCo2", L."CogsOcrCo3",
           L."CogsOcrCo4", L."CogsOcrCo5"
    FROM "Documentos" D
    INNER JOIN DLN1 L ON L."DocEntry" = D."DocEntry"
    WHERE D."TransType" = '15'
    UNION ALL
    -- Devolucion de cliente
    SELECT D."TransId", D."TransType", D."DocEntry", L."LineNum",
           L."ItemCode", L."Dscription", L."AcctCode", L."LineTotal",
           L."OcrCode", L."OcrCode2", L."OcrCode3", L."OcrCode4", L."OcrCode5",
           L."Project", L."CogsOcrCod", L."CogsOcrCo2", L."CogsOcrCo3",
           L."CogsOcrCo4", L."CogsOcrCo5"
    FROM "Documentos" D
    INNER JOIN RDN1 L ON L."DocEntry" = D."DocEntry"
    WHERE D."TransType" = '16'
    UNION ALL
    -- Entrada por compra
    SELECT D."TransId", D."TransType", D."DocEntry", L."LineNum",
           L."ItemCode", L."Dscription", L."AcctCode", L."LineTotal",
           L."OcrCode", L."OcrCode2", L."OcrCode3", L."OcrCode4", L."OcrCode5",
           L."Project", L."CogsOcrCod", L."CogsOcrCo2", L."CogsOcrCo3",
           L."CogsOcrCo4", L."CogsOcrCo5"
    FROM "Documentos" D
    INNER JOIN PDN1 L ON L."DocEntry" = D."DocEntry"
    WHERE D."TransType" = '20'
    UNION ALL
    -- Devolucion de proveedor
    SELECT D."TransId", D."TransType", D."DocEntry", L."LineNum",
           L."ItemCode", L."Dscription", L."AcctCode", L."LineTotal",
           L."OcrCode", L."OcrCode2", L."OcrCode3", L."OcrCode4", L."OcrCode5",
           L."Project", L."CogsOcrCod", L."CogsOcrCo2", L."CogsOcrCo3",
           L."CogsOcrCo4", L."CogsOcrCo5"
    FROM "Documentos" D
    INNER JOIN RPD1 L ON L."DocEntry" = D."DocEntry"
    WHERE D."TransType" = '21'
    UNION ALL
    -- Entrada de mercancias
    SELECT D."TransId", D."TransType", D."DocEntry", L."LineNum",
           L."ItemCode", L."Dscription", L."AcctCode", L."LineTotal",
           L."OcrCode", L."OcrCode2", L."OcrCode3", L."OcrCode4", L."OcrCode5",
           L."Project", L."CogsOcrCod", L."CogsOcrCo2", L."CogsOcrCo3",
           L."CogsOcrCo4", L."CogsOcrCo5"
    FROM "Documentos" D
    INNER JOIN IGN1 L ON L."DocEntry" = D."DocEntry"
    WHERE D."TransType" = '59'
    UNION ALL
    -- Salida de mercancias
    SELECT D."TransId", D."TransType", D."DocEntry", L."LineNum",
           L."ItemCode", L."Dscription", L."AcctCode", L."LineTotal",
           L."OcrCode", L."OcrCode2", L."OcrCode3", L."OcrCode4", L."OcrCode5",
           L."Project", L."CogsOcrCod", L."CogsOcrCo2", L."CogsOcrCo3",
           L."CogsOcrCo4", L."CogsOcrCo5"
    FROM "Documentos" D
    INNER JOIN IGE1 L ON L."DocEntry" = D."DocEntry"
    WHERE D."TransType" = '60'
    UNION ALL
    -- Traslado de inventario
    SELECT D."TransId", D."TransType", D."DocEntry", L."LineNum",
           L."ItemCode", L."Dscription", L."AcctCode", L."LineTotal",
           L."OcrCode", L."OcrCode2", L."OcrCode3", L."OcrCode4", L."OcrCode5",
           L."Project", L."CogsOcrCod", L."CogsOcrCo2", L."CogsOcrCo3",
           L."CogsOcrCo4", L."CogsOcrCo5"
    FROM "Documentos" D
    INNER JOIN WTR1 L ON L."DocEntry" = D."DocEntry"
    WHERE D."TransType" = '67'
    UNION ALL
    -- Anticipo de proveedor
    SELECT D."TransId", D."TransType", D."DocEntry", L."LineNum",
           L."ItemCode", L."Dscription", L."AcctCode", L."LineTotal",
           L."OcrCode", L."OcrCode2", L."OcrCode3", L."OcrCode4", L."OcrCode5",
           L."Project", L."CogsOcrCod", L."CogsOcrCo2", L."CogsOcrCo3",
           L."CogsOcrCo4", L."CogsOcrCo5"
    FROM "Documentos" D
    INNER JOIN DPO1 L ON L."DocEntry" = D."DocEntry"
    WHERE D."TransType" = '204'
    UNION ALL
    -- Anticipo de cliente
    SELECT D."TransId", D."TransType", D."DocEntry", L."LineNum",
           L."ItemCode", L."Dscription", L."AcctCode", L."LineTotal",
           L."OcrCode", L."OcrCode2", L."OcrCode3", L."OcrCode4", L."OcrCode5",
           L."Project", L."CogsOcrCod", L."CogsOcrCo2", L."CogsOcrCo3",
           L."CogsOcrCo4", L."CogsOcrCo5"
    FROM "Documentos" D
    INNER JOIN DPI1 L ON L."DocEntry" = D."DocEntry"
    WHERE D."TransType" = '203'
),
"RenglonesContables" AS
(
    SELECT A."TransId", A."Number", A."RefDate", A."TransType", A."BaseRef",
           J."Line_ID", J."Account",
           COALESCE(J."Debit", 0) AS "Debit", COALESCE(J."Credit", 0) AS "Credit",
           J."ProfitCode", J."OcrCode2", J."OcrCode3", J."OcrCode4", J."OcrCode5",
           J."Project", COALESCE(D."Comments", J."LineMemo", A."Memo") AS "Comentarios",
           D."DocEntry", D."DocNum",
           CASE WHEN B."CardCode" IS NULL
                     AND COALESCE(J."VatLine", 'N') <> 'Y'
                     AND COALESCE(J."InterimTyp", 0) <> 5
                THEN 1 ELSE 0 END AS "AdmiteArticulo"
    FROM "Asientos" A
    INNER JOIN JDT1 J ON J."TransId" = A."TransId"
    LEFT JOIN "Documentos" D ON D."TransId" = A."TransId"
        AND D."TransType" = A."TransType"
    LEFT JOIN OCRD B ON B."CardCode" = J."ShortName"
),
"TiposCuentaInventario" AS
(
    SELECT 1 AS "Tipo" FROM DUMMY UNION ALL
    SELECT 2 FROM DUMMY UNION ALL
    SELECT 3 FROM DUMMY UNION ALL
    SELECT 4 FROM DUMMY UNION ALL
    SELECT 5 FROM DUMMY UNION ALL
    SELECT 6 FROM DUMMY UNION ALL
    SELECT 7 FROM DUMMY
),
"ValoresInventario" AS
(
    -- OIVL puede tener varias capas, lotes o almacenes para la misma linea.
    -- Se agregan antes de enlazar a JDT1 para no multiplicar los importes.
    SELECT L."TransId", L."LineNum", T."Tipo",
           CASE T."Tipo"
               WHEN 1 THEN V."InvntAct"
               WHEN 2 THEN V."CostAct"
               WHEN 3 THEN V."TrnsfrAct"
               WHEN 4 THEN V."WipAct"
               WHEN 5 THEN V."ClearAct"
               WHEN 6 THEN V."IOffIncAcc"
               WHEN 7 THEN V."DOffDecAcc"
           END AS "Cuenta",
           SUM(ABS(COALESCE(
               CASE T."Tipo"
                   WHEN 2 THEN V."CogsVal"
                   WHEN 4 THEN V."WipVal"
                   WHEN 5 THEN V."Allocation"
                   WHEN 6 THEN V."IOffIncVal"
                   WHEN 7 THEN V."DOffDecVal"
                   ELSE V."SumStock"
               END, 0))) AS "Peso"
    FROM "LineasDocumento" L
    INNER JOIN OIVL V ON TO_NVARCHAR(V."TransType") = L."TransType"
        AND V."CreatedBy" = L."DocEntry" AND V."DocLineNum" = L."LineNum"
    CROSS JOIN "TiposCuentaInventario" T
    GROUP BY L."TransId", L."LineNum", T."Tipo",
             CASE T."Tipo"
                 WHEN 1 THEN V."InvntAct"
                 WHEN 2 THEN V."CostAct"
                 WHEN 3 THEN V."TrnsfrAct"
                 WHEN 4 THEN V."WipAct"
                 WHEN 5 THEN V."ClearAct"
                 WHEN 6 THEN V."IOffIncAcc"
                 WHEN 7 THEN V."DOffDecAcc"
             END
),
"CuentasCandidatas" AS
(
    -- La cuenta registrada en inventario tiene prioridad sobre AcctCode.
    SELECT V."TransId", V."LineNum", V."Cuenta", V."Peso", 1 AS "Prioridad"
    FROM "ValoresInventario" V
    WHERE COALESCE(V."Cuenta", '') <> ''

    UNION ALL

    SELECT L."TransId", L."LineNum", L."AcctCode", L."LineTotal", 2
    FROM "LineasDocumento" L
    WHERE COALESCE(L."AcctCode", '') <> ''
      AND L."TransType" NOT IN ('15', '16', '59', '60', '67')

    UNION ALL

    -- En entradas/salidas, AcctCode es la contrapartida del inventario.
    SELECT L."TransId", L."LineNum", L."AcctCode", V."Peso", 2
    FROM "LineasDocumento" L
    INNER JOIN (
        SELECT "TransId", "LineNum", SUM("Peso") AS "Peso"
        FROM "ValoresInventario"
        WHERE "Tipo" = 1 AND COALESCE("Cuenta", '') <> ''
        GROUP BY "TransId", "LineNum"
    ) V ON V."TransId" = L."TransId" AND V."LineNum" = L."LineNum"
    WHERE COALESCE(L."AcctCode", '') <> '' AND L."TransType" IN ('59', '60')

    UNION ALL

    -- El anticipo puede usar una cuenta distinta de AcctCode.
    -- Tomamos la cuenta efectivamente contabilizada, nunca la configuracion actual.
    SELECT DISTINCT L."TransId", L."LineNum", J."Account", L."LineTotal", 3
    FROM "LineasDocumento" L
    INNER JOIN "RenglonesContables" J ON J."TransId" = L."TransId"
    WHERE L."TransType" IN ('203', '204') AND J."AdmiteArticulo" = 1
),
"CuentasOrdenadas" AS
(
    -- Una sola relacion por linea/cuenta, aunque aparezca por varios caminos.
    SELECT C.*,
           ROW_NUMBER() OVER (
               PARTITION BY C."TransId", C."LineNum", C."Cuenta"
               ORDER BY C."Prioridad", ABS(C."Peso") DESC
           ) AS "OrdenCuenta"
    FROM "CuentasCandidatas" C
),
"DetallePorCuenta" AS
(
    SELECT L.*, C."Cuenta", C."Peso", C."Prioridad"
    FROM "LineasDocumento" L
    INNER JOIN "CuentasOrdenadas" C ON C."TransId" = L."TransId"
        AND C."LineNum" = L."LineNum" AND C."OrdenCuenta" = 1
),
"Cruces" AS
(
    -- Se respeta la dimension del asiento. No se atribuye un articulo de otra
    -- sucursal/proyecto. Si SAP desgloso una regla de reparto y no hay cruce
    -- directo con las dimensiones del documento, el renglon queda sin articulo.
    SELECT J.*, L."LineNum", L."ItemCode", L."Dscription", L."Peso"
    FROM "RenglonesContables" J
    LEFT JOIN "DetallePorCuenta" L ON L."TransId" = J."TransId"
        AND L."Cuenta" = J."Account" AND J."AdmiteArticulo" = 1
        AND (
                ((COALESCE(J."ProfitCode", '') = '' OR COALESCE(J."ProfitCode", '') = COALESCE(L."OcrCode", ''))
                 AND (COALESCE(J."OcrCode2", '') = '' OR COALESCE(J."OcrCode2", '') = COALESCE(L."OcrCode2", ''))
                 AND (COALESCE(J."OcrCode3", '') = '' OR COALESCE(J."OcrCode3", '') = COALESCE(L."OcrCode3", ''))
                 AND (COALESCE(J."OcrCode4", '') = '' OR COALESCE(J."OcrCode4", '') = COALESCE(L."OcrCode4", ''))
                 AND (COALESCE(J."OcrCode5", '') = '' OR COALESCE(J."OcrCode5", '') = COALESCE(L."OcrCode5", '')))
             OR (L."Prioridad" = 1 AND (COALESCE(J."ProfitCode", '') = '' OR COALESCE(J."ProfitCode", '') = COALESCE(L."CogsOcrCod", ''))
                 AND (COALESCE(J."OcrCode2", '') = '' OR COALESCE(J."OcrCode2", '') = COALESCE(L."CogsOcrCo2", ''))
                 AND (COALESCE(J."OcrCode3", '') = '' OR COALESCE(J."OcrCode3", '') = COALESCE(L."CogsOcrCo3", ''))
                 AND (COALESCE(J."OcrCode4", '') = '' OR COALESCE(J."OcrCode4", '') = COALESCE(L."CogsOcrCo4", ''))
                 AND (COALESCE(J."OcrCode5", '') = '' OR COALESCE(J."OcrCode5", '') = COALESCE(L."CogsOcrCo5", '')))
            )
        AND (COALESCE(J."Project", '') = ''
             OR COALESCE(J."Project", '') = COALESCE(L."Project", ''))
),
"Pesos" AS
(
    SELECT C.*,
           SUM(COALESCE(C."Peso", 0)) OVER (
               PARTITION BY C."TransId", C."Line_ID") AS "PesoTotal",
           SUM(ABS(COALESCE(C."Peso", 0))) OVER (
               PARTITION BY C."TransId", C."Line_ID") AS "PesoAbsoluto",
           COUNT(*) OVER (PARTITION BY C."TransId", C."Line_ID") AS "CantidadLineas",
           ROW_NUMBER() OVER (
               PARTITION BY C."TransId", C."Line_ID"
               ORDER BY ABS(COALESCE(C."Peso", 0)) DESC, C."LineNum"
           ) AS "OrdenAjuste"
    FROM "Cruces" C
),
"Proporciones" AS
(
    SELECT P.*,
           CASE WHEN P."PesoTotal" <> 0 THEN P."Peso" / P."PesoTotal"
                WHEN P."PesoAbsoluto" <> 0 THEN ABS(P."Peso") / P."PesoAbsoluto"
                ELSE 1.0 / P."CantidadLineas"
           END AS "Proporcion"
    FROM "Pesos" P
),
"Importes" AS
(
    SELECT P.*,
           ROUND(P."Debit" * P."Proporcion", 6) AS "DebitoParcial",
           ROUND(P."Credit" * P."Proporcion", 6) AS "CreditoParcial"
    FROM "Proporciones" P
)
SELECT
    'ATANASIA' AS "Empresa",
    I."TransId" AS "Asiento ID",
    I."Number" AS "Asiento",
    TO_DATE(I."RefDate") AS "Fecha",
    I."TransType",
    COALESCE(TO_NVARCHAR(I."DocEntry"), I."BaseRef") AS "Documento ID",
    COALESCE(TO_NVARCHAR(I."DocNum"), I."BaseRef") AS "Documento Origen",
    I."Account" AS "Cuenta",
    CASE WHEN I."OrdenAjuste" = 1 THEN
             I."Debit" - (SUM(I."DebitoParcial") OVER (
                 PARTITION BY I."TransId", I."Line_ID") - I."DebitoParcial")
         ELSE I."DebitoParcial"
    END AS "Debito del asiento",
    CASE WHEN I."OrdenAjuste" = 1 THEN
             I."Credit" - (SUM(I."CreditoParcial") OVER (
                 PARTITION BY I."TransId", I."Line_ID") - I."CreditoParcial")
         ELSE I."CreditoParcial"
    END AS "Credito del asiento",
    I."ProfitCode" AS "Negocio",
    I."OcrCode2" AS "Sucursal",
    I."OcrCode3" AS "Area",
    I."OcrCode4" AS "Ciclo",
    I."OcrCode5" AS "Equipos",
    I."Project" AS "Proyecto",
    I."Comentarios",
    I."ItemCode" AS "No. Articulo",
    I."Dscription" AS "Articulo"
FROM "Importes" I
ORDER BY I."Number" DESC, I."TransId" DESC, I."Line_ID", I."LineNum";
