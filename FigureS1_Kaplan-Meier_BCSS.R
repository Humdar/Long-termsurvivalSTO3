##### Project: Long-term survival and benefit from tamoxifen therapy #####
##### Author: Huma Dar #####

#My packages
library(survival)
library(ggplot2)
library(survminer)
library(ggpubr)
library(bshazard)
library(rstpm2)  # for the flexible parametric model
library(dplyr)   # for data manipulation
library(devtools)
library(rpart)
library("ggthemes")

#set the working directory
setwd("~/Documents/R code")

#### Load and prepare data ----

#My Dataset
bc <- read.csv("Sto3_uppdfu_190312_Final.txt",header = TRUE,sep = "\t",dec = ",")

#Create a subset with only er positive patients and HER2 negative
bc_erp <- subset(bc,Erstatus_WT=="Positive")
bc_erp_her2 <- subset(bc_erp,HER2status_WT=="Negative")


#******************TUMOR SIZE***************************

#Remove patients with unknown tumor size
bc_erp_size <- subset(bc_erp_her2, size20nm!="99")
bc_erp_mmnm <- subset(bc_erp_size, mmnm!="99")

table(bc_erp_mmnm$mmnm)

#Create categories for tumor size
bc_erp_mmnm$Tsize[bc_erp_mmnm$mmnm<=10]<- "T1a/b"
bc_erp_mmnm$Tsize[bc_erp_mmnm$mmnm>=11 & bc_erp_mmnm$mmnm<=20] <- "T1c"
bc_erp_mmnm$Tsize[bc_erp_mmnm$mmnm>=21 & bc_erp_mmnm$mmnm<=60] <- "T2"

summary(bc_erp_mmnm$Tsize)
bc_erp_mmnm$Tsize

bc_erp_mmnm$Tsize <- factor(bc_erp_mmnm$Tsize, levels = c("T1a/b","T1c","T2"))
levels(bc_erp_mmnm$Tsize) <- c(1,2,3)
levels(bc_erp_mmnm$Tsize)

bc_erp_mmnm$Tsize <- as.numeric(as.vector(bc_erp_mmnm$Tsize))
bc_erp_mmnm$Tsize

summary(bc_erp_mmnm$Tsize)

#Define reference
bc_erp_mmnm$Tsize <- factor(bc_erp_mmnm$Tsize, levels = c("1","2","3"))

#Rename the file
bc_erp_nomissing <- bc_erp_mmnm

#Kaplan-meier - Breast cancer specific survival in all ER positive and HER2 negative patients according to Tumor size
km <- survfit(Surv(Surv_25yr_16,CODBC25yr_16) ~ Tsize, data=bc_erp_nomissing)
table(bc_erp_nomissing$Tsize) #Frequency table for Tsize

g1 <- ggsurvplot(km, data = bc_erp_nomissing, conf.int = FALSE,
                 pval = TRUE,pval.method = TRUE,
                 risk.table = TRUE, 
                 censor.shape="",
                 title = "A.Tumor Size",
                 tables.height = 0.2,
                 tables.theme = theme_cleantable(),
                 ggtheme = theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
                                 panel.background = element_blank(), axis.line = element_line(colour = "black"),
                                 legend.key = element_rect(fill = "white"), plot.margin = unit(c(0.5,0.5,0.5,0.5), "cm")), 
                 risk.table.y.text.col = T, # colour risk table text annotations.
                 #risk.table.y.text = FALSE, # show bars instead of names in text annotations
                 palette = c("dodgerblue4","dodgerblue4","dodgerblue4"),
                 #colour.palette="jco",
                 linetype=c("solid", "twodash", "dotted"),
                 #legend.title = "",
                 xlab = "Years",
                 ylab = "BCSS, Proportion",
                 legend.title = "",
                 #legend = c(0.2, 0.2),
                 legend.labs= c("T1a/b", "T1c", "T2"),
                 font.main = c(20, "plain", "black"), 
                 font.x = c(15, "plain", "black"),
                 font.y = c(15, "plain", "black"),
                 font.tickslab = c(15, "plain", "black"), 
                 font.legend = c(15, "plain", "black"),
                 fontsize = 5,
                 axes.offset = FALSE
)  
g1


#******************TUMOR GRADE***************************

#Remove patients with unknown tumor grade
bc_erp_grade <- subset(bc_erp_her2, gradenm_TMA!="99")

#Rename the file
bc_erp_nomissing1 <- bc_erp_grade

#Kaplan-meier - Breast cancer specific survival in all ER positive and HER2 negative patients according to Tumor grade
km <- survfit(Surv(Surv_25yr_16,CODBC25yr_16) ~ gradenm_TMA, data=bc_erp_nomissing1)

