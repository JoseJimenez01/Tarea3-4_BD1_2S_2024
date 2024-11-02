CREATE DATABASE DBTarea3
GO

USE DBTarea3
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE TABLE dbo.Usuario
(
	id INT IDENTITY(1, 1) PRIMARY KEY
	, Username VARCHAR(64) NOT NULL
	, Password VARCHAR(64) NOT NULL
);

CREATE TABLE dbo.TarjetaHabientes_TH --clientes de una operación de tarjeta de crédito
(
	id INT IDENTITY(1,1) PRIMARY KEY
	, idUsuario INT NOT NULL
	, Nombre VARCHAR(128) NOT NULL
	, ValorDocumentoIdentidad VARCHAR(16) NOT NULL
	, FechaNacimiento DATE NOT NULL
	, FOREIGN KEY (idUsuario) REFERENCES dbo.Usuario(id)
);

CREATE TABLE dbo.TarjetasCredito_TC
(
	Codigo INT IDENTITY(1,1) PRIMARY KEY
	, idTH INT NOT NULL
	--En caso de ocuparlo
	--, SaldoConfirmado MONEY
	--, SaldoSospechoso MONEY
	, FOREIGN KEY (idTH) REFERENCES dbo.TarjetaHabientes_TH(id)
);

CREATE TABLE dbo.MotivoInvalidacionTarjeta
(
	id INT IDENTITY(1, 1) PRIMARY KEY
	, Nombre VARCHAR(32)
);

CREATE TABLE dbo.TarjetasFisicas_TF --Tarjeta físico-plástica
(
	id INT IDENTITY(1,1) PRIMARY KEY
	, CodigoTC INT NOT NULL
	, idMotivoInvalidacion INT NOT NULL
	, NumeroTarjeta BIGINT NOT NULL
	, CCV INT NOT NULL
	, FechaVencimiento DATE NOT NULL
	, FechaCreacion DATE  NOT NULL
	, EsActivo BIT NOT NULL
	, FOREIGN KEY (CodigoTC) REFERENCES dbo.TarjetasCredito_TC(Codigo)
	, FOREIGN KEY (idMotivoInvalidacion) REFERENCES dbo.MotivoInvalidacionTarjeta(id)
);

CREATE TABLE dbo.TarjetasCreditoAdicionales_TCA -- no puede tener saldo, solo es instrumento de compras
(
	Codigo INT PRIMARY KEY
	, CodigoTC INT
	, idTH INT NOT NULL
	, FOREIGN KEY (CodigoTC) REFERENCES dbo.TarjetasCredito_TC(Codigo)
	, FOREIGN KEY (idTH) REFERENCES dbo.TarjetaHabientes_TH(id)
);

CREATE TABLE dbo.TipoTC
(
	id INT IDENTITY(1, 1) PRIMARY KEY
	, Nombre VARCHAR(32) NOT NULL
);

CREATE TABLE dbo.TarjetasCreditoMaestras_TCM
(
	CodigoTC INT PRIMARY KEY
	, idTH INT NOT NULL
	, idTipoTC INT NOT NULL
	, idTCA INT NOT NULL
	, LimiteCredito MONEY NOT NULL
	, Saldo MONEY NOT NULL
	, PagosAcumuladosDelPeriodo INT NOT NULL
	, SaldoIntCorrientesAcumulados MONEY NOT NULL
	, SaldoIntMoratoriosAcumulados MONEY NOT NULL
	, FOREIGN KEY (CodigoTC) REFERENCES dbo.TarjetasCredito_TC(Codigo)
	, FOREIGN KEY (idTH) REFERENCES dbo.TarjetaHabientes_TH(id)
	, FOREIGN KEY (idTipoTC) REFERENCES dbo.TipoTC(id)
	, FOREIGN KEY (idTCA) REFERENCES dbo.TarjetasCreditoAdicionales_TCA(Codigo)
);

CREATE TABLE dbo.TipoReglaNegocio
(
	id INT IDENTITY(1, 1) PRIMARY KEY NOT NULL
	, Nombre VARCHAR(64) NOT NULL		--porcentaje, cant dias, cant operaciones, monto monetario
	, TipoDeDato VARCHAR(8) NOT NULL
);

CREATE TABLE dbo.ReglasNegocio
(
	id INT IDENTITY(1, 1) PRIMARY KEY
	, idTipoTC INT NOT NULL
	, idTipoReglaNegocio INT NOT NULL
	, Nombre VARCHAR(64) NOT NULL
	, Valor FLOAT NOT NULL --lo agregamos aqui para quitar la tabla ReglasXTC
	, FOREIGN KEY (idTipoTC) REFERENCES dbo.TipoTC(id)
	, FOREIGN KEY (idTipoReglaNegocio) REFERENCES dbo.TipoReglaNegocio(id)
);

--CREATE TABLE dbo.ReglasXTC
--(
--	id INT IDENTITY(1, 1) PRIMARY KEY
--	, idTipoTC INT NOT NULL
--	, Valor DECIMAL NOT NULL
--	, FOREIGN KEY (idTipoTC) REFERENCES dbo.TipoTC(id)
--);

