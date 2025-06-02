library(DBI)
library(RPostgres)

conectar <- function() {
  con <- dbConnect(
    RPostgres::Postgres(),
    host = Sys.getenv("DB_HOST"),
    port = as.integer(Sys.getenv("DB_PORT")),
    user = Sys.getenv("DB_USER"),
    password = Sys.getenv("DB_PASSWORD"),
    dbname = Sys.getenv("DB_NAME")
  )
  
  # Verificar se a conexão foi estabelecida com sucesso
  if (dbIsValid(con)) {
    print("Conexão estabelecida com sucesso!")
  } else {
    print("Falha na conexão ao banco de dados.")
  }
  
}





