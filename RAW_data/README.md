# Raw log-returns — *Are Cryptos becoming alternative Assets?*

Daily log-returns for the full asset universe used in the paper, in plain,
self-describing formats (no RAR volumes, no MATLAB structs).

**906 assets × 1740 trading days, 2014-01-03 → 2020-11-30.**

## Files

| File | Content |
|---|---|
| `logreturns_wide.csv.gz` | 1740 rows × 907 cols. First column `Date` (`YYYY-MM-DD`), one column per asset, named by `name_symb`. Empty cells = asset not traded / not yet listed. |
| `logreturns_long.csv.gz` | Tidy long format: `date, name_symb, Symbol, Name, type, logreturn`. 1,412,881 rows, no missing values. |
| `assets_metadata.csv` | One row per asset: `name_symb, Name, Symbol, type, type_num, n_obs, first_date, last_date`. |
| `logreturns.rds` | R bundle: `list(returns = <1740×906 numeric matrix>, dates = <Date vector>, assets = <data.frame>)`. |

## Asset classes

| `type` | assets |
|---|---|
| Crypto | 234 |
| Stock | 635 |
| Commodity | 17 |
| Exchange rate | 13 |
| Bond | 5 |
| Real Estate | 2 |

## Identifier

Use **`name_symb`** (`<Name>_<Symbol>`) as the unique key — ticker `Symbol` alone is
not unique (896 distinct symbols for 906 assets).

## Loading

```r
d <- readRDS("logreturns.rds")
dim(d$returns)          # 1740 906
d$returns[1:5, 1:5]
head(d$assets)

# crypto-only sub-matrix
crypto <- d$returns[, d$assets$type == "Crypto"]
```

```r
# or straight from the CSV
w <- read.csv(gzfile("logreturns_wide.csv.gz"), check.names = FALSE)
X <- as.matrix(w[, -1]); rownames(X) <- w$Date
```

```python
import pandas as pd
X = pd.read_csv("logreturns_wide.csv.gz", index_col="Date", parse_dates=True)
meta = pd.read_csv("assets_metadata.csv")
```

## Provenance

Rebuilt from `SFA_Cryptos/new_assets_2021_c.rar` → `new_assets_2021_c.csv`
(long format, columns `Name, Symbol, type, logreturn, type_num, name_symb, date`)
by pivoting on `name_symb` × `date`. No values were altered, filtered or imputed;
`(name_symb, date)` is unique in the source and the source has no missing returns.

Note the archives under `DFA_cryptos/`, `CONV_cryptos/` and `VaR_Cryptos/` are a
*different* dataset: `dynamic_dataset_2021.csv` / `data_dynamic_jan_2021.mat` hold the
24 estimated distribution statistics (quantiles, CTEs, FIGARCH d, stable α/γ, variance,
skewness, kurtosis, ACF lag-1, Hurst) per asset per expanding-window *wave* — the input
to the factor analysis, not the returns themselves.
