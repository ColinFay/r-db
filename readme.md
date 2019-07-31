# r-db

A Dockerfile that can install the whole stack of packages from the CRAN task view "Databases", plus some others. Probably for teaching purpose.

Once launched, this Docker image has everything needed to connect and interact with the databases listed in the [Databases CRAN View](https://cran.r-project.org/web/views/Databases.html), well at least with the one that can be installed with the `{ctv}` package, plus some others you'll find listed below.

Note that the Task View will be installed with the status it had on the date of the Docker container, which is defined by the version of R used.

Each DB has an example code you can run if you go to <http://colinfay.me/r-db/>. Most are taken from these packages README / docs. Not all are filled and any help testing / writting example code will be welcome.

Please check the [License file](LICENSE) before using.

## How to 

Please read <http://colinfay.me/r-db/> for how to install and interact with these DBMS with other containers.