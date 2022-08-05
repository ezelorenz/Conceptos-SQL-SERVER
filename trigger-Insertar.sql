
use AprendiendoSQL;

if object_id('ventas') is not null
  drop table ventas;
if object_id('libros') is not null
  drop table libros;

create table libros(
  codigo int identity,
  titulo varchar(40),
  autor varchar(30),
  precio decimal(6,2), 
  stock int,
  constraint PK_libros primary key(codigo)
);

create table ventas(
  numero int identity,
  fecha datetime,
  codigolibro int not null,
  precio decimal (6,2),
  cantidad int,
  constraint PK_ventas primary key(numero),
  constraint FK_ventas_codigolibro
   foreign key (codigolibro) references libros(codigo)
);

go

insert into libros values('Uno','Richard Bach',15,100);
insert into libros values('Ilusiones','Richard Bach',18,50);
insert into libros values('El aleph','Borges',25,200);
insert into libros values('Aprenda PHP','Mario Molina',45,200);

go

-- Creamos un disparador para que se ejecute cada vez que una instrucci�n "insert" 
-- ingrese datos en "ventas"; el mismo controlar� que haya stock en "libros"
-- y actualizar� el campo "stock":
create trigger DIS_ventas_insertar
  on ventas
  for insert
  as
   declare @stock int
   select @stock= stock from libros
		 join inserted
		 on inserted.codigolibro=libros.codigo
		 where libros.codigo=inserted.codigolibro
  if (@stock>=(select cantidad from inserted))
    update libros set stock=stock-inserted.cantidad
     from libros
     join inserted
     on inserted.codigolibro=libros.codigo
     where codigo=inserted.codigolibro
  else
  begin
    raiserror ('Hay menos libros en stock de los solicitados para la venta', 16, 1)
    rollback transaction
  end

go

set dateformat ymd;

-- Ingresamos un registro en "ventas":
insert into ventas values('2018/04/01',1,15,1);
-- Al ejecutar la sentencia de inserci�n anterior, se dispar� el trigger, el registro
-- se agreg� a la tabla del disparador ("ventas") y disminuy� el valor del campo "stock"
-- de "libros".

-- Verifiquemos que el disparador se ejecut� consultando la tabla "ventas" y "libros":
select * from ventas;
select * from libros where codigo=1;

-- Ingresamos un registro en "ventas", solicitando una cantidad superior al stock 
-- (El disparador se ejecuta y muestra un mensaje, la inserci�n no se realiz� porque
-- la cantidad solicitada supera el stock.):
 insert into ventas values('2018/04/01',2,18,100);

 -- Finalmente probaremos ingresar una venta con un c�digo de libro inexistente
 -- (El trigger no lleg� a ejecutarse, porque la comprobaci�n de restricciones 
 -- (que se ejecuta antes que el disparador) detect� que la infracci�n a la "foreign key"):
 insert into ventas values('2018/04/01',5,18,1);