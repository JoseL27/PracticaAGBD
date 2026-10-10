USE PracABD1;

ALTER TABLE Clientes ADD PRIMARY KEY (ClienteID);
ALTER TABLE Juegos ADD PRIMARY KEY (JuegoID);
ALTER TABLE Clientes_Juegos ADD CONSTRAINT Clave_Clientes_Juegos PRIMARY KEY (ClienteID, JuegoID, FechaAlquiler);