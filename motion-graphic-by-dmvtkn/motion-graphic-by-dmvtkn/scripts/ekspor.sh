#!/usr/bin/env bash
# Satukan frame PNG + suara + musik jadi MP4 (H.264 + AAC, 30 fps, tepat DUR x 30 frame).
# Pakai:  ekspor.sh <folder-frames> <suara|-> <musik|-> <output.mp4> <DUR>
#   "-" berarti tidak ada. Frame harus bernama 00000.png, 00001.png, ...
set -euo pipefail
if [ $# -ne 5 ]; then echo "Pakai: ekspor.sh <folder-frames> <suara|-> <musik|-> <output.mp4> <DUR>" >&2; exit 1; fi
FR="$1"; VO="$2"; MU="$3"; OUT="$4"; DUR="$5"
FRAMES=$((DUR*30))
FADE_ST=$(awk -v d="$DUR" 'BEGIN{print d-2.5}')
END_FADE=$(awk -v d="$DUR" 'BEGIN{print d-0.5}')

ADA=$(find "$FR" -maxdepth 1 -name '[0-9][0-9][0-9][0-9][0-9].png' | wc -l | tr -d ' ')
if [ "$ADA" -ne "$FRAMES" ]; then
  echo "Jumlah frame $ADA, seharusnya $FRAMES ($DUR detik x 30). Render dulu frame yang kurang." >&2; exit 2
fi
LAST=$(printf "%s/%05d.png" "$FR" $((FRAMES-1)))
[ -f "$LAST" ] || { echo "Frame terakhir $LAST tidak ada; penomoran frame bolong." >&2; exit 2; }

# amix normalize=0 ada di ffmpeg 7+. Versi lama: kembalikan level dengan volume=2.
if ffmpeg -hide_banner -h filter=amix 2>/dev/null | grep -q normalize; then
  MIX="amix=inputs=2:duration=longest:dropout_transition=0:normalize=0"
else
  MIX="amix=inputs=2:duration=longest:dropout_transition=0,volume=2"
fi
FMT="aresample=48000,aformat=sample_fmts=fltp:channel_layouts=stereo"

IN=(-framerate 30 -i "$FR/%05d.png")
if [ "$VO" != "-" ] && [ "$MU" != "-" ]; then
  IN+=(-i "$VO" -stream_loop -1 -i "$MU")
  FG="[1:a]$FMT,adelay=1000:all=1,apad=whole_dur=$DUR,atrim=0:$DUR,asetpts=PTS-STARTPTS,asplit=2[vo1][vo2];\
[2:a]$FMT,atrim=0:$DUR,asetpts=PTS-STARTPTS,volume=0.35,afade=t=out:st=$FADE_ST:d=2.5[bg];\
[bg][vo1]sidechaincompress=threshold=0.03:ratio=8:attack=20:release=300[duck];\
[duck][vo2]$MIX,alimiter=limit=0.95[aout]"
elif [ "$VO" != "-" ]; then
  IN+=(-i "$VO")
  FG="[1:a]$FMT,adelay=1000:all=1,apad=whole_dur=$DUR,atrim=0:$DUR,asetpts=PTS-STARTPTS,afade=t=out:st=$END_FADE:d=0.5,alimiter=limit=0.95[aout]"
elif [ "$MU" != "-" ]; then
  IN+=(-stream_loop -1 -i "$MU")
  FG="[1:a]$FMT,atrim=0:$DUR,asetpts=PTS-STARTPTS,volume=0.6,afade=t=in:d=0.5,afade=t=out:st=$FADE_ST:d=2.5,alimiter=limit=0.95[aout]"
else
  IN+=(-f lavfi -t "$DUR" -i anullsrc=r=48000:cl=stereo)
  FG="[1:a]atrim=0:$DUR[aout]"
fi

ffmpeg -y -hide_banner -loglevel error "${IN[@]}" \
  -filter_complex "$FG" -map 0:v -map "[aout]" \
  -c:v libx264 -preset slow -crf 18 -pix_fmt yuv420p -r 30 -frames:v "$FRAMES" \
  -c:a aac -b:a 192k -ar 48000 -t "$DUR" \
  -movflags +faststart "$OUT"
echo "Selesai: $OUT ($DUR detik, $FRAMES frame). Lanjut cek dengan cek.sh."
