#libraries
library(tidyverse)
library(cowplot)
library(ggimage)
library(viridis)
library(here)
theme_set(theme_cowplot())

#read nameability data
english_original_naming_data <- read.csv(here("processed_data","vcs_nameability_english_postagged.csv")) %>%
  mutate(language = "english_original")
arabic_naming_data <- read.csv(here("processed_data","vcs_nameability_arabic.csv")) %>%
  mutate(language = "arabic")
chinese_naming_data <- read.csv(here("processed_data","vcs_nameability_chinese.csv")) %>%
  mutate(language = "chinese")
english_naming_data <- read.csv(here("processed_data","vcs_nameability_english.csv")) %>%
  mutate(language = "english")

#goodness of fit data
english_response_data <- read.csv(here("processed_data","vcs_naming_english_data_filtered.csv")) %>%
  mutate(language = "english")
arabic_response_data <- read.csv(here("processed_data","vcs_naming_arabic_filtered_data.csv")) %>%
  mutate(language = "arabic")
chinese_response_data <- read.csv(here("processed_data","vcs_naming_chinese_filtered_data.csv")) %>%
  mutate(language = "chinese")

all_response_data <- english_response_data %>%
  bind_rows(arabic_response_data) %>%
  bind_rows(chinese_response_data)

#summarize goodness of fit
english_fit_summarized <- english_response_data %>%
  #filter(!(image %in% c("dog.png","square.png","triangle.png"))) %>%
  group_by(language,image) %>%
  summarize(
    fit = mean(goodness_of_fit,na.rm=T),
    sd_fit = sd(goodness_of_fit,na.rm=T),
    prop_four = sum(goodness_of_fit ==4)/n()
  )
english_naming_data <- english_naming_data %>%
  left_join(english_fit_summarized)

chinese_fit_summarized <- chinese_response_data %>%
  #filter(!(image %in% c("dog.png","square.png","triangle.png"))) %>%
  group_by(language,image) %>%
  summarize(
    fit = mean(goodness_of_fit,na.rm=T),
    sd_fit = sd(goodness_of_fit,na.rm=T),
    prop_four = sum(goodness_of_fit ==4)/n()
  )
chinese_naming_data <- chinese_naming_data %>%
  left_join(chinese_fit_summarized)

arabic_fit_summarized <- arabic_response_data %>%
  #filter(!(image %in% c("dog.png","square.png","triangle.png"))) %>%
  group_by(language,image) %>%
  summarize(
    fit = mean(goodness_of_fit,na.rm=T),
    sd_fit = sd(goodness_of_fit,na.rm=T),
    prop_four = sum(goodness_of_fit ==4)/n()
  )
arabic_naming_data <- arabic_naming_data %>%
  left_join(arabic_fit_summarized)

#combine
naming_data <- english_naming_data %>%
  bind_rows(arabic_naming_data) %>%
  bind_rows(chinese_naming_data) 

#images to remove
images_to_remove <- c("dog.png","square.png","triangle.png")

#filter
naming_data <- naming_data %>%
  filter(!(image %in% images_to_remove))

all_response_data <- all_response_data %>%
  filter(!(image %in% images_to_remove))

naming_data <- naming_data %>%
  mutate(image_name=str_remove(image,".png")) %>%
  separate(image_name,into = c("image_type","angle"),sep="_",remove=F) %>%
  mutate(angle=as.numeric(as.character(angle)))

#create image paths in dendrogram order (with dendroextras package)
image_paths <- paste("../stimuli/VCSshapes_transparent/",as.character(naming_data$image),sep="")

#add images
cur_images <- data.frame(
  label=as.character(naming_data$image),
  image=image_paths,
  x=naming_data$angle)

#reformat modal response
naming_data <- naming_data %>%
  mutate(modal_names_format =str_replace_all(modal_names,pattern=",",replacement="/\n"),
         modal_response_format =str_replace_all(modal_response,pattern=",",replacement="/\n"),)

