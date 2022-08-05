
use AprendiendoSQL;

/*
Vamos a crear procedimientos que incluyan combinaciones (join), subconsultas, varias instrucciones
y llamadas a otros procedimientos.
Un club dicta clases de distintos deportes. Almacena la información en varias tablas:

- deportes: codigo y nombre,
- cursos: numero de curso, codigo de deporte, documento del profesor que lo dicta 
  y dia de la semana,
- profesores: documento, nombre y domicilio,
- socios: documento, nombre y domicilio,
- inscriptos: documento del socio, número del curso y si la matricula está paga o no.

Una vez por semana se dicta cada curso.
Puede haber varios cursos de un mismo deporte que se dicten distintos días y/o por
distintos profesores. Por ejemplo: curso 1 de natación los lunes por Carlos Caseres,
curso 2 de natación los martes por Carlos Caseres y curso 3 de natación los miércoles por Ana Acosta.
Un profesor puede estar a cargo de distintos cursos, incluso de distintos deportes.
Por ejemplo: curso 1 de natación los lunes por Carlos Caseres y curso 4 de tenis los miércoles por Carlos Caseres.
Quien se inscriba debe ser socio, es decir, debe estar en la tabla "socios".
Un socio no puede inscribirse en un mismo curso.
*/

-- Eliminamos las tablas si existen y las creamos:
if (object_id('inscriptos')) is not null
  drop table inscriptos;
if (object_id('deportes')) is not null
  drop table deportes;
if (object_id('cursos')) is not null
  drop table cursos;
if (object_id('profesores')) is not null
  drop table profesores;
if (object_id('socios')) is not null
  drop table socios;

create table deportes(
  codigo tinyint identity,
  nombre varchar(30),
  primary key (codigo)
);

create table profesores(
  documento char(8),
  nombre varchar(30),
  domicilio varchar(30),
  primary key (documento)
);

create table socios(
  documento char(8),
  nombre varchar(30),
  domicilio varchar(30),
  primary key (documento)
);

create table cursos(
  numero tinyint identity,
  codigodeporte tinyint not null,
  documentoprofesor char(8) not null,
  dia varchar(15),
  constraint PK_cursos_numero
   primary key clustered (numero),
  constraint FK_cursos_documentoprofesor
   foreign key (documentoprofesor)
   references profesores(documento)
   on update cascade,
  constraint FK_cursos_codigodeporte
   foreign key (codigodeporte)
   references deportes(codigo)
);

create table inscriptos(
  documentosocio char(8) not null,
  numero tinyint not null,
  matricula char(1) --'s'=paga 'n'=impaga,
  constraint PK_inscriptos_documentosocio_numero
   primary key(documentosocio,numero),
  constraint FK_inscriptos_documentosocio
   foreign key (documentosocio)
   references socios(documento),
  constraint FK_inscriptos_numero
   foreign key (numero)
   references cursos(numero)
);

go

-- Ingresamos algunos registros para todas las tablas:
 insert into deportes values('tenis');
 insert into deportes values('natacion');
 insert into deportes values('basquet');
 insert into deportes values('futbol');
 
 insert into profesores values('22222222','Ana Acosta','Colon 123');
 insert into profesores values('23333333','Carlos Caseres','Sarmiento 847');
 insert into profesores values('24444444','Daniel Duarte','Avellaneda 284');
 insert into profesores values('25555555','Fabiola Fuentes','Caseros 456');
 insert into profesores values('26666666','Gaston Garcia','Bulnes 345');

 insert into cursos values(1,'22222222','jueves');
 insert into cursos values(1,'22222222','viernes');
 insert into cursos values(1,'23333333','miercoles');
 insert into cursos values(2,'22222222','miercoles');
 insert into cursos values(2,'23333333','lunes');
 insert into cursos values(2,'23333333','martes');
 insert into cursos values(3,'24444444','lunes');
 insert into cursos values(3,'24444444','jueves');
 insert into cursos values(3,'25555555','martes');
 insert into cursos values(3,'25555555','viernes');
 insert into cursos values(4,'24444444','martes');
 insert into cursos values(4,'24444444','miercoles');
 insert into cursos values(4,'24444444','viernes');

 insert into socios values('31111111','Luis Lopez','Colon 464');
 insert into socios values('30000000','Nora Nores','Bulnes 234');
 insert into socios values('33333333','Mariano Morales','Sucre 464');
 insert into socios values('32222222','Patricia Perez','Peru 1234');
 insert into socios values('34444444','Susana Suarez','Salta 765');

 insert into inscriptos values('30000000',1,'s');
 insert into inscriptos values('30000000',4,'n');
 insert into inscriptos values('31111111',1,'s');
 insert into inscriptos values('31111111',4,'s');
 insert into inscriptos values('31111111',7,'s');
 insert into inscriptos values('31111111',13,'s');
 insert into inscriptos values('32222222',1,'s');
 insert into inscriptos values('32222222',4,'s');

 
 -- Eliminamos el procedimiento "pa_inscriptos", si existe:
 if (object_id('pa_inscriptos')) is not null
  drop proc pa_inscriptos;

 go

