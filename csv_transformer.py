import xml.etree.ElementTree as ET
import csv


consolas = ["GameBoy", "MegaDrive", "Nintendo"]

for consola in consolas:
    archivo_xml = "datasets/" + consola + ".xml"
    archivo_csv = "datasets/" + consola + ".csv"


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
