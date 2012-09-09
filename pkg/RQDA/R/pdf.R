importPDF <- function(file, type=c("higjlight")){
    if (missing(file)) {
        file <- gfile(text="select a pdf file", type="open", filter=list("PDF"=list(patterns=c("*.PDF"))))
    }
    fileName <- basename(file)
    fileName <- enc(fileName)
    maxid <- RQDAQuery("select max(id) from source")[[1]]
    nextid <- ifelse(is.na(maxid),0+1, maxid+1)
    write <- FALSE
    if (nextid==1) {
        write <- TRUE
    } else {
        if (nrow(RQDAQuery(sprintf("select name from source where name='%s'", fileName)))==0) {
            write <- TRUE
        } else {
            gmessage("A file withe the same name exists in the database!")
        }
    }
    if (write ) {
        ans <- pdfutils:::extractHL(file)
        RQDAQuery(sprintf("insert into source (name, file, id, status,date,owner )
                             values ('%s', '%s',%i, %i, '%s', '%s')",
                          fileName,enc(ans), nextid, 1, date(), .rqda$owner))
        FileNamesUpdate()
    }
}