-- Creamos un procedimiento que muestre el nombre del socio, el nombre del deporte,
-- el día, el profesor y la matrícula.
-- Si necesitamos esta información frecuentemente, este procedimiento nos evita tipear
-- este join repetidamente; además si no queremos que el usuario conozca la estructura
-- de las tablas involucradas, éste y otros procedimientos permiten el acceso a ellas.
 create procedure pa_inscriptos
  as
   select s.nombre, d.nombre, dia, p.nombre, matricula
   from socios as s
   join inscriptos as i
   on s.documento=i.documentosocio
   join cursos as c
   on c.numero=i.numero
   join deportes as d
   on c.codigodeporte=d.codigo
   join profesores as p
   on c.documentoprofesor=p.documento;

 go

-- Ejecutamos el procedimiento:
 exec pa_inscriptos;

-- Eliminamos el procedimiento "pa_documentovalido", si existe:
 if (object_id('pa_documentovalido')) is not null
  drop proc pa_documentovalido;

  go

-- Creamos un procedimiento que reciba un documento y nos retorne distintos valores según:
-- sea nulo (1), no sea válido (2), no esté en la tabla "socios" (3), sea un socio deudor 
--(4) o sea un socio sin deuda (0)
-- Este procedimiento recibe parámetro, emplea "return" e incluye subconsultas.
 create procedure pa_documentovalido
  @documento char(8)=null
  as
   if @documento is null return 1
   else 
    if len(@documento)<8 return 2
    else
     if not exists (select *from socios where documento=@documento) return 3
     else
     begin
      if exists (select *from inscriptos
                where documentosocio=@documento and
                matricula='n') return 4
      else return 0
     end;

 go

-- Eliminamos el procedimiento "pa_deportediavalido", si existe:
 if (object_id('pa_deportediavalido')) is not null
  drop proc pa_deportediavalido;

  go

-- Creamos un procedimiento al cual le enviamos el nombre de un deporte y el día y 
-- nos retorna un valor diferente según: el nombre del deporte o día sean nulos (1),
-- el día sea inválido (2), deporte no se dicte (3), el deporte se dicte pero no el
-- día ingresado (4) o el deporte se dicte el día ingresado (0):
 create procedure pa_deportediavalido
  @deporte varchar(30)=null,
  @dia varchar (15)=null
  as
   if @deporte is null or @dia is null return 1
   else
    if @dia not in ('lunes','martes','miercoles','jueves','viernes','sabado') return 2
    else
    begin
     declare @coddep tinyint
     select @coddep= codigo from deportes where nombre=@deporte
     if @coddep is null return 3
     else
      if not exists(select *from cursos where codigodeporte=@coddep and dia=@dia) return 4
      else return 0
    end;

 go

-- Eliminamos el procedimiento "pa_ingreso", si existe:
 if (object_id('pa_ingreso')) is not null
  drop proc pa_ingreso;

 go

-- Creamos un procedimiento que nos permita ingresar una inscripción con los siguientes datos:
-- documento del socio, nombre del deporte, dia y matrícula.
-- El procedimiento llamará a los procedimientos "pa_documentovalido" y "pa_deportediavalido"
-- (creados anteriormente) y mostrará diferentes mensajes. Un socio que deba alguna matrícula NO debe poder 
-- inscribirse en ningún curso:
 create procedure pa_ingreso
  @documento char(8)=null,
  @deporte varchar(20)=null,
  @dia varchar(20)=null,
  @matricula char(1)=null
  as
   --verificamos el documento
   declare @doc int
   exec @doc=pa_documentovalido @documento
   if @doc=1 select 'Ingrese un documento'
   else
    if @doc=2 select 'Documento debe tener 8 digitos'
    else
     if @doc=3 select @documento+' no es socio'
     else
      if @doc=4 select 'Socio '+ @documento+' debe matriculas'
  --verificamos el deporte y el dia
   declare @depdia int
   exec @depdia=pa_deportediavalido @deporte, @dia
   if @depdia=1 select 'Ingrese deporte y dia'
   else
    if @depdia=2 select 'Ingrese día válido'
    else
     if @depdia=3 select @deporte+' no se dicta'
     else
      if @depdia=4 select @deporte+' no se dicta el '+ @dia
   
   --verificamos que el socio no esté inscripto ya en el deporte el día solicitado
   if @doc=0 and @depdia=0
   begin
     declare @codcurs int
     select @codcurs=c.numero from cursos as c
                     join deportes as d
                     on c.codigodeporte=d.codigo
	             where @deporte=d.nombre and
                     @dia=c.dia
     if exists (select *from inscriptos as i
                join cursos as c
                on i.numero=c.numero
                where @codcurs=i.numero and 
                i.documentosocio=@documento)
            select 'Ya está inscripto en '+@deporte+' el '+ @dia
     else
       if @matricula is null or @matricula='s' or @matricula='n'
       begin
        insert into inscriptos values(@documento,@codcurs,@matricula)
        print 'Inscripción del socio '+@documento+' para '+@deporte+' el '+@dia+' realizada'  
       end
       else select 'Matricula debe ser s, n o null'
   end;

   go

