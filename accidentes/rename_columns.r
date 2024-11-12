
#.Instalar.y.cargar.las.bibliotecas.necesarias
install.packages("sf")
library(sf)
library(dplyr)
library(stringr)
library(stringi)
#.Cargar.el.archivo.GeoPackage
##ruta_archivo.<-."/mnt/data/accidentes_septiembre.gpkg"
ruta_archivo<-"C:/Users/mfortiz/Documents/GIS/Basura/accidentes_septiembre.gpkg"


data<-st_read(ruta_archivo)
colnames(data)
geom <- st_geometry(data)



nombres_limpios <- colnames(data) %>%
  str_replace_all("\\.{3,}", "_") %>%    # Reemplaza secuencias de tres o más puntos por un solo guion bajo
  str_replace_all("\\.{1,2}", "_") %>%   # Reemplaza secuencias de uno o dos puntos por un solo guion bajo
  str_replace_all("\\s+", "_") %>%       # Reemplaza espacios con un guion bajo
  stri_trans_general("Latin-ASCII") %>%      # Elimina tildes o caracteres especiales
  
  str_to_lower()                         # Convierte todo a minúsculas

# Asignar los nombres limpios a las columnas
colnames(data) <- nombres_limpios


# 2. Renombrar las columnas sin geometría
data <- data %>%
  st_set_geometry(NULL) %>%
        rename(
      id = "id",
      numero_de_parte = "numero_de_parte",
      fecha_hora_original = "fecha_hora_original",
      anio = "ano",
      mes = "mes",
      dia = "dia",
      dia_de_semana = "dia_de_semana",
      fecha = "fecha",
      dia_tipo = "dia_tipo",
      horario = "horario",
      hora = "hora",
      banda_horaria = "banda_horaria",
      eje_original = "eje_original",
      eje_desc_original = "eje_desc_original",
      autopista = "autopista",
      banda_ramal = "banda_y_o_ramal",
      tramo_troncal = "tramo_troncal",
      pk_original = "pk_original",
      pk = "pk",
      indicador_por_au = "indicador_por_au",
      localizacion_original = "localizacion_original",
      local = "local_",
      tronco = "tronco",
      acceso = "acceso",
      salida = "salida",
      via = "via",
      visibilidad_original = "visibilidad_original",
      visibilidad = "visibilidad",
      clima_original = "clima_original",
      condiciones_meteorologicas = "condiciones_meteorologicas",
      iluminacion_original = "iluminacion_original",
      condiciones_de_iluminacion = "condiciones_de_iluminacion",
      rodadura_original = "rodadura_original",
      superficie_de_la_via = "superficie_de_la_via",
      calzada_libre_original = "calzada_libre_original",
      total_de_carriles = "total_de_carriles",
      restriccion_calzada = "restriccion_de_calzada",
      livianos = "livianos",
      buses_y_pesados = "buses_y_pesados",
      total = "total",
      ilesos = "ilesos",
      heridos = "heridos",
      leve = "leve",
      moderado_sdg = "moderado_sdg",
      grave = "grave",
      muertos = "muertos",
      victimas_ = "victimas_",
      obitos = "obitos",
      peaton_ileso = "peaton_ileso",
      peaton_herido = "peaton_herido",
      peaton_muerto = "peaton_muerto",
      ciclista_ileso = "ciclista_ileso",
      ciclista_herido = "ciclista_herido",
      ciclista_muerto = "ciclista_muerto",
      tipo_de_accidente_original = "tipo_de_accidente_original",
      colision_primer_evento = "colision_primer_evento",
      colision_segundo_evento = "colision_segundo_evento",
      colision_tipo_de_impacto_del_primer_evento = "colision_tipo_de_impacto_del_primer_evento",
      causal = "causal",
      factor = "factor",
      buscador = "buscador",
      colisionante = "colisionante",
      indicadores_ambientales = "indicadores_ambientales",
      celda_sin_calculo = "celda_sin_calculo",
      impactos_con_danos = "impactos_con_danos",
      impactos_tipo_de_defensa = "impactos_tipo_de_defensa",
      impactos_ubicacion_defensa = "impactos_ubicacion_defensa"
    )

  data <- st_set_geometry(data, geom)
  
  #.Guardar.los.datos.renombrados.en.un.nuevo.archivo.GeoPackage
st_write(data,"C:/Users/mfortiz/Documents/GIS/Basura/accidentes_septiembre_renombrado.gpkg")
