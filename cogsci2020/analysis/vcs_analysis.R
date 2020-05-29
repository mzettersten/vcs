#  Load packages
library(tidyverse) #version 1.2.1
library(cowplot) #version 1.0.0
library(sciplot) #version 1.1-1
library(car) #version 3.0-3
library(lme4)  #version 1.1-21
library(viridis) #version 0.5.1
library(ggimage)  #version 0.2.1
library(lmerTest) #version 3.1-0
library(AICcmodavg) #version 2.2-2
library(here) #version 0.1
theme_set(theme_cowplot())


#### Nameability Descriptives ####

## read in data
d <- read.csv(here("..","data","vcs_data_processed.csv"))
#naming data
naming_data <- read.csv(here("..","data","vcs_nameability.csv"))
#images to remove  (attention check)
images_to_remove <- c("dog.png","square.png","triangle.png")
#filter out attention check images
naming_data <- naming_data %>%
  filter(!(image %in% images_to_remove))
#add angle info
naming_data <- naming_data %>%
  mutate(image_name=str_remove(image,".png")) %>%
  separate(image_name,into = c("image_type","angle"),sep="_",remove=F) %>%
  mutate(angle=as.numeric(as.character(angle)))

#naming pair similarity
sim_pair=read.csv(here("..","data","vcs_cosine_similarity_image_pairs.csv"))

#polar plots nameability
#create image paths in dendrogram order (with dendroextras package)
image_paths <- paste("../stimuli/vcs_transparent/",as.character(naming_data$image),sep="")

#add images
cur_images <- data.frame(
  label=as.character(naming_data$image),
  image=image_paths,
  x=naming_data$angle)

#reformat modal response
naming_data <- naming_data %>%
  mutate(modal_names_format =str_replace_all(modal_names,pattern=",",replacement="/\n"),
         modal_response_format =str_replace_all(modal_response,pattern=",",replacement="/\n"),) %>%
  arrange(angle)

ggplot(naming_data,aes(angle,simpson_diversity,label=modal_names_format,fill=simpson_diversity))+
  geom_bar(stat="identity",alpha=0.8,fill="#a50f15")+
  coord_polar(start=0.08)+
  scale_x_continuous(breaks=seq(10,360,10))+
  geom_text(aes(y=rep(c(0.31,0.38),18)),size=4)+
  ylab("Name Agreement\n(Simpson's Diversity Index)")+
  xlab("Angle")+
  #scale_fill_viridis(option="inferno")+
  geom_image(data=cur_images,aes(x=x,y=0.45,image=image,label=NULL,fill=NULL),size=0.08)+
  theme(legend.position="none")+
  theme(panel.grid.major = element_line(colour="black", size = 0.05))+
  theme(axis.text.x  = element_text(size=16),
        axis.title.x = element_text(size=20,face="bold"),
        axis.text.y =  element_text(size=18),
        axis.title.y= element_text(size=20,face="bold"))+
  scale_y_continuous(breaks=seq(0,0.2,0.05),limits=c(0,0.48))

ggsave(here("..","figures","vcs_simpson_diversity.jpg"), height=8, width=8)
ggsave(here("..","figures","vcs_simpson_diversity.pdf"), height=8, width=8)

#nameability summary
summary_naming <- naming_data %>%
  summarize(
    N = n(),
    mean = mean(simpson_diversity),
    sd = sd(simpson_diversity),
    ci=qt(0.975, N-1)*sd/sqrt(N),
    ci_lower=mean-ci,
    ci_upper=mean+ci,
    min = min(simpson_diversity),
    max=max(simpson_diversity)
  )
summary_naming

#relation between name-based similarity and distance
#(not in paper)
ggplot(sim_pair,aes(distance,word_cosine_sim))+
  geom_point()+
  geom_smooth()+
  ylab("Naming Cosine Similarity")
ggsave(here("..","figures","vcs_cosine_vs_distance.jpeg"))
ggsave(here("..","figures","vcs_cosine_vs_distance.pdf"))


#plot trajectories for variation of naming pair similarity by distance
#(not in paper)
sim_pair_trajectory <- sim_pair %>%
  separate(image_pair, into=c("image_1","image_2"),sep="_", remove=F) %>%
  pivot_longer(cols=c(image_1,image_2), names_to=c("image_pos"),values_to=c("image_angle")) %>%
  mutate(image_name = as.character(image_angle),distanceC=distance-90)

