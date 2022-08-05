
use AprendiendoSQL;

if object_id('libros') is not null
  drop table libros; 

create table libros(
  codigo int identity,
  titulo varchar(40),
  autor varchar(30),
  editorial varchar(20),
  precio decimal(6,2)
);

go

insert into libros values('Uno','Richard Bach','Planeta',15);
insert into libros values('Ilusiones','Richard Bach','Planeta',10);
insert into libros values('El aleph','Borges','Emece',25);
insert into libros values('Aprenda PHP','Mario Molina','Siglo XXI',55);
insert into libros values('Alicia en el pais','Lewis Carroll','Paidos',35);
insert into libros values('Matematica estas ahi','Paenza','Nuevo siglo',25);

-- Eliminamos la función "f_ofertas" si existe":
if object_id('f_ofertas') is not null
  drop function f_ofertas; 

go

-- Creamos la función "f_ofertas" que reciba un parámetro correspondiente a un precio y 
-- nos retorne una tabla con código, título, autor y precio de todos los libros cuyo
-- precio sea inferior al parámetro:
create function f_ofertas
 (@minimo decimal(6,2)
 )
 returns @ofertas table-- nombre de la tabla
 --formato de la tabla
 (codigo int,
  titulo varchar(40),
  autor varchar(30),
  precio decimal(6,2)
 )
 as
 begin
   insert @ofertas
    select codigo,titulo,autor,precio
    from libros
    where precio<@minimo
   return
 end;

go

--Llamamos a la función como si fuera una tabla, recuerde que podemos
-- omitir el nombre del propietario:
select * from f_ofertas(30);

-- Realizamos un join entre "libros" y la tabla retornada por la función 
-- "f_ofertas" y mostramos todos los campos de "libros". 
-- Incluimos una condición para el autor:
select l.titulo,l.autor,l.editorial
  from libros as l
  join dbo.f_ofertas(25) as o
  on l.codigo=o.codigo
  where l.autor='Richard Bach';

-- La siguiente consulta nos retorna algunos campos de la tabla 
--retornada por "f_ofertas" y algunos registros que cumplen 
-- con la condición "where":
select titulo,precio from f_ofertas(40)
  where autor like '%B%';

-- Eliminamos la función "f_listadolibros" si existe":
if object_id('f_listadolibros') is not null
  drop function f_listadolibros; 

go

-- Creamos otra función que retorna una tabla:
create function f_listadolibros
 (@opcion varchar(10)
 )
 returns @listado table
 (titulo varchar(40),
 detalles varchar(60)
 )
 as 
 begin
  if @opcion not in ('autor','editorial')
    set @opcion='autor'
  if @opcion='editorial'
   insert @listado 
    select titulo,
   (editorial+'-'+autor) from libros
   order by 2
  else
    if @opcion='autor'
     insert @listado
     select titulo,
     (autor+'-'+editorial) from libros  
     order by 2
  return
end;

go

-- Llamamos a la función enviando el valor "autor":
select * from dbo.f_listadolibros('autor');

-- Llamamos a la función enviando el valor "editorial":
select * from dbo.f_listadolibros('editorial');

-- Llamamos a la función enviando un valor inválido:
select * from dbo.f_listadolibros('precio');