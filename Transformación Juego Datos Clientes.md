# Transformación de juegos de datos (Clientes, Clientes_Juegos)

Al analizar el documento Excel, se encuentra ciertos problemas:
- Algunos campos contienen el carácter coma `,`
- Algunos campos contienen el carácter doble-comilla `"`

![Excel Juego de Datos Clientes: Búsqueda en campos comas](docs_imagenes/excel_busqueda_comas.png)
![Excel Juego de Datos Clientes: Búsqueda en campos comillas](docs_imagenes/excel_busqueda_comillas.png)

Un fichero CSV por definición, es un documento texto plano con estructura similar a una tabla, en cual, cada linea
es una fila (Row) de datos, y las columnas (Column) separadas por comas.

Que el fichero Excel original contenga en sus campos comas y comillas presentan un problema: no se podrán identificar columnas correctamente, y algunos Softwares (Como Microsoft Excel y LibreOffice Calc) rodearán el campo que contengan comas con doble-comillas.

![Notepad++ Clientes Exportado Excel en tabulador: campo con coma rodeado por comillas](docs_imagenes/clientes_exportado_excel_elmoral_rodeado_comillas.png)

El rodeo de comillas presentarán otro problema, si algún campo ya por sí contienen comillas (`"CANTINFLAS"`), se duplicará las comillas, y se rodeará el campo entero con otro doble comilla. Lo cual tenemos un Comilla-Inception.

![Notepad++ Clientes Exportado Excel en tabulador: campo con comillas rodeado por comillas](docs_imagenes/clientes_exportado_excel_cantinflas_doblerodeado_comillas.png)

Para evitar complicaciones con las comas en un fichero de CSV (Comma Separated Values/Valores separados por Comas). Se opta por separar cada columna usando tabuladores (`\t`).

En el juego de datos, ciertos clientes tienen en su dirección valores con comillas, `CALLE DE MARIO MORENO "CANTINFLAS"`. Y localidades que contienen comas `MOLINOS, LOS`.

Microsoft Excel al exportar documentos XLSX a CSV (O ficheros separados por tabuladores), campos con comas lo rodeará con doble comillas (`"`). Esto puede ir en conflicto con campos de direcciones que contienen caractéres de doble comillas, como es el caso de `CANTINFLAS`. **Esto dificulta la sentencia de `LOAD DATA` en SQL**

Lo que queremos es: tener un CSV (separado por tabuladores), y que cada campo se ve EXACTAMENTE como era cuando esté abierta en Excel.

En Microsoft Office no hay opciones de personalizar el formato de exportado de CSV, o se exporta como CSV separado con comas, o tabuladores.

En cambio, LibreOffice Calc permite la exportación de CSV (`Archivo -> Guardar Como, elegir "Texto CSV" como formato, guardar, Usar formato Texto CSV`) y te pregunta cómo quieres exportar. Incluyendo cómo es el separador de campos (por defecto: coma), y con qué carácter se rodea los campos con comas (Por defecto: doble-comilla). Con qué codificación, etc.

![LibreOffice Calc: ventana de exportación CSV por defecto](docs_imagenes/libreoffice_wizard_exportcsv_default.png)

Cambiamos "Delimitador de campos" a `{Tabulación}` y Delimitador de cadena a comilla simple `'`

![LibreOffice Calc: ventana de exportación CSV modificado](docs_imagenes/libreoffice_wizard_exportcsv_modified.png)

El exportador de CSV de LibreOffice es más inteligente, cuando configuramos los delimitador de campos y cadena como Tabulación y comilla simple respectivamente, cuando se encuentra con un campo que contiene comas, como separamos por tabulador, no hace falta usar comillas para rodear el campo, porque se distingue ya con el tabulador.

![Notepad++ Clientes Exportado LibreOffice en tabulador: campo con coma rodeado separado por tabulador](docs_imagenes/clientes_exportado_libreoffice_elmoral_sin_comillas.png)

![Notepad++ Clientes Exportado LibreOffice en tabulador: campo con comillas sin comilla-inception](docs_imagenes/clientes_exportado_libreoffice_cantinflas_sin_comillas_inception.png)

Esto facilita infinitamente la sentencia de `LOAD DATA` en SQL. Puesto ahora los datos se ven exáctamente como se ve en Excel/LibreOffice.

**Mucho cuidado con la fecha: en algunos sistemas configurado con diferentes región/idioma en el sistema.** El separador de fecha puede aparecer como raya `-` (2026-03-21) o como forward-slash `/` (2026/03/21). Esto habría que reflejarlo en la sentencia de `LOAD DATA` en su función de `STR_TO_DATE()`, para cambiar raya por forward-slash o vice-versa. **También hay que tener en cuenta el formato de nueva línea**, que en sistemas Unix se usa simplemente `\n`, mientras que en Windows se usa `\r\n`.

Al final, para transformar el fichero original a CSV para tratarlo fácilmente con `LOAD DATA`, hay que:

1. Abrir el fichero Excel original en LibreOffice
2. En LibreOffice: `Archivo -> Guardar Como, elegir "Texto CSV" como formato, guardar, Usar formato Texto CSV`
3. Cambiar delimitadores de campo y cadenas a `{Tabulación}` y comilla simple `'`
4. Si es necesario, ajustar el separador de fecha y nuevas lineas en la sentencia `LOAD DATA`

Estos pasos serán los mismos para `Clientes.xlsx` y para `Clientes_juegos.xlsx`. Siendo el juego de dato `Clientes_juegos` mucho más simple que `Clientes`, excepto la columna de comentario (que algunos contiene cadenas simples, otras con comas, y algunos con comas y puntos). Pero se aplica a ambos documentos el mismo tratamiento descrito arriba.