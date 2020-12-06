#We want to use the r-base as the base image
FROM rocker/rstudio:latest

RUN apt-get update -qq && apt-get -y --no-install-recommends install \
  libxml2-dev \
  libxt-dev \
  libjpeg-dev \
  libglu1-mesa-dev \
  libcairo2-dev \
  libsqlite3-dev \
  libmariadbd-dev \
  libmariadb-client-lgpl-dev \
  libpq-dev \
  libssh2-1-dev \
  unixodbc-dev \
  git \
  && R -e "source('https://bioconductor.org/biocLite.R')" \
  && install2.r --error \
    --deps TRUE \
    shiny \
    dplyr \
    tidytext \
    stringr \
    tidyr \
    ggplot2 \
    wordcloud2\
    scales \
    igraph \
    ggraph \
    widyr \
    topicmodels \
    textdata
#Updating to the latest version
#RUN app-get update
#To clone the git repository
RUN git clone https://github.com/Chidi93/sentiment-Analysis.git

#Working directory
WORKDIR /sentiment-Analysis

#We need to copy Donald Tweets csv file
COPY DT_tweets.csv .

#Copying the Lexicon File
COPY nrc.csv .
#We need to copy the Rscript
COPY DTrumpTweets.R .

#Installing the need r library from the install_package folder
RUN mkdir -p /opt/software/setup/RUN/R
ADD install_packages.R /opt/software/setup/R/
RUN Rscript /opt/software/setup/R/install_packages

# Run the Rscript code
CMD [ "Rscript", "./DTrumpTweets.R" ]

