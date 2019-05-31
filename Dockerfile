FROM rocker/tidyverse:3.6.0
    
# R Task View

RUN sudo apt-get install -y default-jre \
  && apt-get install -y default-jdk \
  && R CMD javareconf
RUN apt-get install libicu-dev \ 
  libbz2-dev \ 
  liblzma-dev -y
RUN R -e 'remotes::install_cran("rJava");'

RUN apt-get install -y \
  autoconf \
  libtool \ 
  m4 \
  automake

RUN git clone https://git.osgeo.org/gitea/geos/geos.git \
  && cd geos \
  && ./autogen.sh \
  && ./configure \
  && make \
  && make check \
  && make install
RUN R -e 'remotes::install_cran("rgeos");'

RUN apt-get install libhiredis-dev -y
RUN R -e 'remotes::install_cran("redux");'
RUN R -e 'remotes::install_cran("RJDBC");'

RUN wget https://github.com/bumpx/oracle-instantclient/raw/master/oracle-instantclient18.3-devel-18.3.0.0.0-1.x86_64.rpm \
  && wget https://github.com/bumpx/oracle-instantclient/raw/master/oracle-instantclient18.3-basic-18.3.0.0.0-1.x86_64.rpm \
  && apt-get install -y alien libaio1 \
  && alien -i oracle-instantclient18.3-basic*.rpm \
  && alien -i oracle-instantclient18.3-devel*.rpm \
  && export LD_LIBRARY_PATH=/usr/lib/oracle/18.3/client64/lib:$LD_LIBRARY_PATH \
  && export ORACLE_HOME=/usr/lib/oracle/18.3/client64 \
  && mkdir $ORACLE_HOME/rdbms  \
  && mkdir $ORACLE_HOME/rdbms/public \
  && cp /usr/include/oracle/18.3/client64/* $ORACLE_HOME/rdbms/public \
  && wget https://cran.r-project.org/src/contrib/ROracle_1.3-1.tar.gz \
  && R CMD INSTALL ROracle_1.3-1.tar.gz \
  && R -e 'remotes::install_cran("ora");'
RUN R -e 'remotes::install_cran("RH2");'
RUN R -e 'remotes::install_cran("rpostgis");'

RUN apt-get install odbcinst -y \
  && wget https://downloads.cloudera.com/connectors/impala_odbc_2.5.40.1025/Debian/clouderaimpalaodbc_2.5.40.1025-2_amd64.deb \
  && dpkg -i clouderaimpalaodbc_*.deb \
  && odbcinst -i -d -f /opt/cloudera/impalaodbc/Setup/odbcinst.ini
  
RUN apt-get install -y default-libmysqlclient-dev \
  && apt-get install -y libmariadb-client-lgpl-dev \
  && touch /etc/my.cnf \
  && echo "[rs-dbi]" >> /etc/my.cnf \
  && echo "database=test" >> /etc/my.cnf \
  && echo "user=root" >> /etc/my.cnf \
  && echo "password=root" >> /etc/my.cnf

RUN R -e 'remotes::install_cran("ctv"); ctv::install.views("Databases")'

COPY test_install.R /test_install.R

RUN R -e "source('/test_install.R')" && rm /test_install.R

ENV LD_LIBRARY_PATH=/usr/lib/oracle/18.3/client64/lib:$LD_LIBRARY_PATH

CMD /init