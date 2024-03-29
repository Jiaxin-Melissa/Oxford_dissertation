# Code for statistical analysis-Oxford Dissertation

library(tidyr)
library(dplyr)

data=read.csv("feedback 2.csv")

data=data %>% filter(!is.na(Reviewer))

###############################################################################################################

# Code the reviewer's experience
data = data %>% mutate(Experience123 = Experience1 + Experience2 + Experience3)

# Extract experience and put it into a separate table
experience = data %>% dplyr::select(Reviewer, Experience4, Experience123) %>% rename(Participant=Reviewer)
data = data %>% rename(Experience123_Reviewer = Experience123, Experience4_Reviewer = Experience4)

# add receiver experience
data = merge(data, experience %>% rename(Receiver=Participant, Experience123_Receiver = Experience123, Experience4_Receiver = Experience4), by=c("Receiver"))

################################################################################################################

library(lme4)
data_suggestions = data %>% gather(type, suggestions, formal, MP, MR)
library(ggplot2)

##############################################################################################
# First, analyze whether the number of suggestions is predicted by profiency, type, experience

# Code discrete variables
data_suggestions = data_suggestions %>% mutate(ReceiverProficiencyNum = ifelse(ReceiverProficiency == "H", 1, -1))
data_suggestions = data_suggestions %>% mutate(ReviewerProficiencyNum = ifelse(ReviewerProficiency == "H", 1, -1))
data_suggestions = data_suggestions %>% mutate(formal = (type == "formal"))
data_suggestions = data_suggestions %>% mutate(MR = (type == "MR"))
data_suggestions = data_suggestions %>% mutate(MP = (type == "MP"))

# Centering variables
data_suggestions = data_suggestions %>% mutate(MR.C = MR - mean(MR))
data_suggestions = data_suggestions %>% mutate(MP.C = MP - mean(MP))
data_suggestions = data_suggestions %>% mutate(ReviewerProficiency.C = ReviewerProficiencyNum - mean(ReviewerProficiencyNum))
data_suggestions = data_suggestions %>% mutate(ReceiverProficiency.C = ReceiverProficiencyNum - mean(ReceiverProficiencyNum))
data_suggestions = data_suggestions %>% mutate(Experience123_Reviewer.C = Experience123_Reviewer - mean(Experience123_Reviewer))
data_suggestions = data_suggestions %>% mutate(Experience123_Receiver.C = Experience123_Receiver - mean(Experience123_Receiver))
data_suggestions = data_suggestions %>% mutate(Experience4_Reviewer.C = Experience4_Reviewer - mean(Experience4_Reviewer))
data_suggestions = data_suggestions %>% mutate(Experience4_Receiver.C = Experience4_Receiver - mean(Experience4_Receiver))

#####################################################
#####################################################

# Negative Binomial model
summary(glmer.nb(suggestions ~ MR.C + MP.C + ReviewerProficiency.C + ReceiverProficiency.C + Experience123_Reviewer.C + Experience123_Receiver.C + Experience4_Reviewer.C + Experience4_Receiver.C + (1+MR.C+MP.C|Reviewer) + ReviewerProficiency.C*ReceiverProficiency.C + ReviewerProficiency.C*MR.C, data=data_suggestions))
# The AIC is 332

# Poisson model
summary(glmer(suggestions ~ MR.C + MP.C + ReviewerProficiency.C + ReceiverProficiency.C + Experience123_Reviewer.C + Experience123_Receiver.C + Experience4_Reviewer.C + Experience4_Receiver.C + (1|Reviewer) + ReviewerProficiency.C*ReceiverProficiency.C + ReviewerProficiency.C*MR.C,data=data_suggestions, family=poisson))
# The AIC is 320, lower (and thus better) than for the negative binomial model

# Check for multicollinearity
# Requires first downloading the regclass package by running: install.packages("regclass")
library(regclass)
modelVIF = (lm(suggestions ~ MR.C + MP.C + ReviewerProficiency.C + ReceiverProficiency.C + Experience123_Reviewer.C + Experience123_Receiver.C + Experience4_Reviewer.C + Experience4_Receiver.C + ReviewerProficiency.C*ReceiverProficiency.C + ReviewerProficiency.C*MR.C + Experience4_Receiver.C*MP.C,data=data_suggestions))
VIF(modelVIF)

