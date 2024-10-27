CREATE DATABASE DBTarea3
GO

USE DBTarea3
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE dbo.TarjetaHabientes_TH --clientes de una operación de tarjeta de crédito
(
	id INT IDENTITY(1,1) PRIMARY KEY
	, Nombre VARCHAR(128) NOT NULL
	, ValorDocumentoIdentidad INT NOT NULL
	, FechaNacimiento DATE NOT NULL
);

CREATE TABLE dbo.TarjetasCredito_TC
(
	id INT IDENTITY(1,1) PRIMARY KEY
	, idTH INT NOT NULL
	--En caso de ocuparlo
	--, SaldoConfirmado MONEY
	--, SaldoSospechoso MONEY
	, FOREIGN KEY (idTH) REFERENCES dbo.TarjetaHabientes_TH(id)
);

CREATE TABLE dbo.TarjetasFisicas_TF --Tarjeta físico-plástica
(
	id INT IDENTITY(1,1) PRIMARY KEY
	, idTC INT NOT NULL
	, NumeroTarjeta BIGINT NOT NULL
	, CCV INT NOT NULL
	, FechaVencimiento DATE NOT NULL
	, FechaCreacion DATE  NOT NULL
	, TipoCreacion VARCHAR(32) NOT NULL --Reposicion por robo o perdida, o  Renovacion
	, EsActivo BIT NOT NULL
	, FOREIGN KEY (idTC) REFERENCES dbo.TarjetasCredito_TC(id)
);

CREATE TABLE dbo.TarjetasCreditoAdicionales_TCA -- no puede tener saldo, solo es instrumento de compras
(
	idTC INT PRIMARY KEY
	, idTH INT NOT NULL
	, FOREIGN KEY (idTC) REFERENCES dbo.TarjetasCredito_TC(id)
	, FOREIGN KEY (idTH) REFERENCES dbo.TarjetaHabientes_TH(id)
);

CREATE TABLE dbo.TipoTC
(
	id INT IDENTITY(1, 1) PRIMARY KEY
	, Nombre VARCHAR(32) NOT NULL
);

CREATE TABLE dbo.TarjetasCreditoMaestras_TCM
(
	idTC INT PRIMARY KEY
	, idTH INT NOT NULL
	, idTipoTC INT NOT NULL
	, LimiteCredito MONEY NOT NULL
	, Saldo MONEY NOT NULL
	, PagosAcumuladosDelPeriodo INT NOT NULL
	, SaldoIntCorrientesAcumulados MONEY NOT NULL
	, SaldoIntMoratoriosAcumulados MONEY NOT NULL
	, FOREIGN KEY (idTC) REFERENCES dbo.TarjetasCredito_TC(id)
	, FOREIGN KEY (idTH) REFERENCES dbo.TarjetaHabientes_TH(id)
	, FOREIGN KEY (idTipoTC) REFERENCES dbo.TipoTC(id)
);

CREATE TABLE dbo.Reglas
(
	id INT IDENTITY(1, 1) PRIMARY KEY
	, Unidad VARCHAR(32) NOT NULL --Qmeses, Qdias, TasaInteresAnual, MontoMonetario
	
);

CREATE TABLE dbo.ReglasXTC
(
	id INT IDENTITY(1, 1) PRIMARY KEY
	, idTipoTC INT NOT NULL
	, Valor DECIMAL NOT NULL
	, FOREIGN KEY (idTipoTC) REFERENCES dbo.TipoTC(id)
);

CREATE TABLE dbo.TipoMovInt
(
	id INT PRIMARY KEY --1: debito, suma; 2: credito, resta
	, Nombre INT NOT NULL
);

CREATE TABLE dbo.Movimiento
(
	id INT IDENTITY(1, 1) PRIMARY KEY
	, idTCM INT NOT NULL
	, idTipoMov INT NOT NULL
	, FechaOperacion DATE NOT NULL
	, FechaMovimiento DATE NOT NULL
	, NumeroDeTF BIGINT NOT NULL
	-- #numero de de tarjeta que creo que saca del idMovimiento -> idTCM -> idTC -> luego la TF
	, Descripcion NVARCHAR(MAX) NOT NULL
	, Referencia INT NOT NULL
	, Monto MONEY NOT NULL
	, NuevoSaldo MONEY NOT NULL --despues de aplicar el movimiento
	, FOREIGN KEY (idTCM) REFERENCES dbo.TarjetasCreditoMaestras_TCM(idTC)
	, FOREIGN KEY (idTipoMov) REFERENCES dbo.TipoMovInt(id)
);

