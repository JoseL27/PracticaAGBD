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
	ClienteID INT NOT NULL,
	JuegoID INT NOT NULL,
    FechaAlquiler DATE NOT NULL,
    Comentarios VARCHAR(500)
)ENGINE = InnoDB
    TABLESPACE = TBLS_juegos;
