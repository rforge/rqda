RQDA <- function() {
########################### aux functions
########################### 
NI <- function(...){
gmessage("Not Implemented Yet.",con=TRUE)
}

########################### GUI FOR ROOT
########################### 
".root_rqdagui" <- gwindow(title = "RQDA: Qualitative Data Analysis.",parent=c(10,10),
                        width=250,height=600,visible=FALSE,handler=function(h,...){
                        tryCatch(dispose(.rqda$.root_edit),error=function(e){})
                        close_proj(assignenv=h$action$env)
},
                        action=list(env=.rqda)
                        )

addHandlerUnrealize(.root_rqdagui, handler = function(h,...) {
  ## make sure is the project should be closed by issuing a confirm window.
  val <- gconfirm("Really EXIST?\n\nYou can use RQDA() to start this program again.", parent=h$obj)
  if(as.logical(val))
    return(FALSE)             # destroy
  else
    return(TRUE)              # don't destroy
}
                    )

".nb_rqdagui" <- gnotebook(3,container=.root_rqdagui,closebuttons=FALSE)

##addhandlermousemotion(.root_rqdagui,handler=function(h,...){
### no longer needed, generated the metadata and store it as sysdata.rda in R subdirectroy.
## check if the meta data has been deleted.
##if (!exists(".rqda",.GlobalEnv)) 
##gmessage("Meta data has been deleted.\nRun rqdameta() manually in order to work properly.",icon="error",cont=)
## if (gconfirm("Meta data has been deleted, generate it gain?",con=TRUE)) {
##  rqdameta()
## dispose(.root_rqdagui)
##RQDA()
##}
##})

########################### GUI FOR PROJECT
########################### 
".proj_gui" <- ggroup(container=.nb_rqdagui,horizontal=FALSE,label="Project")
".newproj_gui" <- gbutton("New Project",container=.proj_gui,handler=function(h,...){
  path=gfile(type="save") 
  if (path!=""){
    ## if path="", then click "cancel".
    Encoding(path) <- "UTF-8"
    new_proj(path,assignenv=h$action$env)}
  },
                          action=list(env=.rqda)
                          )


".open.proj_gui" <- gbutton("Open Project",container=.proj_gui,handler=function(h,...){
  path <- gfile(type="open",filter=list("rqda"=list(patterns = c("*.rqda"))))
  if (path!=""){
    Encoding(path) <- "UTF-8"
    open_proj(path,assignenv=h$action$env)
  }
},
                            action=list(env=.rqda)
                            )


".close.proj_gui" <- gbutton("Close Project",container=.proj_gui,handler=function(h,...){
  close_proj(assignenv=h$action$env)
},
                             action=list(env=.rqda)
                             )

".projinfo_gui" <- gbutton("Current Project",container=.proj_gui,handler=function(h,...){
    if (is_projOpen(env=h$action$env,conName=h$action$conName)) {
    con <- get(h$action$conName,h$action$env)
    dbname <- dbGetInfo(.rqda$qdacon)$dbname
    ##substr(dbname, nchar(dbname)-15,nchar(dbname))
    gmessage(dbname,title="Info about current project.",con=TRUE)
    }
  },
                          action=list(env=.rqda,conName="qdacon")
                          )


glabel("Basic Usage of RQDA:\n
1. New Project or Open project.\n
2. Update file list or Import files.\n
3. Update code list or Add codes.\n
4. Open a file and begin coding.\n
Author: <ronggui.huang@gmail.com>\n
This software is part of my PhD research.\n",container=.proj_gui)



########################### GUI for FILES 
###########################

".files_pan" <- gpanedgroup(container=.nb_rqdagui,horizontal=FALSE,label="Files")
".files_button" <- ggroup(container=.files_pan,horizontal=TRUE)

.importfilebutton <-gbutton("Import",container=.files_button,handler=function(h,...){
    if (is_projOpen(env=h$action$env,conName=h$action$conName)) {
  path <- gfile(type="open",filter=list("text files" = list(mime.types = c("text/plain"))))
  if (path!=""){
    Encoding(path) <- "UTF-8"
    importfile(path,encoding=get("encoding",envir=h$action$env),con=h$action$env$qdacon,assignenv=h$action$env)
    ## updatefilelist()
    ## add codes here
  }
 }
},action=list(env=.rqda,conName="qdacon"))

##gbutton("Update",contain=.files_button,handler=function(h,...){
##   if (is_projOpen(env=h$action$env,conName=h$action$conName)) {
##   fnamesupdate(h$action$conName,h$action$env)
##}
##},action=list(env=.rqda,conName="qdacon"))

gbutton(" View ",contain=.files_button,handler=function(h,...){
  if (is_projOpen(env=h$action$env,conName=h$action$conName)) {
    if (length(svalue(.fnames_rqda))==0){gmessage("Select a file first.",icon="error",con=TRUE)}
    else{
    tryCatch(dispose(h$action$env$.root_edit),error=function(e) {})## notice the error handler
    assign(".root_edit",gwindow(title=svalue(.fnames_rqda), parent=c(270,10),width=600,height=600),env=h$action$env)
    .root_edit <- get(".root_edit",h$action$env)
   ## addHandlerUnrealize(.root_edit, handler = function(h,...) {
      ## make sure is the project should be closed by issuing a confirm window.
     ## val <- gconfirm("Really close window", parent=h$obj)
      ##if(as.logical(val))
       ## return(FALSE)             # destroy
      ##else
       ## return(TRUE)              # don't destroy
    ##}
    ## ) 
    assign(".openfile_gui",gtext(container=.root_edit,font.attr=c(sizes="large")),env=h$action$env)
    con <- get(h$action$conName,h$action$env)
    content <- dbGetQuery(con, sprintf("select file from source where name='%s'",svalue(.fnames_rqda)))[1,1] 
    ## turn data.frame to 1-length character.
    W <- get(".openfile_gui",h$action$env)
    add(W,content,font.attr=c(sizes="large"))
    slot(W,"widget")@widget$SetEditable(FALSE)
    ## make sure it is read only file in the text window.

codings_index <- dbGetQuery(con,"select rowid, cid, fid, selfirst, selend, status from coding where status=1")
assign("codings_index", codings_index, h$action$env) 

}}
},
        action=list(env=.rqda,conName="qdacon")
        )


gbutton(" Delete ",contain=.files_button,handler=function(h,...)
         {
         if (is_projOpen(env=h$action$env,conName=h$action$conName) & length(svalue(.fnames_rqda))!=0) {
        ## if the project open and a file is selected, then continue the action
        del <- gconfirm("Really delete the file?",icon="question")
        if (isTRUE(del)){
        dbGetQuery(get(h$action$conName,h$action$env), sprintf("update source set status=0 where id=%s",h$action$env$currentFid))
        ## set the status of the selected file to 0
        assign("currentFid",integer(0),envir=h$action$env)
        assign("currentFile",character(0),envir=h$action$env)
        ## set "currentFid" and "currentFile" in .rqda to integer(0) and character(0)
        fnamesupdate(assignenv=h$action$env)
        ## reset files_index in .rqda by updatefilelist()
        }
        }
        },action=list(env=.rqda,conName="qdacon")
        )


".fnames_rqda" <- gtable("Click Here to see the File list.",container=.files_pan)
.fnames_rqda[] <-NULL # get around of the text argument.


addHandlerMouseMotion(.fnames_rqda, handler <- function(h, 
                                                        ## updating the file name list.
                                                        ...) {
  if (is_projOpen(env = h$action$env, conName = h$action$conName, 
                   message = FALSE)) {
    ##     cat("Mouse Motion updated.", fill = TRUE)
    fnamesupdate(assignenv = h$action$env, conName = h$action$conName, 
                 assignfileName = h$action$assignfileName,widget=h$action$widget)
  }
}, action = list(env = .rqda, conName = "qdacon", assignfileName = "files_index",widget=.fnames_rqda))


addHandlerClicked(.fnames_rqda, handler <- function(h, ...) {
  ## updating the file name list, and update the status of curent selected file.
  if (is_projOpen(env = h$action$env, conName = h$action$conName, 
                   message = FALSE)) {
    fnamesupdate(assignenv = h$action$env, conName = h$action$conName, 
                assignfileName = h$action$assignfileName,h$action$widget)
    ##    cat("clicked.", fill = TRUE)
    files_index <- get(h$action$assignfileName, h$action$env)
    assign("currentFile", svalue(.fnames_rqda), env = h$action$env)
    currentFile <- get("currentFile", h$action$env)
    currentFid <- files_index[files_index[["name"]] == 
                              currentFile, "id", drop = TRUE]
    if (is.null(currentFid)) 
                currentFid <- integer(0)
    assign("currentFid", currentFid, env = h$action$env)
  }
}, action = list(env = .rqda, conName = "qdacon", assignfileName = "files_index",widget=.fnames_rqda))


########################### GUI for FILES TREE
###########################
#".files_tree" <- gpanedgroup(container=.nb_rqdagui,horizontal=FALSE,label="Files Tree")
#".files_tree_pg" <- gpanedgroup(cont=.files_tree,horizontal = FALSE)
#ft_buttons <- glayout(con=.files_tree_pg)
#ft_buttons[1,1] <- gbutton("ADD",handler=function(h,...){
#item <- ginput("Enter Level 2 label! ", icon="info",parent=.files_tree)
#Encoding(item) <- "UTF-8"
#ft_gt1[] <- c(item,ft_gt1[][!is.na(ft_gt1[])])
#})
#ft_buttons[1,2] <- gbutton("Delete")
#ft_buttons[1,3] <- gbutton("OK")
#ft_buttons[1,4] <- gl <- glabel("")
#ft_pg2 <- ggroup(cont=.files_tree_pg,horizontal = FALSE)
#ft_gt1 <- gtable(data.frame("Level 2 Categories"="Categories",stringsAsFactors=FALSE),con=ft_pg2,multiple=FALSE,expand=TRUE)
#ft_gt1[] <- NULL
#ft_gt2 <- gtable(data.frame("Files in current Category"="Category",stringsAsFactors=FALSE),container=ft_pg2,expand=T)
#ft_gt2[] <- NULL
#ft_gt3 <- gtable(data.frame("Files List"="env$files_index$name",stringsAsFactors=FALSE),container=ft_pg2,multiple=TRUE,expand=T)
#ft_gt3[] <- NULL

########################### GUI for CODES
###########################

".codes_pan" <- gpanedgroup(container=.nb_rqdagui,horizontal=FALSE,label="Codes")
".codes_button" <- glayout(container=.codes_pan)

                                        #.codes_button[1,1]<- gbutton("Update",handler=function(h,...){
###
###
                                        #} )

.codes_button[1,1]<- gbutton("ADD",
                             handler=function(h,...) {
                               if (is_projOpen(env=h$action$env,conName=h$action$conName)) {
                               ##add1<-gwindow("Add code",width=200,heigh=30,parent=c(270,10))
                               ##add2<-ggroup(cont=add1)
                               ##add3<-gedit(con=add2)
                               ##add4<-gbutton("OK",con=add2,handler=function(h,...){
                               ##codename <- svalue(add3)
                                 codename <- ginput("Enter new code. ", icon="info")
                                 codename <- iconv(codename,from="UTF-8")
                                 addcode(codename,conName=h$action$conName,assignenv=h$action$env,
                                           assigname=h$action$assignname)
                                   codesupdate(conName = h$action$conName, assignenv = h$action$env, 
                                               assignfileName =h$action$assignfileName,
                                               widget=get(h$action$widget)
                                               )
                              ##dispose(add2)
                              ##   },action=h$action # explicitly pass the action argument
                              ##               )## end of add4
                               }},
                             action=list(env=.rqda,name="codename",conName="qdacon",assignname="codes_index",
                               assignfileName="codes_index",widget=".codes_rqda")
                             ## widget should be character, and in the codesupdate() call, use get() to access the widget.
                             )

.codes_button[1,2]<- gbutton("Delete",
                             handler=function(h,...)
                              {
         if (is_projOpen(env=h$action$env,conName=h$action$conName) & length(svalue(.codes_rqda))!=0) {
        ## if project is open and one code is selected,then continue
        del <- gconfirm("Really delete the code?",icon="question")
        if (isTRUE(del)){
        dbGetQuery(get(h$action$conName,h$action$env), sprintf("update freecode set status=0 where id=%s",h$action$env$currentCid))
        ## set status in table freecode to 0
        dbGetQuery(get(h$action$conName,h$action$env), sprintf("update coding set status=0 where cid=%s",h$action$env$currentCid))
        ##  set status in table coding to 0, so when press "HL ALL", the text chunk associated with deleted code will be ignored.
        assign("currentCid",integer(0),envir=h$action$env)
        assign("currentCode",character(0),envir=h$action$env)
        ## set "currentCid" and "currentCode" to integer(0) and character(0)
        codesupdate(assignenv=h$action$env)
        ## update "codes_index" in .rqda by codesupdate
        }
        }
        },action=list(env=.rqda,conName="qdacon")
        )

.codes_button[1,3]<- gbutton("HL ALL",
                             handler=function(h,...) {
                               if (is_projOpen(env=h$action$env,conName=h$action$conName)) {
                                 con <- get(h$action$conName,h$action$env)
                                 fid <- get(h$action$currentFid,h$action$env)
                                 mark_index <- dbGetQuery(con, sprintf("select selfirst, selend,status from coding where fid=%i",fid))
                                 ## only select thoses with the open_file and not deleted (status=1).
                                 ClearMark(get(h$action$widget,h$action$env),0,max(mark_index$selend))
                                 HL(get(h$action$widget,h$action$env),index=mark_index[mark_index$status==1,1:2])
                               }
                             },
                             action=list(env=.rqda,conName="qdacon",widget=".openfile_gui",currentFid="currentFid")
                             )

.codes_button[2,1]<- gbutton("Open",
                             handler=function(h,...) {
    if (is_projOpen(env=h$action$env,conName=h$action$conName)) {
                               retrieval(h$action$cid,h$action$conName,h$action$env,h$action$Code)
                               }},
                             action=list(cid="currentCid",conName="qdacon",env=.rqda,Code="currentCode")
                             )

.codes_button[2,2]<- gbutton("Unmark",
                             handler=function(h,...) {
    if (is_projOpen(env=h$action$env,conName=h$action$conName)) {
                               con <- get(h$action$conName,h$action$env)
                               W <- get(h$action$widget,env=h$action$env) ## widget
                               sel_index <- tryCatch(sindex(W),error=function(e) {})
                               ## if the not file is open, unmark doesn't work.
                               if (!is.null(sel_index)) {
                               codings_index <- get(h$action$codings_index,h$action$env)
                               currentCid <- get("currentCid",h$action$env)
                               currentFid <- get("currentFid",h$action$env)
                               codings_index_current <- codings_index[(codings_index$cid==currentCid & codings_index$fid==currentFid),]
                               ## should only work with those related to current code and current file.
                               rowid <- codings_index_current$rowid[(codings_index_current$selfirst  >= sel_index$startN) &
                                                            (codings_index_current$selend  <= sel_index$endN)]
                               if (is.numeric(rowid)) for (j in rowid){
                                dbGetQuery(con,sprintf("update coding set status=0 where rowid=%i", j))  }
                               ## better to get around the loop by sqlite condition expression.
                               codings_index$status[codings_index$rowid==rowid] <- 0
                               assign("codings_index",h$action$env)
                               ClearMark(W,min=sel_index$startN,max=sel_index$endN)
                               ## This clear all the marks in the gtext window, even for the non-current code. can improve.
                             }}},
                             action=list(env=.rqda,conName="qdacon",widget=".openfile_gui",codings_index="codings_index")
                             )

.codes_button[2,3]<- gbutton("Mark",
                             handler=function(h,...) {
    if (is_projOpen(env=h$action$env,conName=h$action$conName)) {
                               tryCatch({
                                ## browser()
                                ans <- mark(get(h$action$widget,env=h$action$env))
                                if (ans$start != ans$end){ 
                                ## when selected no text, makes on sense to do anything.
                                currentCid <- get("currentCid",h$action$env)
                                currentFid <- get("currentFid",h$action$env)
                                DAT <- data.frame(cid=currentCid,fid=currentFid,seltext=ans$text,
                                                  selfirst=ans$start,selend=ans$end,status=1)
                                con <- get(h$action$conName,h$action$env)
                                success <- dbWriteTable(con,"coding",DAT,row.name=FALSE,append=TRUE)
                                if (!success) gmessage("Fail to write to database.")
                                ## further testing: update codings_index in .rqda env.
                                codings_index <- dbGetQuery(con,"select rowid, cid, fid, selfirst, selend, status from coding where status=1")
                                assign("codings_index", codings_index, h$action$env) 
                                ## end furthing testing
                                }
                              },error=function(e){})
                             }},
                             action=list(env=.rqda,conName="qdacon",widget=".openfile_gui")
                             )

##.codes_button[2,4]<- gbutton("HL SEL",
##                             handler=function(h,...) {
##   sel_index <- dbGetQuery(qdacon, "select selfirst, selend, cid  from coding")
##   ClearMark(.marktxt_rqda,max(sel_index[,2]))
##   sel_index <- subset(sel_index,cid==currentCid,selection=c("selfirst","selend"))
##   HL(.marktxt_rqda,index=sel_index)
##                             })

".codes_rqda" <- gtable("Please click Update",container=.codes_pan)
.codes_rqda[] <- NULL 


addHandlerClicked(.codes_rqda,handler <- function(h,...){
  ## without it, button mark doesn't work due to lack of currentCid.
  ## BUG: only clear the mark but not highlight the selected text chunk.
  codes_index <- get(h$action$fileName, h$action$env)
  assign("currentCode",svalue(.codes_rqda),env=h$action$env) ## current code
  currentCode <- get("currentCode", h$action$env)
  currentCid <- codes_index[codes_index[["name"]] == currentCode, "id", drop = TRUE]
  if (is.null(currentCid)) currentCid <- integer(0)
  assign("currentCid", currentCid, env = h$action$env)
  ## above code: update the meta data -- CurrentCode and Current code id.
  ## following code: Only mark the text chuck according to the current code.
  currentFid <- get("currentFid", h$action$env)
  tryCatch({
    widget <- get(h$action$marktxtwidget,h$action$env)
    ## if widget is not open, then error;which means no need to highlight anything.
    con <- get(h$action$conName,h$action$env)
    sel_index <- dbGetQuery(con, sprintf("select selfirst, selend, cid, status from coding where fid=%i",currentFid))
    Maxindex <- max(sel_index["selend"],na.rm=TRUE)  
    sel_index <- sel_index[(sel_index$cid==currentCid & sel_index$status==1),c("selfirst","selend")]
    ClearMark(widget,min=0,max=Maxindex)
  if (nrow(sel_index)>0){
    HL(widget,index=sel_index)
  }
  },error=function(e){})
},action=list(env=.rqda,fileName="codes_index",conName="qdacon",marktxtwidget=".openfile_gui"
    )
                  )


addHandlerMouseMotion(.codes_rqda, handler <- function(h, 
                                                       ## updating the codes name list.
                                                       ...) {
  if (is_projOpen(env = h$action$env, conName = h$action$conName,message = FALSE)) {
    ##    cat("Mouse Motion updated.", fill = TRUE)
    codesupdate(conName = h$action$conName, assignenv = h$action$env, 
                assignfileName = h$action$assignfileName,widget=h$action$widget)
  }
}, action = list(env = .rqda, conName = "qdacon", assignfileName = "codes_index",widget=.codes_rqda))


addhandlerdoubleclick(.codes_rqda,handler <- function(h,...){
  codes_index <- get(h$action$fileName, h$action$env)
  assign("currentCode",svalue(.codes_rqda),env=h$action$env) ## current code
  currentCode <- get("currentCode", h$action$env)
  currentFid <- get("currentFid", h$action$env)
  currentCid <- codes_index[codes_index[["name"]] == currentCode, "id", drop = TRUE]
  if (is.null(currentCid)) currentCid <- integer(0)
  assign("currentCid", currentCid, env = h$action$env)
  ## above code: update the meta data -- CurrentCode and Current code id.
  ## following code: Only mark the text chuck according to the current code.
  tryCatch({
    widget <- get(h$action$marktxtwidget,h$action$env)
    ## if widget is not open, then error;which means no need to highlight anything.
    con <- get(h$action$conName,h$action$env)
    sel_index <- dbGetQuery(con, sprintf("select selfirst, selend, cid, status from coding where fid=%i",currentFid))
    Maxindex <- max(sel_index["selend"],na.rm=TRUE)  
    sel_index <- sel_index[(sel_index$cid==currentCid & sel_index$status==1),c("selfirst","selend")]
    ClearMark(widget,min=0,max=Maxindex)
if (nrow(sel_index)>0){
    HL(widget,index=sel_index)}
  },error=function(e){})
},action=list(env=.rqda,fileName="codes_index",conName="qdacon",marktxtwidget=".openfile_gui"
    )
                  )



########################### GUI for CODES TREE
###########################
#".codes_tree" <- gpanedgroup(container=.nb_rqdagui,horizontal=FALSE,label="Codes Tree")
#".codes_tree_pg" <- gpanedgroup(cont=.codes_tree,horizontal = FALSE)
#ct_buttons <- glayout(con=.codes_tree_pg)
#ct_buttons[1,1] <- gbutton("ADD",handler=function(h,...){
#item <- ginput("Enter Level 2 label! ", icon="info",parent=.codes_tree)
#Encoding(item) <- "UTF-8"
#ct_gt1[] <- c(item,ct_gt1[][!is.na(ct_gt1[])])
#})
#ct_buttons[1,2] <- gbutton("Delete")
#ct_buttons[1,3] <- gbutton("OK")
#ct_buttons[1,4] <- gl <- glabel("")
#ct_pg2 <- ggroup(cont=.codes_tree_pg,horizontal = FALSE)
#ct_gt1 <- gtable(data.frame("Level 2 Categories"="Categories",stringsAsFactors=FALSE),con=ct_pg2,multiple=FALSE,expand=TRUE)
#ct_gt1[] <- NULL
#ct_gt2 <- gtable(data.frame("Codes in current Category"="Category",stringsAsFactors=FALSE),container=ct_pg2,expand=T)
#ct_gt2[] <- NULL
#ct_gt3 <- gtable(data.frame("Codes List"="env$files_index$name",stringsAsFactors=FALSE),container=ct_pg2,multiple=TRUE,expand=T)
#ct_gt3[] <- NULL

#########################
#########################
visible(.root_rqdagui) <- TRUE
svalue(.nb_rqdagui) <- 1 ## make sure the project tab gain the focus.
### make it a function RQDA().
}

