importfile <- function(path,pathEncoding="unknown",con="qdacon",assignenv=NULL,assigname="files_index", ...){
  ## import a file into a DBI connection _con_.
  readTXT <- function(path){
    ## read txt file into a one-length character vector.
    readChar(path,file.info(path)[,'size']+1000,TRUE)
  }
  
  enc <- function(x) gsub("'", "''", x)
  ## replace " with two '. to make insert smoothly.

  Encoding(path) <- pathEncoding
  Fname <- basename(path)
  
  if ( Fname!="" ) {
    content <- readTXT(path)
    content <- enc(content)
    maxid <- dbGetQuery(con,"select max(id) from source")[[1]]
    nextid <- ifelse(is.na(maxid),0+1, maxid+1)
    write <- FALSE
    ## if the content should be written into con.
    if (nextid==1) {
      write <- TRUE
    } else {
     ## browser()
      allFnames <- RSQLite:::sqliteQuickColumn(con,"source","name")
      if (!any(Fname==allFnames)) {
        write <- TRUE
      }}
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
 fnames <- dbGetQuery(con, "select name, id from source")
 assign(assignfileName, fnames ,env=assignenv) 
 tryCatch(widget[] <- fnames[['name']],error=function(e){})
}

