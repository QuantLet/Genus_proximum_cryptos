install.packages("coinmarketcapr", dependencies = TRUE)


library(coinmarketcapr)

market_today <- get_marketcap_ticker_all()
head(market_today[,1:15])

install.packages("treemap", dependencies=TRUE)

library(treemap)
df1 <- na.omit(market_today[,c('id','market_cap_usd')])
df1$market_cap_usd <- as.numeric(df1$market_cap_usd)
df1$formatted_market_cap <-  paste0(df1$id,'\n','$',
format(df1$market_cap_usd,big.mark = ',',scientific = F, trim = T))
treemap(df1, index = 'formatted_market_cap', 
vSize = 'market_cap_usd', title = 'Cryptocurrency Market Cap', fontsize.labels=c(12, 8), palette='RdYlGn')



