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
#combine
naming_data <- english_naming_data %>%
  bind_rows(arabic_naming_data) %>%
  bind_rows(chinese_naming_data) %>%
  bind_rows(english_original_naming_data)
  

#images to remove
images_to_remove <- c("dog.png","square.png","triangle.png")

#filter
naming_data <- naming_data %>%
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
ggplot(naming_data,aes(angle,simpson_diversity,label=modal_names_format,fill=simpson_diversity))+
  geom_bar(stat="identity",alpha=0.8)+
  coord_polar(start=0.08)+
  scale_x_continuous(breaks=seq(10,360,10))+
  geom_text(aes(y=0.3),size=3)+
  ylab("Simpson's Diversity Index")+
  xlab("Angle")+
  scale_fill_viridis(option="inferno")+
  geom_image(data=cur_images,aes(x=x,y=0.35,image=image,label=NULL,fill=NULL),size=0.04)+
  theme(legend.position="none")+
  theme(panel.grid.major = element_line(colour="black", size = 0.05))+
  scale_y_continuous(breaks=seq(0,0.2,0.05))+
  facet_wrap(~language)
 
ggsave(here("figures","vcs_simpson_diversity_crosslang.jpg"), width=14, height=6)

corr <- naming_data %>%
  pivot_wider(id_cols = "image",names_from = "language",values_from = "simpson_diversity") %>%
  column_to_rownames(var = "image") %>%
  as.matrix() %>%
  cor() %>%
  round(2)
quartz()
corrplot::corrplot(corr,addCoef.col = "grey",type = "lower",method = "circle")

naming_data_wide <- naming_data %>%
  pivot_wider(id_cols = "image",names_from = "language",values_from = "simpson_diversity") 

p0 <- ggplot(naming_data_wide,aes(english, english_original))+
  geom_point()+
  geom_smooth(method="lm")+
  ggtitle("English vs. English Original")

p1 <- ggplot(naming_data_wide,aes(english, arabic))+
  geom_point()+
  geom_smooth(method="lm")+
  ggtitle("English vs. Arabic")

p2 <- ggplot(naming_data_wide,aes(english, chinese))+
  geom_point()+
  geom_smooth(method="lm")+
  ggtitle("English vs. Chinese")

p3 <- ggplot(naming_data_wide,aes(arabic, chinese))+
  geom_point()+
  geom_smooth(method="lm")+
  ggtitle("Arabic vs. Chinese")

plot_grid(p0,p1,p2,p3,nrow=2)
ggsave(here("figures","vcs_simpson_diversity_crosslang_scatterplots.jpg"), height=6, width=12)
  