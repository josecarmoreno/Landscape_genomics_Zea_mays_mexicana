###This script is taken from the methology of Andraca-Gómez et al., 2024 (Peer-reviewed Journal)
###This select the ocurrences that will be used to train the model and runs an MaxEnt model
###For this we first selected the variables with the script Filter_spatial_variables.R (use that one first!!!)
###You need to run the latter script because it has some objects we will use in this one


library(pacman)
p_load(rio, dismo,dplyr)

##We choose 70% of the ocurrences at random to be used for the training of the model
nd <- nrow(opt_swd$occs_swd)
ntrain <- ceiling(nd * 0.7)
set.seed(111)
train_ids <- sample(nd, size = ntrain)

occs_all=opt_swd$occs_swd
occs_all$sp_name="background"

##We define path to save the outputs
path <- "/home/genconser/Documentos/JoseCarlos/Landscape_Zm/Mapoteca/Chalco/"

rio::export(opt_swd$occs_swd, paste0(path, "Chalco_swd_all.csv"))
rio::export(opt_swd$occs_swd[train_ids,], paste0(path, "Chalco_swd_train.csv"))
rio::export(opt_swd$occs_swd[-train_ids,], paste0(path, "Chalco_swd_test.csv"))
rio::export(na.omit(rbind(opt_swd$bg_swd,occs_all)), paste0(path, "Chalco_bg_swd.csv"))

##Run the maxent model in R
maxent_path <- "/home/genconser/R/x86_64-pc-linux-gnu-library/4.6/dismo/java"
run_fromR <- TRUE 
betamult <- 1
features <- c("l","q","p")
samplesfile <- "/home/genconser/Documentos/JoseCarlos/Landscape_Zm/Mapoteca/Chalco/Chalco_swd_train.csv"
testsamplesfile <- "/home/genconser/Documentos/JoseCarlos/Landscape_Zm/Mapoteca/Chalco/Chalco_swd_test.csv"
environmentallayers_path <- "/home/genconser/Documentos/JoseCarlos/Landscape_Zm/Mapoteca/Chalco/Chalco_bg_swd.csv"
outputdirectory <- "/home/genconser/Documentos/JoseCarlos/Landscape_Zm/Mapoteca/Chalco/output"
projectionlayers <- "/home/genconser/Documentos/JoseCarlos/Landscape_Zm/Mapoteca/Chalco"


if(!dir.exists(outputdirectory)) dir.create(outputdirectory)
modelmx <- ntbox::maxent_call(maxentjar_path = maxent_path,
                              run_fromR = run_fromR,
                              wait = FALSE,
                              betamultiplier = betamult,
                              features = features,
                              maximumbackground =49000,
                              responsecurvesexponent = TRUE,
                              memory_assigned = 40000,
                              samplesfile = samplesfile,
                              testsamplesfile = testsamplesfile,
                              jackknife = TRUE,
                              extrapolate =FALSE,
                              appendtoresultsfile	= TRUE,
                              autorun = TRUE,
                              #applythresholdrule = "10 percentile training presence logistic threshold.",
                              threads=4,
                              projectionlayers = projectionlayers,
                              outputformat = "logistic",
                              responsecurves =TRUE,
                              environmentallayers = environmentallayers_path,
                              outputdirectory = outputdirectory)

##We are following the Andraca-Gomez 2024 (PeerJ) methodology. Which involves evalauating the AUC of the model, eliminating the variable
##that contributes less to the AUC and then rerunning the model
##With the 12 original variables we obtained an AUC 0.995 with the wc2.1_30s_bio_14 which contributes 0.02. We eliminate that variable a rerun the script again

##We eliminate the variables from the files 
path <- "/home/genconser/Documentos/JoseCarlos/Landscape_Zm/Mapoteca/Chalco/"

train <- read.csv(paste0(path, "Chalco_swd_train.csv"))
test  <- read.csv(paste0(path, "Chalco_swd_test.csv"))
bg    <- read.csv(paste0(path, "Chalco_bg_swd.csv"))

train <- train %>% select(-wc2.1_30s_bio_14)
test  <- test  %>% select(-wc2.1_30s_bio_14)
bg    <- bg    %>% select(-wc2.1_30s_bio_14)

rio::export(train, paste0(path, "Chalco_swd_train.csv"))
rio::export(test, paste0(path, "Chalco_swd_test.csv"))
rio::export(bg, paste0(path, "Chalco_bg_swd.csv"))

