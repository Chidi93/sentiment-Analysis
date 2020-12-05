# Text Mining Assignment done by Agbo, Chidi Ugo (XMHPFX)
# Read the Donald Trumps tweets script from the my working directory
library(readr)
DT_tweets <- read_csv("C:/Users/darli/OneDrive/Desktop/Corvinus School Materials/RStudio Training/DT_tweets.csv")
View(DT_tweets)

# Had to remove some columns that are not relevant in the analysis as shown below;
DT_tweets$Media_Type <- NULL
DT_tweets$Hashtags <- NULL
DT_tweets$Tweet_Url <- NULL
DT_tweets$twt_favourites_IS_THIS_LIKE_QUESTION_MARK <- NULL

# Install necessary packages!
library(dplyr)
library(tidytext)
library(stringr)
library(tidyr)
library(ggplot2)
library(wordcloud2)
library(scales)
library(igraph)
library(ggraph)
library(widyr)
library(topicmodels)

#Data PreProcessing

#Breaking the Donald Trump's tweet into tokens: this will be done by tokenizing the text by words
#I went further to change the date format.
tidy_texts <- DT_tweets %>% unnest_tokens(word,Tweet_Text)
tidy_texts$Date <- as.Date(tidy_texts$Date, format = "%d/%m/%Y")

#I limited my analysis to 2016-2017 which has the most relevant tweets of Donald Trump.
tidy_texts <- tidy_texts[tidy_texts$Date > "2016-01-01",]
tidy_texts <- tidy_texts[tidy_texts$Date < "2017-01-01",]

#I then ordered the tidy texts by date for better reference and analysis
tidy_texts <- tidy_texts[order(tidy_texts$Date),]
tidy_texts$index <- seq(1:nrow(tidy_texts))

# I decided to separate the year, month and day, so that I can make reference or analyze any of them separately.
tidy_texts <- separate(tidy_texts, "Date", c("Year", "Month", "Day"), sep = "-")

tidy_texts
#Get the word frequencies: This will help me to know the words that appear more in Donald Trump's tweet.
tidy_texts %>% count(word, sort = TRUE)
#From the result above, I was able to get the words that appeared more in his tweet were irrelevant words such as "the", "http", "t.co", "rt". so, I need to remove the stop words. 
 

# In order to eliminate stop words, I need to get the stop word dictionary

data("stop_words")
stop_words[1150,1] <- "t.co"
stop_words[1151,1] <- "https"
stop_words[1152,1] <- "http"
stop_words

# Eliminating stop words
tidy_texts <- tidy_texts %>% anti_join(stop_words) 
tidy_texts

# Let me get the word frequencies again
tidy_texts %>% count(word, sort = TRUE)
#After the removing the stop words, the top ten words that appeared more than other include: realdonaldtrump, trump, amp, trump2016, makeamericagreatagain, cruz, hillary, donald and ted 
#Now, I have words that convey certain meanings 

#Visualization
# Let me visualize the words by setting the frequency greater than 10 in a barchart with ggplot2
tidy_texts %>% count(word, sort = TRUE) %>%
  filter(n>10) %>% #This will display those words whose frequencies are greater than 10
  mutate(word=reorder(word,n)) %>%
  ggplot(aes(word,n)) +
  geom_col() +
  xlab(NULL) +
  ylab("Frequencies") +
  coord_flip() +
  theme(text = element_text(size = 20))

#I used theme function to increase the fontsize of text in the graph
# While the Mutate function adds new column to the dataframe or used to rewrite a column in the dataframe

#Let me visualize the word frequencies in an interactive wordcloud
toTheCloud <- tidy_texts %>% count(word, sort = TRUE)
names(toTheCloud) <- c("word", "freq")
wordcloud2(toTheCloud, color = "random-light", backgroundColor = "gray")



#Tokenize the DT tweet text by bigrams
DT_bigrams <- DT_tweets %>% unnest_tokens(bigram, Tweet_Text, token = "ngrams", n=2)
DT_bigrams

#Now, let me get the bigram frequency as I did for word by word tokenization
DT_bigrams %>% count(bigram, sort = TRUE)
# From the result of the code above, the link "http t.co" has the highest occurance. But I have to remove stop words as I did for one word tokenization.

