#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from nltk.parse import CoreNLPParser
import pandas as pd
import string
import numpy as np
from collections import Counter
import re


#### functions

def remove_emoji(string):
    emoji_pattern = re.compile("["
                           u"\U0001F600-\U0001F64F"  # emoticons
                           u"\U0001F300-\U0001F5FF"  # symbols & pictographs
                           u"\U0001F680-\U0001F6FF"  # transport & map symbols
                           u"\U0001F1E0-\U0001F1FF"  # flags (iOS)
                           u"\U00002702-\U000027B0"
                           u"\U000024C2-\U0001F251"
                           u"\u200d"
                           "]+", flags=re.UNICODE)
    return emoji_pattern.sub(r'', string)

def clean_response(response):
    #I first remove any punctuation/ unusual characters from the response (except apostrophes)
    chars_to_remove = '!"#$%&\()*+,-./:;<=>?@[\\]^_`{|}~' #string.punctuation potentially messes with contractions
    response_punctuation_cleaned=" ".join([y.translate(str.maketrans("","", chars_to_remove)) for y in str(response).lower().split(" ") if (y != "") & (y!=".")])
    
    #remove emojis
    response_final = remove_emoji(response_punctuation_cleaned)
    
    return response_final
        


#### paths

data_path="~/Documents/Madison/Sapirlab/vcs/vcs_naming_crosslang/processed_data/vcs_naming_arabic_filtered_data.csv"
write_path="~/Documents/Madison/Sapirlab/vcs/vcs_naming_crosslang/processed_data/vcs_nameability_arabic.csv"


#### main script

#read in data set
d = pd.read_csv(data_path)
d.loc[range(10),]

#array of unique category names
categoryNames=np.unique(d["image"])

#will contain the number of total responses for a category
number_responses=[]
#will contain the average number of words in a category's response
avg_words_per_response=[]
#tracks percent unique words (number of unique words / number of total words - higher means a higher proportion of unqiue responses, i.e. less agreement)
percent_unique_words=[]
#tracks Simpson diversity over (cleaned) TOKENS (not necessarily types)
simpson_diversity = []
#percent responses contain most modal word(s)
modal_agreement=[]
#modal names
modal_names=[]
#percent responses matching modal response
modal_response_agreement=[]
#modal response
modal_response=[]

#### start parser for tokenization

#Instructions: https://github.com/nltk/nltk/wiki/Stanford-CoreNLP-API-in-NLTK

#start server (in terrminal)
#java -Xmx4g -cp "*" edu.stanford.nlp.pipeline.StanfordCoreNLPServer \
#-serverProperties StanfordCoreNLP-arabic.properties \
#-preload tokenize,ssplit,pos,parse \
#-status_port 9005  -port 9005 -timeout 15000

parser = CoreNLPParser('http://localhost:9005')
#pos_tagger = CoreNLPParser('http://localhost:9005', tagtype='pos')
#list(pos_tagger.tag(parser.tokenize(text)))

#run main script

for category in categoryNames:
    
    #set up list of responses for each category
    wordListResponse=[]
    responseLengthList=[]
    completeWordList=[]
    responseList=[]
    
    #loop through each response for that category
    for response in d.loc[d["image"]==category,"nameing_response"]:
        #break response into a list of unique words
        #first clean up response (removing punctuation, emoji, etc.)
        response_cleaned=clean_response(response)
        #now tokenize
        curWordList = list(parser.tokenize(response_cleaned)) #tokenize
        
        #add to list of word response lists
        wordListResponse.append(curWordList)
        
        #add to list tracking the number of words in each response
        responseLengthList.append(len(curWordList))
        
        #list of all individual word responses
        completeWordList = completeWordList + curWordList
        
        responseList.append(".".join(curWordList))
        
    #number of responses to category
    number_responses.append(len(responseLengthList))
    
    #tracks average words per response
    avg_words_per_response.append(np.mean(responseLengthList))
    
    #unique word list for the category
    uniqueWordList = np.unique(completeWordList)
    
    #proportion of unique words to total words
    percent_unique_words.append(float(len(uniqueWordList))/len(completeWordList))
    
    #compute simpson diversity (tokens)
    N = len(completeWordList)
    #compute simpson diversity numerator
    #uses Counter, which is a quick way of counting number of occurrences of different tokens in a list
    #also uses list comprehension (see above)
    sim_div_numerator=float(sum([Counter(completeWordList)[key]*(Counter(completeWordList)[key]-1) for key in Counter(completeWordList)]))
    #current simpson diversity
    curSimpsonDiversity=sim_div_numerator/(N*(N-1))
    #add to list
    simpson_diversity.append(curSimpsonDiversity)
    
        
    #modal word percent
    modal_num = float(max([Counter(completeWordList)[key] for key in Counter(completeWordList)]))
    modal_agreement.append(modal_num/len(responseLengthList))
    
    #modal name
    modal_names.append(",".join([key for key,value in Counter(completeWordList).items() if value==modal_num]))
    
    #modal response agreement
    modal_response_num = float(max([Counter(responseList)[key] for key in Counter(responseList)]))
    modal_response_agreement.append(modal_response_num/len(responseLengthList))
    
    #modal response
    modal_response.append(",".join([key for key,value in Counter(responseList).items() if value==modal_response_num]))
     
 
       
#put everything in a data frame
df = pd.DataFrame({'image': categoryNames, 'number_responses': number_responses, 'avg_words_per_response': avg_words_per_response, 'percent_unique_words': percent_unique_words, 'simpson_diversity': simpson_diversity, 'modal_agreement': modal_agreement, 'modal_names': modal_names, 'modal_response_agreement': modal_response_agreement, 'modal_response': modal_response})
colNames=['image','number_responses', 'avg_words_per_response', 'percent_unique_words', 'simpson_diversity','modal_agreement','modal_names','modal_response_agreement','modal_response']
#reorder dataframe columns
df=df[colNames]

#write to csv
df.to_csv(write_path,index=False)