#Cleaning the Environment
rm(list=ls(all=T))

#Setting Working Directory
setwd("D:/Data scientist/Project/Bike Rental")

libraries=c("rpart.plot","tidyverse","ggplot2","ggExtra","corrplot","usdm","gridExtra","rpart","randomForest",'DMwR')
lapply(libraries, require, character.only = TRUE)
rm(libraries)

#Loading the csv file
day=read.csv("day.csv", header=T, sep = ",")

##################################Exploratory Analysis###########################################################################
#First 10 rows of the dataset
head(day,10)

#Contents of the data
str(day)

summary(day)

#Renaming Columns

colnames(day)=c("sr_no","date","season","year","month","holiday","week_day","working_day","weather_situation","normalised_temp","apparent_temp","humidity","wind_speed","casual","registered","count")

#Datatype Conversion

day$month=as.factor(as.numeric(day$month))
day$working_day=as.factor(as.numeric(day$working_day))
day$year=as.factor(as.numeric(day$year))
day$season=as.factor(as.numeric(day$season))
day$week_day=as.factor(as.numeric(day$week_day))
day$month=as.factor(as.numeric(day$month))
day$holiday=as.factor(as.numeric(day$holiday))
day$weather_situation=as.factor(as.numeric(day$weather_situation))

###############################Data Visualization#############################################

#Libraries used:
library("ggplot2")-
#beacause it makes it simple to create complex plots and it is much more effiecient
#in improving the quality and aesthetics of our graphic

library("ggExtra")
#this package contains functions that are used to enhance ggplot2.
#ggmarginal: it is used to create marginal/probability plots of the variables
#without taking refernce of the values of the other variables.
#(density, histogram, boxplots) can be added to ggplot2 scatter plot using ggmarginal

#aes:things that we want to see in the graph
#geom_count: it is basically used to count overlapping points, number of observations 
 # at each location
#geom_point: type of grapgh that i want to plot
#Geom_smooth: it hepls to see a smooth grapgh in case of overplotting


# Months affecting Count based on Season

ggplot(day,aes(month,count)) + labs(x='Months',y= 'Daily Usage')+
  geom_count(aes(color=season,alpha=0.01)) + geom_point(alpha=0.5, color='green')+
  theme_bw()+ggtitle("Scatter Plot: Months vs Usage based on Season")+theme(plot.title = element_text(hjust = 0.5))+geom_smooth()


# Year affecting Count
ggplot(day,aes(year,count), fill=year) + labs(x="Year: 2011(0) and 2012(1)",y= 'Daily Usage')+
  geom_boxplot(aes(color=year),alpha=0.2) + theme_bw()+ggtitle("Box Plot: Year vs Usage ")+theme(plot.title = element_text(hjust = 0.5))


# Working and Non-Working Days affecting Count

ggplot(day,aes(working_day,count)) + labs(x='Working(1) and Non-Working Days(0)',y= 'Daily Usage')+
  geom_boxplot(aes(color=working_day),alpha=0.2) + theme_bw()

# Normalised Feeling temperature affecting Count

ggMarginal(ggplot(day, aes(x=normalised_temp, y=count))+geom_point(aes(color=normalised_temp),alpha=0.5)+scale_color_gradient(high='green',low='red')+labs(x='Normalised temperature',y= 'Daily Usage')+
             theme_bw()+geom_smooth(method = 'auto')+geom_smooth(method='lm',color='red'),type = "histogram",fill="blue", margins = "x")

# Normalised normalised_temperature affecting Count

ggMarginal(ggplot(day, aes(x=apparent_temp, y=count))+geom_point(aes(color=apparent_temp),alpha=0.5)+ scale_color_gradient(high='black',low='sky blue')+labs(x='Apparent temperature',y= 'Daily Usage')+
             geom_smooth(method = 'auto')+theme_bw()+geom_smooth(method='lm',color='red'),type = "histogram",fill="blue", margins = c("x"))

# Weather situations affecting Count 

