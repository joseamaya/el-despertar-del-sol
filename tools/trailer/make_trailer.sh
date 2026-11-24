#!/usr/bin/env bash
# Builds the recruitment trailer and flyer for the player tests (F5 and F6,
# docs/fases/F6-difusion.md) from real footage of the current build (0.2-slice). Needs ffmpeg and google-chrome.
#
# 1. Record a whole playthrough (about 5 min; a game window opens):
#      godot --path . --resolution 1920x1080 --fixed-fps 30 \
#          --write-movie build/trailer/full.avi -s res://tools/scene_benchmark.gd -- \
#          --scene=res://scenes/levels/carmenca.tscn --playthrough --scale3d=1 --timeout=7200
# 2. bash tools/trailer/make_trailer.sh
#      -> build/trailer/trailer.mp4 and build/trailer/flyer.png
#
# The shot times below fit the recording of 2026-11-23 (0.2-slice) (the bot plays the same way each
# run, but check them with a contact sheet if the slice changes).
set -euo pipefail
export LC_ALL=C

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
OUT="$ROOT/build/trailer"
SRC="$OUT/full.avi"
MUSIC="$ROOT/assets/audio/music/tozan/perustyle3.ogg"
SERIF="$(fc-match -f '%{file}' 'Liberation Serif:bold')"
SANS="$(fc-match -f '%{file}' 'DejaVu Sans')"
TMP="$OUT/parts"
FPS=30
# Letterbox: keep 780 px of the frame from y=100, which hides the HUD bars and the
# dialogue box; centred notices ("¡Llegan más chancas…!") stay.
CROP="crop=1920:780:0:100,pad=1920:1080:0:150:black"
ENC=(-c:v libx264 -preset slow -crf 20 -pix_fmt yuv420p -r "$FPS"
	-c:a aac -b:a 160k -ar 48000 -ac 2)

rm -rf "$TMP" && mkdir -p "$TMP"
n=0

# clip START LENGTH GAME_VOLUME [TITLE] [SUBTITLE]
clip() {
	local start=$1 len=$2 vol=$3 title=${4:-} sub=${5:-}
	local vf="$CROP,fade=t=in:st=0:d=0.3,fade=t=out:st=$(echo "$len - 0.3" | bc):d=0.3"
	if [[ -n "$title" ]]; then
		vf+=",drawtext=fontfile=$SERIF:text='$title':fontsize=96:fontcolor=0xF6D48A"
		vf+=":x=(w-tw)/2:y=(h-th)/2-30:shadowcolor=black:shadowx=3:shadowy=3"
		vf+=":alpha='min(1,max(0,(t-0.6)/0.6))'"
	fi
	if [[ -n "$sub" ]]; then
		vf+=",drawtext=fontfile=$SERIF:text='$sub':fontsize=52:fontcolor=0xF4EAD8"
		vf+=":x=(w-tw)/2:y=(h/2)+60:shadowcolor=black:shadowx=2:shadowy=2"
		vf+=":alpha='min(1,max(0,(t-1.2)/0.6))'"
	fi
	n=$((n + 1))
	ffmpeg -loglevel error -y -ss "$start" -t "$len" -i "$SRC" \
		-vf "$vf" -af "volume=$vol,afade=t=in:d=0.3,afade=t=out:st=$(echo "$len - 0.3" | bc):d=0.3" \
		"${ENC[@]}" "$TMP/$(printf %02d $n).mp4"
}

# card LENGTH LINE1 [LINE2] [SMALL]
card() {
	local len=$1 l1=$2 l2=${3:-} small=${4:-}
	local vf="drawtext=fontfile=$SERIF:text='$l1':fontsize=72:fontcolor=0xF4EAD8"
	vf+=":x=(w-tw)/2:y=(h-th)/2-40:alpha='min(1,max(0,(t-0.3)/0.5))*min(1,max(0,($len-0.3-t)/0.5))'"
	if [[ -n "$l2" ]]; then
		vf+=",drawtext=fontfile=$SERIF:text='$l2':fontsize=56:fontcolor=0xE8B04A"
		vf+=":x=(w-tw)/2:y=(h/2)+50:alpha='min(1,max(0,(t-0.8)/0.5))*min(1,max(0,($len-0.3-t)/0.5))'"
	fi
	if [[ -n "$small" ]]; then
		vf+=",drawtext=fontfile=$SANS:text='$small':fontsize=26:fontcolor=0xA89A86"
		vf+=":x=(w-tw)/2:y=h-90"
	fi
	n=$((n + 1))
	ffmpeg -loglevel error -y -f lavfi -i "color=c=black:s=1920x1080:r=$FPS:d=$len" \
		-f lavfi -i "anullsrc=r=48000:cl=stereo" -t "$len" -vf "$vf" \
		"${ENC[@]}" "$TMP/$(printf %02d $n).mp4"
}

clip 2.8 3.8 0 "Cusco, hacia 1438"
card 3.5 "El Inca ha abandonado la ciudad." "Dicen que el Cusco ya está perdido."
clip 7 4.5 0.7
clip 43.5 4 0.9
clip 82 4 0.9
clip 102.5 4 0.7
card 2.8 "Los chancas avanzan sobre el Cusco."
clip 135 4 0.7
clip 141 4 0.9
card 2.8 "Cusi Yupanqui no huye."
clip 176.5 4 0.9
clip 199 4 0.9
clip 205 5 1.0
clip 228 6.5 0 "PACHACÚTEC" "El Despertar del Sol"
card 6 "Demo gratuita · 10 minutos · Windows y Linux" "Pruébala y ayúdanos a construirlo" \
	"Juego en desarrollo · Imágenes reales del juego · Música\: Tozan (CC0) · Pututu\: David Bolton (CC BY 2.5)"

ls "$TMP"/*.mp4 | sed "s/.*/file '&'/" > "$TMP/list.txt"
ffmpeg -loglevel error -y -f concat -safe 0 -i "$TMP/list.txt" -c copy "$TMP/joined.mp4"
total=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$TMP/joined.mp4")
fade_at=$(echo "$total - 3" | bc)
ffmpeg -loglevel error -y -i "$TMP/joined.mp4" -i "$MUSIC" -filter_complex \
	"[1:a]aresample=48000,volume=0.8,afade=t=in:d=1,afade=t=out:st=$fade_at:d=3[m];[0:a][m]amix=inputs=2:duration=first:normalize=0,loudnorm=I=-16:TP=-1.5[a]" \
	-map 0:v -map "[a]" -c:v copy -c:a aac -b:a 160k -ar 48000 "$OUT/trailer.mp4"

# Flyer: a real frame (Cusi guarding with the huallcanca in the pass) behind the HTML layout.
# The crop leaves out the HUD (objective, enemy bar, health bars).
ffmpeg -loglevel error -y -ss 208.5 -i "$SRC" -frames:v 1 -vf "crop=1300:860:310:110" -q:v 2 \
	"$OUT/flyer_shot.jpg"
cp "$ROOT/tools/trailer/flyer.html" "$OUT/flyer.html"
google-chrome --headless=new --disable-gpu --hide-scrollbars --window-size=1080,1350 \
	--screenshot="$OUT/flyer.png" "file://$OUT/flyer.html" 2>/dev/null

echo "trailer: $OUT/trailer.mp4 ($(printf %.1f "$total") s)"
echo "flyer:   $OUT/flyer.png"
