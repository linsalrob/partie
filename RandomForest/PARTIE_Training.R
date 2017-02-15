#Training set, 'SRA_used_for_training.csv', for PARTIE_Training.R should be in the same folder as this R script
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
rf=randomForest(xtrain, ytrain, xtest, ytest,importance=T, keep.forest=TRUE)
# save the model to disk
saveRDS(rf, "./final_model.rds")