#polar plots
ggplot(naming_data,aes(angle,fit,label=modal_names_format,fill=fit))+
  geom_bar(stat="identity",alpha=0.8)+
  coord_polar(start=0.08)+
  scale_x_continuous(breaks=seq(10,360,10))+
  geom_text(aes(y=3.5),size=6)+
  ylab("Goodness of Fit Rating")+
  xlab("Angle")+
  scale_fill_viridis(option="inferno")+
  geom_image(data=cur_images,aes(x=x,y=4,image=image,label=NULL,fill=NULL),size=0.04)+
  theme(legend.position="none")+
  theme(panel.grid.major = element_line(colour="black", size = 0.05))+
  scale_y_continuous(breaks=seq(0,3,0.5))+
  facet_wrap(~language)

ggsave(here("figures","vcs_goodness_of_fit_crosslang.jpg"), width=14, height=6)

ggplot(naming_data,aes(angle,prop_four,label=modal_names_format,fill=prop_four))+
  geom_bar(stat="identity",alpha=0.8)+
  coord_polar(start=0.08)+
  scale_x_continuous(breaks=seq(10,360,10))+
  #geom_text(aes(y=3.5),size=6)+
  ylab("Proportion of\nFour Fit Rating")+
  xlab("Angle")+
  scale_fill_viridis(option="inferno")+
  geom_image(data=cur_images,aes(x=x,y=0.6,image=image,label=NULL,fill=NULL),size=0.04)+
  theme(legend.position="none")+
  theme(panel.grid.major = element_line(colour="black", size = 0.05))+
  scale_y_continuous(breaks=seq(0,0.5,0.1))+
  facet_wrap(~language)

ggsave(here("figures","vcs_proportion_four_fit_crosslang.jpg"), width=14, height=6)


corr <- naming_data %>%
  pivot_wider(id_cols = "image",names_from = "language",values_from = "fit") %>%
  column_to_rownames(var = "image") %>%
  as.matrix() %>%
  cor() %>%
  round(2)
quartz()
corrplot::corrplot(corr,addCoef.col = "grey",type = "lower",method = "circle")


fit_data_wide <- naming_data %>%
  pivot_wider(id_cols = "image",names_from = "language",values_from = "fit") 

p1 <- ggplot(fit_data_wide,aes(english, arabic))+
  geom_point()+
  geom_smooth(method="lm")+
  ggtitle("English vs. Arabic")

p2 <- ggplot(fit_data_wide,aes(english, chinese))+
  geom_point()+
  geom_smooth(method="lm")+
  ggtitle("English vs. Chinese")

p3 <- ggplot(fit_data_wide,aes(arabic, chinese))+
  geom_point()+
  geom_smooth(method="lm")+
  ggtitle("Arabic vs. Chinese")

plot_grid(p1,p2,p3,nrow=1)
ggsave(here("figures","vcs_goodness_of_fit_crosslang_scatterplots.jpg"), height=6, width=12)

#correlations between simpson diversity and goodness of fit for each language
p1 <- ggplot(filter(naming_data,language=="arabic"),aes(fit, simpson_diversity))+
  geom_point()+
  geom_smooth(method="lm")+
  ggtitle("Arabic")

p2 <- ggplot(filter(naming_data,language=="chinese"),aes(fit, simpson_diversity))+
  geom_point()+
  geom_smooth(method="lm")+
  ggtitle("Chinese")

p3 <- ggplot(filter(naming_data,language=="english"),aes(fit, simpson_diversity))+
  geom_point()+
  geom_smooth(method="lm")+
  ggtitle("English")

plot_grid(p1,p2,p3,nrow=1)
ggsave(here("figures","vcs_goodness_of_fit_simpson_diversity_crosslang.jpg"), height=6, width=12)

ggplot(naming_data,aes(language,fit))+
  geom_violin()+
  geom_point()

ggplot(all_response_data,aes(x=goodness_of_fit))+
  geom_density()+
  facet_wrap(~language)

