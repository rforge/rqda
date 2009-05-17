## "back.col" "BOM"      "encoding" "fore.col" "owner"
addSettingGUI <- function(container,width=12){
Setting <- list(type = "ggroup",
              horizontal = FALSE,
              children = list(
                list(type="fieldset",
                     columns = 1,
                     label = "Settings",
                     label.pos = "top",
                     label.font = c(weight="bold"),
                     children = list(
                       list(name = "owner",
                            label = "Name of Coder",
                            type = "gedit",width=width,
                            text = .rqda$owner
                            ),
                       list(name = "encoding",
                            label = "File Encoding",
                            type = "gedit",width=width,
                            text = .rqda$encoding
                            ),
                       list(name = "BOM",
                            label = "Byte Order Mark",
                            type = "gcombobox",## width=width,
                            items = c(FALSE, TRUE)
                            ),
                      list(name = "SFP",
                           label = "Show File Property",
                           type = "gcombobox",## width=width,
                           items = c(FALSE, TRUE)
                           ),
                       list(name = "fore.col",
                            label = "Color for Coding",
                            type = "gedit",width=width,
                            text = .rqda$fore.col
                            ),
                       list(name = "back.col",
                            label = "Color for Case",
                            type = "gedit",width=width,
                            text = .rqda$back.col
                            ),
                      list(name = "TOR",
                           type="gcombobox",
                           label = "Type of Retrieval",
                           items = c(.rqda$TOR, "case", "filecategory")
                           )
                       )
                     )
                )
                )


##

SettingFL <- gformlayout(Setting, cont = container, expand=TRUE)

ButtonContainer <- ggroup(cont = container) ##, width=100) ## not necessary to set width here
addSpring(ButtonContainer)
resetButton <- gbutton("Default", cont = ButtonContainer)
okButton <- gbutton("OK", cont = ButtonContainer)

addHandlerChanged(okButton, function(h,...) {
    out <- svalue(SettingFL)
    tryCatch(ClearMark(.rqda$.root_edit,0,nchar(svalue(.rqda$.openfile_gui)),TRUE,TRUE),error=function(e){})
    for (i in names(out)) assign(i,out[[i]],env=.rqda)
})

addHandlerChanged(resetButton, function(h,...) {
  tryCatch(ClearMark(.rqda$.root_edit,0,nchar(svalue(.rqda$.openfile_gui)),TRUE,TRUE),error=function(e){})
  tryCatch(svalue(SettingFL[]$BOM) <- FALSE,error=function(e){})
  tryCatch(svalue(SettingFL[]$SFP) <- FALSE,error=function(e){})
  tryCatch(svalue(SettingFL[]$encoding) <- "unknown",error=function(e){})
  tryCatch(svalue(SettingFL[]$owner) <- "default",error=function(e){})
  tryCatch(svalue(SettingFL[]$back.col) <- "gold",error=function(e){})
  tryCatch(svalue(SettingFL[]$fore.col) <- "blue",error=function(e){})
  tryCatch(svalue(SettingFL[]$TOR) <- "unconditional",error=function(e){})
  assign("BOM",FALSE,env=.rqda)
  assign("SFP",FALSE,env=.rqda)
  assign("encoding","unknown",env=.rqda)
  assign("owner","default",env=.rqda)
  assign("back.col","gray92",env=.rqda)
  assign("fore.col","blue",env=.rqda)
  assign("TOR","unconditional",env=.rqda)
})}

