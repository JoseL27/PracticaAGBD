Iniciamos la Practica creando el contenedor de Docker donde almacenaremos la imagen de MySQL para mantenerla aislada del sistema. Lo haremos en el puerto 3307, ya que mas adelante, MariaDB usara el 3306 por predeterminado y esto podría borrarnos la base de datos de MySQL al pisarse una con la otra(ya nos ha pasado).
Comando de creacion:
 ```bash 
docker run --name agbd -e MYSQL_ALLOW_EMPTY_PASSWORD=yes -p 3307:3306 -d mysql:8.0
 ```

Una vez hecho esto podemos tanto conectarnos a nuestro servidor de MySQL por MySQLWorkbench como pasar ficheros .sql al contenedor y hacer source con el servicio de MySQL iniciado para ejecutar las querys (Preferible hacer esto para la inyeccion de datos, ya que se ejecuta en un entorno que no esta capado).

creamos el fichero .sql de la creacion de la BBDD llamado database_Creation.sql:
```sql
CREATE DATABASE IF NOT EXISTS PracABD1
	CHARACTER SET = utf8mb4;
```
este comando creara un schema en nuestro servidor con el nombre PracABD1.
guardariamos el fichero y lo enviariamos al contenedor con el comando:

```bash
sudo docker cp database_Creation.sql agbd:/home/querys
```

Para poder pasarlo al directorio agbd:/home/querys tenemos que haber creado antes dicho directorio, por lo que ejecutamos una shell del contenedor con el comando:

```Bash
sudo docker exec -it agbd bash
```

Ahora nos movemos a /home y creamos /querys con un mkdir.

Hecho esto, sabriamos como ejecutar una bash en el contenedor llamado agbd y como pasara archivos a este contenedor. Ahora pasariamos a la ejecucion de dichos archivos.

Para poder ejecutarlos hay que meterse a un entorno MySQL dentro del contenedor para ejecutar comandos desde dicha terminal, asi que ejecutamos el comando:

```bash
sudo docker exec -it agbd mysql -u root -p --local-infile=1
```

ANTENCION:
No ponemos contraseña aunque nos la pida, le hemos dicho en el comando de creacion que no hace falta contraseña para entrar en el contenedor. Simplemente pulsamos ENTER.

Perfecto, estamos en un entorno MySQL dentro del contenedor, ahora tenemos que indicarle al entorno que tiene permitido ejecutar codigo de ficheros .sql, lo hacemos con este comando:

```sql
SET GLOBAL local_infile = 1;
```

Al haber realizado todo esto podemos hacer:

```sql
source /home/querys/database_Creation.sql
```

y se creara nuestro schema llamado PracABD1.

creamos tambien el fichero de eliminacion de la BBDD, que tendra este aspecto:

```sql
DROP DATABASE PracABD1;
```

Ahora creamos el fichero de creacion de los TableSpaces:

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

Asi como el de eliminacion de estos:

```sql
DROP TABLESPACE TBLS_clientes;
DROP TABLESPACE TBLS_juegos;
DROP TABLESPACE TBLS_clientesjuegos;
```

Ahora el fichero de creacion de tablas:

```sql
CREATE TABLE clientes (
	ClienteID		INTEGER,
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

Ahora que tenemos las tablas creadas, nos encargamos de asignarles claves primarias y foraneas:

### **CLAVES PRIMARIAS**
```sql
ALTER TABLE Clientes ADD PRIMARY KEY (ClienteID);
ALTER TABLE Juegos ADD PRIMARY KEY (JuegoID);
ALTER TABLE Clientes_Juegos ADD CONSTRAINT Clave_Clientes_Juegos PRIMARY KEY (ClienteID, JuegoID, FechaAlquiler);
```
### **CLAVES FORANEAS**
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

Y sus respectivas eliminaciones:

### **CLAVES PRIMARIAS**

```sql
ALTER TABLE Clientes DROP PRIMARY KEY;
ALTER TABLE Juegos DROP PRIMARY KEY;
ALTER TABLE Clientes_Juegos DROP PRIMARY KEY;
```
### **CLAVES FORANEAS**

```sql
ALTER TABLE Clientes DROP PRIMARY KEY;
ALTER TABLE Juegos DROP PRIMARY KEY;
ALTER TABLE Clientes_Juegos DROP PRIMARY KEY;
```

Ahora Pasamos a los scripts de Inyeccion de datos de la BBDD:

Antes de hacer esto, preprocesamos los datos del fichero .xsls para que actuen como un csv y poder tratar mejor con ellos.

Una vez realizado el preprocesamiento copiamos el fichero .csv de los datos procesados al contenedor para poder usarlo mas comodamente.

Dicho esto, lo primero de todo creamos una funcion para normalizar el dato del Email, ya que habia que tener en cuenta ciertas reestricciones:

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
```

Ahora podemos crear otro fichero que inserte bien los datos:

```sql
LOAD DATA LOCAL INFILE "/path/to/Clientes.txt"
INTO TABLE clientes 
CHARACTER SET utf8mb4
FIELDS TERMINATED BY "Caracter del delimitador del preprocesado"
LINES TERMINATED BY "\r\n" --esto es si es en windows por ejemplo
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

Pasamos tambien los ficheros de datos de los videojuegos y creamos los tres ficheros .sql que corresponden a cada uno de los archivos .xml que contienen los datos de los juegos:

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

# **HASTA AQUI ME HE QUEDAO**