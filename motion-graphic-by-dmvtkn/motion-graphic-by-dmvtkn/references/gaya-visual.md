# Gaya Visual

Baca sebelum membangun adegan. Ini arah bawaan, bukan cetakan. Sesuaikan dengan aset user dan topiknya.

## Isi
1. Memakai video referensi
2. Gaya bawaan
3. Teks yang bergerak (kinetic typography)
4. Menghidupkan aset
5. Transisi
6. Sinkron dengan suara
7. Musik dan mixing

## 1. Memakai video referensi

Dari referensi yang diambil adalah *alasan* video itu enak ditonton: palet warna, hierarki huruf, cara teks dan gambar bertumpuk, ritme potongan, jenis transisi, bayangan dan kedalaman, serta cara gerak mengikuti suara.

Yang tidak diambil: adegan yang sama, komposisi yang sama, posisi teks yang sama, atau urutan animasi frame demi frame. Targetnya video orisinal yang terasa serapi atau lebih rapi dari referensinya.

## 2. Gaya bawaan (tanpa referensi)

Editorial modern yang bersih, minimalis, dan berani, disusun untuk layar tegak 1080×1920:

- Jaga bagian penting di area aman: kira-kira 120 px dari atas, 300 px dari bawah, dan 60 px dari sisi kiri-kanan. Bagian bawah dan kanan layar biasanya tertutup caption serta tombol aplikasi.

- Latar putih, abu muda, atau satu warna polos yang kontras dengan aset.
- Huruf hitam tebal dengan tingkatan ukuran yang tegas.
- Satu warna aksen terang (misalnya kuning) yang cocok dengan aset. Aksen boleh berganti antaradegan asal masih satu keluarga warna.
- Teks besar, komposisi tidak simetris, ruang kosong yang disengaja, lapisan yang saling menimpa.
- Gambar cut-out, ilustrasi, dan ikon menyatu dengan tata letak, bukan ditempel di samping teks.
- Bayangan, kedalaman, masking, motion blur, dan perubahan skala dipakai secukupnya.

Jauhi kesan slideshow: gambar diam di sebelah teks yang muncul pakai fade atau slide yang sama terus-menerus. Tiap adegan punya satu ide visual sendiri, tapi seluruh video tetap terasa satu keluarga.

Tanpa gambar dari user, visual dibangun dari bentuk geometris, ikon vektor, diagram, angka besar, garis, dan tipografi. Karena semuanya grafis kode, kekuatannya harus ada di komposisi dan gerak.

## 3. Teks yang bergerak

Teks ikut bercerita, bukan cuma subtitle.

Teknik yang bisa dipilih sesuai isi: teks muncul tepat saat katanya diucapkan, reveal lewat mask, kata atau huruf muncul bergantian, skala dengan sedikit pantulan (overshoot), spasi huruf yang merenggang, teks keluar dari balik objek, potongan dan lapisan yang kreatif, penekanan lewat tebal, warna, atau ukuran.

Pegangan:
- Pakai font modern yang tebal dan gampang dibaca, digambar lewat kode. Jangan pakai teks hasil generate gambar karena hurufnya bisa rusak atau jadi kata palsu.
- Ejaan dan makna harus persis seperti naskah.
- Pecah jadi frasa pendek. Jangan tampilkan satu paragraf sekaligus, cukup sorot kata kuncinya.
- Bedakan dengan jelas: judul, kata kunci, teks pendukung, label kecil.
- Hindari huruf kapital acak, font yang susah dibaca, dan hiasan berlebihan.
- Ukur lebar teks dengan fungsi pengukur font sebelum menaruhnya. Kata Bahasa Indonesia sering panjang dan gampang terpotong di tepi layar.

## 4. Menghidupkan aset

Aset penting jangan dibiarkan diam, kecuali memang ada jeda yang disengaja.

Teknik: scale in/out, gerak terarah dan rotasi halus, parallax berlapis, reveal dengan mask, zoom kamera pelan, cropping kreatif, gerak melayang, motion blur, bayangan lembut, dan hubungan gerak antara aset dan teks.

Pakai easing (mulai pelan lalu cepat, melambat di akhir, sedikit pantulan, ancang-ancang, lalu diam dengan mantap), bukan kecepatan rata. Variasikan tekniknya per adegan.

Aset user boleh dipotong, diubah ukuran, digeser, dimasking, dan ditumpuk selama detail pentingnya tetap terlihat. Jangan memotong objek utama, jangan meregangkan gambar, jangan biarkan elemen bertabrakan.

Kalau alat penghapus latar tidak tersedia, pakai masking manual atau bingkai yang tetap menarik, dan jangan menjanjikan cut-out yang tidak bisa dibuat.

## 5. Transisi

Pilihan: match cut, whip, wipe searah, reveal lewat mask, bentuk yang berubah, transisi skala, transisi yang digerakkan teks, parallax berlapis, motion blur, dan elemen yang berpindah dari satu adegan ke adegan berikutnya.

Ini menu, bukan daftar wajib. Pilih yang cocok dengan isi, dan sebisa mungkin sambungkan elemen antaradegan supaya alurnya tidak terasa putus.

Hindari glitch berlebihan, putaran asal, dan kilatan tanpa alasan. Transisi juga tidak boleh menutupi penjelasan. Semua transisi harus muat di dalam durasi yang sudah dihitung, jadi transisi tidak boleh membuat video jadi lebih panjang.

## 6. Sinkron dengan suara

Suara adalah patokan timing. Untuk tiap frasa penting:
- tampilkan teksnya saat kata itu diucapkan,
- munculkan aset saat relevan,
- tekankan kata kunci lewat skala, warna, tebal, posisi, atau gerak,
- beri jeda visual singkat kalau penonton perlu waktu mencerna,
- samakan kecepatan animasi dengan ritme bicara.

Gerak harus terasa menjawab suara. Efek tidak boleh mengalihkan perhatian dari informasinya.

## 7. Musik dan mixing

- Suara narator paling jelas. Turunkan musik saat narator bicara (ducking), terutama di bagian penting.
- Beberapa transisi atau aksen boleh jatuh di ketukan musik kalau memang pas dengan narasi.
- Efek suara secukupnya dan tidak bersaing dengan narator.
- Jangan mempercepat suara atau memotong kata demi durasi. Ritme dan jeda asli dipertahankan.
- Musik turun pelan di akhir. Audio selesai tepat di detik terakhir, tanpa ekor dan tanpa terpotong mendadak.
- Jaga dari clipping, distorsi, lonjakan volume, dan keheningan yang tidak direncanakan.

Kalau user tidak punya musik, buat musik latar sederhana (`scripts/musik_latar.py`) dan bilang terus terang bahwa itu musik sintetis sederhana. Pilihan lain: tanpa musik, dan sarankan user menambah musik bebas royalti sendiri.
