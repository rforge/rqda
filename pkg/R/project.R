new_proj <- function(path, conName="qdacon",assignenv=.rqda,...){
   sucess <- file.create(tmpNamme <- tempfile(pattern = "file", tmpdir = dirname(path)))
  if (!sucess) {
   gmessage("No write permission.",icon="error",container=TRUE) 
    }
   else{
    unlink(tmpNamme)
    path <- paste(gsub("\\.rqda$","",path),"rqda",sep=".") # deal with the ".rqda"
    override <- FALSE
    if (fexist <- file.exists(path)) override <- gconfirm("Over write existing project?",icon="warning")
    if (!fexist | override ){
    ## close con in assignmenv first.
      tryCatch(close_proj(conName=conName,assignenv=assignenv),error=function(e){})
      assign(conName,dbConnect(drv=dbDriver("SQLite"),dbname=path),envir=assignenv)
      con <- get(conName,assignenv)
      if (dbExistsTable(con,"source")) dbRemoveTable(con, "source")
      dbGetQuery(con,"create table source (name text, id integer, file text, memo text, status integer)")
      if (dbExistsTable(con,"freecode")) dbRemoveTable(con, "freecode")
      dbGetQuery(con,"create table freecode  (name text, memo text, id integer, status integer)")
      if (dbExistsTable(con,"treecode")) dbRemoveTable(con, "treecode")
      dbGetQuery(con,"create table treecode  (cid integer, catid integer)")
      if (dbExistsTable(con,"treefile")) dbRemoveTable(con, "treefile")
      dbGetQuery(con,"create table treefile  (fid integer, catid integer)")
      if (dbExistsTable(con,"fcat")) dbRemoveTable(con, "fcat")
      dbGetQuery(con,"create table fcat  (fid integer, catid integer)")
      if (dbExistsTable(con,"ccat")) dbRemoveTable(con, "ccat")
      dbGetQuery(con,"create table ccat  (cid integer, catid integer)")
      if (dbExistsTable(con,"coding")) dbRemoveTable(con, "coding")
      dbGetQuery(con,"create table coding  (cid integer, fid integer,seltext text, selfirst real, selend real, status integer)")
    }
  }
}


open_proj <- function(path,conName="qdacon",assignenv=.rqda,...){
  tryCatch({ con <- get(conName,assignenv)
   if (isIdCurrent(con)) dbDisconnect(con)
       },
  error=function(e){})
  ## Fist close the con if it exist, then open a new con.
  assign(conName, dbConnect(drv=dbDriver("SQLite"),dbname=path),envi=assignenv)
}



close_proj <- function(conName="qdacon",assignenv=.rqda,...){
  tryCatch({
  con <- get(conName,assignenv)
  if (isIdCurrent(con)) {
    if (!dbDisconnect(con)) gmessage("Closing project failed.",icon="waring",con=TRUE)
  }
  } ,error=function(e){})
}

is_projOpen <- function(env=.rqda,conName="qdacon",message=TRUE){
## test if any project is open.
 open <- FALSE
 tryCatch({
  con <- get(conName,env)
  open <- open + isIdCurrent(con)
  } ,error=function(e){}) 
if (!open & message) gmessage("No Project is Open.",icon="warning",con=TRUE)
return(open)
}
