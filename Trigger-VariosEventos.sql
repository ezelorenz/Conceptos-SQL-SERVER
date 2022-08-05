use AprendiendoSQL;

if object_id('inscriptos') is not null
  drop table inscriptos;
if object_id('socios') is not null
  drop table socios;
if object_id('morosos') is not null
  drop table morosos;

create table socios(
  documento char(8) not null,
  nombre varchar(30),
  domicilio varchar(30),
  constraint PK_socios primary key(documento)
);

create table inscriptos(
  numero int identity,
  documento char(8) not null,
  deporte varchar(20),
  matricula char(1),
  constraint FK_inscriptos_documento
   foreign key (documento)
   references socios(documento),
  constraint CK_inscriptos_matricula check (matricula in ('s','n')),
  constraint PK_inscriptos primary key(documento,deporte)
);
 
create table morosos(
  documento char(8) not null
);

go

insert into socios values('22222222','Ana Acosta','Avellaneda 800');
insert into socios values('23333333','Bernardo Bustos','Bulnes 345');
insert into socios values('24444444','Carlos Caseros','Colon 382');
insert into socios values('25555555','Mariana Morales','Maipu 234');

insert into inscriptos values('22222222','tenis','s');
insert into inscriptos values('22222222','natacion','n');
insert into inscriptos values('23333333','tenis','n');
insert into inscriptos values('24444444','futbol','s');
insert into inscriptos values('24444444','natacion','s');

insert into morosos values('22222222');
insert into morosos values('23333333');

go

-- Creamos un trigger para evitar que se inscriban socios que deben matrículas y
-- no permitir que se eliminen las inscripciones de socios deudores.
-- El trigger se define para ambos eventos en la misma sentencia de creación.
create trigger dis_inscriptos_insert_delete
  on inscriptos
  for insert,delete
  as
   if exists (select *from inserted join morosos 
              on morosos.documento=inserted.documento)
   begin
     raiserror('El socio es moroso, no puede inscribirse en otro curso', 16, 1)
     rollback transaction
   end
   else
     if exists (select *from deleted join morosos
	        on morosos.documento=deleted.documento)
     begin
       raiserror('El socio debe matriculas, no puede borrarse su inscripcion', 16, 1)
       rollback transaction
     end
     else
      if (select matricula from inserted)='n'
       insert into morosos select documento from inserted;

go

-- Ingresamos una inscripción de un socio no deudor con matrícula paga:
insert into inscriptos values('25555555','tenis','s');
-- El disparador se activa ante el "insert" y permite la transacción.

-- Ingresamos una inscripción de un socio no deudor con matrícula 'n':
insert into inscriptos values('25555555','natacion','n');
-- El disparador se activa ante el "insert", permite la transacción y agrega 
-- al socio en la tabla "morosos".

--Verifiquémoslo consultando las tablas correspondientes: 
select * from inscriptos;
select * from morosos;

-- Ingresamos una inscripción de un socio deudor:
insert into inscriptos values('25555555','basquet','s');
-- El disparador se activa ante el "insert" y deshace la transacción porque
-- encuentra su documento en la tabla "morosos".

-- Eliminamos una inscripción de un socio no deudor:
delete inscriptos where numero=4;
-- El disparador se activa ante la sentencia "delete" y permite la transacción.

-- Verificamos que la inscripción nº 4 fue eliminada de "inscriptos":
select * from inscriptos;

-- Intentamos eliminar una inscripción de un socio deudor:
delete inscriptos where numero=6;
-- El disparador se activa ante el "delete" y deshace la transacción porque
-- encuentra su documento en "morosos".