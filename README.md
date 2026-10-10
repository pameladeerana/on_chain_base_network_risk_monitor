# On-Chain Risk Monitor: Detecting Suspicious Wallet Drain Patterns on the Base Network

Analyzing Base token transactions to identify potential wallet drain behaviors and risk concentration patterns.

Database: basetoken_db
Table: base_token_txns
Focus: Risk / Wallet Drain Detection
Source: Base Network token transaction snapshot from BaseScan / Base Mainnet explorer, downloaded on **October 8, 2026 (Snapshot: 2026-10-08 04:40:00 UTC). Dataset contains 500 transactions sampled for risk pattern analysis.

## 

## Study Questions / Risk Questions

1. What is the total number of transactions in this dataset?
2. Which wallets show potential drain behavior by sending many transactions within 1 hour?
3. What are the largest single token transfers that could represent a wallet drain?
4. Are there sweep patterns where one victim wallet sends multiple different tokens to the same address?
5. Are there dust or near-zero transactions that could be test transactions before a drain?
6. Find pairs that BOTH sent to each other with Amount 0.
7. Which receiver addresses are collecting from many distinct sender wallets?
8. What is the status and method breakdown? Do failed transactions indicate attempted drains?

## 

## Files



* README.md - project overview
* base\_token\_txns.csv - sample 500 rows (real dataset snapshot from 2026-10-08, 04:40:00 UTC)
* base\_token\_schema.txt
* base\_network\_risk\_monitor.sql - 8 risk queries
* results\_and\_summary.txt - summary of the case and recommendations
* basescan.source.png - screenshot of data source from BaseScan


##

## Workflow

1. Downloaded Source Data: Exported Base token transaction data from BaseScan public explorer (Base Mainnet). The page data was downloaded as multiple CSV exports on October 8, 2026 at 04:40 UTC.
2. File Cleaning: All exported CSV files were filed and cleaned into one Excel workbook (WPS Office). The consolidated file was converted to CSV for SQL import.
3. Database Creation \& Import in MySQL Workbench:** Created a new database basetoken\_db in MySQL Workbench. Imported the cleaned CSV using Table Data Import Wizard.
4. Query Development: Wrote 8 risk-focused SQL queries covering volume, burst behavior, large transfers, sweep patterns, dust transactions, coordinated pairs, collection wallets, and status breakdown. Each query was tested with `LIMIT` and validated via Result Grid.
5. Result Validation: Ran each query and checked Result Grid. (Used `ORDER BY Amount DESC` and `COUNT(DISTINCT)` to validate high-risk patterns).

6. Documentation & Export: Exported result grids for key insights. Created summary for both project findings and workflow.



##

## Key Insights (Summary)

**Overall Snapshot from 500 transactions:**

* High burst activity: `0x3af997...f3c4a` sent 100 txns in one hour at 04:00 on 2026-10-08.
* Largest single transfer: 967,231.97 TOWNS, followed by 512,867.4 ZORA.
* No multi-token sweep pattern (0 rows for 3+ distinct tokens to same address).
* 6 dust transactions with Amount 0 (test/probe signal).
* 3 coordinated bidirectional pairs with mutual zero-value exchanges.
* 7 collection wallets receiving from 5+ unique senders. Top: `0x49858...b2652` with 10 unique sources and 19 incoming
* All transactions in sample show Status = Success, top method is `Handle Ops` (27).



For detailed information per query, see separate sheet: "results\_and\_summary.txt"

Recommendation: Monitor burst threshold >=5/hr, large transfer >100k, zero-value probes, and collection wallet concentration as primary risk alerts. This is a neutral monitoring report, not confirmed malicious activity.

##

## Tools

* basescan.org/tokentxns?ps=100\&p=5
* Excel / WPS Office
* MySQL Workbench / MySQL



**Author:** Pamela Dee Elegio Rana (@pameladeerana)

