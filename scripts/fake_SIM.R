library(microdatasus)
library(dplyr)

## ----------------------------------
## Baixando a base de óbitos do SIM
## ----------------------------------
# base de óbitos
sim <- fetch_datasus(
  year_start = 2016, 
  year_end = 2023, 
  uf = "PB", 
  information_system = "SIM-DO")

sim <- sim |> 
  mutate(
    id_unico = paste0("SIM_", row_number())
  ) |> 
  select(id_unico, everything())

## ----------------------------------
## Upload no banco de dados
## ----------------------------------
source("R/conectar.R")
con_fake <- conectar("fake")
dbWriteTable(con_fake, "sim", sim, overwrite = TRUE, row.names = FALSE)
