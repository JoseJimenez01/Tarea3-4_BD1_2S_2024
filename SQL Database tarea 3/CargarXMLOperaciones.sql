
USE DBTarea3
GO

DECLARE @xmlData XML;

-- Se cargan los datos XML a la variable, cambiar la ruta según sea el caso
SET @xmlData = (
		SELECT *
		FROM OPENROWSET(BULK 'C:\Users\Usuario\OneDrive\Escritorio\Material_y_evaluaciones_de_cursos\2 S 2024\Bases de Datos 1\Tarea 3\Tarea3-4_BD1_2S_2024\SQL Database tarea 3\XMLOperaciones.xml', SINGLE_BLOB) 
		AS xmlData
		);


-- Primero se insertan los "catalogos"
INSERT INTO dbo.Usuario
(
	Username
	, Password
)
SELECT
	NTH.value('@NombreUsuario', 'VARCHAR(64)')
	, NTH.value('@Password', 'VARCHAR(64)')
FROM @xmlData.nodes('/root/fechaOperacion') AS Operacion(FechaOperacion)
CROSS APPLY FechaOperacion.nodes('NTH/NTH') AS NTH(NTH)

INSERT INTO dbo.TarjetaHabientes_TH
(
	idUsuario
	, Nombre
	, ValorDocumentoIdentidad
	, FechaNacimiento
)
SELECT
		U.id
		, NTH.value('@Nombre', 'VARCHAR(128)')
		, NTH.value('@ValorDocIdentidad', 'VARCHAR(16)')
		, NTH.value('@FechaNacimiento', 'DATE')
FROM @xmlData.nodes('/root/fechaOperacion') AS Operacion(FechaOperacion)
CROSS APPLY FechaOperacion.nodes('NTH/NTH') AS NTH(NTH)
INNER JOIN dbo.Usuario AS U
ON U.Username = NTH.value('@NombreUsuario', 'VARCHAR(20)');

INSERT INTO dbo.TarjetasCredito_TC
(
	Codigo
	, idTH
)
SELECT
		NTCM.value('@Codigo', 'INT')
		, TH.id
FROM @xmlData.nodes('/root/fechaOperacion') AS Operacion(FechaOperacion)
CROSS APPLY FechaOperacion.nodes('NTCM/NTCM') AS NTCM(NTCM)
INNER JOIN dbo.TarjetaHabientes_TH AS TH
ON TH.ValorDocumentoIdentidad = NTCM.value('@TH', 'VARCHAR(16)')

INSERT INTO dbo.TarjetasCreditoMaestras_TCM
(
	CodigoTC
	, idTH
	, idTipoTC
	, idTCA
	, LimiteCredito
	, Saldo
	, PagosAcumuladosDelPeriodo
	, SaldoIntCorrientesAcumulados
	, SaldoIntMoratoriosAcumulados
)
SELECT
		TC.Codigo
		, TH.id
		, TTC.id
		, --arreglar este campo antes de seguir editando
		, NTCM.value('@LimiteCredito', 'MONEY')
		, NTCM.value('@LimiteCredito', 'MONEY')
		, 0
		, 0
		, 0
FROM @xmlData.nodes('/root/fechaOperacion') AS Operacion(FechaOperacion)
CROSS APPLY FechaOperacion.nodes('NTCM/NTCM') AS NTCM(NTCM)
INNER JOIN dbo.TarjetasCredito_TC AS TC
ON TC.Codigo = NTCM.value('@Codigo', 'INT')
INNER JOIN dbo.TarjetaHabientes_TH AS TH
ON TH.ValorDocumentoIdentidad = NTCM.value('@TH', 'VARCHAR(16)')
INNER JOIN dbo.TipoTC AS TTC
ON TTC.Nombre = NTCM.value('@TipoTCM', 'VARCHAR(32)')