##############################################################################################
# Predicting incorporation

data_inc = data %>% gather(type, incorporated, Iformal, IMP, IMR)
data_inc = data_inc %>% dplyr::select(type, incorporated, ReviewerProficiency, ReceiverProficiency, Reviewer, Receiver , Experience123_Reviewer, Experience123_Receiver, Experience4_Reviewer, Experience4_Receiver)
data_inc = data_inc %>% mutate(type = case_when(type == "Iformal" ~ "formal", type == "IMP" ~ "MP", type == "IMR" ~ "MR"))

#####################################################################
data_inc = data_inc %>% mutate(ReceiverProficiencyNum = ifelse(ReceiverProficiency == "H", 1, -1))
data_inc = data_inc %>% mutate(ReviewerProficiencyNum = ifelse(ReviewerProficiency == "H", 1, -1))

data_inc = data_inc %>% mutate(formal = (type == "formal"))
data_inc = data_inc %>% mutate(MR = (type == "MR"))
data_inc = data_inc %>% mutate(MP = (type == "MP"))

data_inc = data_inc %>% mutate(MR.C = MR - mean(MR))
data_inc = data_inc %>% mutate(MP.C = MP - mean(MP))
data_inc = data_inc %>% mutate(ReviewerProficiency.C = ReviewerProficiencyNum - mean(ReviewerProficiencyNum))
data_inc = data_inc %>% mutate(ReceiverProficiency.C = ReceiverProficiencyNum - mean(ReceiverProficiencyNum))
data_inc = data_inc %>% mutate(Experience123_Reviewer.C = Experience123_Reviewer - mean(Experience123_Reviewer))
data_inc = data_inc %>% mutate(Experience123_Receiver.C = Experience123_Receiver - mean(Experience123_Receiver))
data_inc = data_inc %>% mutate(Experience4_Reviewer.C = Experience4_Reviewer - mean(Experience4_Reviewer))
data_inc = data_inc %>% mutate(Experience4_Receiver.C = Experience4_Receiver - mean(Experience4_Receiver))

#####################################################
#####################################################

## negative binomial
summary(glmer.nb(incorporated ~ MR.C + MP.C + ReviewerProficiency.C + ReceiverProficiency.C + Experience123_Reviewer.C + Experience123_Receiver.C + Experience4_Reviewer.C + Experience4_Receiver.C + (1|Reviewer) + ReviewerProficiency.C*MR.C + ReviewerProficiency.C*ReceiverProficiency.C  , data=data_inc))

#  poisson distribution
summary(glmer( incorporated ~ MR.C + MP.C + ReviewerProficiency.C + ReceiverProficiency.C + Experience123_Reviewer.C + Experience123_Receiver.C + Experience4_Reviewer.C + Experience4_Receiver.C + (1|Reviewer) + ReviewerProficiency.C*MR.C + ReviewerProficiency.C*ReceiverProficiency.C, data=data_inc, family=poisson))


## Check for multicollinearity
model = (lm( incorporated ~ MR.C + MP.C + ReviewerProficiency.C + ReceiverProficiency.C + Experience123_Reviewer.C + Experience123_Receiver.C + Experience4_Reviewer.C + Experience4_Receiver.C + (1|Reviewer) + ReviewerProficiency.C*MR.C + ReviewerProficiency.C*ReceiverProficiency.C   ,data=data_inc))
VIF(model)

######################################################################################################################
# Logistic Regression

data2 = merge(data_inc, data_suggestions %>% select(suggestions, type, Reviewer, Receiver), by=c("type", "Reviewer", "Receiver"))
data2 = data2 %>% mutate(rejected = suggestions - incorporated)
data2 = data2 %>% filter(!is.na(data2$incorporated))

data2Accepted = data2[rep(row.names(data2), data2$incorporated),]
data2Rejected = data2[rep(row.names(data2), data2$rejected),]
data2Accepted = data2Accepted %>% mutate(Accepted=TRUE)
data2Rejected = data2Rejected %>% mutate(Accepted=FALSE)
data2 = rbind(data2Accepted, data2Rejected)

