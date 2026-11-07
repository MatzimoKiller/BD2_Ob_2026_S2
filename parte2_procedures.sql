/*Parte 2
Se solicita cumplir con los siguientes requerimientos para la gestión de cuentas, lugares, categorías,
horarios, fotografías y reseñas (relacional):




Requerimiento 2.1
Implementar un servicio para facilitar la creación de un lugar. Se deberán proveer todos los datos
básicos necesarios para su creación, incluyendo su categoría principal y, si corresponde, el lugar al
que pertenece y su propietario.*/

CREATE OR REPLACE PROCEDURE crear_lugar_2_1 (
    p_nombre IN Lugar.nombre%TYPE,
    p_estado IN Lugar.Estado%TYPE,
    p_longitud IN Lugar.longitud%TYPE,
    p_latitud IN Lugar.latitud%TYPE,
    p_direccion IN Lugar.direccion%TYPE,
    p_categoria_principal IN Lugar.categoria_principal%TYPE,
    p_contenedor IN Contenido.contenedor%TYPE default null,
    p_propietario IN Es_Dueno.propietario%TYPE default null
) AS 
    --Declaracion de variables locales
    v_id_lugar Lugar.Identificador%TYPE;
    v_cant_cat NUMBER; 
    v_cant_prop NUMBER;
    v_cant_contenedor NUMBER;

BEGIN
    --VALIDAR CATEGORIA
    SELECT count(*)
    INTO v_cant_cat
    FROM Categoria
    WHERE Identificador = p_categoria_principal;

    IF v_cant_cat <> 1 THEN
        RAISE_APPLICATION_ERROR(-20101, 'Error, se ingreso una categoria inexistente');
    END IF;
    
    --VALIDAR PROPIETARIO
    IF p_propietario is not null then
        SELECT count(*)
        INTO v_cant_prop
        FROM Propietario
        WHERE cuenta = p_propietario;

        IF v_cant_prop <> 1 THEN
            RAISE_APPLICATION_ERROR(-20102, 'Error, se ingreso un propietario inexistente');
        END IF;

    END IF;

    --VALIDAR CONTENIDO
    IF p_contenedor is not null then
        SELECT count(*)
        INTO v_cant_contenedor
        FROM Lugar
        WHERE Identificador = p_contenedor;

        IF v_cant_contenedor <> 1 THEN
            RAISE_APPLICATION_ERROR(-20103, 'Error, se ingreso un lugar contenedor inexistente');
        END IF;

    END IF; 


    --Validaciones correctas, se insertan los registros 
    v_id_lugar:= seq_lugar.NEXTVAL; 


    INSERT INTO Lugar(
        Identificador,
        Nombre,
        Estado, 
        longitud, 
        latitud, 
        direccion, 
        categoria_principal
        )
        VALUES(
            v_id_lugar,
            p_nombre,
            p_estado,
            p_longitud,
            p_latitud,
            p_direccion,
            p_categoria_principal
        );

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

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END crear_lugar_2_1;