#Eliminating stop words
DT_bigrams_separated <- DT_bigrams %>%
  separate(bigram, c("word1", "word2"), sep = " ")
DT_bigrams_separated

data("stop_words")
stop_words[1150,1] <- "t.co"
stop_words[1151,1] <- "https"
stop_words[1152,1] <- "http"
stop_words


DT_bigrams_filtered <- DT_bigrams_separated %>%
  filter(!word1 %in% stop_words$word) %>%
  filter(!word2 %in% stop_words$word)
DT_bigrams_filtered

#Having filtered the stop words, let me get the bigram frequencies again
DT_bigrams_count <- DT_bigrams_filtered %>% count(word1, word2, sort = TRUE)
DT_bigrams_count

#Remember, I separated the bigram into two individual words, let me bring the two words together again
DT_bigrams_united <- DT_bigrams_filtered %>% unite(bigram, word1, word2, sep = " ")
DT_bigrams_united
DT_bigrams_united %>% count(bigram, sort = TRUE)

#Let me visualize the bigram frequencies in an interactive wordcloud as I did word by word frequencies
toTheCloud <- DT_bigrams_united %>% count(bigram, sort = TRUE)
names(toTheCloud) <- c("word", "freq")
wordcloud2(toTheCloud, color = "random-light", backgroundColor = "gray")

#plot bigram Graph
DT_bigrams_count <- DT_bigrams_count %>% filter(word1 != "NA" | word2 != "NA")

Bigram_graph <- DT_bigrams_count %>% filter(n >10) %>%
  graph_from_data_frame()

set.seed(1234)

# Show the graph!
ggraph(Bigram_graph, layout = "fr") +
  geom_edge_link() +
  geom_node_point() +
  geom_node_text(aes(label = name), vjust = 1, hjust = 1)

# Weight the edges by the frequency of the bigram!

set.seed(3212)
# Define the graph edge design!
a <- grid::arrow(type = "closed", length = unit(.15, "inches"))

# Plot the graph with the ggraph package
ggraph(Bigram_graph, layout = "fr") +
  geom_edge_link(aes(edge_alpha = n), show.legend = FALSE,
                 arrow = a, end_cap = circle(.07, 'inches')) +
  geom_node_point(color = "lightblue", size = 5) +
  geom_node_text(aes(label = name), vjust = 1, hjust = 1) +
  theme_void()
#From the result of the graph above, it shows words that are correlated or associated together. for example, Hillary clinton, bill and crooked are clustered together.
#This grouping gives a better understanding of his tweets.
 
#Next Task is to analyze the sentiment lexicons

#So, let's see the sentiment lexicons

library(textdata)
get_sentiments("afinn")
get_sentiments("bing")
nrc <- read_csv("C:/Users/darli/OneDrive/Desktop/Corvinus School Materials/RStudio Training/nrc.csv")
nrc

#Let me get the words expressing joy according to the NRC lexicon
nrc_joy <- nrc %>% filter(sentiment=="joy")
nrc_joy

#Let me get the words expressing joy in Donald Trump's tweet text
tidy_texts %>%
  inner_join(nrc_joy) %>%
  count(word, sort = TRUE)

##Let me get the words expressing anger according to the NRC lexicon
nrc_anger <- nrc %>% filter(sentiment=="anger")
nrc_anger

#Let me get the words expressing anger in Donald Trump's tweet text
tidy_texts %>%
  inner_join(nrc_anger) %>%
  count(word, sort = TRUE)
#Let me get the words expressing trust according to the NRC lexicon
nrc_trust <- nrc %>% filter(sentiment=="trust")
nrc_trust

#Let me get words expressing trust in Donald Trump's tweet
tidy_texts %>%
  inner_join(nrc_trust) %>%
  count(word, sort = TRUE)
# Get the sentiment scores of the 10-word-long substrings of the DT_Tweet Scripts based on the Bing lexicon

DT_sentiment <- tidy_texts %>% inner_join(get_sentiments("bing")) %>%
  count(index= index %/% 100, sentiment) %>%
  spread(sentiment, n, fill = 0) %>% 
  mutate(sentiment=positive-negative)
DT_sentiment
# From the code above, I created a new column called index which runs from 1 to the end of the row.
# It works in a way that a 10-word-long substring belongs to index 0, another 10-word-long substrings to index 1 and so on.
#With this, I am able to see the index with the most positive or negative words using the sentiment.

