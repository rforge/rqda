strapplyByDictionary <- function(x,dictionary=NULL,...){
    ## x id Corpus[[i]]
    ## dictionary is a tm::Dictionary
    ## this function extract dictionary as term from a Corpus to form a doc x term matrix.
    require(gsubfn)
    if (is.null(dictionary)){
        if (exists("control",parent.frame())) {
            envir <- parent.frame()
        } else if (exists("control",parent.frame(2))) envir <- parent.frame(2)
        dictionary <- evalq(control$dictionar,envir=envir)
    }
    if (is.null(dictionary)) stop("dictionary must be provided.")
    ans <- unlist(sapply(as.list(dictionary), function(ii)strapply(x,ii)))
    ans
}

## example
##termFreq(u[[1]],list(tokenize=function(x)tokenize(x),minWordLength=1,dictionary=d))
##termFreq(u[[1]],list(tokenize=tokenize,minWordLength=1,dictionary=d))
##DocumentTermMatrix(u,list(tokenize=function(x) tokenize(x),minWordLength=1,dictionary=d))
##DocumentTermMatrix(u,list(tokenize=tokenize,minWordLength=1,dictionary=d))
