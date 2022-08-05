
use AprendiendoSQL

if object_id('libros') is not null
  drop table libros;

create table libros(
  codigo int identity,
  titulo varchar(40),
  autor varchar(30),
  editorial varchar(20),
  precio decimal(5,2),
  primary key(codigo) 
);

go

insert into libros values ('Uno','Richard Bach','Planeta',15);
insert into libros values ('Ilusiones','Richard Bach','Planeta',12);
insert into libros values ('El aleph','Borges','Emece',25);
insert into libros values ('Aprenda PHP','Mario Molina','Nuevo siglo',50);
insert into libros values ('Matematica estas ahi','Paenza','Nuevo siglo',18);
insert into libros values ('Puente al infinito','Richard Bach','Sudamericana',14);
insert into libros values ('Antología','J. L. Borges','Paidos',24);
insert into libros values ('Java en 10 minutos','Mario Molina','Siglo XXI',45);
insert into libros values ('Antología','Borges','Planeta',34);

if object_id('pa_autor_promedio') is not null
  drop proc pa_autor_promedio;

go

--  Creamos un procedimiento almacenado para que reciba el nombre de un autor
--  y nos retorne el promedio de los precios de todos los libros de tal autor:
create procedure pa_autor_promedio
  @autor varchar(30)='%',
  @promedio decimal(6,2) output
  as 
  select @promedio=avg(precio)
   from libros
   where autor like @autor;

go

exec sp_help pa_autor_promedio;

exec sp_helptext pa_autor_promedio;

exec sp_stored_procedures;

exec sp_stored_procedures 'pa_%';

exec sp_depends pa_autor_promedio;

exec sp_depends libros;

select * from sysobjects;

select * from sysobjects
  where xtype='P' and-- tipo procedimiento
  name like 'pa%'--búsqueda con comodín;

drop proc pa_autor_promedio;

exec sp_depends libros;