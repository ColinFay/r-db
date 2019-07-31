# Install mongodb
RUN apt-get update && apt-get install -y gnupg2 \
  && sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 \
  --recv 9DA31620334BD75D9DCB49F368818C72E52529D4 \
  && echo "deb http://repo.mongodb.org/apt/debian \
  stretch/mongodb-org/4.0 main" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.0.list \
  && sudo apt-get update && sudo apt-get install -y mongodb-org \
  && apt-get install -y systemd && sudo mkdir -p /data/db \
  && apt-get install -y libsasl2-dev && apt-get install -y zlib1g-dev \
  && R -e 'install.packages("remotes"); remotes::install_cran("mongolite")' 
  
  
## Install Neo4J
RUN apt-get install -y openjdk-8-jre \
  && mkdir /home/neo4j \
  && cd /home/neo4j && wget -O neo4j.tar.gz \
  https://neo4j.com/artifact.php?name=neo4j-community-3.5.0-unix.tar.gz \
  && tar xvf neo4j.tar.gz && rm neo4j.tar.gz \  
  && apt-get install -y libudunits2-dev \
  && R -e 'remotes::install_cran(c("ggraph", "visNetwork")); \
    remotes::install_github("neo4j-rstats/neo4r")'