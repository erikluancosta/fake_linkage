library(lubridate)
library(dplyr)
source("R/conectar.R")
con_fake <- conectar("fake")

## ------------------------------
## Criando a base de linkage fake
## ------------------------------
# Base do SIM
sim_fake <- dbGetQuery(con_fake, 'SELECT "id_unico", "DTNASC" as dt_nasc, "SEXO" as sexo FROM sim') |> 
  vitallinkage::ajuste_data(tipo_data=1) |> 
  mutate(
    sexo = case_when(
      sexo == 1 ~ 'Masc',
      sexo == 2 ~ 'Fem',
      TRUE ~ NA_character_
    ),
    banco_origem = "SIM",
    ano_nasc = lubridate::year(dt_nasc)
  )

# Base do SINAN Violências
sinan_viol_fake <- dbGetQuery(
  con_fake, 
  'SELECT "id_unico", 
    "ANO_NASC" as ano_nasc,
    "CS_SEXO" as sexo
   FROM sinan_viol') |> 
  mutate(
    sexo = case_when(
      sexo == "M" ~ 'Masc',
      sexo == "F" ~ 'Fem',
      TRUE ~ NA_character_
    ),
    banco_origem = "SINAN_VIOL"
  )

# Nomes fake
nomes_fake <- dbGetQuery(con_fake, 'SELECT * FROM nomes_fake')



