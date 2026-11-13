/*Parte 2
Se solicita cumplir con los siguientes requerimientos para la gestión de cuentas, lugares, categorías,
horarios, fotografías y reseñas (relacional):*/


--Procedure auxiliar, sirve para validar cuantos registros en una tabla tiene el valor especificado. Está pensado para PKs. 
/*Ejemplo para invocarlo
    validar_existencia(
        p_valor_existencia => PARAMETRO_DE_ENTRADA_CON_ID,
        p_tabla => 'TABLA_A_REVISAR',
        p_campo => 'CAMPO_PK',
        p_out => RESULTADO_A_CONSULTAR
    );
*/
--Da resultado 1 cuando existe un registro para el id y 0 caso contrario.
CREATE OR REPLACE PROCEDURE validar_existencia (
    p_valor_existencia IN VARCHAR2,
    p_tabla IN VARCHAR2,
    p_campo IN VARCHAR2,
    p_out OUT NUMBER
) AS
    v_sql VARCHAR2(1000);
BEGIN

    v_sql := 'SELECT CASE
                WHEN EXISTS (
                    SELECT 1
                    FROM ' || DBMS_ASSERT.SQL_OBJECT_NAME(p_tabla) || '
                    WHERE ' || DBMS_ASSERT.SIMPLE_SQL_NAME(p_campo) || ' = :valor
                )
                THEN 1
                ELSE 0
              END
              FROM DUAL';

    EXECUTE IMMEDIATE v_sql
    INTO p_out
    USING p_valor_existencia;

END validar_existencia;



/*Requerimiento 2.1
Implementar un servicio para facilitar la creación de un lugar. Se deberán proveer todos los datos
básicos necesarios para su creación, incluyendo su categoría principal y, si corresponde, el lugar al
que pertenece y su propietario.*/

CREATE OR REPLACE PROCEDURE crear_lugar_2_1 (
    p_nombre IN Lugar.nombre%TYPE,
    p_estado IN Lugar.Estado%TYPE,
    p_longitud IN Lugar.longitud%TYPE,
    p_latitud IN Lugar.latitud%TYPE,
    p_categoria_principal IN Lugar.categoria_principal%TYPE,
    p_contenedor IN Contenido.contenedor%TYPE default null,
    p_propietario IN Es_Dueno.propietario%TYPE default null,
    --Direccion se puede insertar por contenedor, ingresando el id de direccion o los valores para crearla.
    --Ingresar parametros para mas de uno de los formatos devolvera una excepcion.
    p_direccion IN Lugar.direccion%TYPE default null,
    p_direccion_numero IN Direccion.Numero%TYPE default null,
    p_direccion_calle IN Direccion.Calle%TYPE default null,
    p_direccion_ciudad IN Direccion.Ciudad%TYPE default null,
    p_direccion_pais IN Direccion.Pais%TYPE default null
) AS 
    --Declaracion de variables locales
    v_id_lugar Lugar.Identificador%TYPE; --id del lugar generado
    v_cant_cat NUMBER; --validacion categoria
    v_cant_prop NUMBER; --validacion propiedades
    v_cant_contenedor NUMBER; --validacion lugar contenedor existente
    v_direccion_insertada NUMBER; --inserto un id de direccion
    v_valores_direccion NUMBER; --inserto valores para crear una direccion nueva
    v_contenedor_insertado NUMBER; --inserto un valor de contenedor
    v_id_direccion Direccion.Identificador%TYPE; --id de la direccion, tomara un valor u otro dependiendo de lo que ingrese el usuario
    
