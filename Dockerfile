#Starting with the r-base intermediary image that support git
FROM r-base:4.0.3

RUN apt install -y git


#To clone the git repo
RUN git clone https://github.com/Chidi93/sentiment-Analysis.git

WORKDIR /sentiment-Analysis

# Install R packages
#RUN install2.r --error \
#    methods \
#   jsonlite \
#    tseries \
#    tidytext \
#    stringr \
#    tidyr \
#   ggplot2 \
#   wordcloud2 \
#    scales \
#   ggraph \
#   widyr \
#   topicmodels \
#   textdata \
#   dplyr

RUN Rscript -e "install.packages('tidytext', dependencies = TRUE)"
RUN Rscript -e "install.packages('stringr', dependencies = TRUE)"
RUN Rscript -e "install.packages('tidyr', dependencies = TRUE)"
RUN Rscript -e "install.packages('ggplot2', dependencies = TRUE)"
RUN Rscript -e "install.packages('wordcloud2', dependencies = TRUE)"
RUN Rscript -e "install.packages('scales', dependencies = TRUE)"
RUN Rscript -e "install.packages('igraph', dependencies = TRUE)"
RUN Rscript -e "install.packages('ggraph', dependencies = TRUE)"
RUN Rscript -e "install.packages('widyr', dependencies = TRUE)"
RUN Rscript -e "install.packages('topicmodels', dependencies = TRUE)"
RUN Rscript -e "install.packages('textdata', dependencies = TRUE)"
RUN Rscript -e "install.packages('Rcpp', dependencies = TRUE)"
RUN Rscript -e "install.packages('dplyr', dependencies = TRUE)"

# Clean up package registry
#RUN rm -rf /var/lib/apt/lists/*

#Copy the csv files and the R script
COPY DT_tweets.csv .
COPY nrc.csv .
COPY DTrumpTweets.R .

CMD ["Rscript", "./DTrumpTweets.R"]