ggplot(sim_pair_trajectory,aes(distance,word_cosine_sim, group=image_angle,color=image_angle))+
  #geom_point(alpha=0.3)+
  geom_smooth(se=F)+
  ylab("Naming Cosine Similarity")+
  xlab("Angular Distance")+
  theme(legend.position="none")
ggsave(here("..","figures","vcs_cosine_trajectory_vs_distance.jpeg"))
ggsave(here("..","figures","vcs_cosine_trajectory_vs_distance.pdf"))

#predict distance from cosine similarity
#(not in paper)
m <- lm(response_cosine_sim~distance,data=sim_pair)
summary(m)
Anova(m, type="III",test="F")

#### Experiment 1 - Clustering ####

## read in and process data
#overall clustering
clusters <- read.csv(here("..","data","SAL_cluster_data.csv"))

#cluster probability
cluster_prob <- read.csv(here("..","data","SAL_cluster_pair_probability.csv")) %>%
  select(-X)

#cluster labels
cluster_labels <- read.csv(here("..","data","SAL_clusters_x_labels.csv")) 

#process
cluster_prob <- cluster_prob %>%
  separate(item_pair,into=c("item_1","item_2"),sep="-",remove=F) %>%
  separate(item_1,into = c("image_type_1","angle_1"),sep="_",remove=F) %>%
  separate(item_2,into = c("image_type_2","angle_2"),sep="_",remove=F) %>%
  mutate(angle_1=as.numeric(angle_1), angle_2=as.numeric(angle_2)) %>%
  mutate(angle_distance=abs(angle_2-angle_1)) %>%
  mutate(image_pair=paste(as.character(pmin(angle_1,angle_2)),"_",as.character(pmax(angle_1,angle_2)),sep=""))

#summarize cluster prob
summary_cluster_prob <- cluster_prob %>%
  summarize(
    N = n(),
    mean = mean(avg_clustered),
    sd = sd(avg_clustered),
    ci=qt(0.975, N-1)*sd/sqrt(N),
    ci_lower=mean-ci,
    ci_upper=mean+ci,
    min = min(avg_clustered),
    max=max(avg_clustered)
  )
summary_cluster_prob

#summarize number of clusters
summary_cluster_num <- clusters %>%
  group_by(subjCode) %>%
  summarize(cluster_nc=cluster_nc[1])  %>%
  ungroup(subjCode) %>%
  summarize(
    N = n(),
    mean = mean(cluster_nc),
    sd = sd(cluster_nc),
    ci=qt(0.975, N-1)*sd/sqrt(N),
    ci_lower=mean-ci,
    ci_upper=mean+ci,
    min = min(cluster_nc),
    max=max(cluster_nc)
  )
summary_cluster_num

#### relationship between nameability and cluster nameability ####
#cluster nameability
cluster_nameability <- read.csv(here("..","data","vcs_nameability_clusters.csv"))
#rename columns
cluster_nameability <- cluster_nameability %>%
  rename(image_name=image,
         simpson_diversity_cluster=simpson_diversity,
         modal_agreement_cluster=modal_agreement,
         modal_response_agreement_cluster=modal_response_agreement,
         modal_names_cluster=modal_names,
         modal_response_cluster=modal_response,
         number_responses_cluster=number_responses) %>%
  select(image_name,number_responses_cluster,simpson_diversity_cluster,modal_agreement_cluster,modal_response_agreement_cluster,modal_names_cluster,modal_response_cluster)

#cluster nameability summary
summary_cluster_naming <- cluster_nameability %>%
  summarize(
    N = n(),
    mean = mean(simpson_diversity_cluster),
    sd = sd(simpson_diversity_cluster),
    ci=qt(0.975, N-1)*sd/sqrt(N),
    ci_lower=mean-ci,
    ci_upper=mean+ci,
    min = min(simpson_diversity_cluster),
    max=max(simpson_diversity_cluster)
  )
summary_cluster_naming

#combine with cluster naming data
naming_data <- naming_data %>%
  left_join(cluster_nameability)

p1A <- ggplot(naming_data,aes(simpson_diversity,simpson_diversity_cluster))+
  geom_point(size=3)+
  geom_smooth(method="lm",size=2)+
  xlab("Name agreement for individual shapes\n(naming task)")+
  ylab("Name agreement for clusters \ncontaining the shape (sorting task)")+
  theme(axis.text.x  = element_text(size=16),
        axis.title.x = element_text(size=18,face="bold"),
        axis.text.y =  element_text(size=16),
        axis.title.y= element_text(size=18,face="bold"))+
  scale_y_continuous(breaks=c(0,0.05,0.1))+
  scale_x_continuous(breaks=c(0,0.1,0.2))
