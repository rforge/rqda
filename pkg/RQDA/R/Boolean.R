getCodingsByOne <- function(cid){
    if (length(cid)!=1) stop("cid should be length-1 integer vector.")
    ct <- RQDAQuery(sprintf("select coding.rowid as rowid, coding.cid, coding.fid, freecode.name as codename, source.name as filename, coding.selfirst as index1, coding.selend as index2, coding.seltext as coding, coding.selend - coding.selfirst as CodingLength from coding left join freecode on (coding.cid=freecode.id) left join source on (coding.fid=source.id) where coding.status==1 and source.status=1 and freecode.status=1 and coding.cid=%s",cid))
    if (nrow(ct) != 0) {
        Encoding(ct$codename) <- Encoding(ct$filename) <- Encoding(ct$coding) <- "UTF-8"
    }
    class(ct) <- c("codingsByOne","data.frame")
    ct
}


summary.codingsByOne <- function (object,...)
{
    ComputeCallbackFun <- function(FileName,rowid){
        CallBackFUN <- function(widget,event,...){
            ViewFileFunHelper(FileName,hightlight=FALSE)
            textView <- .rqda$.openfile_gui@widget@widget
            buffer <- textView$GetBuffer()
            mark1 <- gtkTextBufferGetMark(buffer,sprintf("%s.1",rowid))
            gtkTextViewScrollToMark(textView,mark1,0)
            iter1 <- buffer$GetIterAtMark(mark1)$iter
            idx1 <- gtkTextIterGetOffset(iter1)
            mark2 <- buffer$GetMark(sprintf("%s.2", rowid))
            gtkTextMarkSetVisible(mark2,TRUE)
            iter2 <- buffer$GetIterAtMark(mark2)$iter
            idx2 <- gtkTextIterGetOffset(iter2)
            HL(.rqda$.openfile_gui, data.frame(idx1,idx2), fore.col = .rqda$fore.col, back.col = NULL)
        }
        CallBackFUN
    }

    if (nrow(object) == 0)
      gmessage("No Codings.", con = TRUE)
    else {
        fid <- unique(object$fid)
        Nfiles <- length(fid)
        Ncodings <- nrow(object)
        title <- sprintf(ngettext(Ncodings, "%i coding from %s %s",
                                  "%i codings from %s %s"), Ncodings,
                         Nfiles, ngettext(Nfiles, "file", "files"))
        tryCatch(eval(parse(text = sprintf("dispose(.rqda$.codingsOf%s)",
                            "codingsByone"))), error = function(e) {
                            })
        .gw <- gwindow(title = title, parent = getOption("widgetCoordinate"),
                       width = getOption("widgetSize")[1], height = getOption("widgetSize")[2])
        mainIcon <- system.file("icon", "mainIcon.png", package = "RQDA")
        .gw@widget@widget$SetIconFromFile(mainIcon)
        assign(sprintf(".codingsOf%s","codingsByone"), .gw, env = .rqda)
        .retreivalgui <- gtext(container = .gw)
        font <- pangoFontDescriptionFromString(.rqda$font)
        gtkWidgetModifyFont(.retreivalgui@widget@widget,font)
        .retreivalgui@widget@widget$SetPixelsBelowLines(5)
        .retreivalgui@widget@widget$SetPixelsInsideWrap(5)
        buffer <- .retreivalgui@widget@widget$GetBuffer()
        iter <- buffer$getIterAtOffset(0)$iter
        apply(object, 1, function(x) {
            metaData <- sprintf("%s [%i:%i]", x[["filename"]],as.numeric(x[["index1"]]), as.numeric(x[["index2"]]))
            buffer$InsertWithTagsByName(iter, metaData, "red")
            anchorcreated <- buffer$createChildAnchor(iter)
            iter$BackwardChar()
            anchor <- iter$getChildAnchor()
            lab <- gtkLabelNew("Back")
            widget <- gtkEventBoxNew()
            widget$Add(lab)
            gSignalConnect(widget, "button-press-event",
                           ComputeCallbackFun(x[["filename"]],as.numeric(x[["rowid"]])))
            .retreivalgui@widget@widget$addChildAtAnchor(widget, anchor)
            widget$showAll()
            iter$ForwardChar()
            buffer$insert(iter, "\n")
            buffer$InsertWithTagsByName(iter, x[["coding"]])
            buffer$insert(iter, "\n\n")
        })
        buffer$PlaceCursor(buffer$getIterAtOffset(0)$iter)
    }
}


