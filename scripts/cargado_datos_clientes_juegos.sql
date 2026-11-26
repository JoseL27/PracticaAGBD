LOAD DATA LOCAL INFILE '/home/nigga/Clientes_juegos.txt'
INTO TABLE Clientes_Juegos
CHARACTER SET utf8mb4
FIELDS TERMINATED BY "\t"
LINES TERMINATED BY "\n"
(ClienteId, JuegoID, @fecha, Comentarios)
SET
    FechaAlquiler = STR_TO_DATE(@fecha, "%Y-%c-%e");
