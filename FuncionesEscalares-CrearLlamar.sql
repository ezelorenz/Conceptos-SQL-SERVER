
use AprendiendoSQL;

-- El idioma de la sesión determina los formatos de fecha y hora
--  y los mensajes del sistema.
set language us_english; 

-- Una empresa tiene almacenados los datos de sus empleados en una tabla denominada "empleados".
--Eliminamos la tabla, si existe y la creamos con la siguiente estructura:
if object_id('empleados') is not null
  drop table empleados;

create table empleados(
  documento char(8) not null,
  nombre varchar(30),
  fechaingreso datetime,
  mail varchar(50),
  telefono varchar(12)
);

go

-- Fijamos el formato de la fecha
set dateformat ymd;

insert into empleados values('22222222', 'Ana Acosta','1985/10/10','anaacosta@gmail.com','4556677');
insert into empleados values('23333333', 'Bernardo Bustos', '1986/02/15',null,'4558877');
insert into empleados values('24444444', 'Carlos Caseros','1999/12/02',null,null);
insert into empleados values('25555555', 'Diana Dominguez',null,null,'4252525');

-- Eliminamos, si existe, la función "f_fechaCadena":
if object_id('dbo.f_fechaCadena') is not null
  drop function dbo.f_fechaCadena;

go

-- Creamos una función a la cual le enviamos una fecha (de tipo varchar),
-- en el cuerpo de la función se analiza si el dato enviado corresponde a una fecha, 
-- si es así, se almacena en una variable el mes (en español) y se le concatenan el día 
-- y el año y se retorna esa cadena; en caso que el valor enviado no corresponda a una fecha,
-- la función retorna la cadena 'Fecha inválida':
create function f_fechaCadena
 (@fecha varchar(25))
  returns varchar(25)
  as
  begin
    declare @nombre varchar(25)
    set @nombre='Fecha inválida'   
    if (isdate(@fecha)=1)
    begin
      set @fecha=cast(@fecha as datetime)
      set @nombre=
      case datename(month,@fecha)
       when 'January' then 'Enero'
       when 'February' then 'Febrero'
       when 'March' then 'Marzo'
       when 'April' then 'Abril'
       when 'May' then 'Mayo'
       when 'June' then 'Junio'
       when 'July' then 'Julio'
       when 'August' then 'Agosto'
       when 'September' then 'Setiembre'
       when 'October' then 'Octubre'
       when 'November' then 'Noviembre'
       when 'December' then 'Diciembre'
      end--case
      set @nombre=rtrim(cast(datepart(day,@fecha) as char(2)))+' de '+@nombre
      set @nombre=@nombre+' de '+ rtrim(cast(datepart(year,@fecha)as char(4)))
    end--si es una fecha válida
    return @nombre
 end;

go

-- Recuperamos los registros de "empleados", mostrando el nombre y la fecha
-- de ingreso empleando la función creada anteriormente:
select nombre, dbo.f_fechaCadena(fechaingreso) as ingreso from empleados;

-- Empleamos la función en otro contexto:
select dbo.f_fechaCadena(getdate());