ggsave(here("..","figures","simpson_image_nameability_vs_cluster_nameability.jpeg"), width=6,  height=6)
ggsave(here("..","figures","simpson_image_nameability_vs_cluster_nameability.pdf"), width=6,  height=6)

cor.test(naming_data$simpson_diversity,naming_data$simpson_diversity_cluster)

#### relationship between name-based similarity and clustering probability ####
#join sim_pair and cluster_prob
cluster_prob_naming_similarity_temp <- cluster_prob %>%
  left_join(sim_pair)

cluster_prob_naming_similarity_wide <- cluster_prob_naming_similarity_temp %>%
  pivot_longer(cols=c(item_1,item_2),names_to="item_num",values_to="image_name") %>%
  left_join(naming_data) 
cluster_prob_naming_similarity <- cluster_prob_naming_similarity_wide %>%
  pivot_wider(names_from = item_num,values_from = c(image_name:modal_response_cluster))

#### exploratory plots
ggplot(cluster_prob_naming_similarity,aes(response_cosine_sim,avg_clustered))+
  geom_point()+
  geom_smooth(method="lm")+
  facet_wrap(~distance)
ggplot(cluster_prob_naming_similarity,aes(response_cosine_sim,avg_clustered, group=distance,color=distance))+
  #geom_point()+
  geom_smooth(method="lm",se=F)
ggplot(filter(cluster_prob_naming_similarity, distance<70),aes(response_cosine_sim,avg_clustered,group=as.factor(distance),color=as.factor(distance)))+
  geom_point()+
  geom_smooth(method="lm",alpha=0.2)+
  scale_color_viridis(option="magma",name="Angular Distance", discrete=T)+
  xlab("Naming Cosine Similarity")+
  ylab("Probability of Belonging to Same Cluster")#+
  #theme(legend.position=c(0.05, 0.75))
ggsave(here("..","figures","vcs_image_nameability_vs_cluster_nameability.jpeg"), width=6,  height=6)
ggsave(here("..","figures","vcs_image_nameability_vs_cluster_nameability.pdf"), width=6,  height=6)

#main model
summary(lm(avg_clustered~response_cosine_sim+distance,data=cluster_prob_naming_similarity))

#Alternate analysis trying to control for non-independence due to items (imperfect)
m <- lmer(avg_clustered~response_cosine_sim+distance+(1|image_item_1)+(1|image_item_2),data=cluster_prob_naming_similarity)
summary(m)
Anova(m,type="III",test="F")

##Additional analysis
#There is also evidence for an interaction with distance - response similarity is a stronger predictor at  smaller distances
#interaction
summary(lm(avg_clustered~response_cosine_sim*distance,data=cluster_prob_naming_similarity))

#### Experiment 2: VCS discriminability ####

#### Overall Descriptives ####
##overall subject accuracy - pre-filtering
subj_acc_prefilter <- d %>%
  group_by(subjCode, start,distance, subj_excluded) %>%
  summarize(
    trial_num=n(),
    num_trials_excluded=sum(trial_excluded==1),
    perc_excluded=num_trials_excluded/trial_num,
    avg_accuracy = mean(isRight[trial_excluded==0]), 
    avg_correct_rt = mean(RT[isRight==1&trial_excluded==0]),
    median_correct_rt=median(RT[isRight==1&trial_excluded==0])
  )
subj_acc_prefilter

#filter excluded subjects
subj_acc <- subj_acc_prefilter %>%
  filter(subj_excluded==0)

#summarize descriptives
overall_summary <- subj_acc %>%
  ungroup() %>%
  summarize(
    N = n(),
    overall_excluded = sum(num_trials_excluded)/sum(trial_num),
    mean_accuracy = mean(avg_accuracy),
    sd_accuracy  = sd(avg_accuracy),
    ci_accuracy=qt(0.975, N-1)*sd_accuracy/sqrt(N),
    ci_accuracy_lower=mean_accuracy-ci_accuracy,
    ci_accuracy_upper=mean_accuracy+ci_accuracy,
    mean_rt = mean(avg_correct_rt),
    sd_rt  = sd(avg_correct_rt),
    ci_rt=qt(0.975, N-1)*sd_rt/sqrt(N),
    ci_rt_lower=mean_rt-ci_rt,
    ci_rt_upper=mean_rt+ci_rt
  )
