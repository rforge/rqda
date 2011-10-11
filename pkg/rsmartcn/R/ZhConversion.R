dicGen <- function(file,encoding="UTF-8"){
    ## file=http://svn.wikimedia.org/svnroot/mediawiki/trunk/phase3/includes/ZhConversion.php
    ## http://gerry.lamost.org/blog/?p=603
    zhTable <- readLines(file,encoding=encoding)
    idx1 <- grep("zh2",zhTable)
    idx2 <- grep(");",zhTable)

    mdic <- list()
    for (i in 1:length(idx1)){
        mdic[[i]] <- zhTable[seq(from=idx1[i]+1,to=idx2[i]-1)]
    }

    names(mdic) <- gsub(" = array\\(","", gsub("^\\$", "", zhTable[idx1]))

    for (i in 1:length(mdic)) {
        mat <- t(sapply(mdic[[i]], function(x) strsplit(x," => ")[[1]]))
        rownames(mat) <- NULL
        res <- as.data.frame(mat,stringsAsFactors=FALSE)
        res$V2 <- gsub(",","",res$V2)
        res$V2 <- gsub("'","",res$V2)
        res$V1 <- gsub("'","",res$V1)
        mdic[[i]] <- res
    }
    mdic
}

## dic <- dicGen("http://svn.wikimedia.org/svnroot/mediawiki/trunk/phase3/includes/ZhConversion.php")

zhConv <-  function(string,dic=dic$zh2Hans) {
    ## dic must be a UTF8 character.
    i = 1
    string2 <- strsplit(string,"")[[1]]
    while (i < length(string2)) {
        for (j in seq(from=length(string2),to=i)) {
            item <- paste(string2[seq(from=i,to=j)],collapse="")
            if  (any(dic[,1]==item)) {
                sub = dic[,2][ dic[,1] ==item]
                sub <- strsplit(sub,"")[[1]]
                if (j >= length(string2))  string2 <- c(string2[seq(from=0,to=i-1)], sub) else {
                   string2 <- c(string2[seq(from=0,to=i-1)], sub, string2[seq(from=j+1,to=length(string2))])
               }
                break
            }
        }
        i <- i+1
    }
    ans <- paste(string2,collapse="")
    ans
}
