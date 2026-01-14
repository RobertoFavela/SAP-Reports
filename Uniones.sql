-- Pedido
FROM OPOR  

-- Lineas de pedido
INNER JOIN POR1  ON OPOR."DocEntry" = POR1."DocEntry"

-- Lineas Entrada de mercancia
LEFT JOIN PDN1 ON POR1."DocEntry" = PDN1."BaseEntry" 
    AND POR1."ObjType" = PDN1."BaseType" 
    AND POR1."LineNum" = PDN1."BaseLine"

-- Entrada de mercancia
LEFT JOIN OPDN ON PDN1."DocEntry" = OPDN."DocEntry"

-- Lineas de factura proveedor
LEFT JOIN PCH1 ON PDN1."DocEntry" = PCH1."BaseEntry" 
    AND PDN1."ObjType" = PCH1."BaseType" 
    AND PDN1."LineNum" = PCH1."BaseLine"

-- Factura proveedor
LEFT JOIN OPCH ON PCH1."DocEntry" = OPCH."DocEntry"

-- Pagos realizados
LEFT JOIN VPM2 ON VPM2."DocEntry" = OPCH."DocEntry"
               AND VPM2."InvType" = 18 
LEFT JOIN OVPM ON OVPM."DocEntry" = VPM2."DocNum"

-- Lineas de pedido
INNER JOIN POR1 ON OPOR."DocEntry" = POR1."DocEntry"

-- Lineas Factura anticipo
LEFT JOIN DPO1 ON POR1."ObjType" = DPO1."BaseType" 
    AND POR1."DocEntry" = DPO1."BaseEntry" 
    AND POR1."LineNum" = DPO1."BaseLine"

-- Factura anticipo
LEFT JOIN ODPO ON DPO1."DocEntry" = ODPO."DocEntry"

-- Tipo de cambio
LEFT JOIN ORTT ON ORTT."RateDate" = OPOR."DocDate"
        AND ORTT."Currency" = 'USD'