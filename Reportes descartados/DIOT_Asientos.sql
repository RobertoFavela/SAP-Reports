(
    SELECT
        OJDT."TransType",

        -- PROVEEDOR
        '' AS "Proveedor",
        '' AS "Nombre",
        '' AS "RFC",

        -- FACTURA
        CAST(NULL AS DECIMAL(19,6)) AS "No Factura",
        CAST(NULL AS NVARCHAR(20)) AS "Fecha Factura",
        CAST(NULL AS NVARCHAR(20)) AS "UDF_UUID",
        
        -- LINEAS
        CAST(NULL AS NVARCHAR(20)) AS "Item Code",
        CAST(NULL AS NVARCHAR(200)) AS "Descripcion",
        CAST(NULL AS DECIMAL(19,6)) AS "Subtotal",
        CAST(NULL AS DECIMAL(19,6)) AS "IVA",
        CAST(NULL AS DECIMAL(19,6)) AS "Tasa IVA",

        -- RETENCIONES
        CAST(NULL AS DECIMAL(19,6)) AS "Retencion",
        CAST(NULL AS NVARCHAR(100)) AS "Tipo Retencion",

        -- PAGO
        OVPM."DocNum" AS "No Pago",
        OVPM."DocEntry" AS "Id Pago",
        
        CASE 
            WHEN OVPM."Canceled" = 'Y' THEN 'Cancelado'
            ELSE ''
        END AS "Estado",

        -- Asiento
        OJDT."Number" AS "Asiento",
        TO_DATE(OJDT."RefDate") AS "Fecha",

        -- Cuenta
        JDT1."OrgAccName" AS "Cuenta mayor",
        JDT1."Account" AS "Cuenta",

        -- Cargos
        JDT1."Debit",
        JDT1."Credit"

    FROM JDT1
    INNER JOIN OJDT ON OJDT."TransId" = JDT1."TransId"

    LEFT JOIN OVPM ON OJDT."BaseRef" = OVPM."DocNum"
    LEFT JOIN VPM2 ON OVPM."DocEntry" = VPM2."DocNum"
    LEFT JOIN OPCH ON VPM2."DocEntry" = OPCH."DocEntry"
    LEFT JOIN PCH1 ON OPCH."DocEntry" = PCH1."DocEntry"
    LEFT JOIN PCH5 ON OPCH."DocEntry" = PCH5."AbsEntry"
    LEFT JOIN OWHT ON PCH5."WTCode" = OWHT."WTCode"
    LEFT JOIN OCRD ON OPCH."CardCode" = OCRD."CardCode"

    WHERE
        OJDT."RefDate" BETWEEN '2025-09-01' AND '2025-09-30'
        AND EXISTS (
            SELECT 1
            FROM JDT1 t2
            WHERE t2."TransId" = JDT1."TransId"
              AND t2."Account" = '1118-001-000-00'
        )
        AND JDT1."SourceLine" NOT IN ('-1', '-2')
)

