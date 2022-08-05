
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
insert into libros values ('Antolog�a','J. L. Borges','Paidos',24);
insert into libros values ('Java en 10 minutos','Mario Molina','Siglo XXI',45);
insert into libros values ('Antolog�a','Borges','Planeta',34);

if object_id('pa_libros_autor') is not null
  drop procedure pa_libros_autor;

go

-- Creamos el procedimiento almacenado "pa_libros_autor" con la opci�n de encriptado
-- para que muestre todos los t�tulos de los libros cuyo autor se env�a como argumento:
create procedure pa_libros_autor
  @autor varchar(30)=null
  with encryption
  as
   select titulo from libros
    where autor like @autor;

-- Ejecutamos el procedimiento:
exec pa_libros_autor 'Richard Bach';

-- Intentamos ver el contenido del procedimiento (No se puede porque est� encriptado):
exec sp_helptext pa_libros_autor;

go

-- Modificamos el procedimiento almacenado "pa_libros_autor" para que muestre, 
-- adem�s del t�tulo, la editorial y precio, quit�ndole la encriptaci�n:
alter procedure pa_libros_autor
  @autor varchar(30)=null
  as
   select titulo, editorial, precio from libros
    where autor like @autor;

go

-- Ejecutamos el procedimiento:
exec pa_libros_autor 'Borges';

-- Veamos el contenido del procedimiento (es posible porque ya no est� encriptado):
exec sp_helptext pa_libros_autor;

go

-- Modificamos el procedimiento almacenado "pa_libros_autor" para que,
--  en caso de no enviarle un valor, muestre todos los registros:
alter procedure pa_libros_autor
  @autor varchar(30)='%'
  as
   select titulo, editorial, precio from libros
    where autor like @autor;

go

-- Ejecutamos el procedimiento:
exec pa_libros_autor;