drop table direccion;

create table direccion(
        id int not null, 
        numero int not null,
        calle varchar(60) not null,
        ciudad varchar(60) not null,
        pais varchar(60) not null,
        primary key (id)        
);



/*
Sitioweb(idlugar, sitio)
	PK: (sitio, lugar)
	FK: idlugar  -> lugar(id)

Telefono_Lugar(idlugar, numero)
	PK: (numero,lugar)
	FK: idlugar  -> lugar(id)

Categoria(id, nombre, descripcion)
	PK: (id)

Categoria_Secundaria(categoria, lugar)
	PK: (categoria, lugar)
	FK: categoria -> Categoria(id)
	FK: lugar -> Lugar(id)

Contenido(es_contenido, contenedor)
	PK: (es_contenido) 
	FK: es_contenido -> Lugar(id)
	FK: contenedor -> Lugar(id)

Horario(lugar, dia_semana, hora_cierre, hora_apertura)
	PK: (lugar, dia_semana)
	FK: lugar-> Lugar(id)

Cuenta(correo_electronico, pais_residencial, nombre, idioma_preferido, estado, fecha_creacion)
	PK: (correo_electronico)

Telefono_Cuenta(cuenta, telefono)
	PK: (numero, cuenta) //No sería teléfono tambien?
	FK: cuenta-> Cuenta(correo_electronico)

Guia_Local(cuenta, fecha_ingreso)
	PK: (cuenta)
	FK: cuenta-> Cuenta(correo_electronico)

Propietario(cuenta, fecha_verificacion_titulo, metodo_verificacion, rut, razon_social)
	PK: (cuenta)
	AK: razon_social
	FK: cuenta-> Cuenta(correo_electronico)

Es_Dueño(propietario, lugar, fecha_comienzo, fecha_fin)
	PK: (lugar, propietario)
	FK: lugar-> Lugar(id)
	FK: propietario-> Propietario(id)

Fotografia(id, lugar, fecha_subida, fecha_tomada, descripcion)
	PK: (id, lugar)
	FK: lugar-> Lugar(id)

Subida_Por(lugar, id, cuenta) 
	PK: (lugar, id)
	FK: lugar,id-> Fotografia(lugar,id)
	FK: cuenta -> Cuenta(correo_electronico) //esto estaría mal? Para que sepa de cuenta??

Reseña(id, texto, puntaje, idioma, fecha_subida, lugar, cuenta)
	PK: (id)
	FK: lugar-> Lugar(id)
FK: cuenta-> Cuenta(id)
// en el caso de “CreadoPor”, no se tendría que poner? por el tema del trigger, o se hace en otro lado entonces? 
LeGusta(cuenta, resenia, fecha)
	PK: (cuenta, resenia)
	FK: cuenta-> Cuenta(id)
	FK: resenia-> Reseña(id)

Respuesta(id, texto, fecha_publicacion, resenia)
	PK: (id)
	FK: resenia-> Reseña(id)

Dada_Por(respuesta, propietario)
	PK: (respuesta)
	FK: propietario-> Propietario(id)
	FK: respuesta-> Respuesta(id)

*/

--Direccion(id, numero, calle, ciudad, pais) //Colocamos su tipo?
CREATE TABLE Direccion(
Identificador NUMBER(12),
Numero NUMBER(5) NOT NULL,-- puse 5 por si acaso
Calle VARCHAR (50) NOT NULL,
Ciudad VARCHAR (50) NOT NULL,
Pais VARCHAR (50) NOT NULL,
PRIMARY KEY (Identificador)
);

--Lugar( id, estado, nombre, longitud, latitud, direccion, categoria_principal)
    
CREATE TABLE Lugar(
Identificador NUMBER(12),
Estado CHAR(2) NOT NULL CHECK(Estado in ('OP','CT','CD')),
Nombre VARCHAR(20) NOT NULL,
Longitud NUMBER(3) NOT NULL,--Longitud va de -180 a 180
Latitud NUMBER(2) NOT NULL,--Latitud va de -90 a 90
Direccion NUMBER(12),
Categoria_principal NUMBER(12),
PRIMARY KEY (Identificador),
FOREIGN KEY (direccion) REFERENCES Direccion (Identificador),
FOREIGN KEY (categoria_principal) REFERENCES Categoria (Identificador)
);

--Sitioweb(idlugar, sitio)

    
CREATE TABLE SitioWeb(
IdLugar NUMBER(12),
Sitio VARCHAR(20) NOT NULL, --Que tan grande se hace? es el url o el nombre de la pagina?
PRIMARY KEY (IdLugar,Sitio),
FOREIGN KEY (IdLugar) REFERENCES Lugar (Identificador)
);

