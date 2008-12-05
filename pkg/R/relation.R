relation <- function(index1,index2){
  ## index1 and index2 are length-2 numeric vectors
  ## results:
  ## Relation: type of relation
  ## WhichMin: which argument containts min(c(index1,index2))
  ## Distance: The distance between to index when Relation is proximity
  ## the index of the overlap of index1 and index2.
  if ( !is.vector(index1) || !is.vector(index1) ) stop("index1 and index2 must be vector.")
  if (any(is.na(c(index1,index2)))) stop("index1 or index2 should not have any NA.")
  names(index1) <- names(index2) <- NULL
  if (length(index1)==2 || length(index1)==2){
    Max <- max(c(index1,index2))
    Min <- min(c(index1,index2))
    ans <- list(Relation=NA,WhichMin=NA,Distance=NA,OverlapIndex=c(NA,NA),UnionIndex=c(NA,NA))
     if (sum(index1 %in% c(Min,Max))==2 || sum(index2 %in% c(Min,Max))==2) {
       ans$Relation <- "inclusion"
       if ((index1[1]==Min && index1[2] == Max)) {
         ans$WhichMin <- 1
         ans$OverlapIndex <- index2
         ans$UnionIndex <- index1
       }
       else {
         ans$WhichMin <- 2
         ans$OverlapIndex <- index1
         ans$UnionIndex<- index2
       }
       ##if (identical(ans$Index,c(index1,index2)[c(ans$WhichMin*2-1,ans$WhichMin*2)])){
       ##ans$Relation <- "exact"
       ##ans$WhichMin <- NULL
       ##}
         if (identical(ans$UnionIndex,ans$OverlapIndex)) {
           ans$Relation <- "exact"
           ans$WhichMin <- NA
         }
     } else {
       if (min(index1) < min(index2) &&
           max(index1) > min(index2)) {
         ans$Relation <- "overlap"
         ans$WhichMin <- 1
         ans$OverlapIndex <- c(min(index2),max(index1))
         ans$UnionIndex <- c(min(index1),max(index2))
       }
       if (min(index2) < min(index1) &&
           max(index2) > min(index1)) {
         ans$Relation <- "overlap"
         ans$WhichMin <- 2
         ans$OverlapIndex<- c(min(index1),max(index2))
         ans$UnionIndex<- c(min(index2),max(index1))
       }
       if (max(index1) <= min(index2)){
         ans$Relation <- "proximity"
         ans$WhichMin <- 1
         ans$Distance <- min(index2) -max(index1)
       }
       if (max(index2) <= min(index1)){
         ans$Relation <- "proximity"
         ans$WhichMin <- 2
         ans$Distance <- min(index1) -max(index2)
       }
     }
    ans
  }
}

