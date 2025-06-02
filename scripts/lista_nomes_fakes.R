library(genderBR)
library(dplyr)
source("R/conectar.R")
con_nomes <- conectar("testes")

# Query para nomes na base da Receita Federal
nomes <- dbGetQuery(
  con_nomes, 
  "SELECT nome_socio_razao_social as ds_nome_pac
   FROM socios
   WHERE nome_do_representante IS NULL
    AND cpf_cnpj_socio LIKE '**%'
   LIMIT 200000"
)


# Estimar sexo com base no nome
nomes <- nomes |> 
  mutate(
    sexo = get_gender(ds_nome_pac),
    sexo = case_when(
      sexo == "Male"~"Masc",
      sexo == "Female"~"Fem",
      TRUE ~ NA_character_
    )
  )





# split no primeiro espaço
nomes <- nomes |> 
  mutate(
    primeiro_nome = sub(" .*", "", ds_nome_pac)
  )

