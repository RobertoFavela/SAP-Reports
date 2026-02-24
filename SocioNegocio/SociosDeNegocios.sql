SELECT 
    OCRD."CardCode",
    OCRD."CardName",
    OCRD."Phone1",
    OCRD."Phone2",
    OCPR."Tel1",
    OCPR."Tel2"

FROM OCRD
LEFT JOIN OCPR ON OCRD."CardCode" = OCPR."CardCode"