data2 = data2 %>% mutate(ReceiverProficiencyNum = ifelse(ReceiverProficiency == "H", 1, -1))
data2 = data2 %>% mutate(ReviewerProficiencyNum = ifelse(ReviewerProficiency == "H", 1, -1))

data2 = data2 %>% mutate(formal = (type == "formal"))
data2 = data2 %>% mutate(MR = (type == "MR"))
data2 = data2 %>% mutate(MP = (type == "MP"))

#################################################
# assumption check:
# linearity: check interactions between continuous predictors and their log transforms (Field 769)
data2 = data2 %>% mutate(LogExperience123_Reviewer = log(Experience123_Reviewer))
data2 = data2 %>% mutate(LogExperience4_Reviewer = log(Experience4_Reviewer))
data2 = data2 %>% mutate(LogExperience123_Receiver = log(Experience123_Receiver))
data2 = data2 %>% mutate(LogExperience4_Receiver = log(Experience4_Receiver))

summary(glmer(Accepted ~ type + ReviewerProficiency + ReceiverProficiency + Experience123_Reviewer* LogExperience123_Reviewer + Experience123_Receiver* LogExperience123_Receiver + Experience4_Reviewer* LogExperience4_Reviewer + Experience4_Receiver* LogExperience4_Receiver + (1|Reviewer), data=data2, family="binomial"))
##################################################

# Center variables
data2 = data2 %>% mutate(MR.C = MR - mean(MR))
data2 = data2 %>% mutate(MP.C = MP - mean(MP))
data2 = data2 %>% mutate(ReviewerProficiency.C = ReviewerProficiencyNum - mean(ReviewerProficiencyNum))
data2 = data2 %>% mutate(ReceiverProficiency.C = ReceiverProficiencyNum - mean(ReceiverProficiencyNum))
data2 = data2 %>% mutate(Experience123_Reviewer.C = Experience123_Reviewer - mean(Experience123_Reviewer))
data2 = data2 %>% mutate(Experience123_Receiver.C = Experience123_Receiver - mean(Experience123_Receiver))
data2 = data2 %>% mutate(Experience4_Reviewer.C = Experience4_Reviewer - mean(Experience4_Reviewer))
data2 = data2 %>% mutate(Experience4_Receiver.C = Experience4_Receiver - mean(Experience4_Receiver))

# With all selected interactions

model = (glmer(Accepted ~ MR.C + MP.C + ReviewerProficiency.C + ReceiverProficiency.C + Experience123_Reviewer.C + Experience123_Receiver.C + Experience4_Reviewer.C + Experience4_Receiver.C + (1|Reviewer) + MP.C*ReceiverProficiency.C, data=data2, family="binomial"))
summary(model)

# Get CIs

standardErrors = sqrt(diag(vcov(model)))
beta = fixef(model)
lowerCI = beta - 1.96 * standardErrors
upperCI = beta + 1.96 * standardErrors

odds = exp(beta)
oddsLowerCI = exp(lowerCI)
oddsUpperCI = exp(upperCI)

##############################################################################

# Check for overdispersion of the model
sum(residuals(model, type = "deviance")^2)/df.residual(model)
# That is, take ratio between chi-squared statistic and the degrees of freedom, as explained by Field. The result is smaller than 1, therefore no overdispersion is present in the data.

# Check for multicollinearity
VIF(glm(Accepted ~ MR.C + MP.C + ReviewerProficiency.C + ReceiverProficiency.C + Experience123_Reviewer.C + MP.C*ReceiverProficiency.C, data=data2, family="binomial"))

#############################################################################

## Model fit statistics:
## There are many such "pseudo-R-squared" statistics, see https://stats.idre.ucla.edu/other/mult-pkg/faq/general/faq-what-are-pseudo-r-squareds/
#
## Here are a few from there computed for the model
#
# McFadden's
 modelBase = (glmer(Accepted ~  (1|Reviewer), data=data2, family="binomial"))
