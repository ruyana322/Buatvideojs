#!/usr/bin/env bash
# Hitung durasi video, jumlah frame, dan titik mulai fade musik dari file suara.
# Pakai:  durasi.sh <file-suara> [target-detik]
# Hasil berupa KEY=VALUE, bisa dipakai langsung:  eval "$(durasi.sh vo.mp3)"
set -euo pipefail
if [ $# -lt 1 ]; then echo "Pakai: durasi.sh <file-suara> [target-detik]" >&2; exit 1; fi
VO="$1"; TARGET="${2:-}"
VO_DUR=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$VO")
# suara + 1 detik pembuka + 1,5 detik penutup, dibulatkan ke atas
MIN=$(awk -v v="$VO_DUR" 'BEGIN{t=v+2.5; d=int(t); if (d<t) d++; print d}')
if [ -n "$TARGET" ]; then
  case "$TARGET" in ''|*[!0-9]*) echo "Target harus bilangan bulat detik, misalnya 30" >&2; exit 1;; esac
  if [ "$TARGET" -lt "$MIN" ]; then
    echo "TARGET TERLALU PENDEK: suara $VO_DUR detik butuh video minimal $MIN detik. Tanyakan ke user." >&2; exit 2
  fi
  DUR=$TARGET
else
  DUR=$MIN
fi
if [ "$DUR" -gt 60 ]; then
  echo "MELEBIHI 60 DETIK: video jadi $DUR detik. Jangan render, tanyakan ke user." >&2; exit 3
fi
echo "VO_DUR=$VO_DUR"
echo "DUR=$DUR"
echo "FRAMES=$((DUR*30))"
echo "FADE_ST=$(awk -v d="$DUR" 'BEGIN{print d-2.5}')"