CREATE TABLE dbo.TipoMovimientos
(
	id INT IDENTITY(1, 1) PRIMARY KEY
	, Nombre VARCHAR(64) NOT NULL
	, Accion VARCHAR(8) NOT NULL
	, AcumOperaATM VARCHAR(2) NOT NULL		--Acumula Operacion en ATM
	, AcumOperaVentana VARCHAR(2) NOT NULL
);

--Con correcciones, segun el XML de operaciones
CREATE TABLE dbo.Movimiento
(
	id INT IDENTITY(1, 1) PRIMARY KEY
	, CodigoTCM INT NOT NULL  --para enlazar la tarjeta
	, idTipoMov INT NOT NULL
	, FechaMovimiento DATE NOT NULL
	, Descripcion NVARCHAR(MAX) NOT NULL
	, Referencia VARCHAR(16) NOT NULL
	, Monto MONEY NOT NULL
	, NuevoSaldo MONEY NOT NULL --despues de aplicar el movimiento
	, FOREIGN KEY (CodigoTCM) REFERENCES dbo.TarjetasCreditoMaestras_TCM(CodigoTC)
	, FOREIGN KEY (idTipoMov) REFERENCES dbo.TipoMovimientos(id)
);

-- Tabla sobrante segun el profe
--CREATE TABLE dbo.MovimientoConTF
--(
--	id INT IDENTITY(1, 1) PRIMARY KEY
--	, idMovimiento INT NOT NULL
--	, FechaYHora DATETIME NOT NULL
--	, NombreMov VARCHAR(32) NOT NULL --debito: suma, credito: resta
--	, Monto MONEY NOT NULL
--	, Descripcion VARCHAR(64) NOT NULL
--	, Referencia INT NOT NULL --un numero aleatorio que es una referencia a algo, ya sea un documento o factura o número de autorización, etc.
--	, FOREIGN KEY (idMovimiento) REFERENCES dbo.Movimiento(id)
--);

CREATE TABLE dbo.MovimientoSospechoso
(
	id INT IDENTITY(1, 1) PRIMARY KEY
	, CodigoTC INT NOT NULL
	
	, FOREIGN KEY (CodigoTC) REFERENCES dbo.TarjetasCredito_TC(Codigo)
);

CREATE TABLE dbo.EstadoDeCuenta_EC
(
	id INT IDENTITY(1, 1) PRIMARY KEY
	, CodigoTCM INT NOT NULL
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
	, FOREIGN KEY (CodigoTCM) REFERENCES dbo.TarjetasCreditoMaestras_TCM(CodigoTC)
	, FOREIGN KEY (idMovimiento) REFERENCES dbo.Movimiento(id)
);

CREATE TABLE dbo.TipoMovIntCorrientes
(
	id INT IDENTITY(1, 1) PRIMARY KEY
	, Nombre VARCHAR(32) NOT NULL
);

CREATE TABLE dbo.TipoMovIntMoratorios
(
	id INT IDENTITY(1, 1) PRIMARY KEY
	, Nombre VARCHAR(32) NOT NULL
);

CREATE TABLE dbo.MovimientoInteresesCorrientes
(
	id INT IDENTITY(1, 1) PRIMARY KEY
	, CodigoTCM INT NOT NULL
	, idTipoMovIntCorr INT NOT NULL
	, Monto MONEY NOT NULL			--MovIntereses.Monto = Saldo * TasaInteresMensual / 100 / 20 
	, Fecha DATE NOT NULL
	, FOREIGN KEY (CodigoTCM) REFERENCES dbo.TarjetasCreditoMaestras_TCM(CodigoTC)
	, FOREIGN KEY (idTipoMovIntCorr) REFERENCES dbo.TipoMovIntCorrientes(id)
);

CREATE TABLE dbo.MovimientoInteresesMoratorios
(
	id INT IDENTITY(1, 1) PRIMARY KEY
	, CodigoTCM INT NOT NULL
	, idTipoMovIntMoratorios INT NOT NULL
	, Monto MONEY NOT NULL
	, Fecha DATE NOT NULL
	, FOREIGN KEY (CodigoTCM) REFERENCES dbo.TarjetasCreditoMaestras_TCM(CodigoTC)
	, FOREIGN KEY (idTipoMovIntMoratorios) REFERENCES dbo.TipoMovIntMoratorios(id)
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
GO

--------------------------------------------------- SECCION DE FUNCIONES -------------------------------------------

CREATE OR ALTER FUNCTION dbo.CalcularInteresesCorrientes(@Saldo MONEY, @TasaInteres DECIMAL)
RETURNS MONEY --MovIntereses.Monto = Saldo * TasaInteresMensual / 100 / 20 
AS
BEGIN
    DECLARE @Interes MONEY;

    SET @Interes = @Saldo * @TasaInteres / 100 / 20

    RETURN @Interes;
END;
GO