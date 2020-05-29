import pandas as pd
import string
import numpy as np
from collections import Counter
import nltk
from nltk.stem import WordNetLemmatizer
from nltk.corpus import wordnet
#nltk.download('averaged_perceptron_tagger')
#nltk.download('wordnet') #uncomment if wordnet is not already downloaded
lemmatiser = WordNetLemmatizer()

#function for creating lemmas/ types
def make_singular(response): #lemmatize nouns. If the repsonse has multiple words, lemmatize just the last word
    response = response.split(' ')
    singular = lemmatiser.lemmatize(response[-1], pos="n")
    if len(response)==1:
        return singular
    else:
        return ' '.join((' '.join(response[0:-1]),singular))
    
def get_wordnet_pos(treebank_tag):

    if treebank_tag.startswith('J'):
        return wordnet.ADJ
    elif treebank_tag.startswith('V'):
        return wordnet.VERB
    elif treebank_tag.startswith('N'):
        return wordnet.NOUN
    elif treebank_tag.startswith('R'):
        return wordnet.ADV
    else:
        return ''
    
    
def lemmatize_pos(response): #lemmatize responses
    response = response.split(' ')
    pos_tags = nltk.pos_tag(response)
    lemma_list=[]
    for i in range(len(response)):
        wordnet_pos=get_wordnet_pos(pos_tags[i][1])
        if wordnet_pos == '':
            lemma_list.append(lemmatiser.lemmatize(response[i]))
        else:
            lemma_list.append(lemmatiser.lemmatize(response[i], pos=wordnet_pos))
    return lemma_list


#read in data set
d = pd.read_csv("../data/SAL_clusters_x_labels.csv")
#d = pd.read_csv("test.csv") #test data set
#check out the data (first 10 rows)
d.loc[range(10),]

#array of unique category names
categoryNames=np.unique(d["Item"])

#will contain the number of total responses for a category
number_responses=[]
#will contain the average number of words in a category's response
avg_words_per_response=[]
#tracks percent unique words (number of unique words / number of total words - higher means a higher proportion of unqiue responses, i.e. less agreement)
percent_unique_words=[]
percent_unique_lemmas=[]
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


for category in categoryNames:
    
    #set up list of responses for each category
    wordListResponse=[]
    lemmaListResponse=[]
    responseLengthList=[]
    completeWordList=[]
    completeLemmaList=[]
    responseList=[]
    
    #loop through each response for that category
    for response in d.loc[d["Item"]==category,"label"]:
        #break response into a list of unique words while stripping punctuation
        #look up list comprehension in python to try to break down what's going on here
        #I first remove any punctuation/ unusual characters from the response (except apostrophes)
        chars_to_remove = '!"#$%&\()*+,-./:;<=>?@[\\]^_`{|}~' #string.punctuation potentially messes with contractions
        response_punctuation_cleaned=" ".join([y.translate(string.maketrans("",""), chars_to_remove) for y in str(response).lower().split(" ") if (y != "") & (y!=".")])
        #now tokenize
        curWordList = nltk.word_tokenize(response_punctuation_cleaned) #tokenize
        curLemmaList=[lemmatize_pos(x) for x in curWordList]
        #flatten list
        curLemmaList=[y for x in curLemmaList for y in x]
        
        #add to list of word response lists
        wordListResponse.append(curWordList)
        lemmaListResponse.append(curLemmaList)
        
        
        #add to list tracking the number of words in each response
        responseLengthList.append(len(curWordList))
        
        #list of all individual word responses
        completeWordList = completeWordList + curWordList
        completeLemmaList = completeLemmaList + curLemmaList
        
        responseList.append(".".join(curWordList))

    
    #number of responses to category
    number_responses.append(len(responseLengthList))
    
    #tracks average words per response
    avg_words_per_response.append(np.mean(responseLengthList))
    
    #unique word list for the category
    uniqueWordList = np.unique(completeWordList)
    
    #unique lemma list for the category
    uniqueLemmaList = np.unique(completeLemmaList)
    
    #proportion of unique words to total words
    percent_unique_words.append(float(len(uniqueWordList))/len(completeWordList))
    
    #proportion of unique lemmas to total lemmas
    percent_unique_lemmas.append(float(len(uniqueLemmaList))/len(completeLemmaList))
    
    #compute simpson diversity (tokens)
    N = len(completeWordList)
    #compute simpson diversity numerator
    #uses Counter, which is a quick way of counting number of occurrences of different tokens in a list
    #also uses list comprehension (see above)
    sim_div_numerator=float(sum([Counter(completeLemmaList)[key]*(Counter(completeLemmaList)[key]-1) for key in Counter(completeLemmaList)]))
    #current simpson diversity
    curSimpsonDiversity=sim_div_numerator/(N*(N-1))
    #add to list
    simpson_diversity.append(curSimpsonDiversity)
    
        
    #modal word percent
    modal_num = float(max([Counter(completeLemmaList)[key] for key in Counter(completeLemmaList)]))
    modal_agreement.append(modal_num/len(responseLengthList))
    
    #modal name
    modal_names.append(",".join([key for key,value in Counter(completeLemmaList).items() if value==modal_num]))
    
    #modal response agreement
    modal_response_num = float(max([Counter(responseList)[key] for key in Counter(responseList)]))
    modal_response_agreement.append(modal_response_num/len(responseLengthList))
    
    #modal response
    modal_response.append(",".join([key for key,value in Counter(responseList).items() if value==modal_response_num]))
     
 
       
#put everything in a data frame
df = pd.DataFrame({'image': categoryNames, 'number_responses': number_responses, 'avg_words_per_response': avg_words_per_response, 'percent_unique_words': percent_unique_words,'percent_unique_lemmas': percent_unique_lemmas, 'simpson_diversity': simpson_diversity, 'modal_agreement': modal_agreement, 'modal_names': modal_names, 'modal_response_agreement': modal_response_agreement, 'modal_response': modal_response})
colNames=['image','number_responses', 'avg_words_per_response', 'percent_unique_words','percent_unique_lemmas', 'simpson_diversity','modal_agreement','modal_names','modal_response_agreement','modal_response']
#reorder dataframe columns
df=df[colNames]

#write to csv
df.to_csv('../data/vcs_nameability_clusters.csv',index=False)
#df.to_csv('test_nameability.csv',index=False)