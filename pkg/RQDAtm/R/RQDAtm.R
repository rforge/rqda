# tm-adtFR.R
# J-P Müller, SSP/ UNIL, jean-pierre.mueller@unil.ch
# version 1.1 du 13 mars 2009
# distributed under the terms of the GNU General Public License Version 2, June 1991.
# http://wwwpeople.unil.ch/jean-pierre.mueller/ATO_avec_R_files/tm-adtFR.R

setGeneric("FRtreetager", function(object, keep = c("word", "pos", "lemma") , reduce = TRUE, sep = "/", bef = "",  aft = "", ... ) standardGeneric("FRtreetager"))

setMethod("FRtreetager",
			signature(object = "PlainTextDocument"),
			function(object, keep = c("word", "pos", "lemma") , reduce = TRUE, sep = "/", bef = "",  aft = "", ... ) {
				zz <- file("~/treein.txt", "w", enc="latin1")
				cat(Content(object), file=zz)
				close(zz)
				system("~/cmd/tree-tagger-french ~/treein.txt  >treeout.txt ", ignore.stderr=TRUE)
				con <- file("~/treeout.txt",  encoding="latin1")
				toout <-  read.csv(con, header = FALSE, sep="\t", stringsAsFactors = FALSE)
				u <- NULL
				if("word" %in% keep)
				{
					u <- cbind(u, toout[,1])
				}
				if("pos" %in% keep)
				{
					u <- cbind(u, toout[,2])
				}
				if("lemma" %in% keep)
				{
					u <- cbind(u, toout[,3])
				}
				vv <- apply(u, 1 , paste, collapse = sep)
				vv <- paste( bef, vv, aft)
				if (reduce)
			    {
			    	Content(object) <- paste(vv, collapse = " ")
			    }
			    else
			    {
					Content(object) <- vv
				}
				return(object)
			}
	)


splitDoc <- function(corpus, words= 30,  keep.sent=FALSE, keep.par.bound=TRUE) {
	require("tm", quietly = TRUE)
    spl.docs <- NULL
	new.DMD <- NULL
	DMD <- DMetaData(corpus)
	DMD <- data.frame(DMD, ID.ori = row.names(DMD))
    for (k in seq_along(corpus)) {
        c.k <- corpus[[k]]
    	if ((keep.par.bound)|(length(c.k)==1)) {
    		c.k <- unlist(strsplit(c.k, "\r"))
    		c.k <- c.k[nchar(c.k)!=0]
        }
        if (!keep.par.bound) {
    		c.k <- paste(c.k,collapse=" ")
        }
        c.k <- c(c.k)
        s <- 1: length(c.k)
        for (i in s) {
            zz <- file("~/treein.txt", "w", enc="latin1")
			cat( c.k[i], file=zz)
			close(zz)
			system("~/cmd/tree-tagger-french ~/treein.txt  >treeout.txt ", ignore.stderr=TRUE)
			con <- file("~/treeout.txt",  encoding="latin1")
			tab.w.pos <- read.csv(con, header = FALSE, sep="\t", stringsAsFactors = FALSE)
			tab.w.pos$wc <- 0
            tab.w.pos[ (tab.w.pos[,2]!="PUN") & (tab.w.pos[,2]!="PUN:cit") & (tab.w.pos[,2]!="SENT"), "wc"] <- 1
            tab.w.pos$wc <- cumsum(tab.w.pos$wc)
            ss <- c( seq(1, tab.w.pos$wc[length(tab.w.pos$wc)], words) , tab.w.pos$wc[length(tab.w.pos$wc)] +1 )
            if (keep.sent) {
            	st.li <- tab.w.pos$wc[tab.w.pos[,2]=="PUN:cit"] +1
            	st.li <- c(1, (tab.w.pos$wc[tab.w.pos[,2]=="SENT"] +1 ), st.li , tab.w.pos$wc[length(tab.w.pos$wc)] +1 )
            	st.li <- sort(unique(st.li))
            	vs <- NULL
            	for (j in 1:(length(ss))) {
            		vs <- c(vs, st.li[ which.min( abs(st.li- ss[j]))])
      			}
      			ss <- vs
      			ss <- unique(ss)
            }
            zl <- NULL
            for (j in 1:(length(ss)-1)) {
            	start.v <- min( (1:nrow(tab.w.pos)) [tab.w.pos$wc == (ss[j])] )
            	end.v <-   min( c( nrow(tab.w.pos)+1 , (1:nrow(tab.w.pos)) [tab.w.pos$wc == (ss[j+1])] ) -1)
            	zt <- tab.w.pos[ start.v : end.v , 1]
            	zt <- paste(zt, collapse=" ")
            	zl <- c(zl, zt)
      		}
        	spl.docs <- c(spl.docs, zl)
			k.rep <- rep( k, length(zl) )
			r.DMD <- DMD[k.rep, ]
	new.DMD <- rbind(new.DMD, r.DMD)
        }
    }
	spl.docs <- Corpus( VectorSource(spl.docs), readerControl = list( language = "french"))
	row.names(new.DMD) <- NULL
	spl.docs <- appendMeta(spl.docs, dmeta = new.DMD)
    return(spl.docs)
}

