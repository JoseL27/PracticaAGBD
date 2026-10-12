# Creacion de la Estructura
## Creacion de Database:

```sql
CREATE SCHEMA IF NOT EXISTS PracABD1
DEFAULT CHARSET utf8
DEFAULT COLLATE utf8_spanish2_ci;
```

## Borrado de Database:
```sql
DROP SCHEMA IF EXISTS PracABD1;
```

## Creacion Tablespaces:

```sql
CREATE TABLESPACE TBLS_clientes
ADD DATAFILE 'DF_clientes.ibd'
ENGINE=InnoDB;

CREATE TABLESPACE TBLS_juegos
ADD DATAFILE 'DF_juegos.ibd'
ENGINE=InnoDB;

CREATE TABLESPACE TBLS_clientes_juegos
ADD DATAFILE 'DF_clientes_juegos.ibd'
ENGINE=InnoDB;
```

## Borrado de Tablespaces:
```sql
DROP TABLESPACE TBLS_clientes;
DROP TABLESPACE TBLS_juegos;
DROP TABLESPACE TBLS_clientes_juegos;
```
## Creacion Tablas:

```sql
USE PracABD1;

CREATE TABLE IF NOT EXISTS Clientes (
	ClienteID INT UNIQUE NOT NULL, -- Se deja la creacion de la clave primaria para el script dedicado a ello
    DNI VARCHAR(9) UNIQUE NOT NULL,
    Nombre VARCHAR(20) NOT NULL,
    Apellidos VARCHAR(30) NOT NULL,
    Genero VARCHAR(1),
    Direccion VARCHAR(60),
    Localidad VARCHAR(50),
	Provincia VARCHAR(30),
    CodPostal INT,
    Telefono VARCHAR(9),
    Canal TINYINT,
    FechaNacimiento DATE,
    FechaContacto DATE,
    Email VARCHAR(60)
) ENGINE = InnoDB
    TABLESPACE = TBLS_clientes;

CREATE TABLE IF NOT EXISTS Juegos (
	JuegoID INT UNIQUE NOT NULL, -- Se deja la creacion de la clave primaria para el script dedicado a ello
    Titulo VARCHAR(32) UNIQUE NOT NULL,
    Consola VARCHAR(12) NOT NULL,
    Tamanio INT,
    Editor VARCHAR(32)
)ENGINE = InnoDB
    TABLESPACE = TBLS_juegos;


CREATE TABLE IF NOT EXISTS Clientes_Juegos (
	-- Se deja la creacion de la clave primaria para el script dedicado a ello
	ClienteID INT NOT NULL,
	JuegoID INT NOT NULL,
    FechaAlquiler DATE NOT NULL,
    Comentarios VARCHAR(500)
)ENGINE = InnoDB
    TABLESPACE = TBLS_juegos;
```

## Borrado Tablas:

```sql
USE PracABD1;

DROP TABLE IF EXISTS Clientes;
DROP TABLE IF EXISTS Juegos;
DROP TABLE IF EXISTS Clientes_Juegos;
```


## Creacion Claves Primarias:

```sql
USE PracABD1;

ALTER TABLE Clientes ADD PRIMARY KEY (ClienteID);
ALTER TABLE Clientes_Juegos ADD CONSTRAINT Clave_Clientes_Juegos PRIMARY KEY (ClienteID, JuegoID, FechaAlquiler);
```

## Borrado Claves Primarias:

```sql
USE PracABD1;

ALTER TABLE Clientes DROP PRIMARY KEY;
ALTER TABLE Juegos DROP PRIMARY KEY;
ALTER TABLE Clientes_Juegos DROP PRIMARY KEY;
```


## Creacion Claves Foraneas:

```sql
USE PracABD1;

ALTER TABLE Clientes_Juegos
ADD CONSTRAINT Clave_Clientes 
FOREIGN KEY (ClienteID) 
REFERENCES Clientes(ClienteID);

ALTER TABLE Clientes_Juegos
ADD CONSTRAINT Clave_Juegos
FOREIGN KEY (JuegoID) 
REFERENCES Juegos(JuegoID);
```

## Borrado Claves Foraneas:

```sql
USE PracABD1;

ALTER TABLE Clientes_Juegos DROP FOREIGN KEY Clave_Clientes;
ALTER TABLE Clientes_Juegos DROP FOREIGN KEY Clave_Juegos;
```

# Cargado de Datos

## Cargado Tabla Clientes:

Exportamos el archivo .xlsx a csv desde excel, usando como separador  ';' y ejecutamos la siguiente sentencia:

