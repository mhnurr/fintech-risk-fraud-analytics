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