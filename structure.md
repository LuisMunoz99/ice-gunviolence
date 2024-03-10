Este documento detalla los pasos del proceso de análisis de segregación economica de muertes de menores por arma de fuego entre 2021 y 2022 atravez del Indice de Concentración en los Extremos. El pipeline sigue una estructura autoexplicativa y autocontenida.

### Import

#### Input (readonly)

-   **Regdem_2021_agosto2022:** Contiene muertes de 2021 hasta agosto de 2022; filtradas para el año 2021.
-   **Regdem_2022:** Fuente para muertes ocurridas en 2022.

#### Src

-   **Import-regdem.R:** Importa datos desde su origen (formato xlsx) a formato csv para procesamiento mas adelante.
-   **child-firearm.R:**
    -   Filtra muertes mayores a un año, excluyendo unidades de edad en días y edades menores o iguales a cero.
    -   Crea indicadores para menores (1-19 años) y armas de fuego (ICD10 con "firearm" en la descripción).

#### Output

-   **Regdem2021-2022.csv:** Muertes registradas por el registro demográfico entre 2021-2022.
-   **regdem_CF:** Lista de muertes de menores (1-19 años) por causas relacionadas con armas de fuego según ICD10 entre 2021-2022![]()

### Geocode

#### Import (Symlink)

(Dentro de esta tarea se conecta con un enlace simbólico al directorio Import.)

#### Manual

##### Src

-   **manual-export-CF.R:** Exporta la lista preparada de muertes de interés para extraer coordenadas manualmente.

##### Output

-   **geocoding_CF:** Lista de muertes de interés en formato xlsx para geocodificar e importar más adelante.

#### Transform-cords

##### Import

###### Input

-   **geocodingCF-done:** Lista de muertes de interés en formato xlsx con coordenadas extraídas manualmente

###### Src

-   **import-manual-geocoding.R:** Importa lista de muertes en xlsx y las convierte a CSV.

###### Output

-   **geocodingCF-manual-done.csv:** Lista de muertes de interés en formato csv.

##### Export

###### Src

-   **transforming-cords-CF.R:** Transforma coordenadas en simple feature points, excluyendo eventos no geocodificados.

###### Output

-   **Geocoded-coords.csv:** Coordenadas geocodificadas.

En resumen, la tarea GEOCODE utiliza la lista generada en la tarea IMPORT para exportar datos en formato xlsx. Después de obtener las coordenadas de las direcciones, se importan nuevamente para transformarlas en un objeto de simple features que se conecta con la información del censo. El resultado es una lista de eventos geocodificados a sus respectivos tramos censales.
