FROM rocker/r-base

MAINTAINER "Bas van Reeuwijk" bvk@qlik.com

RUN apt-get update \
 && apt-get upgrade -y
RUN apt-get install libcurl4-gnutls-dev libssl-dev -y

RUN install2.r --error -r "https://cran.rstudio.com" Rserve \
 && install2.r --error -r "https://cran.rstudio.com" TTR \
 && install2.r --error -r "https://cran.rstudio.com" forecast \
 && install2.r --error -r "https://cran.rstudio.com" dplyr \
 && install2.r --error -r "https://cran.rstudio.com" devtools \
 && install2.r --error -r "https://cran.rstudio.com" ChainLadder \
 && rm -rf /tmp/downloaded_packages/ /tmp/*.rds

# you have to run Rserve with remote=TRUE otherwise
# it won't let you connect to the container
EXPOSE 6311
ENTRYPOINT R -e "Rserve::run.Rserve(remote=TRUE)" 