overall_summary 

#summarize descriptives by distance
overall_summary_by_distance <- subj_acc %>%
  ungroup() %>%
  group_by(distance) %>%
  summarize(
    N = n(),
    overall_excluded = sum(num_trials_excluded)/sum(trial_num),
    mean_accuracy = mean(avg_accuracy),
    sd_accuracy  = sd(avg_accuracy),
    ci_accuracy=qt(0.975, N-1)*sd_accuracy/sqrt(N),
    ci_accuracy_lower=mean_accuracy-ci_accuracy,
    ci_accuracy_upper=mean_accuracy+ci_accuracy,
    mean_rt = mean(avg_correct_rt),
    sd_rt  = sd(avg_correct_rt),
    ci_rt=qt(0.975, N-1)*sd_rt/sqrt(N),
    ci_rt_lower=mean_rt-ci_rt,
    ci_rt_upper=mean_rt+ci_rt
  )
overall_summary_by_distance 

#process items
d <- d %>%
  mutate(
    top_stim_angle = as.numeric(as.character(str_remove(top_stim,"VCS_"))),
    left_stim_angle = as.numeric(as.character(str_remove(left_stim,"VCS_"))),
    right_stim_angle = as.numeric(as.character(str_remove(right_stim,"VCS_"))),
    ) %>%
  mutate(item_combo=paste(as.character(pmin(left_stim_angle,right_stim_angle)),"_",as.character(pmax(left_stim_angle,right_stim_angle)),sep=""))

#relation between accuracy and average reaction times  (supplementary figure)
ggplot(subj_acc,aes(median_correct_rt,avg_accuracy,color=as.factor(distance)))+
  geom_point(size=3)+
  geom_smooth(method="lm",se=F,size=1.5)+
  xlab("Average Correct Reaction Time (in ms)")+
  ylab("Average Accuracy")+
  theme(legend.position=c(0.7,0.1))
ggsave(here("..","figures","vcs_accuracy_rt_relationship.jpeg"), width=7,height=7)
ggsave(here("..","figures","vcs_accuracy_rt_relationship.pdf"), width=7,height=7)

#### Nameability and name-based similarity predict discriminability ####

#filter  data
d_clean <- d %>%
  filter(subj_excluded==0 & trial_excluded==0)

#summarize by top prompt/ standard image
#first within subjects, by distance
subj_summary_item <- d_clean %>%
  group_by(subjCode,distance,top_stim_angle) %>%
  summarize(n=n(),avg_accuracy=mean(isRight),avg_correct_rt=mean(RT[isRight==1]))

#across subjects
summary_item <- subj_summary_item %>%
  group_by(distance,top_stim_angle) %>%
  summarize(
    N=n(),
    accuracy=mean(avg_accuracy),
    se=se(avg_accuracy,na.rm=T),
    accuracy_ci=qt(0.975, N-1)*sd(avg_accuracy,na.rm=T)/sqrt(N),
    accuracy_lower_ci=accuracy-accuracy_ci,
    accuracy_upper_ci=accuracy+accuracy_ci,
    correct_rt=mean(avg_correct_rt),
    se_rt=se(avg_correct_rt,na.rm=T),
    rt_ci=qt(0.975, N-1)*sd(avg_correct_rt,na.rm=T)/sqrt(N),
    rt_lower_ci=correct_rt-rt_ci,
    rt_upper_ci=correct_rt+rt_ci)
summary_item

#join nameability data
summary_item <-  summary_item %>%
  mutate(angle=top_stim_angle) %>%
  left_join(naming_data)

#relation between nameability and rt
p <- ggplot(summary_item, aes(simpson_diversity, correct_rt,color=as.factor(distance), label=angle))+
  geom_point(size=2.5)+
  geom_smooth(method="lm",size=1.3)+
  #geom_text()+
  theme(legend.position="none")+
  facet_wrap(~distance)+
  scale_color_brewer(palette="Set1")+
  xlab("Name Agreement for Standard Image")+
  ylab("Average Reaction Time (in ms)")+
  theme(axis.text.x  = element_text(size=16),
        axis.title.x = element_text(size=18,face="bold"),
        axis.text.y =  element_text(size=16),
        axis.title.y= element_text(size=18,face="bold"),
        strip.text.x = element_text(size=16, face="bold"))