CREATE TABLE dbo.MovimientoConTF
(
	id INT IDENTITY(1, 1) PRIMARY KEY
	, idMovimiento INT NOT NULL
	, FechaYHora DATETIME NOT NULL
	, NombreMov VARCHAR(32) NOT NULL --debito: suma, credito: resta
	, Monto MONEY NOT NULL
	, Descripcion VARCHAR(64) NOT NULL
	, Referencia INT NOT NULL --un numero aleatorio que es una referencia a algo, ya sea un documento o factura o número de autorización, etc.
	, FOREIGN KEY (idMovimiento) REFERENCES dbo.Movimiento(id)
);

CREATE TABLE dbo.MovimientoSospechoso
(
	id INT IDENTITY(1, 1) PRIMARY KEY
	, idTC INT NOT NULL
	
	, FOREIGN KEY (idTC) REFERENCES dbo.TarjetasCredito_TC(id)
);

CREATE TABLE dbo.EstadoDeCuenta_EC
(
	id INT IDENTITY(1, 1) PRIMARY KEY
	, idTCM INT NOT NULL
	, idMovimiento INT NOT NULL
	, PagoMinimo MONEY NOT NULL
	, FechaLimitePagoMinimo DATE NOT NULL
	, CantOperacionesATM INT NOT NULL
	, CantOperacionesVentanilla INT NOT NULL
	, CantPagosDelMes INT NOT NULL
	, SumaCompras MONEY NOT NULL
	, CantCompras INT NOT NULL
	, SumaRetiros MONEY NOT NULL
	, CantRetiros INT NOT NULL
	, SumaDeTodosLosCreditos MONEY NOT NULL
	, CantDeTodosLosCreditos INT NOT NULL
	, SumaDeTodosLosDebitos MONEY NOT NULL
	, CantDeTodosLosDebitos INT NOT NULL
	, FOREIGN KEY (idTCM) REFERENCES dbo.TarjetasCreditoMaestras_TCM(idTC)
	, FOREIGN KEY (idMovimiento) REFERENCES dbo.Movimiento(id)
);

CREATE TABLE dbo.MovimientoIntereses
(
	id INT IDENTITY(1, 1) PRIMARY KEY
	, idTCM INT NOT NULL
	, idTipoMovInt INT NOT NULL
	, Monto MONEY NOT NULL			--MovIntereses.Monto = Saldo * TasaInteresMensual / 100 / 20 
	, Fecha DATE NOT NULL
	, FOREIGN KEY (idTCM) REFERENCES dbo.TarjetasCreditoMaestras_TCM(idTC)
	, FOREIGN KEY (idTipoMovInt) REFERENCES dbo.TipoMovInt(id)
);

CREATE TABLE dbo.SubEstadoDeCuenta
(
	id INT IDENTITY(1, 1) PRIMARY KEY
	, idEstadoDeCuenta INT NOT NULL
	, idMovimiento INT NOT NULL
	, CantOperacionesATM INT NOT NULL
	, CantOperacionesVentanilla INT NOT NULL
	, SumaCompras MONEY NOT NULL
	, CantCompras INT NOT NULL
	, SumaRetiros MONEY NOT NULL
	, CantRetiros INT NOT NULL
	, SumaDeTodosLosCreditos MONEY NOT NULL
	, SumaDeTodosLosDebitos MONEY NOT NULL
	, FOREIGN KEY (idEstadoDeCuenta) REFERENCES dbo.EstadoDeCuenta_EC(id)
	, FOREIGN KEY (idMovimiento) REFERENCES dbo.Movimiento(id)
);

CREATE TABLE dbo.Roles
(
	id INT IDENTITY(1, 1) PRIMARY KEY
	, Rol VARCHAR(32) NOT NULL
);

CREATE TABLE dbo.Usuario
(
	id INT IDENTITY(1, 1) PRIMARY KEY
	, idRol INT NOT NULL
	, Username VARCHAR(64) NOT NULL
	, Password VARCHAR(64) NOT NULL
	, FOREIGN KEY (idRol) REFERENCES dbo.Roles(id)
);

CREATE TABLE dbo.BitacoraEvento
(
	id INT IDENTITY(1, 1) PRIMARY KEY
	, idPostByUser INT NOT NULL
	, Descripcion VARCHAR(256) NOT NULL
	, PostInIP VARCHAR(32) NOT NULL
	, PostTime DATETIME NOT NULL
	, FOREIGN KEY (idPostByUser) REFERENCES dbo.Usuario(id)
);

CREATE TABLE dbo.DBError(
	ErrorID INT IDENTITY(1,1) NOT NULL,
	UserName VARCHAR(100) NULL,
	ErrorNumber INT NULL,
	ErrorState INT NULL,
	ErrorSeverity INT NULL,
	ErrorLine INT NULL,
	ErrorProcedure VARCHAR(MAX) NULL,
	ErrorMessage VARCHAR(MAX) NULL,
	ErrorDateTime DATETIME NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