ggplot(day,aes(weather_situation,count)) + labs(x='Weather Situation',y= 'Daily Usage')+
  geom_boxplot(aes(color=weather_situation),alpha=0.2) + theme_bw()

# Humidity affecting Count

ggMarginal(ggplot(day, aes(x=humidity, y=count))+geom_point(aes(color=humidity),alpha=0.5)+scale_color_gradient(high='blue',low='yellow')+labs(x='Humidity Level',y= 'Daily Usage')+
             geom_smooth(method = 'auto')+geom_smooth(method='lm', color='red')+theme_bw(),type = "histogram",fill="blue", margins = c("x"))

#wind_speed affecting Count

ggMarginal(ggplot(day, aes(x=wind_speed, y=count))+geom_point(aes(color=wind_speed),alpha=0.9)+scale_color_gradient(high='orange',low='grey')+labs(x='Wind Speed',y= 'Daily Usage')+
             geom_smooth(method = 'auto')+geom_smooth(method='lm', color='red')+theme_bw(),type = "histogram",fill="blue", margins = c("x"))


#################################Data Pre-processing#################################################################################

#################################Feature Engineering#################################################################################

#Extracting day number from the date

day$daynum= format(as.Date(day$date,format="%d-%m-%Y"),"%d")
day$daynum = as.factor(as.numeric(day$daynum))
class("windspeed")
str(day)
summary(day)
############################Missing Value Analysis##########################################

apply(day,2,function(x){ sum(is.na(x))})  #if it is 2, it is performed on the cplumns, 1 means row

#There are no missing values in the dataset.

################One Hot Encoding for  Categorical Variables#################################

for(i in unique(day$month)){
  day[[paste0("Month_",i)]]=ifelse(day$month==i,1,0) #paste is used tto cocatenate two strins
}
for(i in unique(day$season)){
  day[[paste0("season_",i)]]=ifelse(day$season==i,1,0)
}
for(i in unique(day$week_day)){
  day[[paste0("week_day_",i)]]=ifelse(day$week_day==i,1,0)
}
for(i in unique(day$weather_situation)){
  day[[paste0("Weather_",i)]]=ifelse(day$weather_situation==i,1,0)
}
colnames(day)
###############################Outlier Analysis#############################################

# BoxPlots - Distribution and Outlier Check

num_index = sapply(day,is.numeric)
num_data = day[,num_index]
var_name = colnames(num_data)
data.class(var_name)
for (i in 1:(length(var_name)))
{
  assign(paste0("plot",i), ggplot(aes_string(y = (var_name[i])), data = subset(day))+ 
           stat_boxplot(geom = "errorbar", width = 0.5) +
           geom_boxplot(outlier.colour="red", fill = "blue" ,outlier.shape=18,
                        outlier.size=1, notch=FALSE, orientation = "x") +
           theme(legend.position="bottom")+
           labs(y=var_name[i])+
           ggtitle(paste("Box plot of",var_name[i])))
}
grid.arrange(plot2,plot3,plot4,plot5,ncol=2)

#Distribution of windspeed with outlier
ggplot(day,aes(y=wind_speed))+geom_boxplot(color="black",fill="grey", outlier.size=1.5)+theme_bw()+ggtitle("With Outliers")+
  theme(plot.title = element_text(hjust = 0.5))+labs(x="",y="")
hist(day$wind_speed, main="With Outliers",xlab=NA, ylab=NA, prob=TRUE)

#Removing Outliers from wind_speed

val = day$wind_speed[day$wind_speed %in% boxplot.stats(day$wind_speed)$out]
day = day[which(!day$wind_speed %in% val),]

#Distribution of windspeed without outlier
ggplot(day,aes(y=wind_speed))+geom_boxplot(color="black",fill="grey", outlier.size=1.5)+theme_bw()+ggtitle("Without Outliers")+
  theme(plot.title = element_text(hjust = 0.5))+labs(x="",y="")
hist(day$wind_speed, main="Without Outliers",xlab=NA, ylab=NA, prob=TRUE) 

#Reordering Columns by position

