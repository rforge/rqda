addAnnoTable <- function(){
  tryCatch(
  RQDAQuery("create table annotation (fid integer,position integer,annotation text, owner text, date text,dateM text, status integer)"),error=function(e){})
} ##RQDAQuery("drop table annotation")

NextRowId <- function(table){
  ans <- RQDAQuery(sprintf("select max(rowid)+1 as nextid from %s",table))
  if (is.na(ans)) ans <- 1
  ans
}
  
InsertAnnotation <- function (index,fid,rowid,label="[Annotation]") 
  {
    widget=.rqda$.openfile_gui
    lab <- gtkLabelNew(label)
    label <- gtkEventBoxNew()
    label$ModifyBg("normal", gdkColorParse("yellow")$color)
    label$Add(lab)
    buffer <- slot(widget, "widget")@widget$GetBuffer()
    button_press <- function(widget, event,moreArgs) {
      openAnnotation(New=FALSE,pos=moreArgs$pos,fid=moreArgs$fid,rowid=moreArgs$rowid)
    }
    gSignalConnect(label, "button-press-event", button_press,data = list(pos=index,fid=fid,rowid=rowid))
    iter <- gtkTextBufferGetIterAtOffset(buffer, index)$iter
    buffer$CreateMark(mark.name=sprintf("%s.3",rowid),where=iter)
    anchorcreated <- buffer$createChildAnchor(iter)
    iter$BackwardChar()
    anchor <- iter$getChildAnchor()
    anchor <- gtkTextIterGetChildAnchor(iter)
    widget@widget@widget$addChildAtAnchor(label, anchor)
  } ## end of helper widget

DeleteAnnotationAnchorByMark <- function(markname){
  buffer <- RQDA:::.rqda$.openfile_gui@widget@widget$GetBuffer()
  mark <- buffer$GetMark(markname)
  buffer$GetIterAtMark(mark)
  offset2 <- buffer$GetIterAtMark(mark)$iter$GetOffset()
  offset1 <- offset2 - 1
  iter2 <- buffer$GetIterAtOffset(offset2)$iter
  iter1 <- buffer$GetIterAtOffset(offset1)$iter
  buffer$Delete(iter1,iter2)
}


openAnnotation <- function(New=TRUE,pos,fid,rowid){
  tryCatch(dispose(.rqda$.annotation),error=function(e) {})
  .annotation <- gwindow(title="Annotation",parent=getOption("widgetCoordinate"),width=600,height=400)
  assign(".annotation",.annotation, env=.rqda)
  .annotation2 <- gpanedgroup(horizontal = FALSE, con=.annotation)
  gbutton("Save Annotation",con=.annotation2,handler=function(h,...){
    newcontent <- svalue(W)
    newcontent <- enc(newcontent,encoding="UTF-8")
    if (newcontent != ""){
    if (New) {
      InsertAnnotation(index=pos,fid=fid,rowid=rowid)
      RQDAQuery(sprintf("insert into annotation (fid,position,annotation,owner,date,status) values (%i,%i,'%s','%s','%s',1)", fid,pos,newcontent,.rqda$owner,date()))
      New <<- FALSE ## note the replacement <<-
    } else {
        RQDAQuery(sprintf("update annotation set annotation='%s' where fid=%i and position=%s and status=1",
                          newcontent,fid,pos))
      }} else {## action for empty new content.
      tryCatch(DeleteAnnotationAnchorByMark(sprintf("%s.3",rowid)),error=function(e){})
      RQDAQuery(sprintf("update annotation set annotation='%s' where fid=%i and position=%s and status=1",
                          newcontent,fid,pos))
      RQDAQuery(sprintf("update annotation set status=0 where fid=%i and position=%s and status=1",
                          fid,pos))
   }
  })## end of save button
  assign(".annotationContent",gtext(container=.annotation2,font.attr=c(sizes="large")),env=.rqda)
    prvcontent <- RQDAQuery(sprintf("select annotation from annotation where fid=%i and position=%s and status=1",fid,pos))[1,1]
  if (is.null(prvcontent)) prvcontent <- ""
  Encoding(prvcontent) <- "UTF-8"
  W <- get(".annotationContent",env=.rqda)
  add(W,prvcontent,font.attr=c(sizes="large"),do.newline=FALSE)
}

Annotation <- function(...){
  if (is_projOpen(env=.rqda,conName="qdacon")) {
    W <- tryCatch( get(".openfile_gui",env=.rqda), error=function(e){})
    ## get the widget for file display. If it does not exist, then return NULL.
    pos <- tryCatch(sindex(W,includeAnchor=FALSE),error=function(e) {}) ## if the not file is open, it doesn't work.
    if (is.null(pos)) {gmessage("Open a file first!",con=TRUE)}
    else {
      SelectedFile <- svalue(.rqda$.root_edit) 
      SelectedFile <- enc(SelectedFile,encoding="UTF-8")
      currentFid <-  RQDAQuery(sprintf("select id from source where name=='%s'",SelectedFile))[,1]
      idx <- RQDAQuery(sprintf("select fid, annotation,rowid from annotation where fid==%i and position=%s and status=1",currentFid,pos$startN))
      New <- ifelse(nrow(idx)==0,TRUE,FALSE)
      if (nrow(idx)==0) rowid <- NextRowId("annotation") else rowid <- idx$rowid
      openAnnotation(New=New,pos=pos$startN,fid=currentFid,rowid=rowid)
    }
  }}


AnnotationButton <- function(label="Add Anno"){
  ans <- gbutton(label,handler=function(h,...) {
    if (is_projOpen(env=.rqda,conName="qdacon")) {
      Annotation()
    }})
  gtkTooltips()$setTip(ans@widget@widget,"Add new annotation to the open file\nat position of cursor.")
  return(ans)
}