1-logLik(model)[[1]]/logLik(modelBase)[[1]]
## Result: 0.27
#
# Count: what percentage of the datapoints are classified correctly by the model? 
mean(as.numeric(predict(model, type="response")>0.5) == data2$Accepted)
## Result: 0.79 (79 % of the data are predicted correctly by the model)
#
## Adjusted count
(sum(as.numeric(predict(model, type="response")>0.5) == data2$Accepted)-sum(data2$Accepted)) / (length(data2$Accepted) - sum(data2$Accepted))
## Result: 0.25

#####################################################
#####################################################

# Code for automated selection of interactions

selectModel = function(typeOfModel, dataset, dependentVariable, additionalPredictors) {
   predictors = c(additionalPredictors, c("MR.C", "MP.C", "ReviewerProficiency.C", "ReceiverProficiency.C", "Experience123_Reviewer.C", "Experience123_Receiver.C", "Experience4_Reviewer.C", "Experience4_Receiver.C"))
   formula = paste(dependentVariable," ~ ", paste(predictors,sep=" + ", collapse=" + "), " + (1|Reviewer)", sep="")
   if(typeOfModel == "nb") {
      lastModel = glmer.nb(formula, data=dataset)
   } else if(typeOfModel == "poisson") {
     lastModel = glmer(formula,data=dataset, family=poisson)
   } else if(typeOfModel == "logistic") {
     lastModel = glmer(formula,data=dataset, family="binomial")
   }
   lastAIC = AIC(lastModel)
    lowestAIC = lastAIC
   for(i in (1:20)) {
    bestAddition = formula
    haveAddedPredictor = FALSE
   for(predictor1 in predictors) {
      if(grepl("Experie", predictor1)) {
         next
      }
      for(predictor2 in predictors) {

         if(grepl("Experie", predictor2)) {
            next
         }

       if(predictor1 <= predictor2) {
       cat(predictor1, predictor2, "\n", sep=" ")
       formulaNew = paste(formula, " + ", predictor1, "*", predictor2, sep="")
           if(typeOfModel == "nb") {
              newModel = glmer.nb(formulaNew, data=dataset)
           } else if(typeOfModel == "poisson") {
             newModel = glmer(formulaNew,data=dataset, family=poisson)
           } else if(typeOfModel == "logistic") {
             newModel = glmer(formulaNew,data=dataset, family="binomial")
           }
       cat(AIC(newModel), "\n")
           if(AIC(newModel) < lowestAIC) {
       cat("BETTER\n")
       lowestAIC = AIC(newModel)
       bestAddition = formulaNew
       haveAddedPredictor=TRUE
       }
       }
      }
   }
   cat(bestAddition, sep="\n")
   formula=bestAddition
   if(!haveAddedPredictor) {
    break 
   }
   }
}


#####################################################
#####################################################

# Now, repeat the same as above but with motivation added

motivation=read.csv("new main study table.csv")

motivation = motivation %>% mutate(Participant = row_number())

motivation = motivation %>% mutate(Ideal_pre = Ideal_pre1 + Ideal_pre2 + Ideal_pre3 + Ideal_pre4 + Ideal_pre5 + Ideal_pre6)
motivation = motivation %>% mutate(Ought_pre = Ought_pre1 + Ought_pre2 + Ought_pre3 + Ought_pre4 + Ought_pre5 + Ought_pre6)
motivation = motivation %>% mutate(L2LE_pre = L2LE_pre1 + L2LE_pre2 + L2LE_pre3 + L2LE_pre4 + L2LE_pre5 + L2LE_pre6)

motivation = motivation %>% select(Participant, Experience.4, Ideal_pre, Ought_pre, L2LE_pre)

data = merge(data, motivation %>% rename(Reviewer = Participant, Ideal_pre_Reviewer = Ideal_pre, Ought_pre_Reviewer = Ought_pre, L2LE_pre_Reviewer = L2LE_pre, Experience.4_Reviewer = Experience.4), by=c("Reviewer"))
data = merge(data, motivation %>% rename(Receiver = Participant, Ideal_pre_Receiver = Ideal_pre, Ought_pre_Receiver = Ought_pre, L2LE_pre_Receiver = L2LE_pre, Experience.4_Receiver = Experience.4), by=c("Receiver"))

