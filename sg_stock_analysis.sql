-- ============================================================
-- Singapore Blue-Chip Stock Portfolio Analysis
-- SQL Analysis Queries
-- Data source: Yahoo Finance (via yfinance)
-- Database: sg_stock_analysis (PostgreSQL)
-- ============================================================


-- ------------------------------------------------------------
-- 0. Preview raw tables
-- ------------------------------------------------------------
SELECT * FROM stock_summary_metrics;
SELECT * FROM close_prices;
SELECT * FROM daily_returns;


-- ------------------------------------------------------------
-- 1. Sharpe ratio ranking
-- Which stock delivers the best risk-adjusted return?
-- ------------------------------------------------------------
SELECT "Ticker", "Annual Return", "Annual Volatility", "Sharpe Ratio"
FROM stock_summary_metrics
ORDER BY "Sharpe Ratio" DESC;
-- Result: D05.SI (DBS) has the highest Sharpe ratio at 2.17.


-- ------------------------------------------------------------
-- 2. Monthly average return for a single stock (DBS)
-- ------------------------------------------------------------
SELECT
	DATE_TRUNC('month', "Date") AS MONTH,
	AVG("D05.SI") AS AVG_DAILY_RETURN
FROM DAILY_RETURNS
GROUP BY DATE_TRUNC('month', "Date")
ORDER BY MONTH;


-- ------------------------------------------------------------
-- 3. Performance summary report
-- A stock performance summary ranked by risk-adjusted return.
-- ------------------------------------------------------------
SELECT
	"Ticker",
	ROUND(CAST("Annual Return" * 100 AS NUMERIC), 2) AS ANNUAL_RETURN_PCT,
	ROUND(CAST("Annual Volatility" * 100 AS NUMERIC), 2) AS ANNUAL_VOLATILITY_PCT,
	ROUND(CAST("Sharpe Ratio" AS NUMERIC), 2) AS SHARPE_RATIO,
	CASE
		WHEN "Sharpe Ratio" >= 2 THEN 'Strong'
		WHEN "Sharpe Ratio" >= 1 THEN 'Moderate'
		ELSE 'Weak'
	END AS RISK_ADJUSTED_RATING
FROM STOCK_SUMMARY_METRICS
ORDER BY "Sharpe Ratio" DESC;


-- ------------------------------------------------------------
-- 4. Extreme drawdown detection
-- Which stocks fell more than 5% in a single day, and when?
-- ------------------------------------------------------------
SELECT
    "Date",
    "Ticker",
    return_pct
FROM (
    SELECT "Date", '9CI.SI' AS "Ticker", "9CI.SI" AS return_pct FROM daily_returns
    UNION ALL
    SELECT "Date", 'C6L.SI', "C6L.SI" FROM daily_returns
    UNION ALL
    SELECT "Date", 'D05.SI', "D05.SI" FROM daily_returns
    UNION ALL
    SELECT "Date", 'S63.SI', "S63.SI" FROM daily_returns
    UNION ALL
    SELECT "Date", 'Z74.SI', "Z74.SI" FROM daily_returns
) AS unpivoted
WHERE return_pct <= -0.05
ORDER BY "Date";
-- Result: 14 single-day drops of 5%+ found across the 5 stocks.
-- Notably, 4 stocks fell together on 2025-04-07, suggesting a broad market shock rather than a company-specific event.


-- ------------------------------------------------------------
-- 5. Quarterly portfolio trend
-- How has the equal-weighted portfolio's return and volatility trended by quarter?
-- ------------------------------------------------------------
SELECT 
    DATE_TRUNC('quarter', "Date") AS quarter,
    ROUND(CAST(AVG(("9CI.SI"+"C6L.SI"+"D05.SI"+"S63.SI"+"Z74.SI")/5) * 100 AS numeric), 3) AS avg_daily_portfolio_return_pct,
    ROUND(CAST(STDDEV(("9CI.SI"+"C6L.SI"+"D05.SI"+"S63.SI"+"Z74.SI")/5) * 100 AS numeric), 3) AS daily_volatility_pct
FROM daily_returns
GROUP BY DATE_TRUNC('quarter', "Date")
ORDER BY quarter;
-- Result: Portfolio volatility peaked in Q2 2025, coinciding with one of the strongest quarterly returns — illustrating the risk/return trade-off at the portfolio level.