```sql
DELIMITER $$
CREATE FUNCTION IF NOT EXISTS normalizar_email(
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

-- Cambiar path a donde se encuentre el juego de datos
LOAD DATA LOCAL INFILE "/home/nigga/Clientes.csv"
INTO TABLE Clientes 
CHARACTER SET latin1
FIELDS TERMINATED BY "\;"
LINES TERMINATED BY "\n"
(ClienteId, DNI, Nombre, Apellidos, @genero, @direccion, @localidad, @provincia, @codPostal, @telefono, @canal, @FechaNac, @FechaCont, @email)
SET
	Genero			= IF(@genero = '', NULL, @genero), -- Se puede mejorar con NULLIF
	Direccion		= IF(@direccion = '', NULL, @direccion),
	Localidad		= IF(@localidad = '', NULL, @localidad),
	Provincia		= IF(@provincia = '', NULL, REPLACE(@provincia, "�", "")), -- Juego de dato fuente continene U+0081, quitar dicho caracter invisible
	CodPostal		= IF(@codPostal = '', NULL, @codPostal),
	Telefono		= IF(@telefono = '', NULL, @telefono),
	Canal			= IF(@canal = '', 0, @canal),
	FechaNacimiento	= IF(@FechaNac = '', NULL, STR_TO_DATE(@FechaNac, "%e/%c/%Y")),
	FechaContacto	= IF(@FechaCont = '', NULL, STR_TO_DATE(@FechaCont, "%e/%c/%Y")),
	Email			= IF(@email = '', NULL, normalizar_email(@email));
```

## Cargado Tabla Juegos:

Transformamos los xml a csv con el siguiente script en python:

```python
import xml.etree.ElementTree as ET
import csv


consolas = ["GameBoy", "MegaDrive", "Nintendo"]

for consola in consolas:
	# Cambiar datasets/ por el path a los datos
    archivo_xml = "datasets/" + consola + ".xml" 
    archivo_csv = "datasets/" + consola + "test.csv"


    def texto(elemento, nombre):
        """Obtiene el texto de un elemento XML o devuelve una cadena vacía."""
        nodo = elemento.find(nombre)

        if nodo is None or nodo.text is None:
            return ""

        return nodo.text.strip()


    tree = ET.parse(archivo_xml)
    root = tree.getroot()

    with open(
        archivo_csv,
        "w",
        newline="",
        encoding="latin1"
    ) as csvfile:

        writer = csv.writer(csvfile, delimiter=';')

        for game in root.findall(".//game"):

            image_number = texto(game, "imageNumber")
            juego_id = 0

            # Si no existe imageNumber, ignoramos el registro
            if not image_number:
                continue

            try:
                additional_value = 0;

                match consola:
                    case "GameBoy":
                        additional_value = 15000
                    case "MegaDrive":
                        additional_value = 10000
                    case "Nintendo":
                        additional_value = 12000


                juego_id = int(image_number) + additional_value
            except ValueError:
                print(
                    f"Advertencia: imageNumber no válido: "
                    f"{image_number}"
                )
                continue

            titulo = texto(game, "title")[:26] + ":" + str(juego_id)
            tamanio = texto(game, "romSize")
            editor = texto(game, "publisher")

            writer.writerow([
                juego_id,
                titulo,
                consola,
                tamanio,
                editor
            ])

    print(f"Archivo generado: {archivo_csv}")
```

Después cargamos la tabla con la siguiente sentencia:

```sql
-- Cambiar path a donde se encuentre el juego de datos
LOAD DATA LOCAL INFILE '/home/nigga/GameBoy.csv'
	INTO TABLE Juegos
	CHARACTER SET 'latin1'
	FIELDS TERMINATED BY ';'
	LINES TERMINATED BY '\n';

-- Cambiar path a donde se encuentre el juego de dato:
LOAD DATA LOCAL INFILE '/home/nigga/MegaDrive.csv'
	INTO TABLE Juegos
	CHARACTER SET 'latin1'
	FIELDS TERMINATED BY ';'
	LINES TERMINATED BY '\n';

-- Cambiar path a donde se encuentre el juego de datos
LOAD DATA LOCAL INFILE '/home/nigga/Nintendo.csv'
	INTO TABLE Juegos
	CHARACTER SET 'latin1'
	FIELDS TERMINATED BY ';'
	LINES TERMINATED BY '\n';
```


## Cargado Tabla Clientes_Juegos


```sql
LOAD DATA LOCAL INFILE '/path/to/Clientes_juegos.txt'
INTO TABLE clientes_juegos
CHARACTER SET utf8mb4
FIELDS TERMINATED BY "\t"
LINES TERMINATED BY "\r\n"
(ClienteId, JuegoID, @fecha, Comentarios)
SET
    FechaAlquiler = STR_TO_DATE(@fecha, "%Y-%c-%e");
```


# Consultas e Indices 
- Obtener el correo de un cliente a partir de su nombre y apellidos:
	```sql
	SELECT *
	FROM Clientes
	WHERE nombre LIKE '[nombre]' AND
	apellidos LIKE '[apellidos]';
	```
