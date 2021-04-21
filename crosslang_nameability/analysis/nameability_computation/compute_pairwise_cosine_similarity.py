from nltk.parse import CoreNLPParser
import pandas as pd
import string
import numpy as np
from collections import Counter
import re
import  itertools
import math


#### paths

data_path="~/Documents/Madison/Sapirlab/vcs/vcs_naming_crosslang/processed_data/vcs_naming_chinese_filtered_data.csv"
write_path="~/Documents/Madison/Sapirlab/vcs/vcs_naming_crosslang/processed_data/vcs_naming_similarity_chinese.csv"


#### start parser for tokenization

### CHINESE

##Instructions: https://github.com/nltk/nltk/wiki/Stanford-CoreNLP-API-in-NLTK

#java -Xmx4g -cp "*" edu.stanford.nlp.pipeline.StanfordCoreNLPServer \
#-serverProperties StanfordCoreNLP-chinese.properties \
#-preload tokenize,ssplit,pos,lemma,ner,parse \
#-status_port 9001  -port 9001 -timeout 15000

parser = CoreNLPParser('http://localhost:9001')

### ARABIC

##Instructions: https://github.com/nltk/nltk/wiki/Stanford-CoreNLP-API-in-NLTK

#start server (in terrminal)
#java -Xmx4g -cp "*" edu.stanford.nlp.pipeline.StanfordCoreNLPServer \
#-serverProperties StanfordCoreNLP-arabic.properties \
#-preload tokenize,ssplit,pos,parse \
#-status_port 9005  -port 9005 -timeout 15000

#parser = CoreNLPParser('http://localhost:9005')
##pos_tagger = CoreNLPParser('http://localhost:9005', tagtype='pos')
##list(pos_tagger.tag(parser.tokenize(text)))

### ENGLISH

##Instructions: https://github.com/nltk/nltk/wiki/Stanford-CoreNLP-API-in-NLTK

#java -mx4g -cp "*" edu.stanford.nlp.pipeline.StanfordCoreNLPServer \
#-preload tokenize,ssplit,pos,lemma,ner,parse,depparse \
#-status_port 9000 -port 9000 -timeout 15000 & 

#parser = CoreNLPParser('http://localhost:9000')

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
    
#define function for computing cosine similarity based on counter
def counter_cosine_similarity(c1, c2):
    terms = set(c1).union(c2)
    dotprod = sum(c1.get(k, 0) * c2.get(k, 0) for k in terms)
    magA = math.sqrt(sum(c1.get(k, 0)**2 for k in terms))
    magB = math.sqrt(sum(c2.get(k, 0)**2 for k in terms))
    return dotprod / (magA * magB)

#### Main Script

#read in data set
d = pd.read_csv(data_path)
#d = pd.read_csv("test.csv") #test data set
#check out the data (first 10 rows)
d.loc[range(10),]

#add column that specifies angle
d.loc[:,'angle']=[item.replace("VCS_","").replace(".png","") for item in d["image"]]

#array of unique category names
categoryNames=np.unique(d["angle"])

pairList=list(itertools.combinations(categoryNames,2))

item_list=[]
word_cosine_sim_list=[]
lemma_cosine_sim_list=[]
response_cosine_sim_list=[]
distance_list=[]

for (category1,category2) in pairList:
    print (category1,category2)
    
    #set up list of responses for each category
    wordListResponse_1=[]
    lemmaListResponse_1=[]
    responseLengthList_1=[]
    completeWordList_1=[]
    completeLemmaList_1=[]
    responseList_1=[]
    
    #loop through each response for that category
    for response in d.loc[d["angle"]==category1,"nameing_response"]:
        #break response into a list of unique words
        #first clean up response (removing punctuation, emoji, etc.)
        response_cleaned=clean_response(response)
        #now tokenize
        curWordList = list(parser.tokenize(response)) #tokenize
        
        #add to list of word response lists
        wordListResponse_1.append(curWordList)
        
        #add to list tracking the number of words in each response
        responseLengthList_1.append(len(curWordList))
        
        #list of all individual word responses
        completeWordList_1 = completeWordList_1 + curWordList
        
        responseList_1.append(".".join(curWordList))
    
    #set up list of responses for each category
    wordListResponse_2=[]
    lemmaListResponse_2=[]
    responseLengthList_2=[]
    completeWordList_2=[]
    completeLemmaList_2=[]
    responseList_2=[]
    
    #loop through each response for that category
    for response in d.loc[d["angle"]==category2,"nameing_response"]:
        #break response into a list of unique words
        #first clean up response (removing punctuation, emoji, etc.)
        response_cleaned=clean_response(response)
        #now tokenize
        curWordList = list(parser.tokenize(response)) #tokenize
        
        #add to list of word response lists
        wordListResponse_2.append(curWordList)
        
        #add to list tracking the number of words in each response
        responseLengthList_2.append(len(curWordList))
        
        #list of all individual word responses
        completeWordList_2 = completeWordList_2 + curWordList
        
        responseList_2.append(".".join(curWordList))
        
    #cosine similarity computations
    word_cosine_sim=counter_cosine_similarity(Counter(completeWordList_1), Counter(completeWordList_2))
    response_cosine_sim=counter_cosine_similarity(Counter(responseList_1), Counter(responseList_2))
    
    non_integer_set = ["triangle","dog","square"]
    
    if (category1 in non_integer_set) or (category2 in non_integer_set):
        item_list.append(category1+"_"+category2)
        distance_list.append("NA")
    elif int(category1)>int(category2):
        item_list.append(category2+"_"+category1)
        distance_list.append(min(int(category1)-int(category2),360-(int(category1)-int(category2))))
    else:
        item_list.append(category1+"_"+category2)
        distance_list.append(min(int(category2)-int(category1),360-(int(category2)-int(category1))))
    word_cosine_sim_list.append(word_cosine_sim)
    response_cosine_sim_list.append(response_cosine_sim)

#put everything in a data frame
df = pd.DataFrame({'image_pair': item_list,'distance': distance_list, 'word_cosine_sim': word_cosine_sim_list, 'response_cosine_sim': response_cosine_sim_list})
colNames=['image_pair','distance', 'word_cosine_sim', 'response_cosine_sim']
#reorder dataframe columns
df=df[colNames]
#write to csv
df.to_csv(write_path,index=False)