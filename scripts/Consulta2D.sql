select Nombre, Apellidos, Title, FechaAlquiler from 
		clientes join clientes_juegos on clientes.ClienteID = clientes_juegos.ClienteID
				join Juegos on clientes_juegos.JuegoID = Juegos.GameId
                where clientes.Provincia = "Madrid"
                And FechaAlquiler >= '2019-01-01' 
				AND FechaAlquiler < '2021-01-01'
                order by Apellidos;