# Render dan Verifikasi

Baca sebelum membangun dan me-render. Semua perintah di sini contoh: ganti nama file sesuai aset user, dan jangan jalankan perintah yang bergantung pada alat yang belum dicek ada.

Skrip bantu ada di folder `scripts/` skill ini. Salin ke folder kerja dulu supaya gampang dipanggil:

```bash
cp -r <folder-skill>/scripts ./mg && chmod +x mg/*.sh
```

## Isi
1. Cek lingkungan
2. Memilih cara render
3. Mengukur suara dan membaca referensi
4. Render bertahap yang bisa dilanjutkan
5. Ekspor dan mixing
6. Verifikasi
7. Musik latar buatan sendiri
8. Jebakan umum

## 1. Cek lingkungan

```bash
ffmpeg -version | head -1; ffprobe -version | head -1
python3 -c "import PIL, numpy; print('PIL + numpy ok')"
node -v
fc-list | head -20                # font yang ada
which espeak-ng pico2wave          # TTS offline, biasanya tidak ada
```

Jaringan di sandbox Claude biasanya terbatas. `pip` dan `npm` umumnya jalan, tapi Google Fonts dan unduhan dari situs lain sering diblokir. Untuk font tambahan coba paket npm `@fontsource/<nama-font>` (berisi file .woff/.ttf), atau pakai font yang sudah ada di sistem.

## 2. Memilih cara render

Prinsipnya: setiap frame digambar dari waktu saja, `t = nomor_frame / 30`, lalu disatukan dengan ffmpeg. Dengan begitu jumlah frame pasti sama dengan durasi × 30, dan render bisa dilanjutkan dari frame mana pun.

| Cara | Cocok untuk | Syarat |
|---|---|---|
| Python (Pillow + numpy) | Teks, bentuk, gambar user, mask, parallax. Paling pasti jalan | PIL, numpy |
| HTML/CSS/JS + browser headless, screenshot per frame | Tipografi rumit, SVG, blur dan bayangan CSS | Browser headless bisa dijalankan |
| Remotion | Komposisi berbasis React | Node + browser headless |
| ffmpeg filter / MoviePy | Komposisi sederhana | ffmpeg |

Pakai yang benar-benar jalan di lingkungan ini. Kalau satu cara gagal, pindah ke cara lain tanpa diam-diam menurunkan kualitas. Kalau semua gagal, ikuti "Jujur soal hasil" di SKILL.md.

## 3. Mengukur suara dan membaca referensi

Durasi video, jumlah frame, dan titik mulai fade musik:

```bash
mg/durasi.sh "Suara Voiceover.mp3"          # cetak VO, DUR, FRAMES, FADE_ST
mg/durasi.sh "Suara Voiceover.mp3" 30       # dengan target durasi user 30 detik
```

Skrip berhenti dengan pesan jelas kalau hasilnya lebih dari 60 detik atau target user terlalu pendek untuk suaranya. Kalau itu terjadi, berhenti dan tanyakan ke user (Langkah 5 SKILL.md).

Jeda antarkalimat (turunkan angka `noise`, misalnya -30dB, kalau rekamannya bising):

```bash
ffmpeg -i "Suara Voiceover.mp3" -af silencedetect=noise=-35dB:d=0.25 -f null - 2>&1 | grep silence_
```

Timing per kata: kalau ada alat transkripsi atau forced alignment yang benar-benar bisa dijalankan, pakai itu. Kalau tidak, bagi waktu menurut jeda dari `silencedetect`, lalu sebar kata di tiap frasa sesuai jumlah suku katanya. Ingat, suara mulai di detik ke-1 video, jadi semua waktu dari file suara ditambah 1 detik.

Video referensi:

```bash
ffprobe -v error -show_entries stream=width,height,r_frame_rate,duration -of default=nw=1 "Referensi Motion Graphic.mp4"
mkdir -p ref && ffmpeg -i "Referensi Motion Graphic.mp4" -vf "fps=2,scale=480:-1" ref/%03d.png
```

Lihat frame-nya (boleh disusun jadi satu lembar kontak) untuk membaca palet, tipografi, komposisi, dan ritme. Video hasil selalu portrait 1080×1920. Kalau referensinya landscape, ambil gayanya saja lalu susun ulang komposisinya untuk layar tegak: teks lebih besar, elemen ditumpuk vertikal, dan bagian penting di tengah layar.

## 4. Render bertahap yang bisa dilanjutkan

Akun gratis bisa kena limit di tengah render. Supaya pekerjaan tidak hilang, susun proyek begini:

```
proyek/
├── timeline.json   # daftar adegan: mulai, selesai, teks, aset, gerak (dari rencana adegan)
├── render.py       # fungsi render(t) dan loop frame
├── aset/           # file user
└── frames/         # 00000.png, 00001.png, ...
```

Aturan `render.py`:
- Satu fungsi `render(t)` menggambar seluruh frame dari waktu saja. Tidak ada state tersembunyi, dan angka acak pakai seed tetap, supaya frame yang dirender ulang hasilnya sama persis.
- Siapkan fungsi easing (ease-out, ease-in-out, overshoot) dan pakai di semua animasi.
- Motion blur bisa dibuat dengan merata-ratakan beberapa sub-frame di waktu yang berdekatan.
- Terima argumen rentang frame, dan **lewati frame yang file-nya sudah ada**. Simpan tiap frame begitu selesai digambar.