and <- function(CT1,CT2,showCoding=FALSE, method= c("overlap","exact","inclusion")){
    ## CT1 and CT2 is from GetCodingTable
    ## for one code and one file only

    and_helper <- function(CT1,CT2){
        ridx <- vector()
        idx <- vector()
        for (i in 1:nrow(CT1)) {
            for (j in 1:nrow(CT2)){
                rel <- relation(as.numeric(CT1[i,c("index1","index2")]),as.numeric(CT2[j,c("index1","index2")]))
                if (rel$Relation %in% method){
                    ridx <- c(ridx,i,j)
                    idx <- c(idx,rel$OverlapIndex)
                }
            }
        }
        if (length(ridx) >=2){
            rf <- ridx[seq(from=1,to=length(ridx),by=2)] ## row index for CT1
            rs <- ridx[seq(from=2,to=length(ridx),by=2)] ## row index for CT2
            index1 <- idx[seq(from=1,to=length(idx),by=2)]
            index2 <- idx[seq(from=2,to=length(idx),by=2)]
            ans <- cbind(CT1[rf,c("rowid","fid","filename")],index1=index1,index2=index2)
            ans
        }}

    fid <- intersect(CT1$fid,CT2$fid)
    if (length(fid)>0) {
        ans <- lapply(fid,FUN=function(x) and_helper(CT1=subset(CT1,fid==x),CT2=subset(CT2,fid==x)))
        ans <- do.call(rbind,ans)
        if (showCoding && !is.null(ans)){
        txt <- apply(ans,1,function(x){
            txt <- RQDAQuery(sprintf("select file from source where id==%s",x[["fid"]]))[1,1]
            Encoding(txt) <- "UTF-8"
            ans <- substr(txt, as.numeric(x[["index1"]])+1, as.numeric(x[["index2"]]))
            ans
        })
        ans$coding <- txt
    }
        class(ans) <- c("codingsByOne","data.frame")
        ans
    } else NULL
}


"%and%.codingsByOne" <- function(e1,e2){
    and(e1, e2, showCoding=TRUE, method= getOption("andMethod"))
}


or <- function(CT1,CT2)
{
    orHelperFUN <- function(From,Exist){ ## from and exist are data frame of codings.
        if (nrow(Exist)==0){## just write to the new code if there is no coding related to that code.
            ans <- From[,c("rowid","fid","filename","index1","index2","coding"),drop=FALSE]
        } else {
            Relations <- apply(Exist[c("index1","index2")],1,FUN=function(x) relation(x,c(From$index1,From$index2)))
            ## because apply convert data to an array, and Exist containts character -> x is charater rather than numeric
            Exist$Relation <- sapply(Relations,FUN=function(x) x$Relation) ## add Relation to the data frame as indicator.
            if (any(Exist$Relation=="exact")) {
                ans <- Exist[,c("rowid","fid","filename","index1","index2","coding"),drop=FALSE]
                ## end of handling exact
            } else {
                ## if they are axact, do nothing; -> if they are not exact, do something. The following lines record meta info.
                Exist$WhichMin <- sapply(Relations,FUN=function(x)x$WhichMin)
                Exist$Start <- sapply(Relations,FUN=function(x)x$UnionIndex[1])
                Exist$End <- sapply(Relations,FUN=function(x)x$UnionIndex[2])
                if (all(Exist$Relation=="proximity")){ ## if there are no overlap in any kind, just write to database
                    ans <- rbind(From[,c("rowid","fid","filename","index1","index2","coding"),drop=FALSE],
                                 Exist[,c("rowid","fid","filename","index1","index2","coding"),drop=FALSE])
                    ## end of handling proximity
                } else {
                    ## if not proximate, pass to else branch.
                    del1 <- (Exist$Relation =="inclusion" & any(Exist$WhichMin==2,Exist$WhichMax==2))
                    ## ==2 -> take care of NA. Here 2 means From according to how Relations is returned.
                    del2 <- Exist$Relation =="overlap"
                    ## if overlap or inclusion [Exist nested in From] -> delete codings in Exist
                    del <- (del1 | del2) ## index of rows in Exist that should be deleted.
                    if (any(del)){
                        tt <-   dbGetQuery(.rqda$qdacon,sprintf("select file from source where id=='%i'", From$fid))[1,1]
                        Encoding(tt) <- "UTF-8"  ## fulltext of the file
                        Sel <- c(min(Exist$Start[del]), max(Exist$End[del])) ## index to get the new coding
                        ans <- data.frame(rowid=From$rowid,fid=From$fid,filename=From$filename,
                                          index1=Sel[1],index2=Sel[2],coding=substr(tt,Sel[1],Sel[2]))
                    }
                } ## end of handling overlapping and inclusion
            }
        }
        ans
    } ## end of helper function.

    if (any(c(nrow(CT1),nrow(CT2))==0)) stop("One code has empty coding.")
    if (nrow(CT1) >= nrow(CT2)) {
        FromDat <- CT2
        ToDat <- CT1
    } else {
        FromDat <- CT1
        ToDat <- CT2
    }
    ans.or <- vector("list",nrow(FromDat))
    for (i in seq_len(nrow(FromDat))) {
        x <- FromDat[i,,drop=FALSE]
        Exist <- ToDat[ToDat$fid==x$fid,]
        ans.or[[i]] <- orHelperFUN(From=x,Exist=Exist)
    }
    ans <- do.call(rbind,ans.or)
    class(ans) <- c("codingsByOne","data.frame")
    ans
}


