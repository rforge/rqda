relation <- function(index1,index2){
  ## index1 and index2 are length-2 numeric vectors
  ## results:
  ## Relation: type of relation
  ## WhichMin: which argument containts min(c(index1,index2))
  ## WhichMax: which argument containts max(c(index1,index2))
  ## Distance: The distance between to index when Relation is proximity
  ## the index of the overlap of index1 and index2.
  if ( !is.vector(index1) || !is.vector(index1) ) stop("index1 and index2 must be vector.")
  if (any(is.na(c(index1,index2)))) stop("index1 or index2 should not have any NA.")
  names(index1) <- names(index2) <- NULL
  if (length(index1)==2 || length(index1)==2){
    Max <- max(c(index1,index2))
    Min <- min(c(index1,index2))
    ans <- list(Relation=NA,WhichMin=NA,WhichMax=NA, Distance=NA,OverlapIndex=c(NA,NA),UnionIndex=c(NA,NA))
    ans$WhichMin <- which(c(index1[1],index2[1])==Min)
    ans$WhichMax <- which(c(index1[2],index2[2])==Max)
    if (sum(index1 %in% c(Min,Max))==2 || sum(index2 %in% c(Min,Max))==2) {
      if (length(ans$WhichMin)==2 && length(ans$WhichMax)==2){
        ans$Relation <- "exact"
      } else {
        ans$Relation <- "inclusion"
        if (intersect(ans$WhichMin,ans$WhichMax)==1) {
          ans$OverlapIndex <- index2
          ans$UnionIndex <- index1
        } else {
          ans$OverlapIndex <- index1
          ans$UnionIndex<- index2
        }
      }
    } else {
      if (min(index1) < min(index2) &&
          max(index1) > min(index2)) {
        ans$Relation <- "overlap"
        ans$OverlapIndex <- c(min(index2),max(index1))
        ans$UnionIndex <- c(min(index1),max(index2))
      }
      if (min(index2) < min(index1) &&
          max(index2) > min(index1)) {
        ans$Relation <- "overlap"
        ans$OverlapIndex<- c(min(index1),max(index2))
        ans$UnionIndex<- c(min(index2),max(index1))
      }
      if (max(index1) <= min(index2)){
        ans$Relation <- "proximity"
        ans$Distance <- min(index2) -max(index1)
      }
      if (max(index2) <= min(index1)){
        ans$Relation <- "proximity"
        ans$Distance <- min(index1) -max(index2)
      }
    }
    if (length(ans$WhichMin)==2) ans$WhichMin <- NA
    if (length(ans$WhichMax)==2) ans$WhichMax <- NA
    ans
  }
}

CrossTable <- function(cid1, cid2,data,relation=c("overlap","inclusion","exact","proximity")) 
{
  ## cid1 and cid2 is length-1 numeric, represents the id of codes
  ## data is return by GetCodingTable.
  ## cid1=1; cid2=2
  relation <- match.arg(relation)
  data <- data[data$cid %in% c(cid1,cid2),c("cid","fid","index1","index2")]
  ans <- 0
  fidList <- unique(data[data$cid %in% cid1,"fid"])
  for (fid in fidList) {
    tmpdat1 <- data[data$fid==fid & data$cid==cid1,,drop=FALSE]
    tmpdat2 <- data[data$fid==fid & data$cid==cid2,,drop=FALSE]
    if (nrow(tmpdat2)>0 && nrow(tmpdat1)>0){
      for(i in seq_len(nrow(tmpdat1))){
        for(j in seq_len(nrow(tmpdat2))){
          Relation <- relation(unlist(tmpdat2[j,c("index1","index2")]),unlist(tmpdat1[i,c("index1","index2")]))
          if (Relation$Relation==relation) {
            ans <- ans+1
            ## may add atributes to ans, so to get more information
          }
        }
      }
    }
  }
  ans
}

#Cross <- function(data=GetCodingTable(),type){
#cidList <- as.numeric(names(table(data$cid)))
#ans <- matrix(nrow=length(cidList), ncol=length(cidList),dimnames=list(cidList,cidList))
#for (
#CrossTable(1,4,dat)
#}

