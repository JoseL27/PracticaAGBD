# Análisis
En el enunciado, parte 2: creación y estudios de índices se han propuesto los siguientes escenarios:

1. Obtener el correo de un cliente a partir de su nombre y apellidos. Realiza las pruebas concretamente Ángeles del Nido, que es la clienta que están buscando en este momento. 
2. Obtener el número de clientes de una determinada provincia. Realiza las pruebas con Lugo, que es la provincia en la que están valorando abrir mercado. 
3. Obtener un listado que contenga el nombre completo y el correo electrónico de los clientes que hayan contactado mediante un determinado canal en cierto periodo de tiempo. Realiza las pruebas concretamente con el canal web y el periodo 2019, que se corresponde con los clientes a los que se les pretende ofrecer un descuento especial. 
4. Obtener un listado de clientes que contenga su nombre completo y el título del videojuego o videojuegos que han alquilado durante los años 2019 y 2020, así como la fecha concreta en la que han alquilado cada juego. El listado debe estar ordenado por apellidos y contener solo clientes que sean de una determinada provincia. Realiza las pruebas con los clientes de Madrid, que es el mercado que se está analizando
5. Realiza dos consultas que pienses que puedan ser de interés para la empresa y con las que puedas extraer alguna conclusión de interés relativa al uso de los índices
6. De interés: Localizar un cliente a partir de su DNI para el sistema de Login de la página web del alquiler
7. De interés: Obtener la cantidad de juegos publicados según su editorial y consola, o solo su editorial para análisis o estadística

Analizando, podemos elaborar la siguiente tabla

| N   | Obtener                                                                   | A partir del                       | Tabla                            | Obtener (Columna)                                                                 | A partir del (Columna)                            | Observación            |
| --- | ------------------------------------------------------------------------- | ---------------------------------- | -------------------------------- | --------------------------------------------------------------------------------- | ------------------------------------------------- | ---------------------- |
| 1   | Correo de un cliente                                                      | Nombre, apellidos                  | Clientes                         | Email                                                                             | Nombre, Apellidos                                 |                        |
| 2   | (Número de) Clientes                                                      | Provincia                          | Clientes                         | COUNT(\*)                                                                         | Provincia                                         |                        |
| 3   | Nombre completo cliente, Correo Electrónico                               | Canal en cierto periodo de tiempo  | Clientes                         | Nombre, Apellidos                                                                 | Canal, FechaContacto                              |                        |
| 4   | Nombre completo cliente, Título del videojuego, Fecha exacto del alquiler | Fecha (año) de alquiler, Provincia | Clientes, Juegos, Cliente_Juegos | Clientes.Nombre, Clientes.Apellidos, Juegos.Titulo, Clientes_juegos.FechaAlquiler | Clientes_juegos.FechaAlquiler, Clientes.Provincia | Ordenado por apellidos |
| 5   | ID del cliente                                                            | DNI cliente                        | Clientes                         | ClienteID                                                                         | DNI                                               |                        |
| 6   | Cantidad de juegos                                                        | Editorial, consola                 | Juegos                           | COUNT(\*)                                                                         | Editor, Consola                                   |                        |

# Creación de índices y sentencias de prueba
En la siguiente sección se indican las sentencias para la creación de índices y sentencias de prueba
## 1 Obtener email del cliente a partir de su nombre y apellidos
### ✏️ Creación
```sql
CREATE INDEX idx_clientes_apellidos_nombre
ON Clientes (Apellidos ASC, Nombre); -- Reordenado para acelerar consulta N4
```
### ⛔ Eliminación
```sql
DROP INDEX idx_clientes_apellidos_nombre
ON Clientes;
```
### ✅ Prueba
```sql
SELECT Email
FROM clientes
WHERE
	Nombre LIKE "Ángeles"
	AND
	Apellidos LIKE "del Nido";
```
# 2 Obtener número de clientes a partir de su provincia
### ✏️ Creación
```sql
CREATE INDEX idx_clientes_provincia
ON Clientes (Provincia);
```
### ⛔ Eliminación
```sql
DROP INDEX idx_clientes_provincia
ON Clientes;
```
### ✅ Prueba
```sql
SELECT COUNT(*)
FROM Clientes
WHERE
	Provincia LIKE 'Lugo';
```
# 3 Obtener nombres, apellidos, correo electrónico del cliente a partir de su canal y fecha de contacto
### ✏️ Creación
```sql
CREATE INDEX idx_clientes_aniocontacto_canal
ON Clientes ((YEAR(FechaContacto)), Canal);
```
### ⛔ Eliminación
```sql
DROP INDEX idx_clientes_aniocontacto_canal
ON Clientes;
```
### ✅ Prueba
```sql
SELECT Nombre, Apellidos, Email
FROM Clientes
WHERE
	YEAR(FechaContacto) = 2019 -- Optimizar el año por si el formato textual de la fecha es distinto
	AND
	Canal = 1; -- Canal Web
```
# 4 Obtener nombre y apellidos, título del videojuego y fecha del alquiler a partir del fecha (año) del alquiler y provincia del cliente