data$Experience.4_Reviewer = NULL
data$Experience.4_Receiver = NULL

data_suggestions = data %>% gather(type, suggestions, formal, MP, MR)
data_suggestions

##############################################################################################
# First, analyze whether the number of suggestions is predicted by profiency, type, experience, motivation

# Remove collinearity between receiver and giver proficiency
data_suggestions = data_suggestions %>% mutate(ReceiverProficiencyNum = ifelse(ReceiverProficiency == "H", 1, -1))
data_suggestions = data_suggestions %>% mutate(ReviewerProficiencyNum = ifelse(ReviewerProficiency == "H", 1, -1))

data_suggestions = data_suggestions %>% mutate(formal = (type == "formal"))
data_suggestions = data_suggestions %>% mutate(MR = (type == "MR"))
data_suggestions = data_suggestions %>% mutate(MP = (type == "MP"))

data_suggestions$Degree = case_when(data_suggestions$formal ~ -1, data_suggestions$MP ~ 0, data_suggestions$MR ~ 1)

data_suggestions = data_suggestions %>% mutate(MR.C = MR - mean(MR))
data_suggestions = data_suggestions %>% mutate(MP.C = MP - mean(MP))
data_suggestions = data_suggestions %>% mutate(ReviewerProficiency.C = ReviewerProficiencyNum - mean(ReviewerProficiencyNum))
data_suggestions = data_suggestions %>% mutate(ReceiverProficiency.C = ReceiverProficiencyNum - mean(ReceiverProficiencyNum))
data_suggestions = data_suggestions %>% mutate(Experience123_Reviewer.C = Experience123_Reviewer - mean(Experience123_Reviewer))
data_suggestions = data_suggestions %>% mutate(Experience123_Receiver.C = Experience123_Receiver - mean(Experience123_Receiver))
data_suggestions = data_suggestions %>% mutate(Experience4_Reviewer.C = Experience4_Reviewer - mean(Experience4_Reviewer))
data_suggestions = data_suggestions %>% mutate(Experience4_Receiver.C = Experience4_Receiver - mean(Experience4_Receiver))

data_suggestions = data_suggestions %>% mutate(Ideal_pre_Receiver.C = Ideal_pre_Receiver - mean(Ideal_pre_Receiver))
data_suggestions = data_suggestions %>% mutate(Ought_pre_Receiver.C = Ought_pre_Receiver - mean(Ought_pre_Receiver))
data_suggestions = data_suggestions %>% mutate(L2LE_pre_Receiver.C = L2LE_pre_Receiver - mean(L2LE_pre_Receiver))

data_suggestions = data_suggestions %>% mutate(Ideal_pre_Reviewer.C = Ideal_pre_Reviewer - mean(Ideal_pre_Reviewer))
data_suggestions = data_suggestions %>% mutate(Ought_pre_Reviewer.C = Ought_pre_Reviewer - mean(Ought_pre_Reviewer))
data_suggestions = data_suggestions %>% mutate(L2LE_pre_Reviewer.C = L2LE_pre_Reviewer - mean(L2LE_pre_Reviewer))


# For model selection, run the following command (in the case of Poisson)
selectModel("poisson", data_suggestions, "suggestions", c("Ideal_pre_Reviewer.C", "Ought_pre_Reviewer.C", "L2LE_pre_Reviewer.C"))


## now with all the interactions: predict suggestions from MOTIVATION, proficiency, type, experience
model = (glmer(suggestions ~ Ideal_pre_Reviewer.C + Ought_pre_Reviewer.C + L2LE_pre_Reviewer.C + MR.C + MP.C + ReviewerProficiency.C + ReceiverProficiency.C + Experience123_Reviewer.C + Experience123_Receiver.C + Experience4_Reviewer.C + Experience4_Receiver.C + (1|Reviewer) + ReviewerProficiency.C*ReceiverProficiency.C + ReviewerProficiency.C*MR.C + ReviewerProficiency.C*Ought_pre_Reviewer.C + ReviewerProficiency.C*L2LE_pre_Reviewer.C + Ideal_pre_Reviewer.C*MP.C,data=data_suggestions, family=poisson))