day=day[,c(1:15,17:43,16)]
colnames(day)

##########################################Feature Selection##############################################3

#Methods used:
#1. Correlation Analysis:
#2. Multicolinearity test

#Visualizing the Correlation Matrix

numerical_var=day[c(10:15,43)]
corrplot(cor(numerical_var),method='number')

#Multicollinearity Test, if VIF>10, then there is collinearity problem.

mcoll_test=day[,c("normalised_temp","apparent_temp","humidity","wind_speed","casual","registered")]
vifcor(mcoll_test)

#Dimension Reduction

colnames(day)
day=day[-c(1,2,3,5,7,9,11,14,15,16)]

#Converting types of Categorical variable into numeric
day$year=as.numeric(as.factor(day$year))
day$holiday=as.numeric(as.factor(day$holiday))
day$working_day=as.numeric(as.factor(day$working_day))

########################################Model Development########################################

#1. Linear Regression
#2. Desicion Tree
#3. Random Forest

# Partitioning dataset into training/validation and test set

set.seed(111)
train_index = sample(1:nrow(day), 0.8 * nrow(day)) #Simple random sampling
training = day[train_index,]
testing = day[-train_index,]

#LINEAR REGRESSION

testing = day[-train_index,]
#Train the data using Linear Regression model

lm_model= lm(count~., data=training)
summary(lm_model)

#Predict the test cases

lm_predictions=predict(lm_model,testing[])

#Writing a function to calculate MAPE

mape=function(y, yhat)
{
  mean(abs(y-yhat)/y)*100
}

#Calculate MAE

mae_LM=regr.eval(testing[,33],lm_predictions,stats= c('mae'))


#Calculate MAPE

mape_LM=mape(testing[,33],lm_predictions)
cat("Linear Regression Model:\nMAE:",abs(mae_LM),"\nMAPE:",round(mape_LM,2),"\nAccuracy:",round(100-mape_LM,2),"%")


#DECISION TREE REGRESSION

#Train the data using Decision Tree

dt_model=rpart(count~.,data = training, method = "anova")

#Visualise the model

rpart.plot(dt_model, box.palette = "RdBu",shadow.col="gray",nn=TRUE)

#Predict the Test cases

dt_predictions= predict(dt_model,testing[,-33])
dt_predictions

#Calculate MAE

mae_DT=regr.eval(testing[,33],dt_predictions,stats= c('mae'))

#Calculate MAPE

mape_DT=mape(testing[,33],dt_predictions)

cat("Decision Tree Model:\nMAE:",abs(mae_DT),"\nMAPE:",round(mape_DT,2),"\nAccuracy:",round(100-mape_DT,2),"%")


#RANDOM FOREST REGRESSION

#Train the data using Random Forest

rf_model=randomForest(count~.,training,imporatnce=TRUE, ntree=500)

#Plotting Error Graph

plot(rf_model)

#Predict the Test Cases

rf_predictions=predict(rf_model,testing[,-33])
str(rf_predictions)

#Calculate MAE

mae_RF=regr.eval(testing[,33],rf_predictions,stats= c('mae'))

#Calculate MAPE

mape_RF=mape(testing[,33],rf_predictions)
cat("Random Forest Model:\nMAE:",abs(mae_RF),"\nMAPE:",round(mape_RF,2),"\nAccuracy:",round(100-mape_RF,2),"%")

# Checking Results on Sample Data

sample_input_data=data.frame(testing)
sample_output_data=cbind(testing$count,rf_predictions)
sample_output_data=data.frame(sample_output_data)

colnames(sample_output_data)=c("Actual_values","Predicted_Values")

#Plotting a graph between Actual Values and Predicted Values
ggplot(aes(abs(Predicted_Values),Actual_values),data = sample_output_data)+geom_point()+geom_smooth(method='loess')+xlab("Predicted values from RF model")+ylab("Actual Values")+theme_bw()
write.csv(sample_input_data,"Sample_input.csv")
write.csv(sample_output_data,"Sample_output.csv")

