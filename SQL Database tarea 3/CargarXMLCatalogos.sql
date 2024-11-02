
USE DBTarea3
GO

-- Se declara la variable que contendrá los datos XML
DECLARE @xmlData XML;

-- SE cargan los datos XML a la variable, cambiar la ruta según sea el caso
SET @xmlData = (
		SELECT *
		FROM OPENROWSET(BULK 'C:\Users\Usuario\OneDrive\Escritorio\Material_y_evaluaciones_de_cursos\2 S 2024\Bases de Datos 1\Tarea 3\Tarea3-4_BD1_2S_2024\SQL Database tarea 3\XMLCatalogos.xml', SINGLE_BLOB) 
		AS xmlData
		);

--SET @xmlData = (
--		SELECT *
--		FROM OPENROWSET(BULK 'https://bases-datos-tarea-tres-archivo.s3.us-east-1.amazonaws.com/OperacionesCompleto.xml', SINGLE_BLOB) 
--		AS xmlData
--		);

----- Seccion de tablas variables para mapeo de los correctos atributos a la hora de insercion -------------------------
DECLARE @TablaVariableReglasNegocio TABLE
(
    Nombre VARCHAR(64) NOT NULL
    , TipoTC VARCHAR(32) NOT NULL
	, TipoReglaNegocio VARCHAR(64) NOT NULL
	, Valor FLOAT NOT NULL
);

----- Seccion de Insercion de informacion en cada una de las tablas de catalogos ---------------------------------------
INSERT INTO dbo.TipoTC
(
	Nombre
)
SELECT  
	T.Item.value('@Nombre', 'VARCHAR(32)')
FROM @xmlData.nodes('root/TTCM/TTCM') AS T(Item);

INSERT INTO dbo.TipoReglaNegocio
(
	Nombre
	, TipoDeDato
)
SELECT  
	T.Item.value('@Nombre', 'VARCHAR(64)')
	, T.Item.value('@tipo', 'VARCHAR(8)')
FROM @xmlData.nodes('root/TRN/TRN') AS T(Item);

INSERT INTO @TablaVariableReglasNegocio
(
	Nombre
    , TipoTC
	, TipoReglaNegocio
	, Valor
)
SELECT  
	T.Item.value('@Nombre', 'VARCHAR(64)')
	, T.Item.value('@TTCM', 'VARCHAR(32)')
	, T.Item.value('@TipoRN', 'VARCHAR(64)')
	, T.Item.value('@Valor', 'FLOAT')
FROM @xmlData.nodes('root/RN/RN') AS T(Item);

INSERT INTO dbo.ReglasNegocio
(
	 idTipoTC
	, idTipoReglaNegocio
	, Nombre
	, Valor
)
SELECT  TTC.id, TRN.id, TVRN.Nombre, TVRN.Valor
FROM @TablaVariableReglasNegocio AS TVRN
INNER JOIN dbo.TipoTC AS TTC
ON TVRN.TipoTC = TTC.Nombre
INNER JOIN dbo.TipoReglaNegocio AS TRN
ON TVRN.TipoReglaNegocio = TRN.Nombre;

INSERT INTO dbo.MotivoInvalidacionTarjeta
(
	Nombre
)
SELECT 
	T.Item.value('@Nombre', 'VARCHAR(32)')
FROM @xmlData.nodes('root/MIT/MIT') AS T(Item);

INSERT INTO dbo.TipoMovimientos
(
	Nombre
	, Accion
	, AcumOperaATM
	, AcumOperaVentana
)
SELECT 
	T.Item.value('@Nombre', 'VARCHAR(64)')
	, T.Item.value('@Accion', 'VARCHAR(8)')
	, T.Item.value('@Acumula_Operacion_ATM', 'VARCHAR(2)')
	, T.Item.value('@Acumula_Operacion_Ventana', 'VARCHAR(2)')
FROM @xmlData.nodes('root/TM/TM') AS T(Item);

INSERT INTO dbo.Usuario
(
	Username
	, Password
)
SELECT
	T.Item.value('@Nombre', 'VARCHAR(64)')
	, T.Item.value('@Password', 'VARCHAR(64)')
FROM @xmlData.nodes('root/UA/Usuario') AS T(Item);

INSERT INTO dbo.TipoMovIntCorrientes
(
	Nombre
)
SELECT  
	T.Item.value('@nombre', 'VARCHAR(32)')
FROM @xmlData.nodes('root/TMIC/TMIC') AS T(Item);

INSERT INTO dbo.TipoMovIntMoratorios
(
	Nombre
)
SELECT  
	T.Item.value('@nombre', 'VARCHAR(32)')
FROM @xmlData.nodes('root/TMIM/TMIM') AS T(Item);