### ✏️ Creación
```sql
CREATE INDEX idx_clientes_juegos_anioalquiler
ON Clientes_juegos ((YEAR(FechaAlquiler)));
-- Clientes.Provincia ya está cubierto por idx_clientes_provincia
-- ORDER BY Clientes.Apellidos podría ser acelerado por idx_clientes_apellidos_nombre
```
### ⛔ Eliminación
```sql
DROP INDEX idx_clientes_juegos_anioalquiler
ON Clientes_juegos;
```
### ✅ Prueba
```sql
SELECT Clientes.Nombre, Clientes.Apellidos, Juegos.Titulo, Clientes_juegos.FechaAlquiler
FROM Clientes_juegos
	INNER JOIN Clientes ON Clientes_juegos.ClienteID = Clientes.ClienteID
	INNER JOIN Juegos ON Clientes_juegos.JuegoID = Juegos.JuegoID
WHERE
	YEAR(Clientes_juegos.FechaAlquiler) IN (2019, 2020)
	AND
	Clientes.Provincia LIKE "Madrid"
ORDER BY Clientes.Apellidos;
```
# 5 Obtener ID del cliente a partir de su DNI
### ✏️ Creación
```sql
CREATE INDEX idx_clientes_dni
ON clientes (DNI);
```
### ⛔ Eliminación
```sql
DROP INDEX idx_clientes_dni
ON clientes;
```
### ✅ Prueba
```sql
SELECT *
FROM clientes
WHERE
	DNI LIKE "99158698F";
```
# 6 Obtener cantidad de juegos a partir del editorial y consola
### ✏️ Creación
```sql
CREATE INDEX idx_juegos_editorial_consola
ON juegos (editor, consola);
```
### ⛔ Eliminación
```sql
DROP INDEX idx_juegos_editorial_consola
ON clientes;
```
### ✅ Prueba
```sql
SELECT Editor, Consola, COUNT(*) as cantidad_juegos FROM juegos
WHERE
	editor LIKE "Bandai"
	AND
	consola LIKE "MegaDrive"
GROUP BY Editor, Consola;
```
# Pruebas
Todas las sentencias usados aquí se ejecutará en **terminal**, excepto indicado por `Workbench:`.
## Sin claves primarios ni foráneas
Antes de empezar las sentencias de prueba para cada sentencias de prueba, se ha ejecutado (4D y 4C, `borrado_claves_foraneas.sql` y `borrado_claves_primarias.sql`):
```sql
-- source borrado_claves_foraneas.sql
ALTER TABLE Clientes_Juegos DROP FOREIGN KEY Clave_Clientes;
ALTER TABLE Clientes_Juegos DROP FOREIGN KEY Clave_Juegos;
ALTER TABLE Clientes DROP PRIMARY KEY;
-- source borrado_claves_primarias.sql
ALTER TABLE Juegos DROP PRIMARY KEY;
ALTER TABLE Clientes_Juegos DROP PRIMARY KEY;
-- Quitar el índice restante de Clave_Juegos
DROP INDEX Clave_juegos ON Clientes_Juegos; -- Por cualquier razón el índice sigue ahí cuando se eliminan las claves foráneas
```
Una vez eliminado las claves primarias y foráneas, al ejecutar las sentencias de prueba, se obtienen los siguientes tiempos:

