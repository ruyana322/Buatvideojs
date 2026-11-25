#!/usr/bin/env bash
# Cek file MP4 hasil ekspor: durasi, frame, fps, codec, ukuran, frame hitam/beku, keheningan, volume.
# Pakai:  cek.sh <video.mp4> <DUR> [LEBAR] [TINGGI]   (bawaan 1080 1920)
set -uo pipefail
if [ $# -lt 2 ]; then echo "Pakai: cek.sh <video.mp4> <DUR> [LEBAR] [TINGGI]" >&2; exit 1; fi
F="$1"; DUR="$2"; W="${3:-1080}"; H="${4:-1920}"; FRAMES=$((DUR*30)); MASALAH=0
[ -f "$F" ] || { echo "File $F tidak ada. Ekspor dulu." >&2; exit 1; }
p() { ffprobe -v error "$@" -of default=nw=1:nk=1 "$F"; }
cocok() { if [ "$2" = "$3" ]; then echo "  ok   $1: $2"; else echo "  BEDA $1: $2 (target $3)"; MASALAH=1; fi; }

echo "== Spesifikasi =="
C_DUR=$(p -show_entries format=duration)
C_DUR3=$(awk -v d="$C_DUR" 'BEGIN{printf "%.3f", d}')
cocok "durasi container" "$C_DUR3" "$(awk -v d="$DUR" 'BEGIN{printf "%.3f", d}')"
cocok "frame terbaca" "$(p -count_frames -select_streams v:0 -show_entries stream=nb_read_frames)" "$FRAMES"
cocok "r_frame_rate" "$(p -select_streams v:0 -show_entries stream=r_frame_rate)" "30/1"
cocok "avg_frame_rate" "$(p -select_streams v:0 -show_entries stream=avg_frame_rate)" "30/1"
cocok "codec video" "$(p -select_streams v:0 -show_entries stream=codec_name)" "h264"
cocok "pix_fmt" "$(p -select_streams v:0 -show_entries stream=pix_fmt)" "yuv420p"
cocok "ukuran" "$(p -select_streams v:0 -show_entries stream=width)x$(p -select_streams v:0 -show_entries stream=height)" "${W}x${H}"
cocok "codec audio" "$(p -select_streams a:0 -show_entries stream=codec_name)" "aac"
[ "${DUR}" -le 60 ] || { echo "  BEDA durasi lebih dari 60 detik"; MASALAH=1; }

echo "== Frame hitam (kosong = aman) =="
ffmpeg -hide_banner -i "$F" -vf blackdetect=d=0.1:pix_th=0.05 -an -f null - 2>&1 | grep -o 'black_start.*' || true
echo "== Frame beku > 1,5 detik (cek apakah disengaja) =="
ffmpeg -hide_banner -i "$F" -vf freezedetect=n=-60dB:d=1.5 -an -f null - 2>&1 | grep -oE 'freeze_(start|end): [0-9.]+' || true
echo "== Hening > 0,5 detik (wajar di pembuka/penutup) =="
ffmpeg -hide_banner -i "$F" -af silencedetect=noise=-50dB:d=0.5 -vn -f null - 2>&1 | grep -oE 'silence_(start|end): [0-9.]+' || true
echo "== Volume =="
ffmpeg -hide_banner -i "$F" -af volumedetect -vn -f null - 2>&1 | grep -oE '(mean|max)_volume: [-0-9.]+ dB' || true

mkdir -p cek
ffmpeg -hide_banner -loglevel error -y -i "$F" -vf "fps=1/2,scale=640:-1" cek/%02d.png
ffmpeg -hide_banner -loglevel error -y -ss "$(awk -v d="$DUR" 'BEGIN{print d-0.1}')" -i "$F" -frames:v 1 -vf scale=640:-1 cek/terakhir.png
echo "== Gambar cek tersimpan di cek/ (tiap 2 detik + terakhir.png). Buka dan periksa. =="
[ "$MASALAH" -eq 0 ] && echo "SPESIFIKASI COCOK" || { echo "ADA YANG BEDA: perbaiki lalu ekspor ulang"; exit 4; }
