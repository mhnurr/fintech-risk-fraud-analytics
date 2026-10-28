-- Q1: Pada rentang nominal mana fraud paling terkonsentrasi,
-- dan berapa nilai fraud yang terlibat?



SELECT type,
      CASE WHEN amount < 10000    THEN '1. < 10K'
            WHEN amount < 100000   THEN '2. 10K-100K'
            WHEN amount < 1000000  THEN '3. 100K-1M'
            ELSE                        '4. >= 1M' END AS rentang_nominal,
      COUNT(*) AS total,
      SUM(is_fraud) AS fraud_count,
       ROUND(100.0 * SUM(is_fraud) / COUNT(*), 2) AS fraud_rate_pct,
      ROUND(SUM(CASE WHEN is_fraud = 1 THEN amount ELSE 0 END)) AS nilai_fraud
FROM raw.transactions
WHERE type IN ('TRANSFER', 'CASH_OUT')
GROUP BY type, rentang_nominal
ORDER BY type, rentang_nominal;