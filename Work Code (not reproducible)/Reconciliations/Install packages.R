# this script installs all required packages.
# we will assume that the the R is >= 3.4.3


#specify the packages of interest
packages = c("tidyverse","dbplyr","RPostgreSQL", "magrittr", "lubridate",
             "RJDBC", "rJava", "jsonlite", "excel.link")

#use this function to check if each package is on the local machine
#if a package is installed, it will be loaded
#if any are not, the missing package(s) will be installed and loaded
package.check <- lapply(packages, FUN = function(x) {
    if (!require(x, character.only = TRUE)) {
        install.packages(x, dependencies = TRUE, repos = 'http://cran.us.r-project.org')
        library(x, character.only = TRUE)
    }
})

#verify they are loaded
search()


# install.packages('readr', repos='http://cran.us.r-project.org')
# install.packages('dplyr', repos='http://cran.us.r-project.org')
# install.packages('dbplyr', repos='http://cran.us.r-project.org')
# install.packages('RPostgreSQL', repos='http://cran.us.r-project.org')
# install.packages('magrittr', repos='http://cran.us.r-project.org')
# install.packages('lubridate', repos='http://cran.us.r-project.org')
# install.packages('stringr', repos='http://cran.us.r-project.org')
# install.packages('tidyr', repos='http://cran.us.r-project.org')
# install.packages('RJDBC', repos='http://cran.us.r-project.org')
# install.packages('rJava', repos='http://cran.us.r-project.org')
# install.packages('formattable', repos='http://cran.us.r-project.org')
# install.packages('xlsx', repos='http://cran.us.r-project.org')
# install.packages('xlsxjars', repos='http://cran.us.r-project.org')
# install.packages('tibble', repos='http://cran.us.r-project.org')
# install.packages('jsonlite', repos='http://cran.us.r-project.org')