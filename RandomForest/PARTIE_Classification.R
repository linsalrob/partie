#Your model, 'final_model.rds', for PARTIE_Classification.R should be in the same folder as this R script


library(base)

# figure out the path of the script: http://stackoverflow.com/questions/1815606/rscript-determine-path-of-the-executing-script
thisFile <- function() {
	cmdArgs <- commandArgs(trailingOnly = FALSE)
	needle <- "--file="
	match <- grep(needle, cmdArgs)
	if (length(match) > 0) {
		# Rscript
		return(normalizePath(sub(needle, "", cmdArgs[match])))
	} else {
		# 'source'd via R console
		return(normalizePath(sys.frames()[[1]]$ofile))
	}
}

script.FullLoc <- thisFile()
script.Path <- sub("PARTIE_Classification.R", "", script.FullLoc)


args = commandArgs(trailingOnly=TRUE)
if (! file.exists(args[1])) {
	write("Usage: PARTIE_Classification.R <file of partie.pl output>", stderr())
	quit(status=1)
}

file_reads = args[1] # the argument will be the SRA partie output


#loading library
library(randomForest)
#load model

if (file.exists(paste(script.Path, "final_model.rds", sep="/"))) {
	Partie.train.rf=readRDS(paste(script.Path, "final_model.rds", sep="/"))
} else if (file.exists(paste(script.Path, "RandomForest/final_model.rds", sep="/"))) {
	Partie.train.rf=readRDS(paste(script.Path, "RandomForest/final_model.rds", sep="/"))
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

