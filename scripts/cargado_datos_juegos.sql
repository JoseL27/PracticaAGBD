-- Cambiar path a donde se encuentre el juego de datos
LOAD DATA LOCAL INFILE '/home/nigga/GameBoy.csv'
	INTO TABLE Juegos
	CHARACTER SET 'latin1'
	FIELDS TERMINATED BY ';'
	LINES TERMINATED BY '\n';

-- Cambiar path a donde se encuentre el juego de dato:
LOAD DATA LOCAL INFILE '/home/nigga/MegaDrive.csv'
	INTO TABLE Juegos
	CHARACTER SET 'utf8mb4'
	FIELDS TERMINATED BY ';'
	LINES TERMINATED BY '\n';

-- Cambiar path a donde se encuentre el juego de datos
LOAD DATA LOCAL INFILE '/home/nigga/Nintendo.csv'
	INTO TABLE Juegos
	CHARACTER SET 'utf8mb4'
	FIELDS TERMINATED BY ';'
	LINES TERMINATED BY '\n';
