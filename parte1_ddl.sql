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
Identificador NUMBER(12) GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
Numero NUMBER(5) NOT NULL,-- puse 5 por si acaso
Calle VARCHAR (50) NOT NULL,
Ciudad VARCHAR (50) NOT NULL,
Pais VARCHAR (50) NOT NULL
);

--Lugar( id, estado, nombre, longitud, latitud, direccion, categoria_principal)
    
CREATE TABLE Lugar(
Identificador NUMBER(12) GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
Estado CHAR(2) NOT NULL CHECK(Estado in ('OP','CT','CD')),
Nombre VARCHAR(20) NOT NULL,
Longitud NUMBER(3) NOT NULL,--Longitud va de -180 a 180
Latitud NUMBER(2) NOT NULL,--Latitud va de -90 a 90
Direccion NUMBER(12) NOT NULL,
Categoria_principal NUMBER(12),
FOREIGN KEY (direccion) REFERENCES Direccion (Identificador),
FOREIGN KEY (categoria_principal) REFERENCES Categoria (Identificador)
);


--Sitioweb(idlugar, sitio)

    
CREATE TABLE SitioWeb(
IdLugar NUMBER(12),
Sitio VARCHAR(150) NOT NULL,
PRIMARY KEY (IdLugar,Sitio),
FOREIGN KEY (IdLugar) REFERENCES Lugar (Identificador)
);

CREATE TABLE Telefono_Lugar (
    lugar NUMBER(12),
    numero NUMBER(12),
    PRIMARY KEY(numero,lugar),
    FOREIGN KEY(lugar) REFERENCES Lugar(Identificador)
);

CREATE TABLE Categoria (
    Identificador NUMBER(3),
    nombre VARCHAR(40) NOT NULL,
    descripcion VARCHAR(200) NOT NULL,
    PRIMARY KEY (Identificador)
);

CREATE TABLE Categoria_Secundaria(
    categoria NUMBER(3),
    lugar NUMBER(12),
    PRIMARY KEY (categoria,lugar),
    FOREIGN KEY (categoria) REFERENCES Categoria (Identificador),
    FOREIGN KEY(lugar) REFERENCES Lugar(Identificador)
);

CREATE TABLE Contenido (
    es_contenido NUMBER(12), 
    contenedor NUMBER(12) NOT NULL,
    PRIMARY KEY es_contenido,
    FOREIGN KEY(es_contenido) REFERENCES Lugar(Identificador),
    FOREIGN KEY(contenedor) REFERENCES Lugar(Identificador)
);

CREATE TABLE Horario (
    lugar NUMBER(12),
    dia_semana CHAR(1) NOT NULL CHECK(dia_semana in ('L','M','X', 'J', 'V', 'S', 'D')),
    hora_cierre NUMBER CHECK((hora_cierre <=24) && (hora_cierre >=0)),
    hora_apertura NUMBER CHECK((hora_apertura <=24) && (hora_apertura >=0)),
    PRIMARY KEY (lugar, dia_semana),
    FOREIGN KEY(lugar) REFERENCES Lugar(Identificador),
    CONSTRAINT chk_cierre_despues_apertura CHECK (hora_cierre > hora_apertura)
);

CREATE TABLE Cuenta(
    correo_electronico VARCHAR(80), 
    pais_residencial VARCHAR(80), 
    nombre VARCHAR(50), 
    idioma_preferido VARCHAR(20), 
    estado CHECK(estado IN ('Activa', 'Suspendida')), 
    fecha_creacion DATE,
    PRIMARY KEY(correo_electronico)
);

CREATE TABLE Telefono_Cuenta(
    cuenta VARCHAR(80),
    numero NUMBER(12),
    PRIMARY KEY(cuenta,numero),
    FOREIGN KEY(cuenta) REFERENCES Cuenta(correo_electronico)
);

CREATE TABLE Guia_Local(
    cuenta VARCHAR(80),
    fecha_ingreso DATE,
    PRIMARY KEY(cuenta),
    FOREIGN KEY(cuenta) REFERENCES Cuenta(correo_electronico)
);

CREATE TABLE Propietario(
    cuenta VARCHAR(80),
    fecha_verificacion_titulo DATE, 
    metodo_verificacion CHAR(1) CHECK(metodo_verificacion in ('P','T','V')), 
    rut NUMBER(15), 
    razon_social varchar(20),
    PRIMARY KEY(cuenta),
    FOREIGN KEY(cuenta) REFERENCES Cuenta(correo_electronico)
);

CREATE TABLE Es_Dueno(
    propietario VARCHAR(80), 
    lugar NUMBER(12), 
    fecha_comienzo DATE, 
    fecha_fin DATE,
    PRIMARY KEY(propietario,lugar),
    FOREIGN KEY(lugar) REFERENCES Lugar(Identificador),
    FOREIGN KEY(propietario) REFERENCES Propietario(cuenta)
);