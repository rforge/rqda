codingTermDF <- function(code,var.name,n=30){
    cp <- codings2tm(code ,byFile = FALSE)
    cp <- tm_map(cp, stripWhitespace)
    txt <- prescindMeta(cp,c("ID"))
    re <- mmseg4j(PlainTextDocument(cp))
    cp <- Corpus(VectorSource(re))
    dtm <- DocumentTermMatrix(cp,control = list(minWordLength=2,removeNumbers=TRUE))
    top_index <- findFreqTerms(dtm,sort(dtm$v ,decreasing = TRUE)[n])
    mat <- as.data.frame(as.matrix(dtm[,top_index]))
    mat <- cbind(code=var.name,mat)
}

vectorTermDF <- function(text,var){
    text <- Corpus(VectorSource(text))
    text<- tm_map(text, stripWhitespace)
    re <- mmseg4j(PlainTextDocument(text))
    text <- Corpus(VectorSource(re))
    dtm <- DocumentTermMatrix(text,control = list(minWordLength=2,removeNumbers=TRUE))
    preData <- as.data.frame(as.matrix(dtm))
    ndata <- as.data.frame(matrix(data = 0, nrow = nrow(preData), ncol = length(var)))
    names(ndata) <- var
    idx <- match(names(preData),names(ndata))
    ndata[,idx[!is.na(idx)]] <- preData[,which(!is.na(idx))]
    ndata
}

## po <- codingTermDF('political opportunity','po')
## smi <- codingTermDF('state-movement intersection','smi')
## nw <- codingTermDF('network','nw')
## comb <- gtools:::smartbind(po,smi,nw)
## comb[is.na(comb)] <- 0
## comb$code <- as.factor(comb$code=="po")
## library(e1071)
## model <- svm(code ~ ., data = comb, kernel = "sigmoid")
## test <- "我们不会拿业委会的钱，但是我们会帮助他们进行定期无风险理财，从盈利部分提取一些手续费，帮助我们交付房租、水电、打印和纸张费用，但是很多开支主要是靠我和叶老师，以及一些业委会主任承担的。"
## dat<- vectorTermDF(test,names(comb)[-1])
## predict(model,dat)