speci.calc <- function (tle)  {
	rstle <- rowSums(tle)
	cstle <- colSums(tle)
	ttle <- sum(tle)
	nb <- matrix( cstle, dim(tle)[1], dim(tle)[2], byrow=TRUE )
	nech <- matrix( rstle, dim(tle)[1], dim(tle)[2], byrow=FALSE )
    spos <- phyper(as.matrix(tle)  - 1, nb, ttle - nb, nech, lower.tail = FALSE)
    sneg <- phyper(as.matrix(tle), nb, ttle-nb, nech, lower.tail = TRUE)
    specificite <- list( pos = spos, neg = sneg)
	return(specificite)
}

speci.extract <- function (speci, level)
{
    speci.cells <- which(speci <= (level) , arr.ind = TRUE)
    z <- NULL
    if (nrow(speci.cells) > 0) {
    o <- order(speci.cells[, 1])
    speci.cells <- speci.cells[o, ]
    z <- data.frame(Doc = rownames(speci)[speci.cells[, 1]],
    				Terms = colnames(speci)[speci.cells[, 2]],
    				p.value = speci[ speci.cells] )
    }
    return(z)
}

speci.indic <- function (tle, tab.ind)  {
	rstle <- rowSums(tle)
	cstle <- colSums(tle)
	ttle <- sum(tle)
	sum.ind <- matrix(0, nrow = ncol(tab.ind), ncol = ncol(tle))
	for (i in 1:ncol(tab.ind)) {
	sum.ind[i, ] <- colSums(tle[tab.ind[,i]==1, ])
	}
	nb <- matrix( cstle, dim(sum.ind)[1], dim(sum.ind)[2], byrow=TRUE )
	nech <- matrix( rowSums(sum.ind), dim(sum.ind)[1], dim(sum.ind)[2], byrow=FALSE )
    spos <- phyper(sum.ind  - 1, nb, ttle - nb, nech, lower.tail = FALSE)
    colnames(spos) <- colnames(tle)
	rownames(spos) <- colnames(tab.ind)
    sneg <- phyper(sum.ind, nb, ttle-nb, nech, lower.tail = TRUE)
    colnames(sneg) <- colnames(tle)
	rownames(sneg) <- colnames(tab.ind)
    specificite <- list( pos = spos, neg = sneg)
	return(specificite)
}

rep.mod <- function(tle, speci.col, tab.ind.col, n=5)
{
	u <- as.matrix(tle) %*% as.vector(speci.col)
	u[tab.ind.col== 0] <- NA
    z <- order(u, na.last=TRUE, decreasing=FALSE)
    z <- z[1:n]
	return(z)
}

RQDA2tm <- function(Code,language="eng"){
    ## require("tm", quietly = TRUE)
    retrieval <- NULL
    currentCode <- Code
    if (length(currentCode)!=0)
    {
        Encoding(currentCode) <- "UTF-8"
        currentCid <- RQDAQuery(sprintf("select id from freecode where name== '%s' ",currentCode))[1,1]
        ## reliable is more important
        if(!is.null(currentCid))
        {
            retrieval <- RQDAQuery(sprintf("select cid,fid, selfirst, selend,seltext from coding where status==1 and cid=%i",as.numeric(currentCid)))
            if (nrow(retrieval)!=0)
            {
                retrieval <-  retrieval[order( retrieval$fid),]
                fid <- unique(retrieval$fid)
                retrieval$fname <-""
                for (i in fid)
                {
                    FileName <- RQDAQuery(sprintf("select name from source where status==1 and id==%i",i))[['name']]
                    tryCatch(Encoding(FileName) <- "UTF-8",error=function(e){})
                    retrieval$fname[retrieval$fid==i] <- FileName
                }
                Encoding(retrieval$seltext) <-  Encoding(retrieval$fname) <- "UTF-8"
            }
        }
    }
    retrived <- tm:::Corpus(tm::VectorSource(retrieval$seltext), readerControl = list( language = language))
    retrieval$seltext <- NULL
    meta(retrived,tag=names(retrieval)) <- retrieval
    return(retrived)
}

setGeneric("tmcollapse", function(object, collapse=" ") standardGeneric("tmcollapse"))
setMethod("tmcollapse",
          	signature(object = "PlainTextDocument"),
          	function(object, collapse=" ") {
          		object <- paste(object, sep = "", collapse = collapse)
          		return(object)
          	}
		)



setGeneric("tm2RQDA", function(object) standardGeneric("tm2RQDA"))
setMethod("tm2RQDA",
          	signature(object = "Corpus"),
          	function(object) {
          		require("RQDA", quietly = TRUE)
          		u <- lapply(object,tmcollapse, collapse="\r")
          		names(u) <- 1:length(u)
          		write.FileList(u)
          	}
		)
