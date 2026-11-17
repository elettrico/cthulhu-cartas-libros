# Cartas de libros para La llamada de Cthulhu

Mazo imprimible en español con 117 cartas de libros, grimorios y tomos para
*La llamada de Cthulhu*, séptima edición. Cada carta reúne la información útil
durante la partida: idioma, fecha, autor, contenido, hechizos, pérdida de
Cordura, ganancia de Mitos de Cthulhu, puntuación de Mitos, Ocultismo y tiempo
de estudio, cuando corresponde.

El proyecto usa [Squib](https://squib.rocks/), una herramienta escrita en Ruby,
para generar automáticamente:

- los frentes y dorsos individuales en PNG;
- un PDF A4 con los frentes, distribuido en páginas de 3 × 3 cartas;
- un PDF A4 con los dorsos preparados para impresión dúplex.

Es un recurso no oficial creado por aficionados. Las referencias utilizadas
para preparar los datos están documentadas en `data/fuentes.yml`.

## Requisitos

- Ruby 2.7 o posterior;
- Squib 0.19;
- Rake;
- las bibliotecas nativas de Cairo, Pango y GdkPixbuf requeridas por Squib.

En Debian, Ubuntu y Linux Mint se pueden instalar las dependencias con:

```bash
sudo apt update
sudo apt install ruby ruby-dev build-essential \
  libcairo2-dev libpango1.0-dev libgdk-pixbuf-2.0-dev
sudo gem install squib rake --no-document
```

## Generar las cartas

Clona el repositorio y entra en su directorio:

```bash
git clone https://github.com/elettrico/cthulhu-cartas-libros.git
cd cthulhu-cartas-libros
```

Comprueba los datos y recursos, y genera después el mazo:

```bash
rake check
rake
```

Los archivos generados aparecen en `output/`:

- `libros_frentes.pdf`: frentes en hojas A4;
- `libros_dorsos.pdf`: dorsos reflejados para impresión dúplex;
- `cards/front_*.png`: frentes individuales;
- `cards/back_*.png`: dorsos individuales.

Para borrar las salidas generadas:

```bash
rake clean
```

## Impresión

Imprime los PDF a tamaño real o al 100 %, sin usar «ajustar a página». Antes de
imprimir todo el mazo conviene hacer una prueba con una hoja para comprobar la
orientación y el borde de giro que utiliza la impresora al imprimir a doble
cara.

## Modificar el mazo

Los datos de las cartas están en `data/libros.xlsx`. El archivo puede editarse
con LibreOffice Calc o cualquier programa compatible con XLSX. Deben
conservarse los nombres de las columnas porque `deck.rb` los utiliza para
componer las cartas.

La primera fila contiene los encabezados y cada fila siguiente representa una
carta. Las columnas utilizadas por el generador son:

| Columna | Contenido |
| --- | --- |
| `titulo` | Título del libro o tomo. |
| `origen` | Publicación o escenario de procedencia. |
| `idioma` | Idioma de la edición representada. |
| `fecha` | Fecha o periodo de publicación. |
| `autor` | Autor real o atribuido. |
| `estudio` | Tiempo necesario para completar el estudio. |
| `COR` | Pérdida de Cordura. |
| `MCI` / `MCC` | Ganancia inicial y completa de Mitos de Cthulhu. |
| `mitos` | Ganancia única de Mitos, cuando no se usa el par anterior. |
| `PM` | Puntuación de Mitos del tomo. |
| `ocultismo` | Ganancia de Ocultismo. |
| `contenido` | Resumen del contenido. |
| `hechizos` | Hechizos incluidos o sugeridos. |

Las referencias completas se mantienen en `data/fuentes.yml`. Para cambiar el
aspecto de las cartas, edita `layout.yml`.

## Estructura del proyecto

- `data/libros.xlsx`: datos de las 117 cartas;
- `data/fuentes.yml`: referencias y criterios de documentación;
- `deck.rb`: composición y generación de las cartas;
- `layout.yml`: posiciones, tamaños, tipografías y colores;
- `config.yml`: configuración general de Squib;
- `assets/`: recursos gráficos usados en frentes y dorsos;
- `scripts/check_data.rb`: validación ejecutada por `rake check`.
