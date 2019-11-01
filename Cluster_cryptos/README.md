[<img src="https://github.com/QuantLet/Styleguide-and-FAQ/blob/master/pictures/banner.png" width="888" alt="Visit QuantNet">](http://quantlet.de/)

## [<img src="https://github.com/QuantLet/Styleguide-and-FAQ/blob/master/pictures/qloqo.png" alt="Visit QuantNet">](http://quantlet.de/) **Mkt_cryptos** [<img src="https://github.com/QuantLet/Styleguide-and-FAQ/blob/master/pictures/QN2.png" width="60" alt="Visit QuantNet 2.0">](http://quantlet.de/)

```yaml

Name of QuantLet : Mkt_cryptos

Published in : Genus_proximum_cryptos

Description : 'Plots the market capitalization of cryptocurrencies, retrived at the time of the plot.'

Keywords : 
 - cryptocurrency
 - genus proximum
 - classiffication
 - market capitalization

 
Author : Daniel Traian Pele

See also : 'FA_cryptos, DFA_cryptos, SFA_cryptos'

Submitted : Mon, 08 April 2019 by Daniel Traian Pele


```

![Picture1](market_cap.png)

### R Code
```r

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




```

automatically created on 2019-04-08