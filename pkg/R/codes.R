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
 codesName <- dbGetQuery(con, "select name, id from freecode")
 assign(assignfileName, codesName ,env=assignenv) 
 tryCatch(widget[] <- codesName[['name']],error=function(e){})
}


mark <- function(widget){
  buffer <- slot(widget,"widget")@widget$GetBuffer()
  bounds = buffer$GetSelectionBounds()
  startI = bounds$start ## start and end iter
  endI = bounds$end
  selected <- buffer$GetText(startI,endI) #get selected text
  startN <- gtkTextIterGetOffset(startI) # translate iter pointer to number
  endN <- gtkTextIterGetOffset(endI)
  buffer$createTag("red.foreground",foreground = "red");
  buffer$ApplyTagByName("red.foreground",startI,endI); ## change colors
  return(list(start=startN,end=endN,text=selected))
}

ClearMark <- function(widget,max){
## max position of marked text.
tryCatch({
  buffer <- slot(widget,"widget")@widget$GetBuffer()
  startI <-gtkTextBufferGetIterAtOffset(buffer,0)$iter # translate number back to iter
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

