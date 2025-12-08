/*
No encontraba en que tabla se guardaban las lineas de ORCT
Inicialmente busque mucho en RCT1
*/

SELECT 
    T0."DocNum" AS "Número de Pago",
    T1."DocEntry" AS "Factura Aplicada",
    T1."SumApplied" AS "Importe Línea"
FROM 
    "ORCT" T0
LEFT JOIN 
    "RCT2" T1 ON T0."DocNum" = T1."DocNum"
WHERE 
    T0."Canceled" = 'N'
ORDER BY 
    T0."DocNum" DESC, T1."DocEntry";