```python
import sys, os
start, end = int(sys.argv[1]), int(sys.argv[2])   # end tidak ikut
os.makedirs("frames", exist_ok=True)
for i in range(start, end):
    path = f"frames/{i:05d}.png"
    if os.path.exists(path):
        continue
    render(i / 30).save(path)
print("selesai sampai frame", end - 1)
```

Render per potongan kira-kira 150–300 frame per pemanggilan, bukan semua sekaligus:

```bash
python3 render.py 0 300
python3 render.py 300 600
# ... sampai FRAMES
```

Kalau user mengetik "lanjutkan dari titik terakhir" setelah limit habis:

```bash
ls frames | wc -l                  # berapa frame sudah ada
ls frames | sort | tail -1         # frame terakhir
```

Hapus frame terakhir (bisa jadi rusak karena terputus saat disimpan), lalu lanjutkan loop dari situ. Kalau file proyek ternyata hilang, bilang ke user dan bangun ulang dari timeline di chat, jangan berpura-pura melanjutkan.

Frame terakhir (`FRAMES − 1`) harus tetap berisi visual penutup yang jelas, bukan layar kosong.

## 5. Ekspor dan mixing

```bash
mg/ekspor.sh frames "Suara Voiceover.mp3" "Musik Latar.mp3" video.mp4 <DUR>
mg/ekspor.sh frames "Suara Voiceover.mp3" - video.mp4 <DUR>        # tanpa musik
mg/ekspor.sh frames - "Musik Latar.mp3" draf-bisu.mp4 <DUR>       # draf tanpa suara, musik saja
mg/ekspor.sh frames - - draf-bisu.mp4 <DUR>                       # draf benar-benar bisu (track audio hening)
```

Yang dilakukan skrip:
- suara digeser mulai di detik ke-1 (`adelay`), diberi hening sampai akhir, lalu dipotong pas di `DUR`;
- musik diulang kalau kependekan, dipotong sepanjang video, volumenya diturunkan, di-duck saat narator bicara, dan fade-out 2,5 detik di akhir;
- `amix` di ffmpeg 7 ke atas memakai `normalize=0`. Di ffmpeg 6 ke bawah opsi itu belum ada, jadi skrip menggantinya dengan `volume=2` setelah mix;
- video H.264 CRF 18, yuv420p, 30 fps, tepat `DUR × 30` frame, audio AAC 192 kbps 48 kHz, `+faststart`.

Kalau user memberi video mentah (bukan urutan gambar) sebagai bahan, tetap paksa `-r 30` dan jumlah frame yang pas.

## 6. Verifikasi

```bash
mg/cek.sh video.mp4 <DUR>          # ukuran yang dicek: 1080×1920
```

Skrip mencetak durasi container, jumlah frame yang benar-benar terbaca, fps, codec, ukuran layar, dan menandai yang meleset. Lalu menjalankan deteksi frame hitam, frame beku, keheningan, dan level volume, serta mengambil frame tiap 2 detik ke folder `cek/` plus frame terakhir.

Cara membaca:
- Bukti durasi adalah durasi container dan jumlah frame video. Stream audio AAC bisa lebih panjang beberapa milidetik karena padding encoder, dan itu wajar.
- Frame beku singkat yang disengaja itu normal. Yang dicurigai adalah yang panjang atau muncul di tempat yang tidak direncanakan.
- `max_volume` mendekati 0 dB berarti berisiko clipping.
- Buka gambar di `cek/` dan lihat sendiri: teks terbaca, ejaan benar, aset tidak terpotong, tidak ada elemen bertabrakan.

Laporkan angka sebenarnya ke user. Kalau meleset, perbaiki dan ekspor ulang, jangan dibulatkan di laporan.

## 7. Musik latar buatan sendiri

Hanya kalau user tidak punya musik:

```bash
python3 mg/musik_latar.py musik.wav <DUR> --bpm 110 --suasana cerah    # pilihan suasana: cerah, tenang, serius
```

Hasilnya pad akor sederhana dengan denyut pelan, WAV 48 kHz, sudah fade-in dan fade-out. Masukkan ke `ekspor.sh` sebagai file musik. Sampaikan ke user bahwa ini musik sintetis sederhana, dan sarankan musik bebas royalti kalau ingin hasil yang lebih kaya.

## 8. Jebakan umum

- **Frame rate berubah-ubah (VFR)**: paksa `-r 30`. Cek `r_frame_rate` dan `avg_frame_rate` sama-sama `30/1`.
- **Selisih satu frame**: jumlah PNG di `frames/` tidak sama dengan `FRAMES`. Hitung dulu sebelum ekspor (`ekspor.sh` mengeceknya).
- **Audio dan video beda panjang**: sudah ditangani `apad` + `atrim` + `-t` di skrip.
- **Font tidak ketemu**: cek `fc-list` atau ambil lewat npm. Jangan diam-diam jatuh ke font bawaan yang jelek.
- **Teks terpotong di tepi**: ukur lebar teks dengan font yang dipakai, jangan menebak.
- **File terlalu besar**: naikkan CRF ke 20–22, jangan turunkan resolusi.
- **Frame rusak setelah limit**: hapus frame terakhir sebelum melanjutkan (bagian 4).