## Check for multicollinearity
modelVIF = (lm(suggestions ~ Ideal_pre_Reviewer.C + Ought_pre_Reviewer.C + L2LE_pre_Reviewer.C + MR.C + MP.C + ReviewerProficiency.C + ReceiverProficiency.C + Experience123_Reviewer.C + Experience123_Receiver.C + Experience4_Reviewer.C + Experience4_Receiver.C + ReviewerProficiency.C*ReceiverProficiency.C + ReviewerProficiency.C*MR.C + ReviewerProficiency.C*Ought_pre_Reviewer.C + ReviewerProficiency.C*L2LE_pre_Reviewer.C + Ideal_pre_Reviewer.C*MP.C, data=data_suggestions))
VIF(modelVIF)


############################################################
############################################################

##############################################################################################
# Second, analyze whether they predict whether a suggestion was incorporated

data_inc = data %>% gather(type, incorporated, Iformal, IMP, IMR)
data_inc
data_inc = data_inc %>% dplyr::select(type, incorporated, ReviewerProficiency, ReceiverProficiency, Reviewer, Receiver , Experience123_Reviewer, Experience123_Receiver, Experience4_Reviewer, Experience4_Receiver, Ideal_pre_Reviewer, Ought_pre_Reviewer, L2LE_pre_Reviewer, Ideal_pre_Receiver, Ought_pre_Receiver, L2LE_pre_Receiver)
data_inc = data_inc %>% mutate(type = case_when(type == "Iformal" ~ "formal", type == "IMP" ~ "MP", type == "IMR" ~ "MR"))


#####################################################################
data_inc = data_inc %>% mutate(ReceiverProficiencyNum = ifelse(ReceiverProficiency == "H", 1, -1))
data_inc = data_inc %>% mutate(ReviewerProficiencyNum = ifelse(ReviewerProficiency == "H", 1, -1))

data_inc = data_inc %>% mutate(formal = (type == "formal"))
data_inc = data_inc %>% mutate(MR = (type == "MR"))
data_inc = data_inc %>% mutate(MP = (type == "MP"))

data_inc = data_inc %>% mutate(MR.C = MR - mean(MR))
data_inc = data_inc %>% mutate(MP.C = MP - mean(MP))
data_inc = data_inc %>% mutate(ReviewerProficiency.C = ReviewerProficiencyNum - mean(ReviewerProficiencyNum))
data_inc = data_inc %>% mutate(ReceiverProficiency.C = ReceiverProficiencyNum - mean(ReceiverProficiencyNum))
data_inc = data_inc %>% mutate(Experience123_Reviewer.C = Experience123_Reviewer - mean(Experience123_Reviewer))
data_inc = data_inc %>% mutate(Experience123_Receiver.C = Experience123_Receiver - mean(Experience123_Receiver))
data_inc = data_inc %>% mutate(Experience4_Reviewer.C = Experience4_Reviewer - mean(Experience4_Reviewer))
data_inc = data_inc %>% mutate(Experience4_Receiver.C = Experience4_Receiver - mean(Experience4_Receiver))

data_inc = data_inc %>% mutate(Ideal_pre_Receiver.C = Ideal_pre_Receiver - mean(Ideal_pre_Receiver))
data_inc = data_inc %>% mutate(Ought_pre_Receiver.C = Ought_pre_Receiver - mean(Ought_pre_Receiver))
data_inc = data_inc %>% mutate(L2LE_pre_Receiver.C = L2LE_pre_Receiver - mean(L2LE_pre_Receiver))

data_inc = data_inc %>% mutate(Ideal_pre_Reviewer.C = Ideal_pre_Reviewer - mean(Ideal_pre_Reviewer))
data_inc = data_inc %>% mutate(Ought_pre_Reviewer.C = Ought_pre_Reviewer - mean(Ought_pre_Reviewer))
data_inc = data_inc %>% mutate(L2LE_pre_Reviewer.C = L2LE_pre_Reviewer - mean(L2LE_pre_Reviewer))

#####################################################
#####################################################

