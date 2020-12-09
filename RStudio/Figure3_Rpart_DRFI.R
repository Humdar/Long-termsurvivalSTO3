##### Project: Long-term survival and benefit from tamoxifen therapy #####
##### Author: Huma Dar #####

#My packages
library(survival)
library(ggplot2) #used for plotting
library(ggpubr)
library(magrittr)
library(survminer)
library(splines)
library(Epi)
library(bshazard)
library(devtools)
library(rpart)
library("ggthemes")

#set the working directory
setwd("~/Documents/R code")

#### Load and prepare data ----

#My Dataset
bc <- read.csv("Sto3_uppdfu_190312_Final.txt",header = TRUE,sep = "\t",dec = ",")

#Create a subset with only ER positive patients and HER2 negative
bc_erp <- subset(bc,Erstatus_WT=="Positive")
bc_erp_her2 <- subset(bc_erp,HER2status_WT=="Negative")

#Remove patients with unknown tumor grade, tumor size, PR status and Ki67 status
bc_erp_size <- subset(bc_erp_her2, size20nm!="99")
bc_erp_grade <- subset(bc_erp_size, gradenm_TMA!="99")
bc_erp_PR <- subset(bc_erp_grade, Prstatus_WT!="Unknown")
bc_erp_mmnm <- subset(bc_erp_PR, mmnm!="99")

summary (bc_erp_mmnm$mmnm)
table(bc_erp_mmnm$mmnm)

bc_erp_ki67 <- subset(bc_erp_mmnm, Ki67status_WT!="Unknown")

summary(bc_erp_ki67$Erstatus_WT)
summary(bc_erp_ki67$HER2status_WT)
summary(bc_erp_ki67$size20nm)
summary(bc_erp_ki67$gradenm_TMA)
summary(bc_erp_ki67$Prstatus_WT)
summary(bc_erp_ki67$Ki67status_WT)
summary(bc_erp_ki67$AGE1)
table(bc_erp_ki67$AGE5)

#Create categories for tumor size
bc_erp_ki67$Tsize[bc_erp_ki67$mmnm<=10]<- "T1a/b"
bc_erp_ki67$Tsize[bc_erp_ki67$mmnm>=11 & bc_erp_ki67$mmnm<=20] <- "T1c"
bc_erp_ki67$Tsize[bc_erp_ki67$mmnm>=21 & bc_erp_ki67$mmnm<=60] <- "T2"

summary(bc_erp_ki67$Tsize)
bc_erp_ki67$Tsize

bc_erp_ki67$Tsize <- factor(bc_erp_ki67$Tsize, levels = c("T1a/b","T1c","T2"))
levels(bc_erp_ki67$Tsize) <- c(1,2,3)
levels(bc_erp_ki67$Tsize)

bc_erp_ki67$Tsize <- as.numeric(as.vector(bc_erp_ki67$Tsize))
bc_erp_ki67$Tsize

summary(bc_erp_ki67$Tsize)

bc_erp_nomissing <- bc_erp_ki67

# Define the reference values----
bc_erp_nomissing$tamoxifen <- factor(bc_erp_nomissing$tamoxifen, levels = c("0","1"))
bc_erp_nomissing$YR1_5 <- factor(bc_erp_nomissing$YR1_5, levels = c("3", "2", "1"))
bc_erp_nomissing$AGE10 <- factor(bc_erp_nomissing$AGE10, levels = c("2","1","3"))
bc_erp_nomissing$AGE5 <- factor(bc_erp_nomissing$AGE5, levels = c("2","1","3","4","5","6"))
bc_erp_nomissing$Prstatus_WT <- factor(bc_erp_nomissing$Prstatus_WT, levels = c("Negative", "Positive"))
bc_erp_nomissing$size20nm <- factor(bc_erp_nomissing$size20nm, levels = c("0", "1"))
bc_erp_nomissing$gradenm_TMA <- factor(bc_erp_nomissing$gradenm_TMA, levels = c("1","2","3"))
bc_erp_nomissing$Ki67status_WT <- factor(bc_erp_nomissing$Ki67status_WT, levels = c("Negative", "Positive"))
bc_erp_nomissing$Tsize <- factor(bc_erp_nomissing$Tsize, levels = c("1", "2", "3"))