g2 <- ggsurvplot(km, data = bc_erp_nomissing1, conf.int = FALSE,
                 pval = TRUE,pval.method = TRUE,
                 risk.table = TRUE, 
                 censor.shape="",
                 title = "B.Tumor Grade",
                 tables.height = 0.2,
                 tables.theme = theme_cleantable(),
                 ggtheme = theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
                                 panel.background = element_blank(), axis.line = element_line(colour = "black"),
                                 legend.key = element_rect(fill = "white"), plot.margin = unit(c(0.5,0.5,0.5,0.5), "cm")), 
                 risk.table.y.text.col = T, # colour risk table text annotations.
                 #risk.table.y.text = FALSE, # show bars instead of names in text annotations
                 palette = c("darkseagreen4","darkseagreen4","darkseagreen4"),
                 #colour.palette="jco",
                 linetype=c("solid","twodash","dotted" ),
                 #legend.title = "",
                 xlab = "Years",
                 ylab = "BCSS, Proportion",
                 legend.title = "",
                 #legend = c(0.2, 0.2),
                 legend.labs= c("Grade 1", "Grade 2", "Grade 3"),
                 font.main = c(20, "plain", "black"), 
                 font.x = c(15, "plain", "black"),
                 font.y = c(15, "plain", "black"),
                 font.tickslab = c(15, "plain", "black"), 
                 font.legend = c(15, "plain", "black"),
                 fontsize = 5,
                 axes.offset = FALSE
)  
g2


#******************PR STATUS***************************

#Remove patients with unknown PR status
bc_erp_PR <- subset(bc_erp_her2, Prstatus_WT!="Unknown")

#Rename the file
bc_erp_nomissing2<- bc_erp_PR

#Kaplan-meier - Breast cancer specific survival in all ER positive and HER2 negative patients according to Tumor grade
km <- survfit(Surv(Surv_25yr_16,CODBC25yr_16) ~ Prstatus_WT, data=bc_erp_nomissing2)

g3 <- ggsurvplot(km, data = bc_erp_nomissing2, conf.int = FALSE,
                 pval = TRUE,pval.method = TRUE,
                 risk.table = TRUE, 
                 censor.shape="",
                 title = "C. PR Status",
                 tables.height = 0.2,
                 tables.theme = theme_cleantable(),
                 ggtheme = theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
                                 panel.background = element_blank(), axis.line = element_line(colour = "black"),
                                 legend.key = element_rect(fill = "white"), plot.margin = unit(c(0.5,0.5,0.5,0.5), "cm")), 
                 risk.table.y.text.col = T, # colour risk table text annotations.
                 #risk.table.y.text = FALSE, # show bars instead of names in text annotations
                 palette = c("darkorange4","darkorange4"),
                 #colour.palette="jco",
                 linetype=c("twodash","solid"),
                 #legend.title = "",
                 xlab = "Years",
                 ylab = "BCSS, Proportion",
                 legend.title = "",
                 #legend = c(0.2, 0.2),
                 legend.labs= c("Negative", "Positive"),
                 font.main = c(20, "plain", "black"), 
                 font.x = c(15, "plain", "black"),
                 font.y = c(15, "plain", "black"),
                 font.tickslab = c(15, "plain", "black"), 
                 font.legend = c(15, "plain", "black"),
                 fontsize = 5,
                 axes.offset = FALSE
)  
g3

#******************KI67 STATUS***************************

#Remove patients with unknown tumor grade, tumor size, PR status and Ki67 status
bc_erp_ki67 <- subset(bc_erp_her2, Ki67status_WT!="Unknown")

#Rename the file
bc_erp_nomissing3<- bc_erp_ki67

#Kaplan-meier - Breast cancer specific survival in all ER positive and HER2 negative patients according to Tumor grade
km <- survfit(Surv(Surv_25yr_16,CODBC25yr_16) ~ Ki67status_WT, data=bc_erp_nomissing3)

g4 <- ggsurvplot(km, data = bc_erp_nomissing3, conf.int = FALSE,
                 pval = TRUE,pval.method = TRUE,
                 risk.table = TRUE, 
                 censor.shape="",
                 title = "D. Ki-67 Status",
                 tables.height = 0.2,
                 tables.theme = theme_cleantable(),
                 ggtheme = theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
                                 panel.background = element_blank(), axis.line = element_line(colour = "black"),
                                 legend.key = element_rect(fill = "white"), plot.margin = unit(c(0.5,0.5,0.5,0.5), "cm")), 
                 risk.table.y.text.col = T, # colour risk table text annotations.
                 #risk.table.y.text = FALSE, # show bars instead of names in text annotations
                 palette = c("goldenrod3","goldenrod3"),
                 #colour.palette="jco",
                 linetype=c("solid","twodash"),
                 #legend.title = "",
                 xlab = "Years",
                 ylab = "BCSS, Proportion",
                 legend.title = "",
                 #legend = c(0.2, 0.2),
                 legend.labs= c("Low", "Medium/High"),
                 font.main = c(20, "plain", "black"), 
                 font.x = c(15, "plain", "black"),
                 font.y = c(15, "plain", "black"),
                 font.tickslab = c(15, "plain", "black"), 
                 font.legend = c(15, "plain", "black"),
                 fontsize = 5,
                 axes.offset = FALSE
)  
g4