model = (glmer(incorporated ~ Ideal_pre_Reviewer.C + Ought_pre_Reviewer.C + L2LE_pre_Reviewer.C + MR.C + MP.C + ReviewerProficiency.C + ReceiverProficiency.C + Experience123_Reviewer.C + Experience123_Receiver.C + Experience4_Reviewer.C + Experience4_Receiver.C + (1|Reviewer) + ReviewerProficiency.C*ReceiverProficiency.C + ReviewerProficiency.C*Ideal_pre_Reviewer.C + ReviewerProficiency.C*MR.C + L2LE_pre_Reviewer.C*Ought_pre_Reviewer.C + ReviewerProficiency.C*L2LE_pre_Reviewer.C ,data=data_inc, family=poisson))

## Check for multicollinearity
modelVIF = (lm(  incorporated ~ Ideal_pre_Reviewer.C + Ought_pre_Reviewer.C + L2LE_pre_Reviewer.C + MR.C + MP.C + ReviewerProficiency.C + ReceiverProficiency.C + Experience123_Reviewer.C + Experience123_Receiver.C + Experience4_Reviewer.C + Experience4_Receiver.C + (1|Reviewer) + ReviewerProficiency.C*ReceiverProficiency.C + ReviewerProficiency.C*Ideal_pre_Reviewer.C + ReviewerProficiency.C*MR.C + L2LE_pre_Reviewer.C*Ought_pre_Reviewer.C + ReviewerProficiency.C*L2LE_pre_Reviewer.C,data=data_inc))
VIF(modelVIF)

######################################################################################################################

data2 = merge(data_inc, data_suggestions %>% select(suggestions, type, Reviewer, Receiver), by=c("type", "Reviewer", "Receiver"))
data2 = data2 %>% mutate(rejected = suggestions - incorporated)
data2 = data2 %>% filter(!is.na(data2$incorporated))

data2Accepted = data2[rep(row.names(data2), data2$incorporated),]
data2Rejected = data2[rep(row.names(data2), data2$rejected),]
data2Accepted = data2Accepted %>% mutate(Accepted=TRUE)
data2Rejected = data2Rejected %>% mutate(Accepted=FALSE)
data2 = rbind(data2Accepted, data2Rejected)

data2 = data2 %>% mutate(ReceiverProficiencyNum = ifelse(ReceiverProficiency == "H", 1, -1))
data2 = data2 %>% mutate(ReviewerProficiencyNum = ifelse(ReviewerProficiency == "H", 1, -1))

data2 = data2 %>% mutate(formal = (type == "formal"))
data2 = data2 %>% mutate(MR = (type == "MR"))
data2 = data2 %>% mutate(MP = (type == "MP"))

# assumption check:
# linearity: check interactions between continuous predictors and their log transforms (Field 769)
data2 = data2 %>% mutate(LogExperience123_Reviewer = log(Experience123_Reviewer))
data2 = data2 %>% mutate(LogExperience4_Reviewer = log(Experience4_Reviewer))
data2 = data2 %>% mutate(LogExperience123_Receiver = log(Experience123_Receiver))
data2 = data2 %>% mutate(LogExperience4_Receiver = log(Experience4_Receiver))
data2 = data2 %>% mutate(LogIdeal_pre_Receiver = log(Ideal_pre_Receiver)-2.0)
data2 = data2 %>% mutate(LogOught_pre_Receiver = log(Ought_pre_Receiver) -2.0)
data2 = data2 %>% mutate(LogL2LE_pre_Receiver = log(L2LE_pre_Receiver) -2.0)
data2 = data2 %>% mutate(LogIdeal_pre_Reviewer = log(Ideal_pre_Reviewer) -2.0)
data2 = data2 %>% mutate(LogOught_pre_Reviewer = log(Ought_pre_Reviewer) -2.0)
data2 = data2 %>% mutate(LogL2LE_pre_Reviewer = log(L2LE_pre_Reviewer) -2.0)