BEGIN
    v_direccion_insertada := 0;
    v_valores_direccion := 0;
    v_contenedor_insertado := 0;


    --VALIDAR CATEGORIA
    validar_existencia(
        p_valor_existencia => p_categoria_principal,
        p_tabla => 'CATEGORIA',
        p_campo => 'IDENTIFICADOR',
        p_out => v_cant_cat
    );

    IF v_cant_cat <> 1 THEN
        RAISE_APPLICATION_ERROR(-20101, 'Error, se ingreso una categoria inexistente');
    END IF;
    
    --VALIDAR PROPIETARIO
    IF p_propietario is not null then
        validar_existencia(
            p_valor_existencia => p_propietario,
            p_tabla => 'Propietario',
            p_campo => 'IdCuenta',
            p_out => v_cant_prop
        );
        
        IF v_cant_prop <> 1 THEN
            RAISE_APPLICATION_ERROR(-20102, 'Error, se ingreso un propietario inexistente');
        END IF;

    END IF;

    --VALIDAR CONTENIDO
    IF p_contenedor is not null then
        validar_existencia(
            p_valor_existencia => p_contenedor,
            p_tabla => 'Lugar',
            p_campo => 'Identificador',
            p_out => v_cant_contenedor
        );

        IF v_cant_contenedor <> 1 THEN
            RAISE_APPLICATION_ERROR(-20103, 'Error, se ingreso un lugar contenedor inexistente');
        END IF;

        v_contenedor_insertado :=1;
        
        --asignar valor de la direccion del contenedor
        SELECT direccion
        INTO v_id_direccion
        FROM Lugar
        WHERE Identificador = p_contenedor;

    END IF; 

    --VALIDAR FORMA DE DIRECCION
    --Por id de direccion
    IF p_direccion IS NOT NULL THEN

    validar_existencia(
        p_valor_existencia => p_direccion,
        p_tabla => 'DIRECCION',
        p_campo => 'IDENTIFICADOR',
        p_out => v_direccion_insertada
    );
        IF v_direccion_insertada <> 1 THEN
            RAISE_APPLICATION_ERROR(-20104, 'Error, se ingreso un id de direccion inexistente');
        END IF;

        v_id_direccion := p_direccion;
    END IF;

    --Por datos para insertar una nueva direccion
    IF p_direccion_numero IS NOT NULL
    AND p_direccion_calle IS NOT NULL
    AND p_direccion_ciudad IS NOT NULL
    AND p_direccion_pais IS NOT NULL THEN
    
        v_valores_direccion := 1;

    ELSIF p_direccion_numero IS NULL
    AND p_direccion_calle IS NULL
    AND p_direccion_ciudad IS NULL
    AND p_direccion_pais IS NULL THEN

        v_valores_direccion := 0;

    ELSE
        RAISE_APPLICATION_ERROR(
            -20105,
            'Error: se deben proporcionar todos los datos de la nueva direccion o ninguno'
        );
    END IF;

    IF v_valores_direccion + v_direccion_insertada + v_contenedor_insertado <> 1 THEN
        RAISE_APPLICATION_ERROR(-20106, 'Error en las formas de insertar direccion. Se debe hacer una de tres, insertar el lugar contenedor, insertar el id de una direccion ya existente o insertar los valores para una direccion nueva');
    END IF;

    --Validaciones correctas, se insertan los registros 

    IF v_valores_direccion = 1 THEN
        INSERT INTO Direccion(
            Numero,
            calle,
            ciudad,
            pais
        )
        VALUES (
            p_direccion_numero,
            p_direccion_calle,
            p_direccion_ciudad,
            p_direccion_pais
        )
        RETURNING Identificador INTO v_id_direccion;
    END IF;

    INSERT INTO Lugar(
        Nombre,
        Estado, 
        longitud, 
        latitud, 
        direccion, 
        categoria_principal
        )
        VALUES(
            p_nombre,
            p_estado,
            p_longitud,
            p_latitud,
            v_id_direccion,
            p_categoria_principal
        )
    RETURNING Identificador INTO v_id_lugar; -- Captura el ID recién autogenerado;

    IF p_contenedor is not null then
    INSERT INTO Contenido(
        es_contenido,
        contenedor
    )
    VALUES(
        v_id_lugar,
        p_contenedor
    );    
    END IF;

    IF p_propietario is not null THEN
        INSERT INTO Es_Dueno(
            propietario,
            lugar,
            fecha_comienzo            
        )
        VALUES(
            p_propietario,
            v_id_lugar,
            sysdate
        );
    END IF;
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END crear_lugar_2_1;