| Consulta | Nombre consulta                                                                                                                      | Tiempo de ejecución | Resultados retornados |
| -------- | ------------------------------------------------------------------------------------------------------------------------------------ | ------------------- | --------------------- |
| 1        | Obtener email del cliente a partir de su nombre y apellidos                                                                          | 0,03s               | 3                     |
| 2        | Obtener número de clientes a partir de su provincia                                                                                  | 0,03s               | 1                     |
| 3        | Obtener nombres, apellidos, correo electrónico del cliente a partir de su canal y fecha de contacto                                  | 0,03s               | 1666                  |
| 4        | Obtener nombre y apellidos, título del videojuego y fecha del alquiler a partir del fecha (año) del alquiler y provincia del cliente | 1,78s               | 9076                  |
| 5        | Obtener ID del cliente a partir de su DNI                                                                                            | 0,04s               | 1                     |
| 6        | Obtener cantidad de juegos a partir del editorial y consola                                                                          | Workbench: 3,359ms  | 1                     |
Observación, la consulta N6 se ejecuta en tan poco tiempo, que en el terminal directamente muestra 0,00s. Lo cual se utiliza Workbench para obtener el tiempo de consulta en ms.
# Reactivando claves primarias y foráneas
Antes de empezar las sentencias de prueba para cada sentencias de prueba, se ha ejecutado (4A y 4B, `creacion_claves_primarias.sql` y `creacion_claves_foraneas.sql`):
```sql
-- source creacion_claves_primarias.sql
ALTER TABLE Clientes ADD PRIMARY KEY (ClienteID);
ALTER TABLE Juegos ADD PRIMARY KEY (JuegoID);
ALTER TABLE Clientes_Juegos ADD CONSTRAINT Clave_Clientes_Juegos PRIMARY KEY (ClienteID, JuegoID, FechaAlquiler);
-- source creacion_claves_foraneas.sql
ALTER TABLE Clientes_Juegos
ADD CONSTRAINT Clave_Clientes
FOREIGN KEY (ClienteID)
REFERENCES Clientes(ClienteID);

ALTER TABLE Clientes_Juegos
ADD CONSTRAINT Clave_Juegos
FOREIGN KEY (JuegoID)
REFERENCES Juegos(JuegoID);
```

| Consulta | Nombre consulta                                                                                                                      | Tiempo de ejecución | Resultados retornados | Cambio con respecto al apartado anterior |
| -------- | ------------------------------------------------------------------------------------------------------------------------------------ | ------------------- | --------------------- | ---------------------------------------- |
| 1        | Obtener email del cliente a partir de su nombre y apellidos                                                                          | 0,02s               | 3                     | -0,01s                                   |
| 2        | Obtener número de clientes a partir de su provincia                                                                                  | 0,01s               | 1                     | -0,02s                                   |
| 3        | Obtener nombres, apellidos, correo electrónico del cliente a partir de su canal y fecha de contacto                                  | 0,02s               | 1666                  | -0,01s                                   |
| 4        | Obtener nombre y apellidos, título del videojuego y fecha del alquiler a partir del fecha (año) del alquiler y provincia del cliente | 0,18s               | 9076                  | -1,60s                                   |
| 5        | Obtener ID del cliente a partir de su DNI                                                                                            | 0,04s               | 1                     | 0                                        |
| 6        | Obtener cantidad de juegos a partir del editorial y consola                                                                          | Workbench: 2,041ms  | 1                     | -1,138ms                                 |
Observación: la consulta N6 fluctúa un poco, pero en general sigue siendo el mismo tiempo que sin claves primarias/foráneas
# Activando gradualmente los índices
Las índices creadas en cada apartado son las siguientes:

