CREATE PROCEDURE U_DCTT (
	in sFechaInicial varchar(10),
	in sFechaFinal varchar(10)
) LANGUAGE SQLSCRIPT SQL SECURITY INVOKER AS begin
---DCTT_Cvo Extrae los cargo de las cuentas de cultivo en proceso y agrega los centros de costo y proyectos de las facturas---
SELECT
	ojdt."Number",
	ojdt."RefDate",
	ojdt."TransType",
	Opch."DocNum" as "Factura",
	jdt1."Account" as "Cuenta",
	sum(pch1."LineTotal") as "Cargo",
	jdt1."Credit" as "Abono",
	pch1."OcrCode" as "Negocio",
	pch1."OcrCode2" as "Sucursal",
	pch1."OcrCode3" as "Area",
	pch1."OcrCode4" as "Ciclo",
	pch1."OcrCode5" as "Equipos",
	pch1."Project" as "Proyecto",
	Opch."Comments" as "Comentario"
from
	ojdt
	join jdt1 on ojdt."TransId" = jdt1."TransId"
	inner join OACT on jdt1."Account" = "AcctCode"
	left join OPCH ON ojdt."BaseRef" = opch."DocNum"
	inner join pch1 on opch."DocEntry" = pch1."DocEntry"
where
	pch1."AcctCode" = jdt1."Account"
	and jdt1."Credit" = 0
	and oact."U_CodAgrup" = 115.03
	and ojdt."TransType" = 18
	and ojdt."RefDate" >= sFechaInicial
	and ojdt."RefDate" <= sFechaFinal
group by
	ojdt."Number",
	ojdt."RefDate",
	ojdt."TransType",
	Opch."DocNum",
	jdt1."Account",
	jdt1."Credit",
	pch1."OcrCode",
	pch1."OcrCode2",
	pch1."OcrCode3",
	pch1."OcrCode4",
	pch1."OcrCode5",
	pch1."Project",
	pch1."LineTotal",
	Opch."Comments"
	--order by ojdt."Number";

UNION ALL

---DATT_Cvo Extra los abonos de las cuentas de cultivo en proceso y agrega los centros de costo y proyectos de las facturas---
SELECT
	ojdt."Number",
	ojdt."RefDate",
	ojdt."TransType",
	Opch."DocNum" as "Factura",
	jdt1."Account" as "Cuenta",
	jdt1."Debit" as "Cargo",
	sum(pch1."LineTotal") as "Abono",
	pch1."OcrCode" as "Negocio",
	pch1."OcrCode2" as "Sucursal",
	pch1."OcrCode3" as "Area",
	pch1."OcrCode4" as "Ciclo",
	pch1."OcrCode5" as "Equipos",
	pch1."Project" as "Proyecto",
	Opch."Comments" as "Comentario"
FROM
	ojdt
	join jdt1 on ojdt."TransId" = jdt1."TransId"
	inner join OACT on jdt1."Account" = "AcctCode"
	left join OPCH ON ojdt."BaseRef" = opch."DocNum"
	inner join pch1 on opch."DocEntry" = pch1."DocEntry"
where
	pch1."AcctCode" = jdt1."Account"
	and jdt1."Debit" = 0
	and oact."U_CodAgrup" = 115.03
	and ojdt."TransType" = 18
	and ojdt."RefDate" >= sFechaInicial
	and ojdt."RefDate" <= sFechaFinal
group by
	ojdt."Number",
	ojdt."RefDate",
	ojdt."TransType",
	Opch."DocNum",
	jdt1."Account",
	jdt1."Debit",
	pch1."OcrCode",
	pch1."OcrCode2",
	pch1."OcrCode3",
	pch1."OcrCode4",
	pch1."OcrCode5",
	pch1."Project",
	pch1."LineTotal",
	Opch."Comments"
	--order by ojdt."Number"
UNION ALL
---DCPC_CCvo Etrae los cargos en las cuentas de cultivo en proceso y agrega centros de costo y proyectos de las notas de crédito de los proveedores, al dia de hoy no arroja mov----
SELECT
	ojdt."Number",
	ojdt."RefDate",
	ojdt."TransType",
	Orpc."DocNum" as "Factura",
	jdt1."Account" as "Cuenta",
	sum(rpc1."LineTotal") as "Cargo",
	jdt1."Credit" as "Abono",
	rpc1."OcrCode" as "Negocio",
	rpc1."OcrCode2" as "Sucursal",
	rpc1."OcrCode3" as "Area",
	rpc1."OcrCode4" as "Ciclo",
	rpc1."OcrCode5" as "Equipos",
	rpc1."Project" as "Proyecto",
	ORPC."Comments" as "Comentario"
from
	ojdt
	join jdt1 on ojdt."TransId" = jdt1."TransId"
	inner join OACT on jdt1."Account" = "AcctCode"
	left join ORPC ON ojdt."BaseRef" = orpc."DocNum"
	inner join rpc1 on orpc."DocEntry" = rpc1."DocEntry"