- Obtener el número de clientes de una determinada provincia:
	```sql
	SELECT COUNT(*)
	FROM Clientes
	WHERE provincia LIKE '[provincia]';
	```

- Obtener un listado que contenga el nombre completo y el correo electrónico de los
clientes que hayan contactado mediante un determinado canal en cierto periodo de
tiempo:  

```sql
	SELECT nombre, apellidos, email
	FROM Clientes
	WHERE Canal = [canal] AND
	FechaContacto LIKE '[año]%';
```

- Obtener un listado de clientes que contenga su nombre completo y el título del
videojuego o videojuegos que han alquilado durante los años 2019 y 2020, así como
la fecha concreta en la que han alquilado cada juego. El listado debe estar ordenado
por apellidos y contener solo clientes que sean de una determinada provincia:

```sql
SELECT Nombre, Apellidos, Titulo, FechaAlquiler FROM 
        Clientes JOIN Clientes_Juegos ON Clientes.ClienteID = Clientes_Juegos.ClienteID
                JOIN Juegos ON Clientes_Juegos.JuegoID = Juegos.JuegoId
                WHERE Clientes.Provincia = "Madrid"
                AND FechaAlquiler >= '2019-01-01' 
                AND FechaAlquiler < '2021-01-01'
                ORDER BY Apellidos;
```

- Dos consultas de interes:
	- Consulta 1, muestra los 10 juegos que mas se han alquilado en total:
	```sql
	SELECT Titulo, COUNT(*) AS veces_alquilado
	FROM Clientes_Juegos 
	INNER JOIN Juegos ON Juegos.JuegoID = Clientes_Juegos.JuegoID
	WHERE consola LIKE '[consola]'
	GROUP BY Clientes_Juegos.JuegoID
	ORDER BY veces_alquilado DESC
	LIMIT 10;
	```

	- Consulta 2, muestra los juegos que se han alquilado en una fecha específica:
	```sql
	SELECT Titulo
	FROM Clientes_Juegos 
	INNER JOIN Juegos ON Clientes_Juegos.JuegoID = Juegos.JuegoID
	WHERE FechaAlquiler LIKE '[anio]-[mes]-[dia]';
	```

# Cosas con MariaDB

## Acceso a mysql con phpmyadmin
- Levantamos la base de datos mysql en el puerto 3307. En caso de usar docker: 
	 docker run -d --name mysql-server -p 3306:3307 -e MYSQL_ROOT_PASSWORD=root -v mysql_data:/var/lib/mysql --restart unless-stopped mysql:latest
- editamos /opt/lampp/phpmyadmin/config.inc.php:
	Añadimos:
		// Oracle MySQL Server
		$i++;
		/* Authentication type */
		$cfg['Servers'][$i]['auth_type'] = 'config';
		$cfg['Servers'][$i]['user'] = 'root';
		$cfg['Servers'][$i]['password'] = 'root';
		/* Server parameters */
		$cfg['Servers'][$i]['verbose'] = 'Oracle MySQL';
		$cfg['Servers'][$i]['host'] = 'localhost:3307';
		$cfg['Servers'][$i]['compress'] = false;
		$cfg['Servers'][$i]['AllowNoPassword'] = false;

	Encima de la linea de "End of servers configuration"

- Iniciamos  xampp: sudo xampp start
-  Abrimos localhost en el navegador y accedemos a phpmyadmin, desde donde seleccionamos la base de datos a la que queramos acceder

## Acceso a MariaDB con MySQL Workbench

- Iniciamos XAMPP: sudo xampp start
- Añadimos una nueva conexion en workbench en el puerto 3306



## Cambios en tamaño de página

- Borramos los contenidos de  la carpeta de datos de MariaDB (/opt/lampp/var/mysql en linux, C:/xampp/mysql/data en windows) menos la carpeta mysql
- Editamos el archivo de configuración (/opt/lamp/etc/my.cnf en linux, C:/xampp/mysql/data/my.ini en windows) para modificar la variable innodb_page_size(4K, 16K, 64K) (y innodb_buffer_pool_size para el caso de 64K)
- Arrancamos xampp y cargamos la base de datos desde backup

- Tamaño para 4K: 26.5MB
- Tamaño para 16K: 23.5MB
- Tamaño para 64K: 24.6MB

Se ve claramente que el tamaño de página afecta al tamaño total de la BD, siendo 16K la mejor opción para este caso, lo cual tiene sentido ya que con páginas de 4K se gasta mucho espacio en almacenar las cabeceras y los pies de las páginas ya que para un tamaño de  página tan pequeño harán falta muchas páginas, y para un tamaño tan grande como 64K se desperdicia mucho espacio si alguna página se llena parcialmente, ya que ese espacio que queda vacío en la página cuenta como ocupado.


