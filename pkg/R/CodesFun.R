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
  }} else gmessage("Cannot update Code List in the Widget. Project is closed already.\n",con=TRUE)
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
    buffer$ApplyTagByName("red.foreground",startI,endI)
    ## buffer$createTag("red.background",list(foreground = "red")) ## better, it can mark space
    ## buffer$ApplyTagByName("red.background",startI,endI); ## change colors   
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
#    gtkTextBufferRemoveTagByName(buffer,"red.background",startI,endI)},

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
#             buffer$createTag("red.background",background = "red")  
#             buffer$ApplyTagByName("red.background",start,end)}),
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
  if (length(currentCode)!=0){
  Encoding(currentCode) <- "UTF-8"
  currentCid <- dbGetQuery(.rqda$qdacon,sprintf("select id from freecode where name== '%s' ",currentCode))[1,1]
  ## reliable is more important                       
  retrieval <- dbGetQuery(.rqda$qdacon,sprintf("select cid,fid, selfirst, selend,seltext from coding where status==1 and cid=%i",currentCid))
  if (nrow(retrieval)==0) gmessage("No Coding associated with the selected code.",con=TRUE) else {
  retrieval <-  retrieval[order( retrieval$fid),]
  fid <- unique(retrieval$fid)
  retrieval$fname <-""
  .gw <- gwindow(title=sprintf("Retrieved text: %s",currentCode),parent=c(370,10),width=600,height=600)
  .retreivalgui <- gtext(con=.gw)
  for (i in fid){
    FileName <- dbGetQuery(.rqda$qdacon,sprintf("select name from source where status==1 and id==%i",i))[['name']]
    tryCatch(Encoding(FileName) <- "UTF-8",error=function(e){})
    ##fname <- paste("Source: ", FileNames, sep="")
    retrieval$fname[retrieval$fid==i] <- FileName
  }
  Encoding(retrieval$seltext) <-  Encoding(retrieval$fname) <- "UTF-8"
  
  apply(retrieval,1, function(x){
     metaData <- sprintf("%s [%s:%s]\n",x[['fname']],x[['selfirst']],x[['selend']])
     add(.retreivalgui,metaData,font.attr=c(foreground="red",size="x-large"),do.newline=FALSE)
     add(.retreivalgui,x[['seltext']],font.attr=c(style="normal",size="large"),do.newline=FALSE)
     add(.retreivalgui,"\n\n",font.attr=c(style="normal",size="large"),do.newline=FALSE)
   }
        )
}
  }
}

retrieval2 <- function(CodeNameWidget){
## CodeNameWidget=.rqda$.codes_rqda for Codes Tab
## CodeNameWidget=.rqda$.CodeofCat for C-Cat Tab
  currentCode <- svalue(CodeNameWidget)
  if (length(currentCode)!=0){
    Encoding(currentCode) <- "UTF-8"
    currentCid <- dbGetQuery(.rqda$qdacon,sprintf("select id from freecode where name== '%s' ",currentCode))[1,1]
    ## reliable is more important                       
    retrieval <- dbGetQuery(.rqda$qdacon,sprintf("select cid,fid, selfirst, selend,seltext from coding where status==1 and cid=%i order by fid",currentCid))
    if (nrow(retrieval)==0) gmessage("No Coding associated with the selected code.",con=TRUE) else {
      ## retrieval <-  retrieval[order( retrieval$fid),]
      ## use sql to order the fid
      fid <- unique(retrieval$fid)
      retrieval$fname <-""
      .gw <- gwindow(title=sprintf("Retrieved text: %s",currentCode),parent=c(370,10),width=600,height=600)
      .retreivalgui <- gtext(con=.gw)
      for (i in fid){
        FileName <- dbGetQuery(.rqda$qdacon,sprintf("select name from source where status==1 and id==%i",i))[['name']]
        tryCatch(Encoding(FileName) <- "UTF-8",error=function(e){})
        ##fname <- paste("Source: ", FileNames, sep="")
        retrieval$fname[retrieval$fid==i] <- FileName
      }
      Encoding(retrieval$seltext) <-  Encoding(retrieval$fname) <- "UTF-8"

      ## modification begins
        ComputeCallbackFun <- function(BeginPosition,EndPosition,FileName){
          CallBackFUN <- function(button){  
            tryCatch(dispose(.rqda$.root_edit),error=function(e) {})
            root <- gwindow(title=FileName, parent=c(370,40),width=580,height=300)
            ## use the same names as the of ViewFile, so can do coding when back to the original file.
            assign(".root_edit",root,env=.rqda)
            displayFile <- gtext(container=.rqda$.root_edit,font.attr=c(sizes="large"))
            assign(".openfile_gui",displayFile,env=.rqda)
            content <- dbGetQuery(.rqda$qdacon, sprintf("select file from source where name='%s'",FileName))[1,1]
            Encoding(content) <- "UTF-8" ## so it display correct in the gtext widget
            add(.rqda$.openfile_gui,content,font.attr=c(sizes="large"))
            HL(.rqda$.openfile_gui,data.frame(begin=BeginPosition,end=EndPosition))
            .rqda$.openfile_gui@widget@widget$SetEditable(FALSE)
            MarkHere <- .rqda$.openfile_gui@widget@widget$GetBuffer()$CreateMark(mark.name = "MarkHere", where=.rqda$.openfile_gui@widget@widget$GetBuffer()$GetIterAtOffset(BeginPosition)$iter)
            # create a mark -> more reliable to use ScrollToMark than ScrollToIter
            #gtkTextViewScrollToIter(.rqda$.openfile_gui@widget@widget,
            #                          .rqda$.openfile_gui@widget@widget$GetBuffer()$GetIterAtOffset(BeginPosition)$iter,
            #                          0.001,xal=0,yal=0,use.align=TRUE)## doesn't seem to work.
            gtkTextViewScrollToMark(.rqda$.openfile_gui@widget@widget,
                                      MarkHere,0,xal=0,yal=0.2,use.align=TRUE)
            }    
         CallBackFUN
        }

      buffer <- .retreivalgui@widget@widget$GetBuffer()
      iter <- buffer$getIterAtOffset(0)$iter
create.tags <- function(buffer)
{
buffer$createTag("big",size = 14 * PANGO_SCALE)
buffer$createTag("x-large",scale = PANGO_SCALE_X_LARGE)
buffer$createTag("large",scale = PANGO_SCALE_LARGE)
buffer$createTag("red.foreground",foreground = "red")
}
create.tags(buffer)

      apply(retrieval,1, function(x){
        metaData <- sprintf("%s [%s:%s]",x[['fname']],x[['selfirst']],x[['selend']])
        buffer$InsertWithTagsByName(iter, metaData,"x-large","red.foreground")
        anchorcreated <- buffer$createChildAnchor(iter)
        iter$BackwardChar()
        anchor <- iter$getChildAnchor()  
        widget <- gtkButtonNewWithLabel("Back")
        gSignalConnect(widget, "clicked", ComputeCallbackFun(x[['selfirst']],x[['selend']],x[['fname']]))
        .retreivalgui@widget@widget$addChildAtAnchor(widget, anchor)
        widget$showAll()
        iter$ForwardChar()
        buffer$insert(iter, "\n")
        buffer$InsertWithTagsByName(iter, x[['seltext']],"large")
        buffer$insert(iter, "\n\n")
      }
            )
    }
  }
}





