
use AprendiendoSQL;

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

-- Eliminamos la tabla "ofertas" si existe y la creamos con los mismos 
-- campos de la tabla "libros":
if object_id('ofertas') is not null
  drop table ofertas;
create table ofertas(
  titulo varchar(40),
  autor varchar(30),
  editorial varchar(20),
  precio decimal(5,2)
);

go

-- Eliminamos el procedimiento llamado "pa_ofertas", si existe:
if object_id('pa_ofertas') is not null
  drop procedure pa_ofertas;

go

-- Creamos el procedimiento para que seleccione los libros
-- cuyo precio no supera los 30 pesos:
create proc pa_ofertas
  as
  select titulo,autor,editorial,precio
   from libros
   where precio<=30;

go

-- Vamos a ingresar en la tabla "ofertas" el resultado devuelto 
-- por el procedimiento almacenado "pa_ofertas":
insert into ofertas exec pa_ofertas;

-- Veamos el contenido de "ofertas":
select * from ofertas;

-- Eliminamos la tabla "libros_por_editorial" si existe y 
--luego creamos la tabla con dos campos: nombre de editorial y cantidad:
if object_id('libros_por_editorial') is not null
  drop table libros_por_editorial;
create table libros_por_editorial(
  editorial varchar(20),
  cantidad int
);

go
 
-- Eliminamos el procedimiento llamado "pa_libros_por_editorial", si existe:
if object_id('pa_libros_por_editorial') is not null
  drop procedure pa_libros_por_editorial;

go

-- Creamos el procedimiento para que cuente la cantidad de libros de cada editorial:
create proc pa_libros_por_editorial
  as
  select editorial,count(*)
   from libros
   group by editorial;

go

-- Vamos a ingresar en la tabla "libros_por_editorial" el resultado devuelto 
-- por el procedimiento almacenado "pa_libros_por_editorial":
insert into libros_por_editorial exec pa_libros_por_editorial;

-- Veamos el contenido de la tabla "libros_por_editorial":
select * from libros_por_editorial;
