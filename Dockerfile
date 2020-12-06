#We want to use the r-base as the base image
FROM r-base:3.4.2

#Updating to the latest version
RUN app-get update

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

