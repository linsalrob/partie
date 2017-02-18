#Your model, 'final_model.rds', for PARTIE_Classification.R should be in the same folder as this R script


args = commandArgs(trailingOnly=TRUE)
if (! file.exists(args[1])) {
	write("Usage: PARTIE_Classification.R <file of partie.pl output>", stderr())
	quit(status=1)
}

file_reads = args[1] # the argument will be the SRA partie output


#loading library
library(randomForest)
#load model

if (file.exists("./final_model.rds")) {
	Partie.train.rf=readRDS("./final_model.rds")
} else if (file.exists("RandomForest/final_model.rds")) {
	Partie.train.rf=readRDS("RandomForest/final_model.rds")
} else {
	write("R could not find the trained model final_model.rds. Please run PARTIE_Training.R", stderr())
	quit(status=1)
}


#below is the PARTIE file you want to classify. This will be the output .txt file from partie.pl
test=as.data.frame(read.table(file=file_reads, sep="\t",header=T,as.is = T, check.names = F, row.names=1))
# ignore the first entry which is the sample name
trf=predict(Partie.train.rf, test)

test$PARTIE_Annotation=predict(Partie.train.rf, newdata = test)
head(test)
write.csv(test, 'partie_classification.csv', row.names=TRUE)

