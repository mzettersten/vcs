library(tidyverse)
library(here)

###  handling exclusions

## Chinese
data_c <- read.csv(here('processed_data','vcs_naming_chinese_all_data.csv'))

#remove unusual responses
odd_response <- c("？", "△","blank","dress","hug","star","vi","x")

data_c <- data_c %>%
  filter(!(tolower(nameing_response) %in% odd_response))

#check attention check stimuli
# triangle: 三角形
# square: 正方形
# dog: 狗
#dog
data_c %>%
  filter(image=="dog.png") %>%
  select(nameing_response) %>%
  table()

#square
data_c %>%
  filter(image=="square.png") %>%
  select(nameing_response) %>%
  table()

#triangle
data_c %>%
  filter(image=="triangle.png") %>%
  select(nameing_response) %>%
  table()

#remaining responses per participant (in case someone has many missing trials)
subj_responses <- data_c %>%
  group_by(subjCode) %>%
  summarize(
    n=n()
  )

#remove participants with fewer than 8 trials
data_c <- data_c %>%
  filter(!(subjCode %in% subj_responses$subjCode[subj_responses$subjCode<8]))

## Arabic
data_a <- read.csv(here('processed_data','vcs_naming_arabic_all_data.csv'))

unique(tolower(data_a$nameing_response))[order(unique(tolower(data_a$nameing_response)))]

