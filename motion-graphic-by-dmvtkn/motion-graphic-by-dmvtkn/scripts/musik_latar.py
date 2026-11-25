"""Musik latar sintetis sederhana: pad akor + denyut pelan, WAV stereo 48 kHz.

Pakai:  python3 musik_latar.py musik.wav <DUR> [--bpm 110] [--suasana cerah|tenang|serius]
Ini musik sederhana buatan kode. Sampaikan begitu ke user.
"""
import argparse
import wave

import numpy as np

SR = 48000
# Progresi akor (frekuensi Hz), satu akor per 2 bar.
AKOR = {
    "cerah":  [[261.63, 329.63, 392.00], [196.00, 246.94, 293.66], [220.00, 261.63, 329.63], [174.61, 220.00, 261.63]],
    "tenang": [[220.00, 261.63, 329.63], [174.61, 220.00, 261.63], [261.63, 329.63, 392.00], [196.00, 246.94, 293.66]],
    "serius": [[146.83, 174.61, 220.00], [116.54, 146.83, 174.61], [130.81, 164.81, 196.00], [110.00, 138.59, 164.81]],
}


def buat(dur, bpm, suasana):
    n = int(dur * SR)
    t = np.arange(n) / SR
    ketuk = 60.0 / bpm
    panjang_akor = ketuk * 8
    kiri = np.zeros(n)
    kanan = np.zeros(n)
    prog = AKOR[suasana]
    for i, mulai in enumerate(np.arange(0, dur, panjang_akor)):
        a, b = int(mulai * SR), min(n, int((mulai + panjang_akor + 0.4) * SR))
        tt = t[a:b] - mulai
        env = np.minimum(1, tt / 0.6) * np.minimum(1, np.maximum(0, (panjang_akor + 0.4 - tt) / 0.8))
        for f in prog[i % len(prog)]:
            kiri[a:b] += env * np.sin(2 * np.pi * f * 0.997 * tt)
            kanan[a:b] += env * np.sin(2 * np.pi * f * 1.003 * tt)
            # oktaf bawah tipis untuk badan suara
            kiri[a:b] += 0.3 * env * np.sin(2 * np.pi * f / 2 * tt)
            kanan[a:b] += 0.3 * env * np.sin(2 * np.pi * f / 2 * tt)
    # denyut lembut di tiap ketukan
    fase = (t % ketuk) / ketuk
    denyut = 0.75 + 0.25 * np.exp(-fase * 6)
    kiri *= denyut
    kanan *= denyut
    # fade-in 1 detik, fade-out 2,5 detik
    fade = np.minimum(1, t / 1.0) * np.minimum(1, np.maximum(0, (dur - t) / 2.5))
    stereo = np.stack([kiri * fade, kanan * fade], axis=1)
    stereo /= max(1e-9, np.abs(stereo).max())
    return (stereo * 0.5 * 32767).astype(np.int16)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("out")
    ap.add_argument("dur", type=float)
    ap.add_argument("--bpm", type=float, default=110)
    ap.add_argument("--suasana", choices=list(AKOR), default="cerah")
    arg = ap.parse_args()
    data = buat(arg.dur, arg.bpm, arg.suasana)
    with wave.open(arg.out, "wb") as w:
        w.setnchannels(2)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes(data.tobytes())
    print(f"Musik {arg.dur:.1f} detik ({arg.suasana}, {arg.bpm:.0f} BPM) -> {arg.out}")


if __name__ == "__main__":
    main()