p
ggsave(here("..","figures","vcs_simpson_nameability_rt.jpeg"),width=7,height=5)
ggsave(here("..","figures","vcs_simpson_nameability_rt.pdf"),width=7,height=5)

#simple linear model (not reported in paper)
m=lm(correct_rt~simpson_diversity+distance,data=summary_item)
summary(m)

#### trial-level predictions
unordered_sim_pair <- sim_pair %>%
  filter(!is.na(distance)) %>%
  separate(image_pair,into=c("angle_1","angle_2"),sep="_",remove=F)  %>%
  unite(reverse_image_pair,angle_2,angle_1,sep="_",remove=F) %>%
  pivot_longer(cols=c(image_pair,reverse_image_pair),names_to = "image_combo",values_to="item_combo") %>%
  select(-image_combo)
#join with d_clean
d_clean <- d_clean %>%
  left_join(unordered_sim_pair)

#join nameability data
d_clean$foil_angle <- ifelse(d_clean$top_stim_angle==d_clean$left_stim_angle,d_clean$right_stim_angle,d_clean$left_stim_angle)
d_clean <- d_clean %>%
  mutate(angle=as.numeric(top_stim_angle))  %>%
  left_join(select(naming_data,angle,simpson_diversity,modal_names, modal_response)) %>%
  rename(
    top_simpson_diversity=simpson_diversity,
    top_modal_names=modal_names, 
    top_modal_response=modal_response
  ) %>%
  mutate(angle=as.numeric(foil_angle)) %>%
  left_join(select(naming_data,angle,simpson_diversity,modal_names, modal_response)) %>%
  rename(
    foil_simpson_diversity=simpson_diversity,
    foil_modal_names=modal_names, 
    foil_modal_response=modal_response
  ) %>%
  mutate(
    modal_response_match=ifelse(top_modal_response==foil_modal_response,1,0),
    modal_name_match=ifelse(top_modal_names==foil_modal_names,1,0)) %>%
  select(-angle)

#center predictors
d_clean  <- d_clean %>%
  ungroup() %>%
  mutate(
    top_simpson_diversityC = top_simpson_diversity-mean(top_simpson_diversity),
    response_cosine_simC = response_cosine_sim-mean(response_cosine_sim),
    word_cosine_simC = word_cosine_sim-mean(word_cosine_sim))
#center within participants
d_clean  <- d_clean %>%
  ungroup() %>%
  group_by(subjCode) %>%
  mutate(
    top_simpson_diversity_subjC = top_simpson_diversity-mean(top_simpson_diversity),
    response_cosine_sim_subjC = response_cosine_sim-mean(response_cosine_sim),
    word_cosine_sim_subjC = word_cosine_sim-mean(response_cosine_sim),)

#### main model 
m <- lmer(RT~top_simpson_diversityC*response_cosine_simC+distance+(1+top_simpson_diversityC|subjCode)+(1|top_stim_angle)+(1|foil_angle),data=subset(d_clean,isRight==1), control=lmerControl(optimizer="bobyqa"))
summary(m)
confint(m,method="Wald")

#### Robustness checks

#similar results when no centering is applied
m <- lmer(RT~top_simpson_diversity*response_cosine_sim+distance+(1+top_simpson_diversity|subjCode)+(1|top_stim_angle)+(1|foil_angle),data=subset(d_clean,isRight==1), control=lmerControl(optimizer="bobyqa"))
summary(m)

#similar results when centering each predictor within subjects
#maximal model (convergence  warning)
m <- lmer(RT~top_simpson_diversity_subjC*response_cosine_sim_subjC+distance+(1+top_simpson_diversity_subjC*response_cosine_sim_subjC|subjCode)+(1|top_stim_angle)+(1|foil_angle),data=subset(d_clean,isRight==1), control=lmerControl(optimizer="bobyqa"))
summary(m)
#simplified model to allow convergence - similar results
m <- lmer(RT~top_simpson_diversity_subjC*response_cosine_sim_subjC+distance+(1+top_simpson_diversity_subjC|subjCode)+(1|top_stim_angle)+(1|foil_angle),data=subset(d_clean,isRight==1), control=lmerControl(optimizer="bobyqa"))
summary(m)

#standard nameability alone is a significant predictor (not including name-based similarity in the model)
m <- lmer(RT~top_simpson_diversity+distance+(1+top_simpson_diversity|subjCode)+(1|top_stim_angle),data=subset(d_clean,isRight==1))
summary(m)
