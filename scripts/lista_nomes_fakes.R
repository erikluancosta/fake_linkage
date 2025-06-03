library(genderBR)
library(dplyr)

## ---------------------------
## Lista de nomes da Receita Federal
## ---------------------------
source("R/conectar.R")
con_nomes <- conectar("testes")

nomes <- dbGetQuery(
  con_nomes, 
  "SELECT nome_socio_razao_social as ds_nome_pac
   FROM socios
   WHERE nome_do_representante IS NULL
    AND cpf_cnpj_socio LIKE '**%'
   LIMIT 530000"
)

## ---------------------------
## Estimar sexo dos nomes
## ---------------------------
nomes <- nomes |> 
  mutate(
    sexo = get_gender(ds_nome_pac),
    sexo = case_when(
      sexo == "Male"~"Masc",
      sexo == "Female"~"Fem",
      TRUE ~ NA_character_
    )
  ) |> 
  distinct() |> 
  mutate(
    # Datas de nascimento distribuídas aleatoriamente
    dt_nasc = sample(
      seq(as.Date("1950-01-01"), as.Date("2023-12-29"), by = "day"),
      size = n(), replace = TRUE
    ),
    primeiro_nome = sub(" .*", "", ds_nome_pac)
  )

# Datas de nascimento e sexo do banco real do SIM
con_fake <- conectar("fake")
datas_nascimento <- dbGetQuery(con_fake, 'SELECT "DTNASC" as dt_nasc, "SEXO" as sexo FROM sim') |> 
  vitallinkage::ajuste_data(tipo_data=1) |> 
  mutate(
    sexo = case_when(
      sexo == 1 ~ 'Masc',
      sexo == 2 ~ 'Fem',
      TRUE ~ NA_character_
    ),
    banco_origem = "SIM"
  )


nomes2 <- nomes |> 
  left_join(
    datas_nascimento,
    by = c("dt_nasc", "sexo")
  ) |> 
  distinct()


## ---------------------------
## Adicionar a lista de nomes ao banco de dados
## ---------------------------
dbWriteTable(con_fake, "nomes_fake", nomes2, overwrite=TRUE)