/*Requerimiento 2.2
Implementar un servicio que permita la transferencia de la titularidad de un lugar entre dos cuentas.
Se debe verificar que la cuenta que transfiere sea realmente la que administra el lugar y que ambas
se encuentren correctamente habilitadas para la transferencia.*/


CREATE OR REPLACE PROCEDURE transferir_propietario_2_2 (
    p_prop_actual IN propietario.IdCuenta%TYPE,
    p_prop_nuevo IN propietario.IdCuenta%TYPE,
    p_lugar IN Lugar.Identificador%TYPE
)AS
    v_cant_prop_actual NUMBER;
    v_cant_prop_actual_activo NUMBER;
    v_cant_prop_nuevo NUMBER;
    v_cant_prop_nuevo_activo NUMBER;
    v_cant_lugar NUMBER;
    v_cant_duenio NUMBER;
BEGIN

    --VALIDAR PROPIETARIOS DIFERENTES
    IF p_prop_actual = p_prop_nuevo THEN
    RAISE_APPLICATION_ERROR(
        -20200,
        'El propietario actual y el nuevo deben ser diferentes'
    );
    END IF;
    
    --VALIDAR PROPIETARIO ACTUAL
    --Existe
    validar_existencia(
        p_valor_existencia => p_prop_actual,
        p_tabla => 'Propietario',
        p_campo => 'IdCuenta',
        p_out => v_cant_prop_actual
    );

    IF v_cant_prop_actual <> 1 THEN
        RAISE_APPLICATION_ERROR(-20201, 'Error, se ingreso un propietario actual inexistente');
    END IF;

    --Esta activo
    SELECT count(*)
    INTO v_cant_prop_actual_activo
    FROM Cuenta
    WHERE Correo_Electronico = p_prop_actual
    AND estado = 'A';

    IF v_cant_prop_actual_activo <> 1 THEN
        RAISE_APPLICATION_ERROR(-20202, 'Error, el propietario actual ingresado no esta activo');
    END IF;

    --VALIDAR PROPIETARIO NUEVO
    --Existe
    validar_existencia(
        p_valor_existencia => p_prop_nuevo,
        p_tabla => 'Propietario',
        p_campo => 'IdCuenta',
        p_out => v_cant_prop_nuevo
    );

    IF v_cant_prop_nuevo <> 1 THEN
        RAISE_APPLICATION_ERROR(-20203, 'Error, se ingreso un propietario nuevo inexistente');
    END IF;

    --Esta activo
    SELECT count(*)
    INTO v_cant_prop_nuevo_activo
    FROM Cuenta
    WHERE Correo_Electronico = p_prop_nuevo
    AND estado = 'A';

    IF v_cant_prop_nuevo_activo <> 1 THEN
        RAISE_APPLICATION_ERROR(-20204, 'Error, el propietario nuevo ingresado no esta activo');
    END IF;


    --VALIDAR LUGAR
    --Existe
    validar_existencia(
        p_valor_existencia => p_lugar,
        p_tabla => 'Lugar',
        p_campo => 'Identificador',
        p_out => v_cant_lugar
    );

    IF v_cant_lugar <> 1 THEN
        RAISE_APPLICATION_ERROR(-20205, 'Error, el lugar ingresado no existe');
    END IF;

    --El propietario actual posee el lugar
    SELECT count(*)
    INTO v_cant_duenio
    FROM Es_Duenio
    WHERE IdPropietario = p_prop_actual
    AND IdLugar = p_lugar
    AND ((Fecha_Fin IS NULL) OR (Fecha_Fin > SYSDATE));

    IF v_cant_duenio <> 1 THEN
        RAISE_APPLICATION_ERROR(-20206, 'Error, el lugar no pertenece al duenio actual especificado');
    END IF;

    --Todas las validaciones completadas, se procede con la transferencia
    
    --Actualizar fecha fin del propietario actual
    UPDATE Es_Duenio
    SET Fecha_Fin = SYSDATE
    WHERE IdPropietario = p_prop_actual
    AND IdLugar = p_lugar
    AND (Fecha_Fin IS NULL OR Fecha_Fin > SYSDATE);

    --Insertar tupla para es_Duenio
    INSERT INTO Es_Duenio (IdPropietario, IdLugar, Fecha_Comienzo)
    VALUES (p_prop_nuevo, p_lugar, SYSDATE);
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END transferir_propietario_2_2;








