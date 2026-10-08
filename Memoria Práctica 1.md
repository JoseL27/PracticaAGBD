# 1A Creación de BBDD
```sql
CREATE DATABASE IF NOT EXISTS PracABD1
	CHARACTER SET = utf8mb4;
```
# 1B Eliminación de BBDD
```sql
DROP DATABASE PracABD1;
```
# 2A Crear Tablespace
```sql
CREATE TABLESPACE TBLS_clientes
	ADD DATAFILE 'DF_clientes.ibd'
	ENGINE = InnoDB;

CREATE TABLESPACE TBLS_juegos
	ADD DATAFILE 'DF_juegos.ibd'
	ENGINE = InnoDB;

CREATE TABLESPACE TBLS_clientesjuegos
	ADD DATAFILE 'DF_clientesjuegos.ibd'
	ENGINE = InnoDB;
```
# 2B Eliminar Tablespace
```sql
DROP TABLESPACE TBLS_clientes;
DROP TABLESPACE TBLS_juegos;
DROP TABLESPACE TBLS_clientesjuegos;
```
# 3A Crear tablas
En general:
```sql
CREATE TABLE NombreTabla (
	COLUMNA TIPO (NOT NULL),
	...
)
ENGINE = InnoDB
TABLESPACE = TBLS_NombreTabla;
```

Para tabla clientes
```sql
CREATE TABLE clientes (
	ClienteID		INTEGER		NOT NULL,
	DNI				CHAR(9)		NOT NULL,
	Nombre			VARCHAR(20)	NOT NULL,
	Apellidos		VARCHAR(30) NOT NULL,
	Genero			CHAR(1),
	Direccion		VARCHAR(60),
	Localidad		VARCHAR(50),
	Provincia		VARCHAR(30),
	CodPostal		INTEGER, /* Podría ser CHAR(5) si se transforma */
	Telefono		INTEGER, /* Podría ser CHAR(9) si se transforma */
	Canal			TINYINT, /* Podría ser un ENUM */
	FechaNacimiento	DATE,
	FechaContacto	DATE,
	Email			VARCHAR(60) /* Transformar acentos y ñ */
)
ENGINE = InnoDB
TABLESPACE = TBLS_clientes;
```

Para tabla juegos
```sql
CREATE Table Juegos (
	JuegoID			INTEGER 	NOT NULL,
	Titulo			VARCHAR(32)	NOT NULL,
	Consola			VARCHAR(12)	NOT NULL,
	Tamanio			INTEGER,
	Editor			VARCHAR(32)
);
ENGINE = InnoDB
TABLESPACE = TBLS_juegos;
```

Para tabla clientes_juegos
```sql
CREATE TABLE clientes_juegos (
    ClienteID      INT		NOT NULL,
    JuegoID        INT		NOT NULL,
    FechaAlquiler  DATE		NOT NULL,
    Comentarios    VARCHAR(500)
)
ENGINE = InnoDB
TABLESPACE = TBLS_clientesjuegos;
```
# 4A Crear Claves Primarias
```sql
ALTER TABLE Clientes ADD PRIMARY KEY (ClienteID);
ALTER TABLE Juegos ADD PRIMARY KEY (JuegoID);
ALTER TABLE Clientes_Juegos ADD CONSTRAINT Clave_Clientes_Juegos PRIMARY KEY (ClienteID, JuegoID, FechaAlquiler);
```
# 4B Crear Claves Foráneas
```sql
ALTER TABLE Clientes_Juegos
ADD CONSTRAINT Clave_Clientes 
FOREIGN KEY (ClienteID) 
REFERENCES Clientes(ClienteID);

ALTER TABLE Clientes_Juegos
ADD CONSTRAINT Clave_Juegos
FOREIGN KEY (JuegoID) 
REFERENCES Juegos(JuegoID);
```
# 4C Eliminar Claves Primarias
```sql
ALTER TABLE Clientes DROP PRIMARY KEY;
ALTER TABLE Juegos DROP PRIMARY KEY;
ALTER TABLE Clientes_Juegos DROP PRIMARY KEY;
```
# 4D Eliminar Claves Foráneas
```sql
ALTER TABLE Clientes DROP PRIMARY KEY;
ALTER TABLE Juegos DROP PRIMARY KEY;
ALTER TABLE Clientes_Juegos DROP PRIMARY KEY;
```

# 5 Todos Scripts previos juntos (1, 2A, 3A, 4A, 4B)
# 6 Load Data

Para Clientes, requiere el documento separado por tabuladores `Clientes.txt` derivado del juego de datos `Clientes.xlsx`

Si hace falta eliminar datos en la tabla `cliente` y función `normalizar_email`:
`TRUNCATE TABLE IF EXISTS clientes;`
`DROP FUNCTION IF EXISTS normalizar_email;`