-- Podemos ejecutar el procedimiento "pa_ingreso" con distintos valores para ver el resultado.
-- Enviamos un documento que no está en "socios":
 exec pa_ingreso '22222222';

-- Enviamos un documento de un socio que tiene deudas:
 exec pa_ingreso '30000000';

-- Enviamos un documento de un socio que no tiene deudas, pero falta el deporte y el día:
 exec pa_ingreso '31111111';

-- Enviamos valor de día inválido:
 exec pa_ingreso '31111111','tenis','sabado';

-- Enviamos datos que ya están en la tabla "inscriptos":
 exec pa_ingreso '31111111','tenis','jueves';

-- Enviamos el documento de un socio y un deporte y día en el cual no está inscripto:
 exec pa_ingreso '33333333','tenis','jueves';

-- Podemos verificar este ingreso consultando "pa_inscriptos":
 exec pa_inscriptos;

-- Eliminamos el procedimiento "pa_profesor", si existe:
 if (object_id('pa_profesor')) is not null
  drop proc pa_profesor;

 go
 
-- Creamos un procedimiento que recibe el documento de un profesor y nos muestra los 
-- distintos deportes de los cuales está a cargo y los días en que se dictan: 
 create proc pa_profesor
  @documento char(8)=null
 as
  if @documento is null or len(@documento)<8
    select 'Ingrese un documento válido'
  else
  begin
   declare @nombre varchar(30)
   select @nombre=nombre from profesores where documento=@documento
   if @nombre is null select 'No es profesor'
   else
     if not exists(select *from cursos where documentoprofesor=@documento)
       select 'El profesor '+@nombre+' no tiene cursos asignados'
     else
       select d.nombre,c.dia
        from cursos as c
        join deportes as d
        on c.codigodeporte=d.codigo
        where c.documentoprofesor=@documento
  end;

 go

-- Ejecutamos el procedimiento creado anteriormente enviando un documento que 
-- no está en la tabla "profesores":
 exec pa_profesor '34343434';

-- Nuevamente ejecutamos el procedimiento creado anteriormente, esta vez con
-- un documento existente en "profesores": 
 exec pa_profesor '22222222';

-- Eliminamos el procedimiento "pa_inscriptos_por_curso", si existe:
 if (object_id('pa_inscriptos_por_curso')) is not null
  drop proc pa_inscriptos_por_curso;

 go

-- Creamos un procedimiento que recibe un parámetro correspondiente al nombre de un deporte
-- y muestra los distintos cursos (número, día y profesor) y la cantidad de inscriptos; 
-- en caso que el parámetro sea "null", muestra la información de todos los cursos:
 create procedure pa_inscriptos_por_curso
  @deporte varchar(20)=null
 as
  if @deporte is null
    select c.numero,d.nombre,dia,p.nombre,
     (select count(*)
     from inscriptos as i
     where i.numero=c.numero) as cantidad
     from cursos as c
     join deportes as d
     on c.codigodeporte=d.codigo
     join profesores as p 
     on p.documento=c.documentoprofesor
  else
    select c.numero,dia,p.nombre,
     (select count(*)
     from inscriptos as i
     where i.numero=c.numero) as cantidad
     from cursos as c
     join deportes as d
     on c.codigodeporte=d.codigo
     join profesores as p 
     on p.documento=c.documentoprofesor
     where d.nombre=@deporte;    

 go

-- Ejecutamos el procedimiento sin enviar valor para el parámetro:
 exec pa_inscriptos_por_curso;

 -- Ejecutamos el procedimiento enviando un valor:
 exec pa_inscriptos_por_curso 'tenis';

-- Ejecutamos el procedimiento enviando otro valor:
 exec pa_inscriptos_por_curso 'voley';

-- Veamos las dependencias. Ejecutamos "sp_depends" con distintos objetos:
 exec sp_depends socios;

 exec sp_depends profesores;

 exec sp_depends cursos;

 exec sp_depends deportes;

 exec sp_depends inscriptos;

-- Vemos las dependencias de los distintos procedimientos:
 exec sp_depends pa_documentovalido;

 exec sp_depends pa_inscriptos;

 exec sp_depends pa_deportediavalido;

 exec sp_depends pa_ingreso;

 exec sp_depends pa_profesor;

 exec sp_depends pa_inscriptos_por_curso;