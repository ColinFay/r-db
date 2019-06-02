# r-db

A Dockerfile that can install the whole stack of packages from the CRAN task view "Databases". Probably for teaching purpose.

Once launched, this Docker image has everything needed to connect and interact with the databases listed in the [Databases CRAN View](https://cran.r-project.org/web/views/Databases.html), well at least with the one that can be installed with the `{ctv}` package. 

On this README, you'll also find how to install and interact with these DBMS with other containers.

Note that the Task View will be installed with the status it had on the date of the Docker container. 

Each DB has an example code you can run. Most arer taken from these packages README / docs. Not all are filled and any help testing / writting example code will be welcome.


## Creating Docker network

Let's get all these folks wired

```
docker network create r-db
```

Launch rstudio instance: 

```
docker pull colinfay/r-db:3.6.0

docker run -it -d -e DISABLE_AUTH=true -p 8787:8787 --net r-db colinfay/r-db:3.6.0 && sleep 2 && open http://localhost:8787/
```

## Task View Package

### Google Big Query & `{bigrquery}`

> Not open source, and no account. Tests & Feedback welcome

### `{dbfaker}`

> Tests needed

### `{DBI}` & `{DBItest}` / `{dbplyr}` & `{dplyr}`

Core package, cross-database.
 
## elasticsearch & `{elastic}` / `{uptasticsearch}`

```
docker pull elasticsearch:7.1.0
docker run -d --name elasticsearch --net r-db -p 9200:9200 -p 9300:9300 -e "discovery.type=single-node" elasticsearch:7.1.0
```

In RStudio 

``` r 
library(elastic)
x <- connect(port = 9200, host = "elasticsearch")

if (index_exists(x, "plos")) index_delete(x, "plos")
plosdat <- system.file("examples", "plos_data.json", package = "elastic")
invisible(docs_bulk(x, plosdat))
Search(x, index = "plos", size = 1)$hits$hits
```

> Tests needed fo {uptasticsearch}

### `{filehashSQLite}`

In RStudio:

``` r 
library(filehashSQLite)
dbCreate("myTestDB", type = "SQLite")
db <- dbInit("myTestDB", type = "SQLite")
set.seed(100)
db$a <- rnorm(100)
db$b <- "a character element"
with(db, mean(a))
cat(db$b, "\n")
```

## impala & {implyr}

```
docker pull cloudera/impala-dev:minimal
docker run -p 21050:21050 -d --name impala --net r-db cloudera/impala-dev:minimal
```

> Not tested yet

## InfluxDB and `{influxdbr}`

```
docker pull influxdb:1.5
docker run -d --name influxdb --net r-db influxdb:1.5
```

In RStudio 

``` r 
library(influxdbr)
library(xts)
data("sample_matrix")
xts_data <- xts::as.xts(x = sample_matrix)
xts::xtsAttributes(xts_data) <- list(info = "SampleDataMatrix",
                                     UnitTesting = TRUE, 
                                     n = 180,
                                     source = "xts")

con <- influx_connection(host = "influxdb", port = 8086)
create_database(con = con, db = "mydb")
show_databases(con = con)
influx_write(con = con, 
             db = "mydb",
             x = xts_data, 
             measurement = "sampledata")
show_databases(con = con)

df_data <- dplyr::bind_cols(time = zoo::index(xts_data), # timestamp
                            data.frame(xts_data)) %>% # coredata
  dplyr::mutate(info = "SampleDataMatrix", # add tag 'info'
                UnitTesting = TRUE, # add tag 'UnitTesting'
                n = row_number(), # add tag 'n'
                source = "df")

influx_write(con = con, 
             db = "mydb",
             x = df_data,
             time_col = "time", tag_cols = c("info", "UnitTesting", "n", "source"),
             measurement = "sampledata")

```

### `{liteq}`

``` r
library(liteq)
db <- tempfile()
q <- ensure_queue("jobs", db = db)
q
list_queues(db)
publish(q, title = "First message", message = "Hello world!")
publish(q, title = "Second message", message = "Hello again!")
list_messages(q)
msg <- try_consume(q)
msg
```

## mongodb & `{mongolite}`

```
docker pull mongo:3.4
docker run -p 27017:27017 -d --name mongo --net r-db mongo:3.4
```

Try in RStudio:

``` r
library(mongolite)
a <- mongo(collection = "collection", db = "db", url = "mongodb://mongo:27017")
a$insert(iris)
a$insert(ggplot2::diamonds)
a$count()
a$find('{"cut" : "Premium", "price" : { "$lt" : 1000 } }')
```

### `{odbc}`

Core package, cross-database.

### `{pointblank}`

Core package, cross-database.

### `{pool}`

In RStudio:

``` r
library(shiny)
library(dplyr)
library(pool)

pool <- dbPool(
  drv = RMySQL::MySQL(),
  dbname = "shinydemo",
  host = "shiny-demo.csa7qlmguqrf.us-east-1.rds.amazonaws.com",
  username = "guest",
  password = "guest"
)
onStop(function() {
  poolClose(pool)
})

ui <- fluidPage(
  textInput("ID", "Enter your ID:", "5"),
  tableOutput("tbl"),
  numericInput("nrows", "How many cities to show?", 10),
  plotOutput("popPlot")
)

server <- function(input, output, session) {
  output$tbl <- renderTable({
    pool %>% tbl("City") %>% filter(ID == input$ID) %>% collect()
  })
  output$popPlot <- renderPlot({
    df <- pool %>% tbl("City") %>% head(input$nrows) %>% collect()
    pop <- df$Population
    names(pop) <- df$Name
    barplot(pop)
  })
}

shinyApp(ui, server)
```

## couchdb and `{R4CouchDB}`

```
docker pull couchdb:2.3.1
docker run --rm --name couchdb --net r-db couchdb:2.3.1
```

In R 

``` r
library(R4CouchDB)
con <- cdbIni("couchdb")
con$queryParam <- "count=10"
cdbGetUuidS(con)
```

+ Cassandra & `{RCassandra}`

```
docker pull cassandra:2.1
docker run --name cassandra --network r-db -d cassandra:2.1
```

In RStudio 

``` r 
library(RCassandra)
con <- RC.connect(host = "cassandra", port = 9160L)
log <- RC.login(con, "cassandra", "cassandra")
```

> Tests needed

### redis & `{RcppRedis}` / `{redux}`

```
docker pull redis:5.0.5
docker run --rm --name redis --net r-db -d redis:5.0.5
```

``` r
r <- redux::hiredis(
  url = "redis"
)
r$PING()
r$SET("foo", "bar")
r$GET("foo")

```

> Tests needed for {RcppRedis}

### {RGreenplum}

``` 
docker pull pivotaldata/gpdb-devel
docker run --rm --name gpdb --net r-db pivotaldata/gpdb-devel
```
> Tests needed

+ H2 & `{RH2}`

> Tests needed

+ `{RJDBC}`

> Tests needed

## Mariadb & `{RMariaDB}`

```
docker pull mariadb:10.4.5-bionic
docker run --net r-db --name mariadb -e MYSQL_ROOT_PASSWORD=root -d mariadb:10.4.5-bionic
```

> Tests needed

+ MySQL & `{RMySQL}`

```
docker pull mysql:8.0.16
docker run --net r-db --name mysql -d mysql:8.0.16
```
> Tests needed

+ Oracle & `{ROracle}` 

> Tests needed

+ {rpostgis}

> Tests needed

## PostGreSQL and `{RPostgres}` / `{RPostgreSQL}`

```
docker pull postgres:11.3
docker run --rm -e POSTGRES_PASSWORD=docker --name postgre --net r-db postgres:11.3
```

In RStudio 

``` r 
library(DBI)
# Connect to a specific postgres database i.e. Heroku
con <- dbConnect(RPostgres::Postgres(),
                 dbname = 'postgres', 
                 host = 'postgre',
                 port = 5432, 
                 user = 'postgres',
                 password = 'docker')

dbListTables(con)
dbWriteTable(con, "mtcars", mtcars)
dbListTables(con)

res <- dbSendQuery(con, "SELECT * FROM mtcars WHERE cyl = 4")
dbFetch(res)
dbClearResult(res)
```

### `{RPresto}`

```
docker pull prestashop/prestashop:1.7
```

### `{RSQLite}`

In RStudio

``` r 
library(DBI)
con <- dbConnect(RSQLite::SQLite(), ":memory:")
dbListTables(con)
dbWriteTable(con, "mtcars", mtcars)
dbListTables(con)
dbReadTable(con, "mtcars")
```

### `{sqldf}`

Core package, cross-database.

### `{tidyr}`

Core package, cross-database.
 
### `{TScompare}`

Core package, cross-database.