# Plot the sentiment scores of the previously examined substrings ordered by their index in his tweets!
ggplot(DT_sentiment, aes(index, sentiment)) +
  geom_col(show.legend = FALSE)
#From the ggplot, it showed that in the begining of the year, his tweets were filled with positive words while in the middle of the year, Donald Trump tweets were filled with negative words may 
# From July to september, he tweeted more with positive words which I believe must be his tweets during his campaign
# In November, his tweet was really negative because almost on the streets of America, it seemed like Hillary clinton will win the election.
# After the period of election, he tweets had more positive words throughout the rest of the year. I guess this must have been about his promises of what he will do for the country and her citizens.

# I want to know word occurance by months
#get word word frequencies by month
word_by_month <- tidy_texts %>%
  count(Month, word, sort = TRUE)
word_by_month
#The result of above code shows that in the 10th Month, he tweeted more about Hillary and realDonald trump.

#I want to get the total word count for each month. Let me know the month that he tweeted more
total_word_count <- word_by_month %>%
  group_by(Month) %>%
  summarise(total = sum(n))
total_word_count

word_by_month <- left_join(word_by_month, total_word_count)
word_by_month
#From the result above, the month with the high word count is the 10 month (November), which was the month of his election.

# Filter the word frequencies and total word counts of June, July, August, September, October and November!
plot_words_total <-word_by_month %>% 
  filter(Month == "06" | Month == "07" | Month == "08" |
           Month == "09" | Month == "10" | Month == "11")

plot_words_total

# Get the word relative frequencies for each month and plot their histogram 
ggplot(plot_words_total, aes(n/total, fill = Month)) +
  geom_histogram(show.legend = FALSE) +
  xlim(NA, 0.052) +
  facet_wrap(~Month, ncol = 2, scales = "free_y")+theme(text = element_text(size=20))

# Order the words of each Month by their relative frequency descending 
rank_by_freq <- plot_words_total %>% 
  group_by(Month) %>% 
  mutate(rank = row_number(), 
         `term frequency` = n/total)
rank_by_freq

 
# Get the words the tf-idf counts for the words six examined Month
word_by_month <- word_by_month %>% bind_tf_idf(word, Month, n)

word_by_month

plot_words_total <- word_by_month %>% 
  filter(Month == "06" | Month == "07" | Month == "08" |
           Month == "09" | Month == "10" | Month == "11")
plot_words_total



#The next thing under sentiment analysis is to define a negation words
#Negation word definition
negation_words <- c("not", "no", "never", "without")
AFinn <- get_sentiments("afinn")
AFinn

#How many positive or negative words based on the Afinn lexicon are preceded by negation words?
negation_words <- DT_bigrams_separated %>% 
  filter(word1 %in% negation_words) %>%
  inner_join(AFinn, by=c(word2="word")) %>%
  count(word1, word2, value, sort = TRUE)

negation_words
#From the result of the code above, the highest occuring negated words in his tweet include; "never forget", "not good", "not want", "no chance" and " not happy"

#Let me Visualize the results!
negation_words %>%
  mutate(contribution = n * value) %>%
  arrange(desc(abs(contribution))) %>%
  head(20) %>%
  mutate(word2 = reorder(word2, contribution)) %>%
  ggplot(aes(word2, n * value, fill = n * value > 0)) +
  geom_col(show.legend = FALSE) +
  xlab("Words preceded by negation term") +
  ylab("Sentiment score * number of occurrences") +
  facet_wrap(~word1, ncol=2, scales = "free")+
  coord_flip()+theme(text = element_text(size=20))
#From the result of the code, we can see the both positive and negative words that were used together with a negation word which changes the meaning of the individual words.

#Conclusion
#The result of this task has shown that Donald Trump used more negative words close to the election period may be as a result of the rumor that Hillary Clinton Might win, a rumor which went viral.
#After the election, he used more positive words in his tweets as seen in the result of the codes above.
#I also saw that he tweeted more in October, a month before the 2016 US presidential election than any other months in 2016.
# In sentiment analysis, the result of one word sentiment does not reflect the actual sentiment found in his tweet.
#The reason is because some of the one word sentiment is preceded by a negated word which alters its meaning
#So in sentiment analysis, it is more accurate to analyze the sentiment using the negated words as I did above.