where
	rpc1."AcctCode" = jdt1."Account"
	and ojdt."TransType" = 19
	and oact."U_CodAgrup" = 115.03
	and jdt1."Credit" = 0
	and ojdt."RefDate" >= sFechaInicial
	and ojdt."RefDate" <= sFechaFinal
group by
	ojdt."Number",
	ojdt."RefDate",
	ojdt."TransType",
	Orpc."DocNum",
	jdt1."Account",
	jdt1."Credit",
	rpc1."OcrCode",
	rpc1."OcrCode2",
	rpc1."OcrCode3",
	rpc1."OcrCode4",
	rpc1."OcrCode5",
	rpc1."Project",
	orpc."Comments"
	--order by ojdt."Number"
UNION ALL
---DAPC_CCvo Extrae los abonos en las cuentas de cultivo en proceso y agrega centros de costo y proyectos de  las notas de crédito---
SELECT
	ojdt."Number",
	ojdt."RefDate",
	ojdt."TransType",
	Orpc."DocNum" as "Factura",
	jdt1."Account" as "Cuenta",
	jdt1."Debit" as "Cargo",
	sum(rpc1."LineTotal") as "Abono",
	rpc1."OcrCode" as "Negocio",
	rpc1."OcrCode2" as "Sucursal",
	rpc1."OcrCode3" as "Area",
	rpc1."OcrCode4" as "Ciclo",
	rpc1."OcrCode5" as "Equipos",
	rpc1."Project" as "Proyecto",
	ORPC."Comments" as "Comentario"
from
	ojdt
	join jdt1 on ojdt."TransId" = jdt1."TransId"
	inner join OACT on jdt1."Account" = "AcctCode"
	left join ORPC ON ojdt."BaseRef" = orpc."DocNum"
	inner join rpc1 on orpc."DocEntry" = rpc1."DocEntry"
where
	rpc1."AcctCode" = jdt1."Account"
	and ojdt."TransType" = 19
	and oact."U_CodAgrup" = 115.03
	and jdt1."Debit" = 0
group by
	ojdt."Number",
	ojdt."RefDate",
	ojdt."TransType",
	Orpc."DocNum",
	jdt1."Account",
	jdt1."Debit",
	rpc1."OcrCode",
	rpc1."OcrCode2",
	rpc1."OcrCode3",
	rpc1."OcrCode4",
	rpc1."OcrCode5",
	rpc1."Project",
	ORPC."Comments"
	--order by ojdt."Number"
	--- DGTT_SinCvo Extrae todos los movimientos contables provenientes de factura de proveedores y notas de crédito, cuya cuenta no es cultivo e proceso 
	--se uso para junto con las consultas DCTT_Cvo, DATT_Cvo, DCPC_CCvo y DAPC_CCvo se integre el 100% de los movimientos contables provenientes de facturas y notas de cargo---
UNION ALL
SELECT
	ojdt."Number",
	ojdt."RefDate",
	ojdt."TransType",
	ojdt."BaseRef" as "Factura",
	jdt1."Account" as "Cuenta",
	jdt1."Debit" as "Cargo",
	jdt1."Credit" as "Abono",
	jdt1."ProfitCode" as "Negocio",
	jdt1."OcrCode2" as "Sucursal",
	jdt1."OcrCode3" as "Area",
	jdt1."OcrCode4" as "Ciclo",
	jdt1."OcrCode5" as "Equipos",
	jdt1."Project" as "Proyecto",
	jdt1."LineMemo" as "Comentario"
FROM
	ojdt
	join jdt1 on ojdt."TransId" = jdt1."TransId"
	inner join OACT on jdt1."Account" = "AcctCode"
WHERE
	ojdt."TransType" IN (18, 19)
	and oact."U_CodAgrup" <> 115.03
	and ojdt."RefDate" >= sFechaInicial
	and ojdt."RefDate" <= sFechaFinal
	--ORDER BY ojdt."Number"
	--- DG_STTPC extra todos los registros contables distintos a los provenientes de fatura de proveedor y nota de crédito, junto con la consultas anteriores integran el 100% de registros---
UNION ALL


SELECT
	OJDT."Number",
	OJDT."RefDate",
	OJDT."TransType",
	OJDT."BaseRef" as "Factura",
	jdt1."Account" AS "Cuenta",
	jdt1."Debit" as "Cargo",
	jdt1."Credit" as "Abono",
	jdt1."ProfitCode" as "Negocio",
	jdt1."OcrCode2" as "Sucursal",
	jdt1."OcrCode3" as "Area",
	jdt1."OcrCode4" as "Ciclo",
	jdt1."OcrCode5" as "Equipos",
	jdt1."Project" as "Proyecto",
	jdt1."LineMemo" as "Comentario"
FROM
	OJDT
	INNER JOIN JDT1 ON ojdt."TransId" = jdt1."TransId"
WHERE
	ojdt."TransType" not in (18, 19)
	and ojdt."RefDate" >= sFechaInicial
	and ojdt."RefDate" <= sFechaFinal
ORDER BY
	ojdt."Number";

End