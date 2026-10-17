#!/usr/bin/env python3
"""Generates the game's music loops as small WAV files — original tones,
no licensing. Each loop is a slow, quiet pentatonic pattern that is meant to
sit under play, never over it. Regenerate: uv run --with numpy scripts/make_music.py
"""

import wave
from pathlib import Path

import numpy as np

OUT = Path("game/assets/audio/music")
RATE = 22050


def note(freq: float, seconds: float, volume: float = 0.12) -> np.ndarray:
    t = np.linspace(0.0, seconds, int(RATE * seconds), endpoint=False)
    tone = np.sin(2 * np.pi * freq * t) + 0.35 * np.sin(4 * np.pi * freq * t)
    attack = min(0.02, seconds / 4)
    envelope = np.ones_like(t)
    ramp = int(RATE * attack)
    envelope[:ramp] = np.linspace(0.0, 1.0, ramp)
    envelope[-ramp:] = np.linspace(1.0, 0.0, ramp)
    return tone * envelope * volume


def silence(seconds: float) -> np.ndarray:
    return np.zeros(int(RATE * seconds))


def sequence(notes: list[tuple[float, float]], gap: float = 0.02) -> np.ndarray:
    parts = [note(freq, seconds) for freq, seconds in notes]
    return np.concatenate([p for n in parts for p in (n, silence(gap))][:-1])


def to_pcm(audio: np.ndarray) -> np.ndarray:
    return np.int16(np.clip(audio, -1.0, 1.0) * 32767)


def write(name: str, audio: np.ndarray) -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    path = OUT / f"{name}.wav"
    with wave.open(str(path), "wb") as f:
        f.setnchannels(1)
        f.setsampwidth(2)
        f.setframerate(RATE)
        f.writeframes(to_pcm(audio).tobytes())
    print(f"{path} ({len(audio) / RATE:.1f}s)")


def main() -> None:
    # A minor pentatonic: A3 C4 D4 E4 G4 A4.
    scale = [220.00, 261.63, 293.66, 329.63, 392.00, 440.00]

    # Menu: six slow rising/falling phrases.
    menu = sequence(
        [
            (scale[0], 0.8), (scale[2], 0.8), (scale[4], 1.0),
            (scale[5], 1.2), (scale[4], 0.8), (scale[2], 0.8),
            (scale[1], 0.8), (scale[3], 1.0), (scale[1], 1.0),
            (scale[0], 1.4),
        ]
    )
    write("menu", menu)

    # Gameplay: steady quarter-note walk, low and even.
    gameplay = sequence(
        [
            (scale[0], 0.30), (scale[2], 0.30), (scale[3], 0.30), (scale[4], 0.30),
            (scale[3], 0.30), (scale[2], 0.30), (scale[1], 0.30), (scale[3], 0.30),
            (scale[0], 0.30), (scale[4], 0.30), (scale[3], 0.30), (scale[2], 0.30),
            (scale[1], 0.30), (scale[2], 0.30), (scale[3], 0.30), (scale[0], 0.30),
        ]
    )
    write("gameplay", gameplay)

    # Zen: long, sparse, mostly low.
    zen = sequence(
        [
            (scale[0], 1.6), (scale[4], 2.0),
            (scale[2], 1.6), (scale[1], 2.0),
            (scale[0], 2.4),
        ]
    )
    write("zen", zen)

    # Sprint finish sting: quick rising major-ish run.
    finish = sequence(
        [
            (scale[0], 0.12), (scale[2], 0.12), (scale[3], 0.12),
            (scale[4], 0.12), (scale[5], 0.35),
        ]
    )
    write("finish", finish)


if __name__ == "__main__":
    main()