```sql
DELIMITER $$
CREATE FUNCTION normalizar_email(
    email VARCHAR(60)
)
RETURNS VARCHAR(60)
DETERMINISTIC
BEGIN
    DECLARE resultado VARCHAR(60);
	SET resultado = email;

	-- Ññ -> Nn
	SET resultado = REPLACE(resultado, 'ñ', 'n');
	SET resultado = REPLACE(resultado, 'Ñ', 'N');

	-- A: acento agudo y grave
	SET resultado = REPLACE(resultado, 'á', 'a');
	SET resultado = REPLACE(resultado, 'à', 'a');
	SET resultado = REPLACE(resultado, 'Á', 'A');
	SET resultado = REPLACE(resultado, 'À', 'A');
	
	-- E: acento agudo y grave
	SET resultado = REPLACE(resultado, 'é', 'e');
	SET resultado = REPLACE(resultado, 'è', 'e');
	SET resultado = REPLACE(resultado, 'É', 'E');
	SET resultado = REPLACE(resultado, 'È', 'E');
	
	-- I: acento agudo y grave
	SET resultado = REPLACE(resultado, 'í', 'i');
	SET resultado = REPLACE(resultado, 'ì', 'i');
	SET resultado = REPLACE(resultado, 'Í', 'I');
	SET resultado = REPLACE(resultado, 'Ì', 'I');
	
	-- O: acento agudo y grave
	SET resultado = REPLACE(resultado, 'ó', 'o');
	SET resultado = REPLACE(resultado, 'ò', 'o');
	SET resultado = REPLACE(resultado, 'Ó', 'O');
	SET resultado = REPLACE(resultado, 'Ò', 'O');
	
	-- U: acento agudo y grave
	SET resultado = REPLACE(resultado, 'ú', 'u');
	SET resultado = REPLACE(resultado, 'ù', 'u');
	SET resultado = REPLACE(resultado, 'Ú', 'U');
	SET resultado = REPLACE(resultado, 'Ù', 'U');
	
	-- U con diéresis
	SET resultado = REPLACE(resultado, 'ü', 'u');
	SET resultado = REPLACE(resultado, 'Ü', 'U');

    RETURN resultado;
END $$
DELIMITER ;

LOAD DATA LOCAL INFILE "/path/to/Clientes.txt"
INTO TABLE clientes 
CHARACTER SET utf8mb4
FIELDS TERMINATED BY "\t"
LINES TERMINATED BY "\r\n"
(ClienteId, DNI, Nombre, Apellidos, @genero, @direccion, @localidad, @provincia, @codPostal, @telefono, @canal, @FechaNac, @FechaCont, @email)
SET
	Genero			= IF(@genero = '', NULL, @genero), -- Se puede mejorar con NULLIF
	Direccion		= IF(@direccion = '', NULL, @direccion),
	Localidad		= IF(@localidad = '', NULL, @localidad),
	Provincia		= IF(@provincia = '', NULL, REPLACE(@provincia, "", "")), -- Juego de dato fuente continene U+0081, quitar dicho caracter invisible
	CodPostal		= IF(@codPostal = '', NULL, @codPostal),
	Telefono		= IF(@telefono = '', NULL, @telefono),
	Canal			= IF(@canal = '', 0, @canal),
	FechaNacimiento	= IF(@FechaNac = '', NULL, STR_TO_DATE(@FechaNac, "%Y-%c-%e")),
	FechaContacto	= IF(@FechaCont = '', NULL, STR_TO_DATE(@FechaCont, "%Y-%c-%e")),
	Email			= IF(@email = '', NULL, normalizar_email(@email));
```

y hacemos las inserciones de los tres ficheros de esta manera:

Para el de GameBoy:
```sql
LOAD XML LOCAL INFILE '/home/querys/GameBoy.xml'
INTO TABLE Juegos
ROWS IDENTIFIED BY '<game>'
(@imageNumber, @title, @publisher, @romSize)
Set
    JuegoID = @imageNumber+12000,
    Titulo = LEFT(@title, 32), 
    Consola = "GameBoy",
    Editor = @publisher,
    Tamanio = @romSize;
```

Para el de Nintendo:
```sql
LOAD XML LOCAL INFILE '/home/querys/Nintendo.xml'
INTO TABLE Juegos
ROWS IDENTIFIED BY '<game>'
(@imageNumber,@title, @publisher, @romSize)
Set
    JuegoID = @imageNumber+15000,
    Titulo = LEFT(@title, 32), 
    Consola = "Nintendo",
    Editor = @publisher,
    Tamanio = @romSize;
```

Para el de MegaDrive:
```sql
LOAD XML LOCAL INFILE '/home/querys/MegaDrive.xml'
INTO TABLE Juegos
ROWS IDENTIFIED BY '<game>'
(@imageNumber,@title, @publisher, @romSize)
Set
    JuegoID = @imageNumber+10000,
    Titulo = LEFT(@title, 32), 
    Consola = "MegaDrive",
    Editor = LEFT(@publisher, 32),
    Tamanio = @romSize;
```

```sql
LOAD DATA LOCAL INFILE "/home/querys/Clientes_juegos.txt"
INTO TABLE clientes_juegos
CHARACTER SET utf8mb4
FIELDS TERMINATED BY "\t"
LINES TERMINATED BY "\r\n"
(ClienteId, JuegoID, @fecha, Comentarios)
SET
    FechaAlquiler = STR_TO_DATE(@fecha, "%Y-%c-%e");
```