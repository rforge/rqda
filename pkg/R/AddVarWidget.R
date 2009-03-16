AddVarWidget <- function(ExistingItems=NULL,container=NULL,title=NULL,...){
  ## modified from RGtk2 package
  ## ExistingItems: existing data set for a case/file etc.
  ## container: similar to that of gWidget package.
  COLUMN <- c(Variable = 0, Value = 1,  editable = 2)
  articles <- NULL
  
  create.model <- function()
    {
      ## create the array of data
      articles <<- list()
      ##  create list store
      model <- gtkListStoreNew( "gchararray", "gchararray", "gboolean")
      ## add item from ExistingItems
      ## needs modification
      if (!is.null(ExistingItems)){
        for (i in 1:length(articles))
          {
            iter <- model$append()$iter
            model$set(iter, COLUMN["Variable"], articles[[i]]$Variable,
                      COLUMN["Value"], articles[[i]]$Value,
                      COLUMN["editable"], articles[[i]]$editable)
          }
      }
      return(model)
    }
  
  add.item <- function(button, data)
    {
      stopifnot(!is.null(articles))
      foo <- list(Variable = "New Var Name", Value = "NA", editable = TRUE)
      articles <<- c(articles, foo)
      iter <- model$append()$iter
      model$set(iter, COLUMN["Variable"], foo$Variable,
                COLUMN["Value"], foo$Value,
                COLUMN["editable"], foo$editable)
    }
  
  remove.item <- function(widget, data)
    {
      checkPtrType(data, "GtkTreeView")
      treeview <- data
      model <- treeview$getModel()
      selection <- treeview$getSelection()
      selected <- selection$getSelected()
      if (selected[[1]])
        {
          iter <- selected$iter
          path <- model$getPath(iter)
          i <- path$getIndices()[[1]]
          model$remove(iter)
          articles <<- articles[-i]
        }
    }
  
  cell.edited <- function(cell, path.string, new.text, data)
    {
      checkPtrType(data, "GtkListStore")
      model <- data
      path <- gtkTreePathNewFromString(path.string) 
      column <- cell$getData("column")
      iter <- model$getIter(path)$iter
      switch(column+1,
             {
               old.text <- model$get(iter, column)
               i <- path$getIndices()[[1]]+1
               articles[[i]]$Variable <<- new.text
               model$set(iter, column, articles[[i]]$Variable)
             },
             {
               i <- path$getIndices()[[1]]+1
               articles[[i]]$Value <<- new.text
               model$set(iter, column, articles[[i]]$Value)
             }
             )
    }
  
  add.columns <- function(treeview)
    {
      model <- treeview$getModel()
      ## Variable column
      renderer <- gtkCellRendererTextNew()
      gSignalConnect(renderer, "edited", cell.edited, model)
      renderer$setData("column", COLUMN["Variable"])
      treeview$insertColumnWithAttributes(-1, "Variable", renderer,text = COLUMN[["Variable"]], editable = COLUMN[["editable"]])
      ## Value column
      renderer <- gtkCellRendererTextNew()
      gSignalConnect(renderer, "edited", cell.edited, model)
      renderer$setData("column", COLUMN["Value"])
      treeview$insertColumnWithAttributes(-1, "Value", renderer, text = COLUMN[["Value"]],editable = COLUMN[["editable"]])
    }
  
  save.project <- function(button){
    ## push dataset into project file.
    cat("testing.\n")
  }
  
  ## create window, etc
  window <- gtkWindowNew("toplevel", show = F)
  window$setTitle(paste("Var:",title))
  window$setBorderWidth(5)
  vbox <- gtkVBoxNew(FALSE, 5)
  window$add(vbox)
  sw <- gtkScrolledWindowNew(NULL, NULL)
  sw$setShadowType("etched-in")
  sw$setPolicy("automatic", "automatic")
  vbox$packStart(sw, TRUE, TRUE, 0)
  ## create model
  model <- create.model()
  ## create tree view
  treeview <- gtkTreeViewNewWithModel(model)
  treeview$setRulesHint(TRUE)
  treeview$getSelection()$setMode("single")
  add.columns(treeview)
  sw$add(treeview)
  ## some buttons
  hbox <- gtkHBoxNew(TRUE, 4)
  vbox$packStart(hbox, FALSE, FALSE, 0)
  button <- gtkButtonNewWithLabel("Add")
  gSignalConnect(button, "clicked", add.item, model)
  hbox$packStart(button, TRUE, TRUE, 0)
  button <- gtkButtonNewWithLabel("Remove")
  gSignalConnect(button, "clicked", remove.item, treeview)
  hbox$packStart(button, TRUE, TRUE, 0)
  button <- gtkButtonNewWithLabel("Save")
  gSignalConnect(button, "clicked",save.project)
  hbox$packStart(button, TRUE, TRUE, 0)
  window$setDefaultSize(150, 350)
  window$showAll()
  invisible(window)
}

##var <- AddVarWidget()
## var$Destroy() ## close
