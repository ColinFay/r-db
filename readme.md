# r-db

A Dockerfile that can install the whole stack of packages from the CRAN task view "Databases".

Each db has an example code you can run. Mostly taken from these packages README / docs.

## Creating Docker network

Let's get all these folks wired

```
docker network create -d bridge --subnet 192.168.0.0/24 rdb
```

Launch rstudio instance: 

```
docker run -it -d -e DISABLE_AUTH=true -p 8787:8787 --net r-db colinfay/r-db:3.6.0 && sleep 2 && open http://localhost:8787/
```

+ {bigrquery}
+ {dbfaker}
+ {DBI}
+ {DBItest}
+ {dbplyr}
+ {dplyr}
+ {elastic}

## elasticsearch & {elastic}

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

+ {filehashSQLite}
+ {implyr}

## impala & {implyr}

```
docker pull cloudera/impala-dev:minimal
docker run -p 21050:21050 -d --name impala --net rdb cloudera/impala-dev:minimal
```


+ {influxdbr}

## InfluxDB and {influxdbr}

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

+ {liteq}
+ {mongolite}

## mongodb & {mongolite}

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

+ {odbc (core)}
+ {ora}
+ {pointblank}
+ {pool}
+ {R4CouchDB}

## couchdb and {R4CouchDB}

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

+ {RCassandra}

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

+ {RcppRedis}
+ {redux}
+ {RGreenplum}

``` 
docker pull pivotaldata/gpdb-devel
docker run --rm --name gpdb --net r-db pivotaldata/gpdb-devel
```

+ {RH2}
+ {RJDBC}
+ {RMariaDB}

## Mariadb 

```
docker pull mariadb:10.4.5-bionic
docker run --net r-db --name mariadb -e MYSQL_ROOT_PASSWORD=root -d mariadb:10.4.5-bionic
```

+ {RMySQL}
+ {ROracle}
+ {rpostgis}
+ {RPostgres}

## PostGreSQL and {RPostgres}

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

+ {RPostgreSQL}
+ {RPresto}

```
docker pull prestashop/prestashop:1.7

```
+ {RSQLite}
+ {sqldf}
+ {tidyr}
+ {TScompare}
+ {uptasticsearch}
