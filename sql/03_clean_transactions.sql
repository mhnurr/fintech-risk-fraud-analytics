-- 03_clean_transactions.sql
-- Pipeline cleaning: raw.transactions -> clean.transactions + clean.cleaning_log
-- Prinsip: tidak ada baris yang dibuang; anomali ditandai lewat kolom flag.
-- (step, type, amount, name_orig, name_dest) terbukti unik, dipakai sebagai urutan txn_id.

CREATE SCHEMA IF NOT EXISTS clean;

DROP TABLE IF EXISTS clean.transactions;
CREATE TABLE clean.transactions AS
SELECT
    ROW_NUMBER() OVER (ORDER BY step, type, amount, name_orig, name_dest) AS txn_id,
    step,
    (step - 1) % 24         AS hour_of_day,
    (step - 1) / 24 + 1     AS day_number,
    type,
    amount,
    name_orig, oldbalance_org, newbalance_orig,
    name_dest, oldbalance_dest, newbalance_dest,
    is_fraud, is_flagged_fraud,
    (amount = 0)                                  AS is_zero_amount,
    (name_dest LIKE 'M%')                         AS is_merchant_dest,
    (oldbalance_org > 0 AND newbalance_orig = 0)  AS orig_emptied,
    CASE WHEN type = 'CASH_IN'
         THEN ABS(oldbalance_org + amount - newbalance_orig) > 0.01
         ELSE ABS(oldbalance_org - amount - newbalance_orig) > 0.01
    END                                           AS orig_balance_mismatch,
    CASE WHEN amount < 10000   THEN '1. < 10K'
         WHEN amount < 100000  THEN '2. 10K-100K'
         WHEN amount < 1000000 THEN '3. 100K-1M'
         ELSE                       '4. >= 1M' END AS amount_bucket
FROM raw.transactions;

ALTER TABLE clean.transactions ADD PRIMARY KEY (txn_id);
ANALYZE clean.transactions;

-- Log keputusan cleaning
DROP TABLE IF EXISTS clean.cleaning_log;
CREATE TABLE clean.cleaning_log (
    step_no       INT,
    check_name    TEXT,
    rows_affected BIGINT,
    decision      TEXT,
    rationale     TEXT
);

INSERT INTO clean.cleaning_log VALUES
(1, 'Jumlah baris raw',
    (SELECT COUNT(*) FROM raw.transactions),
    'info', 'Baseline sebelum cleaning'),
(2, 'Baris dengan NULL',
    (SELECT COUNT(*) FROM raw.transactions
      WHERE step IS NULL OR type IS NULL OR amount IS NULL
         OR name_orig IS NULL OR name_dest IS NULL),
    'tidak ada tindakan bila 0', 'Jika > 0 perlu ditinjau sebelum dibuang atau diisi'),
(3, 'Nilai negatif (nominal/saldo)',
    (SELECT COUNT(*) FROM raw.transactions
      WHERE amount < 0 OR oldbalance_org < 0 OR newbalance_orig < 0
         OR oldbalance_dest < 0 OR newbalance_dest < 0),
    'tidak ada tindakan bila 0', 'Jika > 0 perlu ditinjau'),
(4, 'Baris duplikat (step, type, amount, name_orig, name_dest)',
    (SELECT COUNT(*) - COUNT(DISTINCT (step, type, amount, name_orig, name_dest))
       FROM raw.transactions),
    'tidak ada tindakan bila 0', 'Kombinasi ini juga dipakai sebagai urutan txn_id'),
(5, 'Nominal transaksi = 0',
    (SELECT COUNT(*) FROM clean.transactions WHERE is_zero_amount),
    'ditandai (is_zero_amount), tidak dibuang',
    'Termasuk 16 transaksi berlabel fraud; bisa jadi percobaan gagal, penyebab belum dipahami'),
(6, 'Saldo asal tidak konsisten dengan nominal',
    (SELECT COUNT(*) FROM clean.transactions WHERE orig_balance_mismatch),
    'ditandai (orig_balance_mismatch), tidak diubah',
    'Sangat banyak; diduga sifat data simulasi, pola per tipe dianalisis di EDA'),
(7, 'Tujuan merchant (name_dest diawali M)',
    (SELECT COUNT(*) FROM clean.transactions WHERE is_merchant_dest),
    'ditandai (is_merchant_dest)',
    'Saldo tujuan merchant tampak tidak tercatat (0); jangan dipakai menilai pengosongan akun tujuan'),
(8, 'Jumlah baris clean',
    (SELECT COUNT(*) FROM clean.transactions),
    'info', 'Harus sama dengan baris raw: tidak ada baris yang dibuang');

SELECT * FROM clean.cleaning_log ORDER BY step_no;