##Rerun MaxEnt
if(!dir.exists(outputdirectory)) dir.create(outputdirectory)
modelmx <- ntbox::maxent_call(maxentjar_path = maxent_path,
                              run_fromR = run_fromR,
                              wait = FALSE,
                              betamultiplier = betamult,
                              features = features,
                              maximumbackground =49000,
                              responsecurvesexponent = TRUE,
                              memory_assigned = 40000,
                              samplesfile = samplesfile,
                              testsamplesfile = testsamplesfile,
                              jackknife = TRUE,
                              extrapolate =FALSE,
                              appendtoresultsfile	= TRUE,
                              autorun = TRUE,
                              #applythresholdrule = "10 percentile training presence logistic threshold.",
                              threads=4,
                              projectionlayers = projectionlayers,
                              outputformat = "logistic",
                              responsecurves =TRUE,
                              environmentallayers = environmentallayers_path,
                              outputdirectory = outputdirectory)

### This variables are explaining little variation nitrogen (0.1), ph (0.1), silt (0.3), clay (0.9)
###The AUC is still 0.995
### We are gonna crop the four variables and see what happens
train <- read.csv(paste0(path, "Chalco_swd_train.csv"))
test  <- read.csv(paste0(path, "Chalco_swd_test.csv"))
bg    <- read.csv(paste0(path, "Chalco_bg_swd.csv"))

train <- train %>% select(-clay_5.15cm, -silt_5.15cm, -phh2o_5.15cm, -nitrogen_5.15cm)
test  <- test  %>% select(-clay_5.15cm, -silt_5.15cm, -phh2o_5.15cm, -nitrogen_5.15cm)
bg    <- bg    %>% select(-clay_5.15cm, -silt_5.15cm, -phh2o_5.15cm, -nitrogen_5.15cm)

rio::export(train, paste0(path, "Chalco_swd_train.csv"))
rio::export(test, paste0(path, "Chalco_swd_test.csv"))
rio::export(bg, paste0(path, "Chalco_bg_swd.csv"))

if(!dir.exists(outputdirectory)) dir.create(outputdirectory)
modelmx <- ntbox::maxent_call(maxentjar_path = maxent_path,
                              run_fromR = run_fromR,
                              wait = FALSE,
                              betamultiplier = betamult,
                              features = features,
                              maximumbackground =49000,
                              responsecurvesexponent = TRUE,
                              memory_assigned = 40000,
                              samplesfile = samplesfile,
                              testsamplesfile = testsamplesfile,
                              jackknife = TRUE,
                              extrapolate =FALSE,
                              appendtoresultsfile	= TRUE,
                              autorun = TRUE,
                              #applythresholdrule = "10 percentile training presence logistic threshold.",
                              threads=4,
                              projectionlayers = projectionlayers,
                              outputformat = "logistic",
                              responsecurves =TRUE,
                              environmentallayers = environmentallayers_path,
                              outputdirectory = outputdirectory)

###The AUC is 0.995
###The least explanatory viable is wc2.1_30s_bio_15 (3.5%) we are gonna crop it and see if the AUC drops

#train <- read.csv(paste0(path, "Chalco_swd_train.csv"))
#test  <- read.csv(paste0(path, "Chalco_swd_test.csv"))
#bg    <- read.csv(paste0(path, "Chalco_bg_swd.csv"))

#train <- train %>% select(-wc2.1_30s_bio_15)
#test  <- test  %>% select(-wc2.1_30s_bio_15)
#bg    <- bg    %>% select(-wc2.1_30s_bio_15)

#rio::export(train, paste0(path, "Chalco_swd_train.csv"))
#rio::export(test, paste0(path, "Chalco_swd_test.csv"))
#rio::export(bg, paste0(path, "Chalco_bg_swd.csv"))

#if(!dir.exists(outputdirectory)) dir.create(outputdirectory)
#modelmx <- ntbox::maxent_call(maxentjar_path = maxent_path,
#                              run_fromR = run_fromR,
 #                             wait = FALSE,
  #                            betamultiplier = betamult,
   #                           features = features,
    #                          maximumbackground =49000,
     #                         responsecurvesexponent = TRUE,
      #                        memory_assigned = 40000,
       #                       samplesfile = samplesfile,
        #                      testsamplesfile = testsamplesfile,
         #                     jackknife = TRUE,
          #                    extrapolate =FALSE,
           #                   appendtoresultsfile	= TRUE,
             #                 autorun = TRUE,
              #                #applythresholdrule = "10 percentile training presence logistic threshold.",
               #               threads=4,
                #              projectionlayers = projectionlayers,
                 #             outputformat = "logistic",
                  #            responsecurves =TRUE,
                   #           environmentallayers = environmentallayers_path,
                    #          outputdirectory = outputdirectory)

###The AUC dropped to 0.994, we stop and we stay with the model including wc2.1_30s_bio_15 since it is explanatory