UNION ALL
(
    SELECT
        OJDT."TransType",

        -- PROVEEDOR
        OCRD."CardCode" AS "Proveedor",
        OCRD."CardName" AS "Nombre",
        OCRD."LicTradNum" AS "RFC",

        -- FACTURA
        OPCH."DocNum" AS "No Factura",
        OPCH."DocDate" AS "Fecha Factura",
        OPCH."U_UDF_UUID" AS "UDF_UUID",
        
        -- LINEAS
        PCH1."ItemCode",
        PCH1."Dscription",
        PCH1."LineTotal" AS "Subtotal",
        PCH1."VatSum" AS "IVA",
        PCH1."VatPrcnt" AS "Tasa IVA",

        -- RETENCIONES
        PCH5."WTAmnt" AS "Retencion",
        OWHT."WTName" AS "Tipo Retencion",

        -- PAGO
        OVPM."DocNum" AS "No Pago",
        OVPM."DocEntry" AS "Id Pago",
        
        CASE 
            WHEN OVPM."Canceled" = 'Y' THEN 'Cancelado'
            ELSE ''
        END AS "Estado",

        -- Asiento
        -- OJDT."TransId" AS "Asiento ID",
        OJDT."Number" AS "Asiento",
        TO_DATE(OJDT."RefDate") AS "Fecha",

        -- Cuenta
        JDT1."OrgAccName" AS "Cuenta mayor",
        JDT1."Account" AS "Cuenta",

        -- Cargos
        JDT1."Debit" AS "Debito del asiento",
        JDT1."Credit" AS "Credito del asiento"

    -- Lineas del asiento
    FROM JDT1
        -- Cabecera del asiento
        INNER JOIN OJDT ON OJDT."TransId" = JDT1."TransId"

        LEFT JOIN OVPM ON OJDT."BaseRef" = OVPM."DocNum" -- Pago efectuado
        INNER JOIN VPM2 ON OVPM."DocEntry" = VPM2."DocNum" -- DOCUMENTOS RELACIONADOS AL PAGO
        INNER JOIN OPCH ON VPM2."DocEntry" = OPCH."DocEntry" -- FACTURA PROVEEDOR SEGÚN EL DOCENTRY
        INNER JOIN PCH1 ON OPCH."DocEntry" = PCH1."DocEntry" -- LINEAS DE LA FACTURA
        LEFT JOIN PCH5 ON OPCH."DocEntry" = PCH5."AbsEntry" -- RETENCIONES DE LA FACTURA
        LEFT JOIN OWHT ON PCH5."WTCode" = OWHT."WTCode" -- DESCRIPCIÓN DE RETENCIONES
        INNER JOIN OCRD ON OPCH."CardCode" = OCRD."CardCode" -- PROVEEDOR
    
    WHERE
        OJDT."RefDate" BETWEEN '2025-09-01' AND '2025-09-30'
        -- AND OJDT."Number" = '28525'

         -- TransType 46, Pago Efectuado
        AND OJDT."TransType" = 46
        AND JDT1."SourceLine" IN ('-1', '-2')
) ORDER BY "Asiento" DESC
/*UNION ALL
(
    SELECT
        'Consulta 3' AS "Consulta",

        -- PROVEEDOR (solo si el asiento está ligado a un proveedor)
        OCRD."CardCode" AS "Proveedor",
        OCRD."CardName" AS "Nombre",
        OCRD."LicTradNum" AS "RFC",

        -- FACTURA (no existe en asientos manuales)
        CAST(NULL AS NVARCHAR(100)) AS "No Factura",
        NULL AS "Fecha Factura",
        CAST(NULL AS NVARCHAR(100)) AS "UDF_UUID",

        -- LINEAS
        CAST(NULL AS NVARCHAR(20)) AS "Item Code",
        CAST(NULL AS NVARCHAR(200)) AS "Descripcion",
        CAST(NULL AS DECIMAL(19,6)) AS "Subtotal",
        CAST(NULL AS DECIMAL(19,6)) AS "IVA",
        CAST(NULL AS DECIMAL(19,6)) AS "Tasa IVA",

        -- RETENCIONES
        CAST(NULL AS DECIMAL(19,6)) AS "Retencion",
        CAST(NULL AS NVARCHAR(100)) AS "Tipo Retencion",

        -- PAGO (no existe)
        CAST(NULL AS DECIMAL(19,6)) AS "No Pago",
        NULL AS "Id Pago",
        CAST(NULL AS NVARCHAR(100)) AS "Estado",

        -- Asiento
        OJDT."Number" AS "Asiento",
        TO_DATE(OJDT."RefDate") AS "Fecha",

        -- Cuenta
        JDT1."OrgAccName" AS "Cuenta mayor",
        JDT1."Account" AS "Cuenta",

        JDT1."Debit",
        JDT1."Credit"

    FROM JDT1
    INNER JOIN OJDT ON OJDT."TransId" = JDT1."TransId"
    LEFT JOIN OCRD ON JDT1."ShortName" = OCRD."CardCode"

    WHERE
        OJDT."RefDate" BETWEEN '2025-09-01' AND '2025-09-30'
        AND OJDT."TransType" = 30
        AND EXISTS (
            SELECT 1
            FROM JDT1 t2
            WHERE t2."TransId" = JDT1."TransId"
            AND t2."Account" = '1118-001-000-00'
        )
)*/

-- CONSULTA PARA OBTENER TODOS LOS ASIENTOS CON LA CUENTA DEL IVA

SELECT
    OJDT."Number" AS "Asiento",
    OJDT."TransType",
    JDT1."Account",
    JDT1."Debit",
    JDT1."Credit"
FROM OJDT
INNER JOIN JDT1 
        ON JDT1."TransId" = OJDT."TransId"
WHERE OJDT."TransId" IN (
    SELECT j."TransId"
    FROM JDT1 j
    WHERE j."Account" = '1118-001-000-00'
);


