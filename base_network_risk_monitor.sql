-- ===========================================================================================================
-- PROJECT TITLE: Simple On-Chain Risk Monitor: Detecting Suspicious Wallet Drain Patterns on the Base Network
-- ==========================================================================================================

-- 0. DATABASE CREATION/CHECK TABLE
-- CREATE DATABASE basetoken_db;
-- USE basetoken_db;
SELECT * FROM basetoken_db.base_token_txns;
-- ALTER TABLE basetoken_db.base_token_txns
-- CHANGE COLUMN `ï»¿Transaction_Hash` `Transaction_Hash` TEXT;

-- 1. What is the total number of transactions in this dataset? 
-- (For this specific timeline only. It only shows activity volume in the sampled period.)
SELECT COUNT(*) as total_transactions 
FROM basetoken_db.base_token_txns;

-- 2. Which wallets show potential drain behavior by sending many transactions within 1 hour?
-- (Wallet drain often = many rapid outflows from one From_Address. Flag if >=5 txns in same hour.)
SELECT From_Address, DATE(`Date_Time (UTC)`) as activity_date, HOUR(`Date_Time (UTC)`) as activity_hour, 
COUNT(*) as txns_in_one_hour
FROM basetoken_db.base_token_txns
GROUP BY From_Address, activity_date, activity_hour
HAVING txns_in_one_hour >= 5
ORDER BY txns_in_one_hour DESC;

-- 3. What are the largest single token transfers that could represent a wallet drain?
-- (Large Amount = high-risk single drain event.)
SELECT Transaction_Hash, `Date_Time (UTC)`, From_Address, To_Address, Amount, Token
FROM basetoken_db.base_token_txns
ORDER BY Amount DESC LIMIT 20;

-- 4. Are there sweep patterns where one victim wallet sends multiple different tokens to the same destination?
-- (Classic drain pattern: From_Address -> To_Address with 3+ distinct Tokens (attacker sweeping all assets).
SELECT From_Address, To_Address, COUNT(DISTINCT Token) as distinct_tokens_drained, COUNT(*) as total_sweeps
FROM basetoken_db.base_token_txns
GROUP BY From_Address, To_Address
HAVING distinct_tokens_drained >= 3
ORDER BY distinct_tokens_drained DESC;

-- 5. Are there dust or near-zero transactions that could be test transactions before a drain?
SELECT Transaction_Hash, `Date_Time (UTC)`, From_Address, To_Address, Amount, Token
FROM basetoken_db.base_token_txns
WHERE Amount < 0.000001;

-- 6. Find pairs that BOTH sent to each other with Amount 0. 
-- (Coordinated Addresses)
SELECT 
  LEAST(From_Address, To_Address) as address_A,
  GREATEST(From_Address, To_Address) as address_B,
  COUNT(*) as total_trial_interactions,
  SUM(CASE WHEN Amount < 0.000001 THEN 1 ELSE 0 END) as zero_trials,
  COUNT(DISTINCT From_Address) as directions
FROM basetoken_db.base_token_txns
WHERE Amount < 0.000001
GROUP BY address_A, address_B
HAVING directions = 2
ORDER BY total_trial_interactions DESC
LIMIT 20;

--  7. Which receiver addresses are collecting from many distinct sender wallets (potential attacker wallets)?
-- (If one To_Address receives from 5+ unique From_Address, it may be a drain collection wallet.)
SELECT To_Address, COUNT(DISTINCT From_Address) as unique_source, COUNT(*) as total_incoming
FROM basetoken_db.base_token_txns
GROUP BY To_Address
HAVING unique_source >= 5
ORDER BY unique_source DESC;

-- 8. What is the status and method breakdown? Do failed transactions indicate attempted drains?
SELECT Status, Method, COUNT(*) as count 
FROM basetoken_db.base_token_txns 
GROUP BY Status, Method;