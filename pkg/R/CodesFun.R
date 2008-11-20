addcode <- function(name,conName="qdacon",assignenv=.rqda,...) {
  if (name != ""){
    con <- get(conName,assignenv)
    maxid <- dbGetQuery(con,"select max(id) from freecode")[[1]]
    nextid <- ifelse(is.na(maxid),0+1, maxid+1)
    write <- FALSE
    if (nextid==1){
      write <- TRUE
    } else {
      dup <- dbGetQuery(con,sprintf("select name from freecode where name=='%s'",name))
      if (nrow(dup)==0) write <- TRUE
    }
    if (write ) {
      dbGetQuery(con,sprintf("insert into freecode (name, id, status,date,owner)
                                            values ('%s', %i, %i,%s, %s)",
                             name,nextid, 1, shQuote(date()),shQuote(.rqda$owner)))
    }
  }
}



CodeNamesUpdate <- function(CodeNamesWidget=.rqda$.codes_rqda,...)
{
  if (isIdCurrent(.rqda$qdacon)){
  codesName <- dbGetQuery(.rqda$qdacon, "select name, id from freecode where status=1")
  if (nrow(codesName)!=0) {
  Encoding(codesName[['name']]) <- "UTF-8"
  tryCatch(CodeNamesWidget[] <- codesName[['name']], error=function(e){})
  } else cat("Project is closed already.\n")
}
}


mark <- function(widget){
  index <- sindex(widget)
  startI <- index$startI ## start and end iter
  endI <- index$endI
  selected <- index$seltext
  Encoding(selected) <- "UTF-8"
  startN <- index$startN # translate iter pointer to number
  endN <- index$endN
  if (startN != endN){
    buffer <- slot(widget,"widget")@widget$GetBuffer()
    buffer$createTag("red.foreground",foreground = "red")
    buffer$ApplyTagByName("red.foreground",startI,endI); ## change colors
  }
  ## only when selected text chunk is not "", apply the color scheme.
  return(list(start=startN,end=endN,text=selected))
}



ClearMark <- function(widget,min=0, max){
  ## max position of marked text.
  tryCatch({
    buffer <- slot(widget,"widget")@widget$GetBuffer()
    startI <-gtkTextBufferGetIterAtOffset(buffer,min)$iter # translate number back to iter
    endI <-gtkTextBufferGetIterAtOffset(buffer,max)$iter
    gtkTextBufferRemoveTagByName(buffer,"red.foreground",startI,endI)},
           error=function(e){})
}


HL <- function(W,index){
  ## W is the gtext widget of the text.
  ## highlight text chuck according to index
  ## index is a data frame, each row == one text chuck.
  tryCatch(
           apply(index,1, function(x){
             buffer <- slot(W,"widget")@widget$GetBuffer()
             start <-gtkTextBufferGetIterAtOffset(buffer,x[1])$iter # translate number back to iter
             end <-gtkTextBufferGetIterAtOffset(buffer,x[2])$iter
             buffer$createTag("red.foreground",foreground = "red")  
             buffer$ApplyTagByName("red.foreground",start,end)}),
           error=function(e){})
}



sindex <- function(widget){
  buffer <- slot(widget,"widget")@widget$GetBuffer()
  bounds = buffer$GetSelectionBounds()
  startI = bounds$start ## start and end iter
  endI = bounds$end
  selected <- buffer$GetText(startI,endI)
  startN <- gtkTextIterGetOffset(startI) # translate iter pointer to number
  endN <- gtkTextIterGetOffset(endI)
  return(list(startI=startI,endI=endI,
              startN=startN,endN=endN,seltext=selected))
}



retrieval <- function(){
  currentCode <- svalue(.rqda$.codes_rqda)
  Encoding(currentCode) <- "UTF-8"
  currentCid <- dbGetQuery(.rqda$qdacon,sprintf("select id from freecode where name== '%s' ",currentCode))[1,1]
  ## reliable is more important                       
  retrieval <- dbGetQuery(.rqda$qdacon,sprintf("select cid,fid, selfirst, selend,seltext from coding where status==1 and cid=%i",currentCid))
  fid <- unique(retrieval$fid)
  .gw <- gwindow(title=sprintf("Retrieved text: %s",currentCode),parent=c(370,10),width=600,height=600)
  .retreivalgui <- gtext(con=.gw)
  for (i in fid){
    FileNames <- dbGetQuery(.rqda$qdacon,sprintf("select name from source where status==1 and id==%i",i))[['name']]
    tryCatch(Encoding(FileNames) <- "UTF-8",error=function(e){})
    fname <- paste("Source: ", FileNames, sep="")
    seltext <- retrieval$seltext[retrieval$fid==i]
    seltext <- paste(seltext,collapse="\n\n")
    CodingIndex <- retrieval[retrieval$fid==i,c("selfirst","selend")]
    CodingIndex <- apply(CodingIndex,1,FUN=function(x) paste(x,sep="",collapse=":"))
    Encoding(seltext) <- "UTF-8"
    add(.retreivalgui,fname,font.attr=c(style="italic",size="x-large"))
    add(.retreivalgui,CodingIndex,font.attr=c(style="italic",size="x-large"))
    add(.retreivalgui,"\n",font.attr=c(style="italic"))
    add(.retreivalgui,seltext,font.attr=c(style="normal",size="large"))
    add(.retreivalgui,"\n",font.attr=c(style="italic"))
  }
}

