drop table direccion;

create table direccion(
        id int not null, 
        numero int not null,
        calle varchar(60) not null,
        ciudad varchar(60) not null,
        pais varchar(60) not null,
        primary key (id)        
);
