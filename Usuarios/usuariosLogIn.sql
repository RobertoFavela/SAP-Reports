SELECT 
    T0."USER_CODE" AS "Código de Usuario",
    T0."U_NAME" AS "Nombre de Usuario",
    T0."Department" AS "Departamento",
    T0."E_Mail" AS "Correo Electrónico",
    CASE T0."Locked" 
        WHEN 'Y' THEN 'Bloqueado' 
        ELSE 'Activo' 
    END AS "Estado Usuario",
    T1."Date" AS "Fecha de Sesión",
    T1."Time" AS "Hora de Sesión",
    CASE T1."Action" 
        WHEN 'L' THEN 'Inicio de Sesión'
        WHEN 'O' THEN 'Cierre de Sesión'
        WHEN 'F' THEN 'Intento Fallido'
        ELSE T1."Action" 
    END AS "Acción",
    T1."ClientIP" AS "Dirección IP",
    T1."ClientName" AS "Nombre de Equipo",
    T1."WinUsrName" AS "Usuario Windows",
    T1."ProcName" AS "Aplicación Conectada",
    T1."LogoutTime" AS "Hora Cierre Sesión",
    T1."AliveDurtn" AS "Duración Sesión (min)"
FROM "OUSR" T0
INNER JOIN "USR5" T1 ON T0."USER_CODE" = T1."UserCode"
ORDER BY T1."Date" DESC, T1."Time" DESC;