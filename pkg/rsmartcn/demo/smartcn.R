smartcn("这是一个中文分词软件")

cht <- "這是一個中文分詞軟件"
cht <- iconv(cht,to="UTF-8")
smartcn(zhConv(cht,dic$zh2Hans))