/*Requerimiento 2.3
Implementar un servicio que permita a una cuenta subir una fotografía de un lugar. Es importante
considerar que el número de foto debe asignarse de forma correlativa dentro del lugar.*/
CREATE OR REPLACE PROCEDURE subir_foto_2_3 (
    p_cuenta IN Cuenta.correo_electronico%TYPE,
    p_lugar IN Fotografia.idlugar%TYPE,
    p_imagen IN Fotografia.imagen%TYPE,
    p_fecha_tomada IN Fotografia.fecha_tomada%TYPE default null,
    p_descripcion IN Fotografia.descripcion%TYPE default null
) AS
    v_existe_lugar NUMBER;
    v_existe_cuenta NUMBER;
    v_cuenta_activa NUMBER;
    v_numero_foto NUMBER;
    v_bloqueo_lugar Lugar.Identificador%TYPE;
BEGIN

    --VALIDAR LUGAR
    --Existe
    validar_existencia(
        p_valor_existencia => p_lugar,
        p_tabla => 'LUGAR',
        p_campo => 'Identificador',
        p_out => v_existe_lugar
    );

    IF v_existe_lugar <> 1 THEN
        RAISE_APPLICATION_ERROR(-20301, 'Error, se ingreso un lugar inexistente');
    END IF;

    --VALIDAR CUENTA
    --Existe
    validar_existencia(
        p_valor_existencia => p_cuenta,
        p_tabla => 'CUENTA',
        p_campo => 'Correo_Electronico',
        p_out => v_existe_cuenta
    );

    IF v_existe_cuenta <> 1 THEN
        RAISE_APPLICATION_ERROR(-20302, 'Error, se ingreso una cuenta inexistente');
    END IF;

    --Esta activa
    SELECT CASE
                WHEN EXISTS (
                    SELECT 1
                    FROM Cuenta
                    WHERE Correo_Electronico = p_cuenta
                    AND estado = 'A'
                )
                THEN 1
                ELSE 0
              END
    INTO v_cuenta_activa
    FROM DUAL;

    IF v_cuenta_activa <> 1 THEN
        RAISE_APPLICATION_ERROR(-20303, 'Error, la cuenta no esta activa');
    END IF;

    --VALIDACIONES CORRECTAS SE PROCEDE CON LA INSERCIÓN

    --Bloquear identificador de lugar
    SELECT Identificador
    INTO v_bloqueo_lugar
    FROM Lugar
    WHERE Identificador = p_lugar
    FOR UPDATE;

    --Generar el número correlativo de la foto
    SELECT NVL(MAX(Numero_Foto), 0) + 1
    INTO v_numero_foto
    FROM Fotografia
    WHERE IdLugar = p_lugar;

    --Insertar
    INSERT INTO Fotografia (
        IdLugar,
        Identificador,
        Imagen,
        Fecha_Tomada,
        Descripcion
    )
    VALUES (
        p_lugar,
        v_numero_foto,
        p_imagen,
        p_fecha_tomada,
        p_descripcion
    );

    INSERT INTO Subida_Por(
    IdFotografia, 
    IdLugar, 
    IdCuenta
    )
    VALUES (
        v_numero_foto,
        p_lugar,
        p_cuenta
    );
    
    COMMIT;    

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END subir_foto_2_3;