library(genderBR)
library(dplyr)

## ---------------------------
## Lista de nomes da Receita Federal
## ---------------------------
source("R/conectar.R")
con_nomes <- conectar("testes")

maes <- dbGetQuery(
  con_nomes, 
  "SELECT nome_socio_razao_social as ds_nome_mae
   FROM socios
   WHERE nome_do_representante IS NULL
    AND cpf_cnpj_socio LIKE '**%'
   LIMIT 2100000"
)

## ---------------------------
## Selecionar nomes das mães
## ---------------------------
maes <- maes |> 
  mutate(
    sexo = get_gender(ds_nome_mae),
    sexo = case_when(
      sexo == "Male"~"Masc",
      sexo == "Female"~"Fem",
      TRUE ~ NA_character_
    )
  ) |> 
  distinct() |> 
  mutate(
    primeiro_nome = sub(" .*", "", ds_nome_mae),
    row = row_number()
  ) |> 
  filter(
    sexo == "Fem" & row > 530000
  ) |> 
  mutate(
    row = row_number()
  ) |> 
  filter(
    row < 499802
  )

con_fake <- conectar("fake")
nomes <- dbGetQuery(con_fake, "SELECT * FROM nomes_fake")


maes_expandido <- maes |>
  select(ds_nome_mae) |>
  slice_head(n = nrow(nomes)) |> 
  add_row(ds_nome_mae = rep(NA_character_, nrow(nomes) - nrow(maes)))# preenche com NA se for menor

# Agora pode combinar
final <- bind_cols(nomes, maes_expandido)


## ---------------------------
## Adicionar a lista de nomes ao banco de dados
## ---------------------------
dbWriteTable(con_fake, "nomes_fake_mae", final, overwrite=TRUE)

