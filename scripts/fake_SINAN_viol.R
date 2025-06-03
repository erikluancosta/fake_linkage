library(microdatasus)
library(dplyr)

## ----------------------------------
## Organizando as bases
## ----------------------------------
# Caminho para a pasta com os arquivos .dbc
caminho_pasta <- "data/SINAN_VIOL/"

# Lista todos os arquivos .dbc da pasta
arquivos_dbc <- list.files(path = caminho_pasta, pattern = "\\.dbc$", full.names = TRUE)

# Inicializa lista para armazenar os dataframes
lista_filtrados <- list()

# Loop sobre os arquivos
for (arquivo in arquivos_dbc) {
  message("Lendo: ", arquivo)
  
  # Tenta ler o arquivo
  dados <- tryCatch(
    read.dbc::read.dbc(arquivo),
    error = function(e) {
      message("Erro ao ler ", arquivo, ": ", e$message)
      return(NULL)
    }
  )
  
  # Filtra apenas se leu com sucesso
  if (!is.null(dados)) {
    dados_filtrados <- dplyr::filter(dados, SG_UF_NOT == 25)
    lista_filtrados[[arquivo]] <- dados_filtrados
  }
  
}

# Une todos os dataframes em um só
sinan_viol <- dplyr::bind_rows(lista_filtrados)
rm(dados, dados_filtrados)

## ------------------------------------
## Tratamento de colunas
## ------------------------------------

# Lista de colunas a serem convertidas
cols_to_convert <- c("REL_ESPEC", "LESAO_ESPE","VIOL_ESPEC", "LOCAL_ESPE", "AG_ESPEC",
                     "DEF_ESPEC", "CONS_ESPEC", "ENC_ESPEC")

# Aplicar a conversão em todas as colunas especificadas
sinan_viol[cols_to_convert] <- lapply(sinan_viol[cols_to_convert], function(x) {
  iconv(x, from = "latin1", to = "UTF-8", sub = "byte")
})


sinan_viol <- sinan_viol |> 
  mutate(
    id_unico = paste0("SINAN_VIOL_", row_number())
  ) |> 
  select(id_unico, everything())

## ----------------------------------
##  Salva o dataframe final no banco de dados
## ----------------------------------
source("R/conectar.R")
con_fake <- conectar("fake")

dbWriteTable(con_fake, "sinan_viol", sinan_viol, overwrite = TRUE, row.names = FALSE)
