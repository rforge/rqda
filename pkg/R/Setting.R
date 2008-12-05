## "back.col" "BOM"      "encoding" "fore.col" "owner"
addSettingGUI <- function(container){
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
                            type = "gedit",
                            text = .rqda$owner
                            ),
                       list(name = "encoding",
                            label = "File Encoding",
                            type = "gedit",
                            text = .rqda$encoding
                            ),
                       list(name = "fore.col",
                            label = "Color for Coding",
                            type = "gedit",
                            text = .rqda$fore.col
                            ),
                       list(name = "back.col",
                            label = "Color for Case",
                            type = "gedit",
                            text = .rqda$back.col
                            ),
                       list(name = "BOM",
                            label = "BOM",
                            type = "gcombobox",
                            items = c(FALSE, TRUE)
                            )

                       )
                     )
                )
                )


##

SettingFL <- gformlayout(Setting, cont = container, expand=TRUE)

ButtonContainer <- ggroup(cont = container)
addSpring(ButtonContainer)
resetButton <- gbutton("Default", cont = ButtonContainer)
okButton <- gbutton("OK", cont = ButtonContainer)

addHandlerChanged(okButton, function(h,...) {
  out <- svalue(SettingFL)
  ##print(out)
  for (i in names(out)) assign(i,out[[i]],env=.rqda)
})

addHandlerChanged(resetButton, function(h,...) {
  tryCatch(svalue(SettingFL[]$BOM) <- FALSE,error=function(e){})
  tryCatch(svalue(SettingFL[]$encoding) <- "unknown",error=function(e){})
  tryCatch(svalue(SettingFL[]$owner) <- "default",error=function(e){})
  tryCatch(svalue(SettingFL[]$back.col) <- "gray92",error=function(e){})
  tryCatch(svalue(SettingFL[]$fore.col) <- "blue",error=function(e){})
  assign("BOM",FALSE,env=.rqda)
  assign("encoding","unknown",env=.rqda)
  assign("owner","default",env=.rqda)
  assign("back.col","gray92",env=.rqda)
  assign("fore.col","blue",env=.rqda)
})}