#remove unusual responses
odd_response_a <- c(
  "-",                                                                          
  "!",                                                                          
  "!!",                                                                          
  "!!!",                                                                         
  "!!!!",                                                                        
  "?",                                                                           
  "؟",                                                                           
  "؟؟",                                                                          
  "؟.....",                                                                      
  ".",                                                                           
  ". . .",                                                                       
  "..",                                                                          
  "...",                                                                         
  "....",                                                                        
  ".....",                                                         
  "/",                                                                       
  "×",                                                                           
  "□",                                                                           
  "◇",                                                                           
  "☆",                                                                           
  "♤",                                                              
  "\u2b50️ star",                                                                 
  "\U0001f430",                                                                
  "\U0001f90d",                                                                  
  "\U0001f928",                                          
  "\U0001f937\U0001f3fb‍♀️",                                                       
  "\U0001f9d0",                                                                  
  "\U0001f602\U0001f642 the cowboy",                                             
  "\U0001f605\U0001f605",                                                        
  "\U0001f612\U0001f612\U0001f612",                                              
  "\U0001f642",                                                                        
  "٠",                                                                           
  "4 sided shape",                                                                    
  "a pre star",                                                                  
  "a sharp star",                                                                
  "aloe vera",                                                                   
  "ameaba",                                                                      
  "amobea",                                                                      
  "amoebiasis",                                                                  
  "an animals foot print",                                                       
  "apron",                                                                       
  "armor",                                                                       
  "bacteria",                                                                    
  "bib",                                                                         
  "blade",                                                                       
  "blank box",                                                                   
  "blob",                                                                        
  "blouse",                                                                      
  "body",                                                                        
  "body shape",                                                                  
  "bodysuit",                                                                    
  "bubble",                                                                      
  "bunny",                                                                       
  "carve",                                                                       
  "chef's toque (قبعة الطباغ)",                                                  
  "close space",                                                                 
  "cowboy",                                                                      
  "crown",                                                                       
  "cupcake",                                                                     
  "curvedsides pentagon",                                                        
  "curvy body",                                                                  
  "decagon",                                                                     
  "diamond",                                                                     
  "diamond alike",                                                               
  "dofox",                                                                       
  "dog",                                                                         
  "dog fox",                                                                     
  "dress",                                                                       
  "drop",                                                                        
  "exagone",                                                                     
  "fidget spinner",                                                              
  "floating x",                                                                  
  "fore in 1 k",                                                                 
  "fox",                                                                         
  "frame",                                                                       
  "funny hat",                                                                   
  "funny star",                                                                  
  "g dress",                                                                     
  "h",                                                                           
  "hago",                                                                        
  "half star",                                                                   
  "half starsquared",                                                            
  "halfe rectangular prism starred",                                             
  "hat",                                                                         
  "heptagon",                                                                    
  "hexagon",                                                                     
  "hexagone",                                                                    
  "hidrovine",                                                                   
  "hollywood",                                                                   
  "homestar",                                                                    
  "house star",                                                                  
  "hybrid dog with fox",                                                         
  "i don't know",                                                                
  "idk",                                                                         
  "jellyfish",                                                                   
  "k",                                                                           
  "kkk",                                                                         
  "land scape",                                                                  
  "multiple",                                                                    
  "my stirs",                                                                    
  "necklase",                                                                    
  "night star",                                                                  
  "ninga",                                                                       
  "ninja star",                                                                  
  "ninja tool",                                                                  
  "ninja-ken",                                                                   
  "no h",                                                                        
  "no longer",                                                                   
  "non-straight pentagon",                                                       
  "nontagon",                                                                    
  "not equal",                                                                   
  "not perfect vase",                                                            
  "nothing",                                                                     
  "nuggets \U0001f602",                                                          
  "octagon base vase",                                                           
  "ola",                                                                         
  "patrick",                                                                     
  "pentagon",                                                                    
  "plant pot",                                                                   
  "plaque",                                                                      
  "plop",                                                                        
  "police star",                                                                 
  "polygon",                                                                     
  "polylines",                                                                   
  "pot",                                                                         
  "pot again",                                                                   
  "prepentagon",                                                                 
  "pseudopod",                                                                   
  "puzzle peace",                                                                
  "quadrilateral",                                                               
  "rabbit logo",                                                                 
  "rectangle but i am not",                                                      
  "rex",                                                                         
 "scarecrow",                                                                   
  "semi star",                                                                   
  "shining",                                                                     
  "shirt",                                                                       
  "shurikin",                                                                    
  "slime",                                                                       
  "slimy",                                                                       
  "smear",                                                                       
  "smudge",                                                                      
  "someone saying yaaaay",                                                       
  "something slimy",                                                             
   "spar",                                                                        
  "spiner",                                                                      
  "spinner",                                                                     
  "sponge",                                                                      
  "sqasts",                                                                      
  "sqrow",                                                                       
  "square",                                                                      
  "square star",                                                                 
  "squared face with large cheeks",                                              
  "squared star",                                                                
  "squeezed pillow",                                                             
  "squsta",                                                                      
  "star",                                                                        
  "star but not",                                                                
  "star fish",                                                                   
  "star pentagon",                                                               
  "star pot",                                                                    
  "star square",                                                                 
  "star without legs",                                                           
  "star-square",                                                                 
  "stare",                                                                       
  "starfish",                                                                    
  "stary cup",                                                                   
  "stat",                                                                        
  "swimming suit",                                                               
  "t_shirt",                                                                   
  "t-shirt",                                                                     
  "tall triangle",                                                               
  "tank top",                                                                    
  "tf",                                                                          
  "the empty room",                                                              
  "throwing star",                                                               
  "top",                                                                         
  "traingle",                                                                    
  "triangle",                                                                    
  "trophy",                                                                      
  "uncompleted thing",                                                           
  "underwater",                                                                  
  "unidog",                                                                      
  "upside down ghost \U0001f47b",                                                
  "vas",                                                                         
  "vasa",                                                                        
  "vase",
  "vest قميص",                                                                   
  "warewolf",                                                                    
  "wavy cross",                                                                  
  "weird shape",                                                                 
  "what",                                                                        
  "winnie the pooh",                                                             
  "winnie the pooh after a diet",                                                                       
  "wolf",                                                                        
  "x",                                                                   
  "z")  

data_a <- data_a %>%
  filter(!(tolower(nameing_response) %in% odd_response_a))

#check attention check stimuli
# triangle: مثلث
# square: ميدان
# dog: كلب
#dog
data_a %>%
  filter(image=="dog.png") %>%
  select(nameing_response) %>%
  table()

#square
data_a %>%
  filter(image=="square.png") %>%
  select(nameing_response) %>%
  table()

#triangle
data_a %>%
  filter(image=="triangle.png") %>%
  select(nameing_response) %>%
  table()

#remaining responses per participant (in case someone has many missing trials)
subj_responses <- data_a %>%
  group_by(subjCode) %>%
  summarize(
    n=n()
  )

#remove participants with fewer than 8 trials
data_a <- data_a %>%
  filter(!(subjCode %in% subj_responses$subjCode[subj_responses$subjCode<8]))

write.csv(data_c,here("processed_data","vcs_naming_chinese_filtered_data.csv"),row.names=F)
write.csv(data_a,here("processed_data","vcs_naming_arabic_filtered_data.csv"),row.names=F)