| Consulta | Nombre consulta                                                                                                                      | Nombre índice                      |
| -------- | ------------------------------------------------------------------------------------------------------------------------------------ | ---------------------------------- |
| 1        | Obtener email del cliente a partir de su nombre y apellidos                                                                          | `idx_clientes_apellidos_nombre`    |
| 2        | Obtener número de clientes a partir de su provincia                                                                                  | `idx_clientes_provincia`           |
| 3        | Obtener nombres, apellidos, correo electrónico del cliente a partir de su canal y fecha de contacto                                  | `idx_clientes_aniocontacto_canal`  |
| 4        | Obtener nombre y apellidos, título del videojuego y fecha del alquiler a partir del fecha (año) del alquiler y provincia del cliente | `idx_clientes_juegos_anioalquiler` |
| 5        | Obtener ID del cliente a partir de su DNI                                                                                            | `idx_clientes_dni`                 |
| 6        | Obtener cantidad de juegos a partir del editorial y consola                                                                          | `idx_juegos_editorial_consola`     |
**Asumiendo que los claves primarios y secundarios siguen activos, y los indices creados en los apartados previos siguen activos**
## Obtener email del cliente a partir de su nombre y apellidos
Antes de activar el índice
```sql
EXPLAIN SELECT Email
FROM clientes
WHERE
	Nombre LIKE "Ángeles"
	AND
	Apellidos LIKE "del Nido";
```
```
+----+-------------+----------+------------+------+---------------+------+---------+------+-------+----------+-------------+
| id | select_type | table    | partitions | type | possible_keys | key  | key_len | ref  | rows  | filtered | Extra       |
+----+-------------+----------+------------+------+---------------+------+---------+------+-------+----------+-------------+
|  1 | SIMPLE      | clientes | NULL       | ALL  | NULL          | NULL | NULL    | NULL | 85884 |     1.23 | Using where |
+----+-------------+----------+------------+------+---------------+------+---------+------+-------+----------+-------------+
```

Activamos el índice `idx_clientes_apellidos_nombre` y verificamos que se utiliza el índice
```sql
CREATE INDEX idx_clientes_apellidos_nombre
ON Clientes (Apellidos ASC, Nombre);
```
```
+----+-------------+----------+------------+-------+-------------------------------+-------------------------------+---------+------+------+----------+-----------------------+
| id | select_type | table    | partitions | type  | possible_keys                 | key                           | key_len | ref  | rows | filtered | Extra                 |
+----+-------------+----------+------------+-------+-------------------------------+-------------------------------+---------+------+------+----------+-----------------------+
|  1 | SIMPLE      | clientes | NULL       | range | idx_clientes_apellidos_nombre | idx_clientes_apellidos_nombre | 204     | NULL |    3 |   100.00 | Using index condition |
+----+-------------+----------+------------+-------+-------------------------------+-------------------------------+---------+------+------+----------+-----------------------+
```

## Obtener número de clientes a partir de su provincia

Antes de activar el índice
```sql
EXPLAIN SELECT COUNT(*)
FROM Clientes
WHERE
	Provincia LIKE 'Lugo';
```
```
+----+-------------+----------+------------+------+---------------+------+---------+------+-------+----------+-------------+
| id | select_type | table    | partitions | type | possible_keys | key  | key_len | ref  | rows  | filtered | Extra       |
+----+-------------+----------+------------+------+---------------+------+---------+------+-------+----------+-------------+
|  1 | SIMPLE      | Clientes | NULL       | ALL  | NULL          | NULL | NULL    | NULL | 85884 |    11.11 | Using where |
+----+-------------+----------+------------+------+---------------+------+---------+------+-------+----------+-------------+
```

Activamos el índice `idx_clientes_provincia` y verificamos que se utiliza el índice
```sql
CREATE INDEX idx_clientes_provincia
ON Clientes (Provincia);
```
```
+----+-------------+----------+------------+-------+------------------------+------------------------+---------+------+------+----------+--------------------------+
| id | select_type | table    | partitions | type  | possible_keys          | key                    | key_len | ref  | rows | filtered | Extra                    |
+----+-------------+----------+------------+-------+------------------------+------------------------+---------+------+------+----------+--------------------------+
|  1 | SIMPLE      | Clientes | NULL       | range | idx_clientes_provincia | idx_clientes_provincia | 123     | NULL |   20 |   100.00 | Using where; Using index |
+----+-------------+----------+------------+-------+------------------------+------------------------+---------+------+------+----------+--------------------------+
```

