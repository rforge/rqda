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


and_helper <- function(CT1,CT2,method){
  ## CT1 and CT2 is from GetCodingTable,each for one code and one file only
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
  }
}


and <- function(CT1,CT2,showCoding=FALSE, method= c("overlap","exact","inclusion")){
  ## CT1 and CT2 is from GetCodingTable,each for one code only
  fid <- intersect(CT1$fid,CT2$fid)
  if (length(fid)>0) {
    ans <- lapply(fid,FUN=function(x) {
      and_helper(CT1=subset(CT1,fid==x),CT2=subset(CT2,fid==x),method=method)
    }
      )
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
  } else {
    ans <- data.frame("rowid"=integer(0),"fid"=integer(0),
                      "filename"=character(0), "index1"=integer(0),
                      "index2"=integer(0), "coding"=character(0))
  }
  class(ans) <- c("codingsByOne","data.frame")
  ans
}


"%and%.codingsByOne" <- function(e1,e2){
    and(e1, e2, showCoding=TRUE, method= getOption("andMethod"))
}

or_helper <- function(CT1,CT2){
  ## CT1 and CT2 is from GetCodingTable,each for one code and one file only
  if (nrow(CT1)!=0 && nrow(CT2)!=0) {
    ct <- CT1[0,]
    for (i in 1:nrow(CT1)) {
      rel <- apply(CT2,1,function(x){
        relation(as.numeric(CT1[i,c("index1","index2")]),
                 as.numeric(x[c("index1","index2")]))
      })
      Relation <-  sapply(rel,function(x) x$Relation)
      if (all(sapply(rel,function(x) x$Relation)=="promixity")){
        ct <- rbind(ct,CT1[i,]) ## all proximity, add to CT2
      } else {
        np.idx <- which(Relation!="proximity")
        if (length(np.idx)>0) {
          nidx <- t(sapply(rel[np.idx],function(x) x$UnionIndex))
          CT2[np.idx,c("index1","index2")] <- nidx
        }
      }
    }
    ans <- rbind(CT2,ct)
  } else {
    if (nrow(CT1)==0) ans <- CT2
    if (nrow(CT2)==0) ans <- CT1
  }
  ans <- ans[,c("rowid","fid","filename","index1","index2")]
  ans
}


or <- function(CT1,CT2,showCoding=FALSE){
## older version is in rev 274
  fid <- intersect(CT1$fid,CT2$fid)
  if (length(fid)>0) {
    ans <- lapply(fid,FUN=function(x) or_helper(CT1=subset(CT1,fid==x),CT2=subset(CT2,fid==x)))
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
  } else {
    ans <- data.frame("rowid"=integer(0),"fid"=integer(0),
                      "filename"=character(0), "index1"=integer(0),
                      "index2"=integer(0), "coding"=character(0))
  }
  class(ans) <- c("codingsByOne","data.frame")
  ans
}


"%or%.codingsByOne" <- function(e1,e2){
  or(e1, e2,showCoding=TRUE)
}

not_helper <- function(CT1,CT2){
  ## CT1 and CT2 is coings for one code and one file.
  ridx <- vector()
  idx <- vector()
  if (nrow(CT1)!=0) { ## if1
    if (nrow(CT2)==0) {
      ridx <- c(ridx,nrow(CT1))
      idx <- c(idx,unlist(as.data.frame(t(CT1[,c("index1","index2")]))))
    } else { ## else1
      for (i in 1:nrow(CT1)) {
        relAll <- apply(CT2,1,function(x)
                        relation(CT1[i,c("index1","index2"),drop=TRUE],
                                 as.numeric(x[c("index1","index2")]))
                        ) ## end of apply
        Relation <- sapply(relAll,function(x) x$Relation)
        if (all(Relation=="exact")) {
          ## do nothing
        } else { ## else2 
          if (all(Relation=="proximity")){
            ridx <- c(ridx,i)
            idx <- c(idx, CT1[i,c("index1","index2"),drop=TRUE])
          } else { ## else3
            in.over <- Relation %in% c("inclusion", "overlap") ## index of overlap and inclusion
            rel.in.over <- relAll[in.over]
            nested <- sapply(rel.in.over,function(x){
              if (x$Relation=="inclusion") {
                ans <- (!is.na(x$WhichMin) &&  !is.na(x$WhichMax) &&
                        x$WhichMin==2 &&  x$WhichMax==2)
              } else {
                ans <- FALSE
              }
              ans
            }
                             ) ## end of sapply
            if (any(nested)) {
              ## do nothing
            } else {## else4
              over <- Relation %in% c("overlap")
              if (sum(over)>2) stop("the same text is coded twice by the same code.")

              for (j in which(over)) {
                if (!is.na(relAll[[j]]$WhichMin) &&  relAll[[j]]$WhichMin==2){
                  CT1[i,"index1"] <- relAll[[j]]$OverlapIndex[2]
                }
                if (!is.na(relAll[[j]]$WhichMin) &&  relAll[[j]]$WhichMin==1){
                  CT1[i,"index2"] <- relAll[[j]]$OverlapIndex[1]
                }
              } ## end for j
              
              inidx<- Relation %in% c("inclusion")
              ans <- sapply(relAll[inidx],function(x) x$OverlapIndex)
              ans <- sort(unlist(c(CT1[i,c("index1","index2"),drop=TRUE],ans)))
              ridx <- c(ridx,rep(i,length(ans)/2))
              idx <- c(idx,ans)
            }## else4
          } ## else3
        } ## else 2
      } ## end of for i
    } ## end else1
  }## if1
  
  if (length(ridx) >=1){
    idx <- unlist(idx)
    index1 <- idx[seq(from=1,to=length(idx),by=2)]
    index2 <- idx[seq(from=2,to=length(idx),by=2)]
    ans <- cbind(CT1[ridx,c("rowid","fid","filename")],index1=index1,index2=index2)
    ## ans <- unique(ans)
    ans
  }
  
}## end of fun


not <- function(CT1,CT2,showCoding=FALSE){
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
  } else {
    ans <- data.frame("rowid"=integer(0),"fid"=integer(0),
                      "filename"=character(0), "index1"=integer(0),
                      "index2"=integer(0), "coding"=character(0))
  }
  class(ans) <- c("codingsByOne","data.frame")
  ans
}

"%not%.codingsByOne" <- function(e1,e2){
  not(e1, e2, show=TRUE)
}

