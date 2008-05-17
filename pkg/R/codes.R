addcode <- function(name,conName="qdacon",assignenv=.rqda,assigname="codes_index",...) {
if (name != ""){
  con <- get(conName,assignenv)
  maxid <- dbGetQuery(con,"select max(id) from freecode")[[1]]
  nextid <- ifelse(is.na(maxid),0+1, maxid+1)
    write <- FALSE
  if (nextid==1){
     write <- TRUE
  } else {
    allnames <- RSQLite:::sqliteQuickColumn(con,"freecode","name")
      if (!any(name==allnames)) {
     write <- TRUE
    }
  }
if (write ) {
  dbGetQuery(con,sprintf("insert into freecode (name, id, status) values ('%s', %i, %i)",name,nextid, 1))
}
  assign(assigname, dbGetQuery(con,"select name,id from freecode"),env=assignenv)
 }
}


codesupdate <- function(conName="qdacon",assignenv=.rqda,
                         assignfileName="codes_index",
				 widget,...){
 ## the widget should be get(".codes_rqda",env=.rqda)
 con <- get(conName,assignenv)
 codesName <- dbGetQuery(con, "select name, id from freecode where status=1")
 assign(assignfileName, codesName ,env=assignenv) 
 tryCatch(widget[] <- codesName[['name']],error=function(e){})
}


mark <- function(widget){
  index <- sindex(widget)
  startI <- index$startI ## start and end iter
  endI <- index$endI
  selected <- index$seltext
  startN <- index$startN # translate iter pointer to number
  endN <- index$endN
  if (startN != endN){
  buffer <- slot(widget,"widget")@widget$GetBuffer()
  buffer$createTag("red.foreground",foreground = "red");
  buffer$ApplyTagByName("red.foreground",startI,endI); ## change colors
   } ##only when selected text chunk is not "", apply the color scheme.
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

retrieval <- function(currentCid,conName,env,currentCode="currentCode",assignenv=.rqda){
  currentCid <- get(currentCid,env)
  currentCode <- get(currentCode,env)
  con <- get(conName,env)
  retrieval <- dbGetQuery(con,sprintf("select cid,fid, seltext from coding where status==1 and cid=%i",currentCid))
  fid <- unique(retrieval$fid)
  .gw <- gwindow(title=sprintf("Retrieved text: %s",currentCode),parent=c(270,10),width=600,height=600)
  .retreivalgui <- gtext(con=.gw)
  for (i in fid){
    fname <- paste("Source: ", .rqda$files_index$name[.rqda$files_index$id==i], sep="")
    seltext <- retrieval$seltext[retrieval$fid==i]
    ##seltext <- gsub("\n","", seltext,fixed=TRUE)
    seltext <- paste(seltext,collapse="\n\n")
    Encoding(seltext) <- "UTF-8"
    add(.retreivalgui,fname,font.attr=c(style="italic",size="x-large"))
    add(.retreivalgui,"\n",font.attr=c(style="italic"))
    add(.retreivalgui,seltext,font.attr=c(style="normal",size="large"))
    add(.retreivalgui,"\n",font.attr=c(style="italic"))
  }
}

