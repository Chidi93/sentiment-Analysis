FROM rocker/r-apt:bionic
WORKDIR /app

RUN apt-get update && \
  apt-get install -y libxml2-dev

# Install binaries (see https://datawookie.netlify.com/blog/2019/01/docker-images-for-r-r-base-versus-r-apt/)
COPY ./requirements.txt .
RUN cat requirements.txt | xargs apt-get install -y -qq

# Install remaining packages from source
COPY ./requirements.R .
RUN Rscript requirements.R

# Clean up package registry
RUN rm -rf /var/lib/apt/lists/*

COPY ./src /app

EXPOSE 5000
CMD ["Rscript", "./DTrumpTweets.R"]

#We want to use the r-base as the base image
#FROM rocker/rstudio:latest

#RUN apt-get update -qq && apt-get -y --no-install-recommends install \
    
#Updating to the latest version
#RUN app-get update

#Working directory
#WORKDIR /sentiment-Analysis

#We need to copy Donald Tweets csv file
#COPY DT_tweets.csv .

#Copying the Lexicon File
#COPY nrc.csv .
#We need to copy the Rscript
#COPY DTrumpTweets.R .

#Installing the need r library from the install_package folder


# Run the Rscript code
#CMD [ "Rscript", "./DTrumpTweets.R" ]