data2 = data2 %>% mutate(MR.C = MR - mean(MR))
data2 = data2 %>% mutate(MP.C = MP - mean(MP))
data2 = data2 %>% mutate(ReviewerProficiency.C = ReviewerProficiencyNum - mean(ReviewerProficiencyNum))
data2 = data2 %>% mutate(ReceiverProficiency.C = ReceiverProficiencyNum - mean(ReceiverProficiencyNum))
data2 = data2 %>% mutate(Experience123_Reviewer.C = Experience123_Reviewer - mean(Experience123_Reviewer))
data2 = data2 %>% mutate(Experience123_Receiver.C = Experience123_Receiver - mean(Experience123_Receiver))
data2 = data2 %>% mutate(Experience4_Reviewer.C = Experience4_Reviewer - mean(Experience4_Reviewer))
data2 = data2 %>% mutate(Experience4_Receiver.C = Experience4_Receiver - mean(Experience4_Receiver))

data2 = data2 %>% mutate(Ideal_pre_Receiver.C = Ideal_pre_Receiver -mean(Ideal_pre_Receiver))
data2 = data2 %>% mutate(Ought_pre_Receiver.C = Ought_pre_Receiver - mean(Ought_pre_Receiver))
data2 = data2 %>% mutate(L2LE_pre_Receiver.C = L2LE_pre_Receiver - mean(L2LE_pre_Receiver))
data2 = data2 %>% mutate(Ideal_pre_Reviewer.C = Ideal_pre_Reviewer -mean(Ideal_pre_Reviewer))
data2 = data2 %>% mutate(Ought_pre_Reviewer.C = Ought_pre_Reviewer - mean(Ought_pre_Reviewer))
data2 = data2 %>% mutate(L2LE_pre_Reviewer.C = L2LE_pre_Reviewer - mean(L2LE_pre_Reviewer))
 
# To select interactions, run the following command (takes a long time to run)
# selectModel("logistic", data2, "Accepted", c("Ideal_pre_Reviewer.C", "Ought_pre_Reviewer.C", "L2LE_pre_Reviewer.C"))
# final model
model = (glmer(Accepted ~ Ideal_pre_Reviewer.C + Ought_pre_Reviewer.C + L2LE_pre_Reviewer.C + MR.C + MP.C + ReviewerProficiency.C + ReceiverProficiency.C + Experience123_Reviewer.C + Experience123_Receiver.C + Experience4_Reviewer.C + Experience4_Receiver.C + ReviewerProficiency.C*Ideal_pre_Reviewer.C + L2LE_pre_Reviewer.C*MP.C + ReviewerProficiency.C*MP.C + (1|Reviewer), family="binomial", data=data2))

# Get Cis
standardErrors = sqrt(diag(vcov(model)))
beta = fixef(model)
lowerCI = beta - 1.96 * standardErrors
upperCI = beta + 1.96 * standardErrors

odds = exp(beta)
oddsLowerCI = exp(lowerCI)
oddsUpperCI = exp(upperCI)

# Check for overdispersion of the model
sum(residuals(model, type = "deviance")^2)/df.residual(model)
# That is, take ratio between chi-squared statistic and the degrees of freedom, as explained by Field. The result is smaller than 1, therefore no overdispersion is present in the data.

# Check for multicollinearity
VIF(glm(Accepted ~ Ideal_pre_Reviewer.C + Ought_pre_Reviewer.C + L2LE_pre_Reviewer.C + MR.C + MP.C + ReviewerProficiency.C + ReceiverProficiency.C + Experience123_Reviewer.C + Experience123_Receiver.C + Experience4_Reviewer.C + Experience4_Receiver.C + ReviewerProficiency.C*Ideal_pre_Reviewer.C + L2LE_pre_Reviewer.C*MP.C + ReviewerProficiency.C*MP.C, data=data2, family="binomial"))

## Model fit statistics:
# McFadden's
 modelBase = (glmer(Accepted ~  (1|Reviewer), data=data2, family="binomial"))
1-logLik(model)[[1]]/logLik(modelBase)[[1]] 

# Count: what percentage of the datapoints are classified correctly by the model? 
mean(as.numeric(predict(model, type="response")>0.5) == data2$Accepted) 

## Adjusted count
(sum(as.numeric(predict(model, type="response")>0.5) == data2$Accepted)-sum(data2$Accepted)) / (length(data2$Accepted) - sum(data2$Accepted))

