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
    v_direccion_insertada NUMBER := 0;
    v_valores_direccion NUMBER := 0;
    v_contenedor_insertado NUMBER := 0;


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

        SELECT count(*)
        INTO v_direccion_insertada
        FROM Direccion
        WHERE Identificador = p_direccion;

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

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END crear_lugar_2_1;