"%or%.codingsByOne" <- function(e1,e2){
    or(e1, e2)
}


not <- function(CT1,CT2,showCoding=FALSE){
  
  not_helper <- function(CT1,CT2){
    ridx <- vector()
    idx <- vector()
    for (i in 1:nrow(CT1)) {
      for (j in 1:nrow(CT2)){
        rel <- relation(as.numeric(CT1[i,c("index1","index2")]),as.numeric(CT2[j,c("index1","index2")]))
        if (rel$Relation=="proximity"){
          ridx <- c(ridx,i)
          idx <- c(idx,CT1[i,c("index1","index2")])
        } else if (rel$Relation=="overlap") {
          ridx <- c(ridx,i)
          index <- sort(c(rel$OverlapIndex,rel$UnionIndex))
          if (rel$WhichMin==1) idx <- c(idx,index[1:2])
          if (rel$WhichMin==2) idx <- c(idx,index[3:4])
        } else if (rel$Relation=="inclusion"){
          if ((!is.na(rel$WhichMin) && rel$WhichMin==1) &&
              (!is.na(rel$WhichMax) && rel$WhichMax==1)
              ) {
            ridx <- c(ridx,i,i)
            idx <- c(idx,sort(c(rel$OverlapIndex,rel$UnionIndex)))
          }
          if ((!is.na(rel$WhichMin) && rel$WhichMin==1) &&
              is.na(rel$WhichMax)
              ) {
            ridx <- c(ridx,i)
            idx <- c(idx,sort(c(rel$OverlapIndex,rel$UnionIndex))[1:2])
          }
          if (is.na(rel$WhichMin) &&
              (!is.na(rel$WhichMax) && rel$WhichMax==1)
              ) {
            ridx <- c(ridx,i)
            idx <- c(idx,sort(c(rel$OverlapIndex,rel$UnionIndex))[3:4])
          } ## no need to test exact.
        }
      }
    }
    if (length(ridx) >=2){
      index1 <- idx[seq(from=1,to=length(idx),by=2)]
      index2 <- idx[seq(from=2,to=length(idx),by=2)]
      ans <- cbind(CT1[ridx,c("rowid","fid","filename")],index1=index1,index2=index2)
      ans
    }
  }
  
  fid <- intersect(CT1$fid,CT2$fid)
  if (length(fid)>0) {
    ans <- lapply(fid,FUN=function(x) not_helper(CT1=subset(CT1,fid==x),CT2=subset(CT2,fid==x)))
    ans <- do.call(rbind,ans)
    if (showCoding && !is.null(ans)){
      txt <- apply(ans,1,function(x){
        txt <- RQDAQuery(sprintf("select file from source where id==%s",x[["fid"]]))[1,1]
        Encoding(txt) <- "UTF-8"
        ans <- substr(txt, as.numeric(x[["index1"]])+1, as.numeric(x[["index2"]]))
        ans
      })
      ans$coding <- txt
    }
    class(ans) <- c("codingsByOne","data.frame")
    ans
  } else NULL
}

"%not%.codingsByOne" <- function(e1,e2){
  not(e1, e2)
}
