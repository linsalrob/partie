#Your model, 'final_model.rds', for PARTIE_Classification.R should be in the same folder as this R script


args = commandArgs(trailingOnly=TRUE)
file_reads = args[1]#the argument will be the SRA partie output


#loading library
library(randomForest)
#load model
Partie.train.rf=readRDS("./final_model.rds")

#below is the PARTIE file you want to classify. This will be the output .txt file from partie.pl
test=as.data.frame(read.table(file=file_reads, sep="\t",header=T,as.is = T, check.names = F))
trf=predict(Partie.train.rf, test)

test$PARTIE_Annotation=predict(Partie.train.rf, newdata = test)
head(test)
write.csv(test, 'partie_classification.csv', row.names=FALSE)

