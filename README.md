# Singapore Blue-Chip Stock Portfolio Analysis

An end-to-end data analysis project examining risk-adjusted returns across five Singapore-listed blue-chip stocks, spanning banking, telecom, real estate, aviation, and industrials. Built with a **Python → PostgreSQL → Tableau** pipeline to mirror a real equity research / risk analysis workflow.

**[View the interactive Tableau dashboard →](#)** *(https://public.tableau.com/views/SingaporeBlue-ChipStocksPortfolioAnalysis/SingaporeBlue-ChipStocksPortfolioAnalysis?:language=en-US&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link)*

---

## Project Overview

This project analyzes the historical performance of five SGX-listed companies to answer a core investment question: **which stock delivers the best return per unit of risk taken?**

Rather than just comparing raw returns, the analysis focuses on **risk-adjusted performance** (Sharpe ratio), portfolio diversification effects, and event-driven risk (single-day drawdowns), which are the kinds of questions asked in equity research and portfolio risk roles.

### Companies analyzed

| Ticker | Company | Sector |
|---|---|---|
| D05.SI | DBS Group | Banking |
| Z74.SI | Singtel | Telecommunications |
| 9CI.SI | CapitaLand Investment | Real Estate |
| C6L.SI | Singapore Airlines | Aviation |
| S63.SI | ST Engineering | Industrials / Defense |

**Data period:** January 2024 – July 2026 (daily price data, ~627 trading days)

---

## Key Findings

- **DBS Group (D05.SI)** delivered the best risk-adjusted return, with the highest Sharpe ratio (~2.17) — a strong annual return (~38.5%) achieved with comparatively moderate volatility (~17.8%).
- **ST Engineering (S63.SI)** posted the highest raw return (~45.4%) but with higher volatility (~24.2%), resulting in a lower Sharpe ratio (~1.87) than DBS — a textbook example of return not being "free" of risk.
- **CapitaLand Investment (9CI.SI)** was the only stock with a negative Sharpe ratio, underperforming across the analysis window.
- **Portfolio diversification worked as expected**: an equal-weighted portfolio of all five stocks had a lower annual volatility (~13.1%) than any single stock held alone, despite moderate pairwise correlations (0.25–0.40).
- A **cross-stock drawdown event around early April 2025** was identified where four of the five stocks fell more than 5% on the same day — consistent with a broad market shock rather than a company-specific issue.
- Portfolio volatility peaked in **Q2 2025**, coinciding with the strongest quarterly return — reinforcing the risk/return trade-off visible in the individual stock analysis.

---

## Tech Stack

| Layer | Tool | Purpose |
|---|---|---|
| **Data Collection** | Python (`yfinance`) | Pull historical daily OHLCV price data directly from Yahoo Finance |
| **Analysis** | Python (`pandas`) | Compute daily returns, annualized return/volatility, Sharpe ratio, correlation matrix, portfolio-level metrics |
| **Storage** | PostgreSQL (via `SQLAlchemy` / `psycopg2`) | Persist cleaned datasets and support SQL-based analysis |
| **Querying** | SQL | Risk-tiered performance ranking, drawdown event detection, quarterly trend aggregation |
| **Visualization** | Tableau Public | Interactive dashboard combining all analyses into one view |

---

## Pipeline

```
yfinance (data pull)
      │
      ▼
Python / pandas (return, volatility, Sharpe ratio, correlation, portfolio analysis)
      │
      ▼
PostgreSQL (structured storage: close_prices, daily_returns, stock_summary_metrics)
      │
      ▼
SQL (risk-adjusted rankings, drawdown detection, quarterly aggregation)
      │
      ▼
CSV export → Tableau Public (final dashboard)
```

> **Note:** Tableau Public (free tier) does not support live database connections, so query outputs were exported to CSV as the final hand-off step. All underlying transformation and analysis logic lives in SQL and Python, not in Tableau itself.

---

## Repository Structure

```
sg-stock-portfolio-analysis/
├── sg_stock_analysis.ipynb          # Main analysis notebook (data pull → metrics → DB write)
├── data/
│   ├── close_prices.csv
│   ├── daily_returns.csv
│   ├── stock_summary_metrics.csv
│   ├── extreme_drawdown_days.csv
│   └── portfolio_quarterly_trend.csv
├── sql/
│   └── analysis_queries.sql         # Risk ranking, drawdown detection, quarterly trend queries
└── README.md
```

---

## Methodology

### 1. Data Collection
Daily closing, opening, high, low prices and volume were pulled for all five tickers using `yfinance`, avoiding the manual CSV formatting issues common with downloaded exchange data.

### 2. Risk & Return Metrics
For each stock:
- **Daily return** = percentage change in closing price day-over-day
- **Annualized return** = mean daily return × 252 trading days
- **Annualized volatility** = standard deviation of daily returns × √252
- **Sharpe ratio** = annualized return ÷ annualized volatility *(simplified, assumes 0% risk-free rate)*

### 3. Portfolio-Level Analysis
An equal-weighted (20% each) portfolio was constructed to evaluate diversification benefits, comparing portfolio-level volatility against single-stock volatility.

### 4. SQL Analysis
Three analysis-style SQL queries were written to mirror real reporting needs:
- **Performance summary** — risk-adjusted rating (Strong / Moderate / Weak) via `CASE WHEN`
- **Drawdown event detection** — unpivoting wide return data with `UNION ALL`, filtering for single-day losses ≥ 5%
- **Quarterly trend monitoring** — aggregating portfolio return/volatility by quarter using `DATE_TRUNC`

### 5. Visualization
Five linked views were combined into a single Tableau dashboard:
1. Sharpe ratio ranking (bar chart)
2. Risk vs. return scatter plot
3. Stock price trend (2024–2026)
4. Extreme drawdown event timeline
5. Quarterly portfolio return/volatility trend

---

## Possible Extensions

- Add risk-free rate adjustment to Sharpe ratio calculation for a more precise measure
- Backtest a simple rebalancing strategy against the static equal-weighted portfolio
- Incorporate sector/index benchmarking against the Straits Times Index (STI)
- Add a return-distribution histogram to visualize tail risk per stock
