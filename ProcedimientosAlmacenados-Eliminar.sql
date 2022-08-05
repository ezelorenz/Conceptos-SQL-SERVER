use AprendiendoSQL

-- Eliminamos, si existe, el procedimiento almacenado "pa_crear_libros":
if object_id('pa_crear_libros') is not null
  drop procedure pa_crear_libros;

-- Verificamos que no existe ejecutando "sp_help":
exec sp_help pa_crear_libros;

go

-- Creamos el procedimiento:
create procedure pa_crear_libros 
 as
  if object_id('libros')is not null
   drop table libros
  create table libros(
   codigo int identity,
   titulo varchar(40),
   autor varchar(30),
   editorial varchar(20),
   precio decimal(5,2),
   cantidad smallint,
   primary key(codigo)
  )
  insert into libros values('Uno','Richard Bach','Planeta',15,5)
  insert into libros values('Ilusiones','Richard Bach','Planeta',18,50)
  insert into libros values('El aleph','Borges','Emece',25,9)
  insert into libros values('Aprenda PHP','Mario Molina','Nuevo siglo',45,100)
  insert into libros values('Matematica estas ahi','Paenza','Nuevo siglo',12,50)
  insert into libros values('Java en 10 minutos','Mario Molina','Paidos',35,300);

go
 
-- Verificamos que existe:
exec sp_help pa_crear_libros;

-- Lo eliminamos sin corroborar su existencia:
drop proc pa_crear_libros;

-- Vemos si aparece en la lista de objetos que muestra "sp_help":
exec sp_help pa_crear_libros;

-- Solicitamos su eliminación nuevamente (No existe, aparece un mensaje de error):
drop proc pa_crear_libros;

-- Solicitamos su eliminación verificando si existe, si no existe, mostramos un mensaje:
if object_id('pa_crear_libros') is not null
  drop proc pa_crear_libros
else 
  select 'No existe el procedimiento "pa_crear_libros"';

