
use AprendiendoSQL;

if object_id('libros') is not null
  drop table libros;

create table libros(
  codigo int identity,
  titulo varchar(40),
  autor varchar(30),
  editorial varchar(20)
);

go

insert into libros values('Uno','Richard Bach','Planeta');
insert into libros values('El aleph','Borges','Emece');
insert into libros values('Ilusiones','Richard Bach','Planeta');
insert into libros values('Aprenda PHP','Mario Molina','Nuevo siglo');
insert into libros values('Matematica estas ahi','Paenza','Nuevo siglo');

if object_id('f_libros') is not null
  drop function f_libros;

go

-- Creamos una función que retorna una tabla en línea:
create function f_libros
 (@autor varchar(30)='Borges')
 returns table
 as
 return (
  select titulo,editorial
  from libros
  where autor like '%'+@autor+'%'
 );

go

-- Llamamos a la función creada anteriormente enviando un autor:
select * from f_libros('Bach');

go

-- La modificamos agregando otro campo en el "select":
alter function f_libros
 (@autor varchar(30)='Borges')
 returns table
 as
 return (
  select codigo,titulo,editorial
  from libros
  where autor like '%'+@autor+'%'
 );

go

-- Probamos la función para ver si se ha modificado:
select * from f_libros('Bach');