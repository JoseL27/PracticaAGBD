USE PracABD1;

ALTER TABLE Clientes_Juegos
ADD CONSTRAINT Clave_Clientes 
FOREIGN KEY (ClienteID) 
REFERENCES Clientes(ClienteID);

ALTER TABLE Clientes_Juegos
ADD CONSTRAINT Clave_Juegos
FOREIGN KEY (JuegoID) 
REFERENCES Juegos(JuegoID);