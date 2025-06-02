library(microdatasus)
library(dplyr)
# base de óbitos
sim <- fetch_datasus(
  year_start = 2016, 
  year_end = 2022, 
  uf = "PB", 
  information_system = "SIM-DO")

sim |> select(DTNASC) |> vitallinkage::ajuste_data(tipo_data=1)