## Obtener nombres, apellidos, correo electrónico del cliente a partir de su canal y fecha de contacto
Antes de activar el índice
```sql
EXPLAIN SELECT Nombre, Apellidos, Email
FROM Clientes
WHERE
	YEAR(FechaContacto) = 2019 -- Optimizar el año por si el formato textual de la fecha es distinto
	AND
	Canal = 1; -- Canal Web
```
```
+----+-------------+----------+------------+------+---------------+------+---------+------+-------+----------+-------------+
| id | select_type | table    | partitions | type | possible_keys | key  | key_len | ref  | rows  | filtered | Extra       |
+----+-------------+----------+------------+------+---------------+------+---------+------+-------+----------+-------------+
|  1 | SIMPLE      | Clientes | NULL       | ALL  | NULL          | NULL | NULL    | NULL | 85884 |    10.00 | Using where |
+----+-------------+----------+------------+------+---------------+------+---------+------+-------+----------+-------------+
```

Activamos el índice `idx_clientes_aniocontacto_canal` y verificamos que se utiliza el índice
```sql
CREATE INDEX idx_clientes_aniocontacto_canal
ON Clientes ((YEAR(FechaContacto)), Canal);
```
```
+----+-------------+----------+------------+------+---------------------------------+---------------------------------+---------+-------------+------+----------+-------+
| id | select_type | table    | partitions | type | possible_keys                   | key                             | key_len | ref         | rows | filtered | Extra |
+----+-------------+----------+------------+------+---------------------------------+---------------------------------+---------+-------------+------+----------+-------+
|  1 | SIMPLE      | Clientes | NULL       | ref  | idx_clientes_aniocontacto_canal | idx_clientes_aniocontacto_canal | 4       | const,const | 1666 |   100.00 | NULL  |
+----+-------------+----------+------------+------+---------------------------------+---------------------------------+---------+-------------+------+----------+-------+
```
## Obtener nombre y apellidos, título del videojuego y fecha del alquiler a partir del fecha (año) del alquiler y provincia del cliente
Antes de activar el índice
```sql
EXPLAIN SELECT Clientes.Nombre, Clientes.Apellidos, Juegos.Titulo, Clientes_juegos.FechaAlquiler
FROM Clientes_juegos
	INNER JOIN Clientes ON Clientes_juegos.ClienteID = Clientes.ClienteID
	INNER JOIN Juegos ON Clientes_juegos.JuegoID = Juegos.JuegoID
WHERE
	YEAR(Clientes_juegos.FechaAlquiler) IN (2019, 2020)
	AND
	Clientes.Provincia LIKE "Madrid"
ORDER BY Clientes.Apellidos;
```
```
+----+-------------+-----------------+------------+--------+--------------------------------+--------------+---------+------------------------------------+------+----------+---------------------------------+
| id | select_type | table           | partitions | type   | possible_keys                  | key          | key_len | ref                                | rows | filtered | Extra                           |
+----+-------------+-----------------+------------+--------+--------------------------------+--------------+---------+------------------------------------+------+----------+---------------------------------+
|  1 | SIMPLE      | Juegos          | NULL       | ALL    | PRIMARY                        | NULL         | NULL    | NULL                               | 6252 |   100.00 | Using temporary; Using filesort |
|  1 | SIMPLE      | Clientes_juegos | NULL       | ref    | PRIMARY,Clave_Juegos           | Clave_Juegos | 4       | pracabd1.Juegos.JuegoID            |    4 |   100.00 | Using where; Using index        |
|  1 | SIMPLE      | Clientes        | NULL       | eq_ref | PRIMARY,idx_clientes_provincia | PRIMARY      | 4       | pracabd1.Clientes_juegos.ClienteID |    1 |    50.00 | Using where                     |
+----+-------------+-----------------+------------+--------+--------------------------------+--------------+---------+------------------------------------+------+----------+---------------------------------+
```
Observación: `Clave_Juegos` es el índice generado por la clave foránea entre `Cliente_Juegos` y `Juegos`.

