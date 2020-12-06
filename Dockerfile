#We want to use the r-base as the base image
FROM rocker/rstudio:latest

RUN apt-get update -qq && apt-get -y --no-install-recommends install \
    
#Updating to the latest version
#RUN app-get update

#Working directory
WORKDIR /sentiment-Analysis

#We need to copy Donald Tweets csv file
COPY DT_tweets.csv .

#Copying the Lexicon File
COPY nrc.csv .
#We need to copy the Rscript
COPY DTrumpTweets.R .

#Installing the need r library from the install_package folder


# Run the Rscript code
CMD [ "Rscript", "./DTrumpTweets.R" ]

