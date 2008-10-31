importfile <- function(path,#pathEncoding="unknown",
                       encoding,con="qdacon",assignenv=NULL,assigname="files_index", ...){
## import a file into a DBI connection _con_.
#  readTXT <- function(path){
#    ## read txt file into a one-length character vector.
#    if (.Platform$OS.type=="windows"){
#	readChar(path,file.info(path)[,'size']+1000,TRUE)
#    } else readChar(path,file.info(path)[,'size']+1000)
#  }
#
  enc <- function(x) gsub("'", "''", x)
  ## replace " with two '. to make insert smoothly.

  #Encoding(path) <- pathEncoding
  Fname <- gsub("\\.[[:alpha:]]*$","",basename(path)) ## remove the suffix such as .txt
  
  if ( Fname!="" ) {
    content <- readLines(path,warn=FALSE,encoding=encoding)
    content <- paste(content,collapse="\n")
    #Encoding(content) <- contentEncoding
    content <- enc(content)
    maxid <- dbGetQuery(con,"select max(id) from source")[[1]]
    nextid <- ifelse(is.na(maxid),0+1, maxid+1)
    write <- FALSE
    ## if the content should be written into con.
    if (nextid==1) {
      write <- TRUE
    } else {
      allFnames <- RSQLite:::sqliteQuickColumn(con,"source","name")
      if (!any(Fname==allFnames)) {
        write <- TRUE
      } else {
            gmessage("A file withe the same name exists in the database!")
            }
      }
      if (write ) {
        dbGetQuery(con,sprintf("insert into source (name, file, id, status ) values ('%s', '%s',%i, %i)",
                               Fname,content, nextid, 1))
      } 
    if (!is.null(assignenv)) {
      assign(assigname, dbGetQuery(con,"select name,id from source"), env=assignenv)
    }
  }
}


fnamesupdate <- function(conName="qdacon",assignenv=.rqda,assignfileName="files_index",widget=".fnames_rqda",...){
 ##update file names list.
 ## should have widget argument, or the ".fnames_rqda" cannot be found.
 con <- get(conName,assignenv)
 fnames <- dbGetQuery(con, "select name, id from source where status=1")
 assign(assignfileName, fnames ,env=assignenv) 
 tryCatch(widget[] <- fnames[['name']],error=function(e){})
}

setEncoding <- function(encoding="unknown"){
# specify what encoding is used in the imported files.
.rqda$encoding <- encoding
}