Activamos el índice `idx_clientes_juegos_anioalquiler` y verificamos que se utiliza el índice
```sql
CREATE INDEX idx_clientes_juegos_anioalquiler
ON Clientes_juegos ((YEAR(FechaAlquiler)));
```
```
+----+-------------+-----------------+------------+--------+-------------------------------------------------------+--------------+---------+------------------------------------+------+----------+---------------------------------+
| id | select_type | table           | partitions | type   | possible_keys                                         | key          | key_len | ref                                | rows | filtered | Extra                           |
+----+-------------+-----------------+------------+--------+-------------------------------------------------------+--------------+---------+------------------------------------+------+----------+---------------------------------+
|  1 | SIMPLE      | Juegos          | NULL       | ALL    | PRIMARY                                               | NULL         | NULL    | NULL                               | 6252 |   100.00 | Using temporary; Using filesort |
|  1 | SIMPLE      | Clientes_juegos | NULL       | ref    | PRIMARY,Clave_Juegos,idx_clientes_juegos_anioalquiler | Clave_Juegos | 4       | pracabd1.Juegos.JuegoID            |    4 |    36.32 | Using where                     |
|  1 | SIMPLE      | Clientes        | NULL       | eq_ref | PRIMARY,idx_clientes_provincia                        | PRIMARY      | 4       | pracabd1.Clientes_juegos.ClienteID |    1 |    50.00 | Using where                     |
+----+-------------+-----------------+------------+--------+-------------------------------------------------------+--------------+---------+------------------------------------+------+----------+---------------------------------+
```

Observación: incluso sin crear el índice para este apartado, el tiempo de consulta es 0,06s, es decir, con este índice, es posible que no ha mejorado, incluso se ha empeorado el tiempo de consulta creando el índice. Si comparamos el tiempo de consulta en MySQL Workbench, el tiempo de consulta después de crear el índice, aunque no es consistente, es unos 5-10ms menos que el tiempo de consulta sin índice basado en ejecuciones de números limitados (unos 2 o 3 veces).
## Obtener ID del cliente a partir de su DNI
Antes de activar el índice
```sql
EXPLAIN SELECT *
FROM clientes
WHERE
	DNI LIKE "99158698F";
```
```
+----+-------------+----------+------------+------+---------------+------+---------+------+-------+----------+-------------+
| id | select_type | table    | partitions | type | possible_keys | key  | key_len | ref  | rows  | filtered | Extra       |
+----+-------------+----------+------------+------+---------------+------+---------+------+-------+----------+-------------+
|  1 | SIMPLE      | clientes | NULL       | ALL  | NULL          | NULL | NULL    | NULL | 95608 |    11.11 | Using where |
+----+-------------+----------+------------+------+---------------+------+---------+------+-------+----------+-------------+
```

Activamos el índice `idx_clientes_dni` y verificamos que se utiliza el índice
```sql
CREATE INDEX idx_clientes_dni
ON clientes (DNI);
```
```
+----+-------------+----------+------------+-------+------------------+------------------+---------+------+------+----------+-----------------------+
| id | select_type | table    | partitions | type  | possible_keys    | key              | key_len | ref  | rows | filtered | Extra                 |
+----+-------------+----------+------------+-------+------------------+------------------+---------+------+------+----------+-----------------------+
|  1 | SIMPLE      | clientes | NULL       | range | idx_clientes_dni | idx_clientes_dni | 36      | NULL |    1 |   100.00 | Using index condition |
+----+-------------+----------+------------+-------+------------------+------------------+---------+------+------+----------+-----------------------+
```
## Obtener cantidad de juegos a partir del editorial y consola
Antes de activar el índice
```sql
EXPLAIN SELECT Editor, Consola, COUNT(*) as cantidad_juegos FROM juegos
WHERE
	editor LIKE "Bandai"
	AND
	consola LIKE "MegaDrive"
GROUP BY Editor, Consola;
```
```
+----+-------------+--------+------------+------+---------------+------+---------+------+------+----------+------------------------------+
| id | select_type | table  | partitions | type | possible_keys | key  | key_len | ref  | rows | filtered | Extra                        |
+----+-------------+--------+------------+------+---------------+------+---------+------+------+----------+------------------------------+
|  1 | SIMPLE      | juegos | NULL       | ALL  | NULL          | NULL | NULL    | NULL | 6265 |     1.23 | Using where; Using temporary |
+----+-------------+--------+------------+------+---------------+------+---------+------+------+----------+------------------------------+
```

