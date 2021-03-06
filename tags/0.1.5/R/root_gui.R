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
  ".newproj_gui" <- NewProjectButton(container=.proj_gui)
  ".open.proj_gui" <- OpenProjectButton(container=.proj_gui)
  ".project_memo" <- Proj_MemoButton(label = "Porject Memo", container = .proj_gui)
  ## project memo button
  ".close.proj_gui" <- CloseProjectButton(container=.proj_gui)
  ".projinfo_gui" <- ProjectInforButton(container=.proj_gui)

  glabel("Basic Usage of RQDA:\n
1. New Project or Open project.\n
2. Import files.\n
3. Add codes.\n
4. Open a file and begin coding.\n
Author: <ronggui.huang@gmail.com>\n
License: FreeBSD\n
Version: 0.1.5\n",
         container=.proj_gui)



########################### GUI for FILES 
###########################
  ".files_pan" <- gpanedgroup(container=.nb_rqdagui,horizontal=FALSE,label="Files")
  ".files_button" <- ggroup(container=.files_pan,horizontal=TRUE)
  ".fnames_rqda" <- gtable("Click Here to see the File list.",container=.files_pan)
  .fnames_rqda[] <-NULL # get around of the text argument.
  names(.fnames_rqda) <- "Files"
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
  .codes_rqda[] <- NULL ;names(.codes_rqda) <- "Codes List"
  .codes_button[1,1]<- AddCodeButton()
  .codes_button[1,2]<- DeleteCodeButton()
  .codes_button[1,3] <- FreeCode_RenameButton(label="Rename",CodeNamesWidget=.codes_rqda)
  .codes_button[1,4] <- CodeMemoButton(label="C-Memo")
  .codes_button[1,5]<- CodingMemoButton(label="C2Memo")
  .codes_button[2,1]<- HL_ALLButton()
  .codes_button[2,2]<- RetrievalButton("Retrieval")
  .codes_button[2,3]<- gbutton("Extend",handler=function(h,...)NI())
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
  ##.case_buttons[2,3] <- AddWebSearchButton("WebSearch") # use popup menu instead
  

######################### GUI  for C-cat
#########################
  ".codecat_pan" <- gpanedgroup(container=.nb_rqdagui,horizontal=FALSE,label="C-Cat")
  ".codecat_buttons" <- glayout(container=.codecat_pan)
  ".Ccat_PW" <- ggroup(cont=.codecat_pan,horizontal = FALSE)## parent Widget of C-cat
  ".CodeCatWidget" <- gtable("Please click Update",container=.Ccat_PW,expand=TRUE)
   .CodeCatWidget[] <- NULL; names(.CodeCatWidget)<-"Code Category"
   ".CodeofCat" <- gtable("Please click Update",container=.Ccat_PW,expand=TRUE,multiple=TRUE)
   .CodeofCat[] <- NULL;names(.CodeofCat)<-"Codes of This Category"
   .codecat_buttons[1,1] <- AddCodeCatButton("Add")
   .codecat_buttons[1,2] <- CodeCat_RenameButton("Rename")
   .codecat_buttons[1,3] <- DeleteCodeCatButton("Delete") ## should take care of treecode table
   .codecat_buttons[1,4] <- CodeCatAddToButton("AddTo")
   .codecat_buttons[1,5] <- CodeCatDropFromButton("DropFrom")

######################### GUI  for F-cat
#########################
##   ".fcat_gui" <- ggroup(container=.nb_rqdagui,horizontal=FALSE,label="F-Cat")

######################### GUI  for settings
#########################
##   ".settings_gui" <- ggroup(container=.nb_rqdagui,horizontal=FALSE,label="Settings")

  
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
assign(".CodeCatWidget",.CodeCatWidget,env=.rqda)
assign(".CodeofCat",.CodeofCat,env=.rqda)

##########################
### set the positions
svalue(.codes_pan) <- 0.1
svalue(.codecat_pan)<-0.035
svalue(.case_pan)<-0.035

##########################
Handler()
}
## end of function RQDA

