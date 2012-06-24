cn_scan_tokenizer <- function(x, cws="mmseg4j"){
    cws <- match.fun("mmseg4j")
    tokens <- scan_tokenizer(cws(x))
    tokens
}


cn_MC_tokenizer <- function(x, cws="mmseg4j"){
    cws <- match.fun("mmseg4j")
    tokens <- MC_tokenizer(cws(x))
    tokens
}