Activamos el índice `idx_juegos_editorial_consola` y verificamos que se utiliza el índice
```sql
CREATE INDEX idx_juegos_editorial_consola
ON juegos (editor, consola);
```
```
+----+-------------+--------+------------+-------+------------------------------+------------------------------+---------+------+------+----------+--------------------------+
| id | select_type | table  | partitions | type  | possible_keys                | key                          | key_len | ref  | rows | filtered | Extra                    |
+----+-------------+--------+------------+-------+------------------------------+------------------------------+---------+------+------+----------+--------------------------+
|  1 | SIMPLE      | juegos | NULL       | range | idx_juegos_editorial_consola | idx_juegos_editorial_consola | 181     | NULL |    6 |   100.00 | Using where; Using index |
+----+-------------+--------+------------+-------+------------------------------+------------------------------+---------+------+------+----------+--------------------------+
```

## Tiempos Obtenidos

| Consulta | Nombre consulta                                                                                                                      | Tiempo de ejecución | Resultados retornados | Índices activados                      |
| -------- | ------------------------------------------------------------------------------------------------------------------------------------ | ------------------- | --------------------- | -------------------------------------- |
| 1        | Obtener email del cliente a partir de su nombre y apellidos                                                                          | 0,00s               | 3                     | `idx_clientes_apellidos_nombre`        |
| 2        | Obtener número de clientes a partir de su provincia                                                                                  | 0,00s               | 1                     | `idx_clientes_provincia`               |
| 3        | Obtener nombres, apellidos, correo electrónico del cliente a partir de su canal y fecha de contacto                                  | 0,00s               | 1666                  | `idx_clientes_aniocontacto_canal`      |
| 4        | Obtener nombre y apellidos, título del videojuego y fecha del alquiler a partir del fecha (año) del alquiler y provincia del cliente | 0,08s               | 9076                  | `idx_clientes_juegos_anioalquiler`<br> |
| 5        | Obtener ID del cliente a partir de su DNI                                                                                            | 0,00s               | 1                     | `idx_clientes_dni`                     |
| 6        | Obtener cantidad de juegos a partir del editorial y consola                                                                          | Workbench: 0,843ms  | 1                     | `idx_juegos_editorial_consola`         |
Observación: para la consulta N6, aunque hubo mejoras en teoría, en práctica no tiene mucho mejora. Puesto que solo es diferencia de 1ms.
# Los índices más efectivas para consulta 1 y 4
Para la consulta 1, el índice `idx_clientes_apellidos_nombre` ha sido el más efectivo. Puesto que ha reducido el tiempo de consulta considerablemente.
Para la consulta 3, aunque se crea su propio índice `idx_clientes_juegos_anioalquiler`, esto no ha afectado mucho en el tiempo de consulta, además, en su sentencia de EXPLAIN se aprecia que ha usado los índices de **la clave foránea y la clave primaria de los clientes**. Lo cual simplemente con crear las claves primarias y foráneas ya acelera considerablemente esta consulta.
# Conclusión de los índices
Finalizado este análisis, se concluye ciertos puntos para creación y administración de índices:
- Crear índice no siempre acelera la consulta, aunque sea campos relevantes en `WHERE` y `GROUP BY` de las consultas
- `EXPLAIN SELECT ...` cuyo `possible_keys` parece que pone en lista los posibles índices a disposición del optimizador de consultas de MySQL, y `keys` realmente es el que se escoge para optimizar las consultas, crear un índice que aparezca en `possible_keys` no siempre significa que ha mejorado el tiempo de consulta, solo que el optimizador lo tenga en cuenta y no garantiza su uso
- En las consultas donde existen `JOIN`, el optimizador prefiere escoger las claves primarias y foráneas para la optimización, y solo con estas claves se aceleran considerablemente la consulta. No escoge los índices creados (como es el caso de `idx_clientes_aniocontacto_canal`). Optimizar una consulta con `JOIN` es bastante difícil.