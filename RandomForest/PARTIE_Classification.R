#Training set, 'SRA_used_for_training.csv', for PARTIE_Classification.R should be in the same folder as this R script
args = commandArgs(trailingOnly=TRUE)
file_reads = args[1]#the argument will be the SRA partie output
Partie.train=read.csv("SRA_used_for_training.csv", header=T)
Partie.train$SRA_Annotation=factor(Partie.train$SRA_Annotation)

#randomforest
library(randomForest)
set.seed(20)
xlearn=Partie.train[ ,2:5]
i=sample(nrow(Partie.train),132827, rep=F)
ylearn=Partie.train[,6]
xtest=xlearn[i,]
xtrain=xlearn[-i,]
ytest=ylearn[i]
ytrain=ylearn[-i]
#RF of training dataset
Partie.train.rf=randomForest(xtrain, ytrain, xtest, ytest,importance=T, keep.forest=TRUE)

#RF from above is now used to predict the annotation of the SRA dataset
test=as.data.frame(read.table(file=file_reads, sep="\t",header=T,as.is = T, check.names = F))
trf=predict(Partie.train.rf, test)

test$PARTIE_Annotation=predict(Partie.train.rf, newdata = test)
head(test)