# add labels to variables (will help in the printout of the tree)
bc_erp_nomissing$tamoxifen <- factor(bc_erp_nomissing$tamoxifen, levels = c(0,1), labels = c("Untreated", "Treated"))
bc_erp_nomissing$AGE10 <- factor(bc_erp_nomissing$AGE10, levels = c(1,2,3), labels = c("55-64","45-54","65-74"))  
bc_erp_nomissing$AGE5 <- factor(bc_erp_nomissing$AGE5, levels = c(2,1,3,4,5,6), labels = c("45-49","50-54","55-59", "60-64", "65-69", "70-74")) 
bc_erp_nomissing$gradenm_TMA <- factor(bc_erp_nomissing$gradenm_TMA, levels = c('1','2','3'), labels = c("Grade 1",
                                                                                                         "Grade 2","Grade 3")) 
bc_erp_nomissing$size20nm <- factor(bc_erp_nomissing$size20nm, levels = c('0','1'), labels = c("<20mm",">20mm"))
bc_erp_nomissing$Tsize <- factor(bc_erp_nomissing$Tsize, levels = c('1','2','3'), labels = c("T1a/b", "T1c", "T2")) 

summary(bc_erp_nomissing)

#*********************** METASTSIS FREE SURVIVAL***********************

# Tree model the tree
treefit2 <- rpart(Surv(Met_25yr_16, MetBC25yr_16) ~ tamoxifen + Prstatus_WT + Ki67status_WT +
                    gradenm_TMA + Tsize , data = bc_erp_nomissing)

print(treefit2)  # Look at the complexity parameter  
printcp(treefit2)

plot(treefit2, branch=0.2, uniform=TRUE, compress=TRUE, margin = 0.1) #Plot
text(treefit2,all=TRUE, use.n=TRUE, cex = 1.0)

temp1 <- treefit2$where

#number of events
table(bc_erp_nomissing$Tsize, bc_erp_nomissing$MetBC25yr_16)

#Kaplan-meier
km <- survfit(Surv(Met_25yr_16,MetBC25yr_16) ~ temp1, data=bc_erp_nomissing)

gkm <- ggsurvplot(km, data = bc_erp_nomissing, conf.int = FALSE,
                 pval = TRUE,pval.method = TRUE,
                 risk.table = TRUE, 
                 censor.shape="",
                 title = "R-Part",
                 tables.height = 0.2,
                 tables.theme = theme_cleantable(),
                 ggtheme = theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
                                 panel.background = element_blank(), axis.line = element_line(colour = "black"),
                                 legend.key = element_rect(fill = "white"), plot.margin = unit(c(0.5,0.5,0.5,0.5), "cm")), 
                 risk.table.y.text.col = T, # colour risk table text annotations.
                 #risk.table.y.text = FALSE, # show bars instead of names in text annotations
                 palette = c("darkgreen","orange3","royalblue","tomato4"),
                 #colour.palette="jco",
                 linetype=c("solid","dashed", "dotdash", "dotted"),
                 #legend.title = "",
                 xlab = "Years",
                 ylab = "DRFI Survival, Proportion",
                 legend.title = "",
                 #legend = c(0.2, 0.2),
                 legend.labs= c("T1a/b", "T1c and T2 treated", "T1c untreated","T2 Untreated"),
                 font.main = c(20, "plain", "black"), 
                 font.x = c(15, "plain", "black"),
                 font.y = c(15, "plain", "black"),
                 font.tickslab = c(15, "plain", "black"), 
                 font.legend = c(15, "plain", "black"),
                 fontsize = 5,
                 axes.offset = FALSE
)  
gkm

