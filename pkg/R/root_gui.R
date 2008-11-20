RQDA <- function() {
########################### aux functions
########################### 
  NI <- function(...){
    gmessage("Not Implemented Yet.",con=TRUE)
  }


  
########################### GUI FOR ROOT
########################### 
  ".root_rqdagui" <- gwindow(title = "RQDA: Qualitative Data Analysis.",parent=c(10,10),
                             width=300,height=600,visible=FALSE,handler=function(h,...){
                               tryCatch(dispose(.rqda$.root_edit),error=function(e){})
                               close_proj(assignenv=.rqda)
                             }
                             )

  
  ".nb_rqdagui" <- gnotebook(4,container=.root_rqdagui,closebuttons=FALSE)
  
  
  
########################### GUI FOR PROJECT
########################### 
  ".proj_gui" <- ggroup(container=.nb_rqdagui,horizontal=FALSE,label="Project")

  ".newproj_gui" <- gbutton("New Project",container=.proj_gui,handler=function(h,...){
    path=gfile(type="save") 
    if (path!=""){
      ## if path="", then click "cancel".
      Encoding(path) <- "UTF-8"
      new_proj(path,assignenv=.rqda)}
  }
                            )
  
  
  ".open.proj_gui" <- gbutton("Open Project",container=.proj_gui,handler=function(h,...){
    path <- gfile(type="open",filter=list("rqda"=list(patterns = c("*.rqda","*.*"))))
    if (path!=""){
      Encoding(path) <- "UTF-8"
      open_proj(path,assignenv=.rqda)
      tryCatch(CodeNamesUpdate(),error=function(e){})
      tryCatch(FileNamesUpdate(),error=function(e){})
      tryCatch(CaseNamesUpdate(),error=function(e){})
    }
  }
                              )
  
  ".project_memo" <- Proj_MemoButton(label = "Porject Memo", container = .proj_gui)
  ## project memo button
  
  ".close.proj_gui" <- gbutton("Close Project",container=.proj_gui,handler=function(h,...){
      close_proj(assignenv=.rqda)
      tryCatch(.rqda$.codes_rqda[]<-NULL,error=function(e){})
      tryCatch(.rqda$.fnames_rqda[]<-NULL,error=function(e){})
      tryCatch(.rqda$.CasesNamesWidget[]<-NULL,error=function(e){})
  }
                               )

  
  ".projinfo_gui" <- gbutton("Current Project",container=.proj_gui,handler=function(h,...){
    if (is_projOpen(env=.rqda,conName="qdacon")) {
      con <- .rqda$qdacon
      dbname <- dbGetInfo(.rqda$qdacon)$dbname
      ##substr(dbname, nchar(dbname)-15,nchar(dbname))
      gmessage(dbname,title="Info about current project.",con=TRUE)
    }
  },
                             action=list(env=.rqda,conName="qdacon")
                             )


  glabel("Basic Usage of RQDA:\n
1. New Project or Open project.\n
2. Import files.\n
3. Add codes.\n
4. Open a file and begin coding.\n
Author: <ronggui.huang@gmail.com>\n
This software is part of my PhD research.\n",
         container=.proj_gui)



########################### GUI for FILES 
###########################
  ".files_pan" <- gpanedgroup(container=.nb_rqdagui,horizontal=FALSE,label="Files")
  ".files_button" <- ggroup(container=.files_pan,horizontal=TRUE)
  ".fnames_rqda" <- gtable("Click Here to see the File list.",container=.files_pan)
  .fnames_rqda[] <-NULL # get around of the text argument.
  ImportFileButton("Import",con=.files_button)
  DeleteFileButton("Delete",con=.files_button)
  ViewFileButton("Open",con=.files_button)
  File_MemoButton(label="F-Memo", container=.files_button,FileWidget=.fnames_rqda)
  ## memo button of selected file. The code of File_Memo buttion has been moved into memo.R
  File_RenameButton(label="Rename", container=.files_button,FileWidget=.fnames_rqda)
  ## rename a selected file.

   
########################### GUI for CODES
###########################
  ".codes_pan" <- gpanedgroup(container=.nb_rqdagui,horizontal=FALSE,label="Codes")
  ".codes_button" <- glayout(container=.codes_pan)
  ".codes_rqda" <- gtable("Please click Update",container=.codes_pan)
  .codes_rqda[] <- NULL 
  .codes_button[1,1]<- AddCodeButton()
  .codes_button[1,2]<- DeleteCodeButton()
  .codes_button[1,3] <- FreeCode_RenameButton(label="Rename",CodeNamesWidget=.codes_rqda)
  .codes_button[1,4] <- CodeMemoButton(label="C-Memo")
  .codes_button[1,5]<- CodingMemoButton(label="C2Memo")
  .codes_button[2,1]<- HL_ALLButton()
  .codes_button[2,2]<- RetrievalButton("Retrieval")
  .codes_button[2,3]<- RetrievalButton(label="Extend")
  .codes_button[2,4]<- Unmark_Button()
  .codes_button[2,5]<- Mark_Button()
  
    
######################### GUI  for cases
#########################
  ".case_pan" <- gpanedgroup(container=.nb_rqdagui,horizontal=FALSE,label="Case")
  ".case_buttons" <- glayout(container=.case_pan)
  ".CasesNamesWidget" <- gtable("Please click Update",container=.case_pan)
  .CasesNamesWidget[] <- NULL 
  .case_buttons[1,1] <- AddCaseButton()
  .case_buttons[1,2] <- DeleteCaseButton()
  .case_buttons[1,3] <- Case_RenameButton()
  .case_buttons[1,4] <- CaseMark_Button()
  .case_buttons[1,5] <- CaseMemoButton()

######################### GUI  for F-cat
#########################
   ".fcat_gui" <- ggroup(container=.nb_rqdagui,horizontal=FALSE,label="F-Cat")

######################### GUI  for C-cat
#########################
  ".codecat_gui" <- ggroup(container=.nb_rqdagui,horizontal=FALSE,label="C-Cat")

######################### GUI  for settings
#########################
   ".settings_gui" <- ggroup(container=.nb_rqdagui,horizontal=FALSE,label="Settings")

  
######################### Put them together
#########################
  visible(.root_rqdagui) <- TRUE
  svalue(.nb_rqdagui) <- 1 ## make sure the project tab gain the focus.

##########################
## add documentation here
assign(".root_rqdagui",.root_rqdagui,env=.rqda)
assign(".files_button",.files_button,env=.rqda)
assign(".codes_rqda",.codes_rqda,env=.rqda)
assign(".fnames_rqda",.fnames_rqda,env=.rqda)
assign(".CasesNamesWidget",.CasesNamesWidget,env=.rqda)
 
##########################
Handler()
}
## end of function RQDA

