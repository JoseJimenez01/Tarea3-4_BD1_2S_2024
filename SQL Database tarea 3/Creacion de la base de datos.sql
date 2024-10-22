CREATE DATABASE DBTarea3
GO

USE DBTarea3
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE TABLE dbo.CuentasTarjeta_TC
(
	id INT IDENTITY(1,1) PRIMARY KEY

);

CREATE TABLE dbo.TarjetaHabientes_TH
(
	id INT IDENTITY(1,1) PRIMARY KEY
	--, idPuesto INT NOT NULL
	, Nombre VARCHAR(128) NOT NULL
	, ValorDocumentoIdentidad INT NOT NULL
	, FechaNacimiento DATE NOT NULL

);

CREATE TABLE dbo.TarjetasFisicas_TF
(
	id INT IDENTITY(1,1) PRIMARY KEY
	, NumeroTarjeta VARCHAR(16) NOT NULL
	, CCV INT NOT NULL
	, FechaVencimiento DATE NOT NULL
	, FechaCreacion DATE  NOT NULL
	, TipoCreacion VARCHAR(32) NOT NULL --Reposicion por robo o perdida o  Renovacion
	, EsActivo BIT NOT NULL
);



CREATE TABLE dbo.TipoMovimiento
(
	id INT PRIMARY KEY
	, Nombre VARCHAR(32) NOT NULL
	, TipoAccion VARCHAR(32) NOT NULL
);

CREATE TABLE dbo.Usuario
(
	id INT PRIMARY KEY
	, Username VARCHAR(64) NOT NULL
	, Password VARCHAR(64) NOT NULL
);

--CREATE TABLE dbo.Movimiento
--(
--	id INT IDENTITY(1, 1) PRIMARY KEY
--	, idEmpleado INT NOT NULL
--	, idTipoMovimiento INT NOT NULL
--	, idPostByUser INT NOT NULL
--	, Fecha DATE NOT NULL
--	, Monto MONEY NOT NULL
--	, NuevoSaldo MONEY NOT NULL
--	, PostInIP VARCHAR(32) NOT NULL
--	, PostTime DATETIME NOT NULL
--	, FOREIGN KEY (idEmpleado) REFERENCES dbo.Empleado(id)
--	, FOREIGN KEY (idTipoMovimiento) REFERENCES dbo.TipoMovimiento(id)
--	, FOREIGN KEY (idPostByUser) REFERENCES dbo.Usuario(id)
--);

--CREATE TABLE dbo.TipoEvento
--(
--	id INT PRIMARY KEY
--	, Nombre VARCHAR(64) NOT NULL
--);

--CREATE TABLE dbo.BitacoraEvento
--(
--	id INT IDENTITY(1, 1) PRIMARY KEY
--	, idTipoEvento INT NOT NULL
--	, idPostByUser INT NOT NULL
--	, Descripcion VARCHAR(256) NOT NULL
--	, PostInIP VARCHAR(32) NOT NULL
--	, PostTime DATETIME NOT NULL
--	, FOREIGN KEY (idTipoEvento) REFERENCES dbo.TipoEvento(id)
--	, FOREIGN KEY (idPostByUser) REFERENCES dbo.Usuario(id)
--);

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

CREATE TABLE dbo.Error
(
	id INT IDENTITY(1, 1) PRIMARY KEY
	, Codigo INT NOT NULL
	, Descripcion VARCHAR(128) NOT NULL
);

