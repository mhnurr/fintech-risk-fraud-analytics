# Fintech Risk & Fraud Analytics

## Business Questions
1. Pemetaan Risiko dan Potensi Mitigasi Kerugian

Pada kategori transaksi, rentang nominal, dan rentang waktu manakah insiden kecurangan (fraud) paling terkonsentrasi, serta berapa estimasi nilai kerugian yang dapat dicegah melalui pemantauan terfokus pada segmen tersebut?

2. Analisis Perilaku Transaksi dan Tingkat Sinyal Risiko

Indikator perilaku spesifik apa yang membedakan transaksi fraud dari transaksi normal—seperti pengosongan saldo secara mendadak atau penarikan tunai sesaat setelah transfer—dan sejauh mana keandalan pola tersebut sebagai sinyal risiko?

3. Evaluasi Efektivitas Aturan dan Optimalisasi Threshold

Seberapa optimal kinerja aturan penandaan saat ini (isFlaggedFraud), dan pada threshold risk score berapa organisasi dapat mencapai titik keseimbangan terbaik antara tingkat deteksi fraud dan kenyamanan pengguna sah?

## Dataset
PaySim (synthetic mobile money transactions), 6.36M rows, 8,213 fraud (~0.13%).
Fraud hanya muncul pada tipe TRANSFER dan CASH_OUT.

rumusannya bisa begini:

Pada data PaySim, fraud rate pada TRANSFER mencapai 70,66% di jam 4 dini hari, jauh di atas rata-rata keseluruhan (~0,13%). Transaksi TRANSFER dan CASH_OUT pada jam 1-6 adalah segmen berisiko tertinggi.

Pertanyaan bisnis nomor 1 juga menyebut rentang nominal dan estimasi kerugian. Query ini menjawab bagian itu:

sql
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

Hasilnya menunjukkan di rentang nominal mana fraud paling terkonsentrasi dan berapa nilai rupiah (dalam satuan mata uang dataset) yang terlibat. Itu bahan untuk menghitung potensi kerugian yang bisa dicegah.


## Early Findings (PaySim, simulated data)
- Fraud occurs only in TRANSFER and CASH_OUT.
- Fraud rate is highest at 01:00-06:00 (e.g. TRANSFER at 04:00: 70.66%).
- CASH_OUT >= 1M has an 81.61% fraud rate; transactions >= 1M are ~4.7% of
  TRANSFER/CASH_OUT volume but ~87% of fraud value.


  ## Cleaning Findings
- No NULLs, negatives or duplicates; no rows removed (see clean.cleaning_log).
- Merchant destinations (M...) appear only in PAYMENT transactions.
- Origin-balance inconsistency depends strongly on type: TRANSFER 95.2%, CASH_OUT 88.5%,
  PAYMENT 51.2%, DEBIT 28.4%, CASH_IN ~0%.
- 97.6% of fraud empties the origin balance (fraud rate 0.674% vs 0.013%), but the rule alone
  flags ~1.19M transactions, so it needs to be combined with other signals.