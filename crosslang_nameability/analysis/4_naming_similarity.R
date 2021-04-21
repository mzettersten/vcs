#libraries
library(tidyverse)
library(cowplot)
library(ggimage)
library(viridis)
library(here)
theme_set(theme_cowplot())

#read nameability data
english_naming_similarity_original <- read.csv(here("processed_data","vcs_cosine_similarity_image_pairs_english_original.csv")) %>%
  mutate(language = "english_original") %>%
  select(-lemma_cosine_sim)
arabic_naming_similarity <- read.csv(here("processed_data","vcs_naming_similarity_arabic.csv")) %>%
  mutate(language = "arabic")
chinese_naming_similarity <- read.csv(here("processed_data","vcs_naming_similarity_chinese.csv")) %>%
  mutate(language = "chinese")
english_naming_similarity <- read.csv(here("processed_data","vcs_naming_similarity_english.csv")) %>%
  mutate(language = "english")
#combine
naming_similarity <- english_naming_similarity %>%
  bind_rows(arabic_naming_similarity) %>%
  bind_rows(chinese_naming_similarity) %>%
  bind_rows(english_naming_similarity_original) %>%
  separate(image_pair,into=c("image1","image2"),sep="_",remove=FALSE) %>%
  filter(str_detect(image_pair,pattern="dog",negate=TRUE)) %>%
  filter(str_detect(image_pair,pattern="triangle",negate=TRUE)) %>%
  filter(str_detect(image_pair,pattern="square",negate=TRUE)) %>%
  mutate(
    image1=as.numeric(as.character(image1)),
    image2=as.numeric(as.character(image2))
  ) %>%
  #scale response and word within each language
  group_by(language) %>%
  mutate(
    response_cosine_sim_scaled=response_cosine_sim/max(response_cosine_sim),
    word_cosine_sim_scaled=word_cosine_sim/max(word_cosine_sim),
  ) %>%
  ungroup() %>%
  unite(image_pair_sym, "image2","image1",remove=FALSE)

# extract symmetrical entries as tibble
temp <- naming_similarity %>%
  unite(image_pair_sym,"image2","image1",remove=FALSE) %>%
  select(-image_pair,-image1,-image2) %>%
  rename(image_pair=image_pair_sym) %>%
  separate(image_pair,into=c("image1","image2"),sep="_",remove=FALSE) %>%
  mutate(
    image1=as.numeric(as.character(image1)),
    image2=as.numeric(as.character(image2))
  )
#combine
naming_similarity <- naming_similarity %>%
  select(-image_pair_sym) %>%
  bind_rows(temp)

naming_similarity %>%
  ggplot(aes(image1,image2,fill=response_cosine_sim_scaled))+
  geom_tile()+
  scale_fill_viridis(name="Response Similarity")+
  facet_wrap(~language)+
  theme(legend.title = element_text(size = 8), 
        legend.text = element_text(size = 7))
ggsave(here("figures","vcs_naming_response_similarity.jpg"), height=6, width=8)

naming_similarity %>%
  ggplot(aes(image1,image2,fill=word_cosine_sim_scaled))+
  geom_tile()+
  scale_fill_viridis(name="Word Similarity")+
  facet_wrap(~language)+
  theme(legend.title = element_text(size = 8), 
        legend.text = element_text(size = 7))
ggsave(here("figures","vcs_naming_word_similarity.jpg"), height=6, width=8)
