-- Q1: Pada jam berapa fraud paling terkonsentrasi?
-- Catatan: step = 1 jam; jam = (step - 1) % 24. Data simulasi PaySim.
SELECT type,
      (step - 1) % 24 AS jam,
      COUNT(*) AS total,
      SUM(is_fraud) AS fraud_count,
       ROUND(100.0 * SUM(is_fraud) / COUNT(*), 2) AS fraud_rate_pct
FROM raw.transactions
WHERE type IN ('TRANSFER', 'CASH_OUT')
GROUP BY type, jam
ORDER BY fraud_rate_pct DESC;