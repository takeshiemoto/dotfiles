#!/usr/bin/env python3
"""ふだんの流れ の手書き風シーケンス図を、固定の設計で SVG に描く。

使い方: python3 sequence.py spec.txt > seq.svg

spec の書式（1 行 1 項目、空行と # 行は無視）:
  participants: ブラウザ, アプリ, Redis, S3
  1: ブラウザ -> アプリ: ファイルを送る | POST /upload 5MB
  2: アプリ --> ブラウザ: 受領を返す | 200 OK
  3!: アプリ -> S3: 分割を 1 つ送る | PUT part 1
  repeat: 40 回くり返す
  4: S3 -> アプリ: 受領証を返す | ETag "9b2c…"
  end

  ->  は依頼、--> は返事（破線）。番号の後ろの ! は問題が起きる手順。
  | の後ろは、その時やり取りされる実際の値（省略可）。
  repeat … end で囲んだ手順は、くり返しの枠に入る。
"""
import html
import sys

WIDTH = 720
TOP = 16
BOX_H = 44
HEAD = TOP + BOX_H + 28
ROW = 60
BOTTOM = 24
LABEL_MAX = 14
VALUE_MAX = 26


def esc(s):
    return html.escape(s, quote=True)


def text_w(s, size):
    return sum(size if ord(c) > 0x2E7F else size * 0.56 for c in s) + 8


def bg(x, y, s, size, anchor):
    w = text_w(s, size)
    left = x - w / 2 if anchor == "middle" else x - 4
    return f'<rect class="label-bg" x="{left:.1f}" y="{y - size + 2:.1f}" width="{w:.1f}" height="{size + 4}"/>'


def parse(lines):
    participants, steps = [], []
    for raw in lines:
        line = raw.strip()
        if not line or line.startswith("#"):
            continue
        if line.startswith("participants:"):
            participants = [p.strip() for p in line.split(":", 1)[1].split(",") if p.strip()]
        elif line.startswith("repeat:"):
            steps.append({"kind": "repeat", "label": line.split(":", 1)[1].strip()})
        elif line == "end":
            steps.append({"kind": "end"})
        else:
            num, rest = line.split(":", 1)
            problem = num.endswith("!")
            num = num.rstrip("!").strip()
            route, text = rest.split(":", 1)
            dashed = "-->" in route
            src, dst = [s.strip() for s in route.split("-->" if dashed else "->")]
            label, _, value = text.partition("|")
            label, value = label.strip(), value.strip()
            if len(label) > LABEL_MAX:
                sys.exit(f"手順 {num} のラベルが {LABEL_MAX} 字を超えています: {label}")
            if len(value) > VALUE_MAX:
                sys.exit(f"手順 {num} の値が {VALUE_MAX} 字を超えています: {value}")
            for p in (src, dst):
                if p not in participants:
                    sys.exit(f"手順 {num} の {p} が participants にありません")
            steps.append({"kind": "msg", "num": num, "src": src, "dst": dst, "label": label,
                          "value": value, "dashed": dashed, "problem": problem})
    if not participants:
        sys.exit("participants: 行がありません")
    return participants, steps


def render(participants, steps):
    n = len(participants)
    slot = (WIDTH - 32) / n
    box_w = min(150, slot - 16)
    xs = [16 + slot * i + slot / 2 for i in range(n)]
    rows = sum(1 for s in steps if s["kind"] == "msg")
    repeats = sum(1 for s in steps if s["kind"] == "repeat")
    height = HEAD + rows * ROW + repeats * 42 + BOTTOM
    out = []
    out.append(f'<svg viewBox="0 0 {WIDTH} {int(height)}" role="img" aria-label="ふだんの流れのシーケンス図" class="seq">')
    out.append('<defs><filter id="sketch" x="-2%" y="-2%" width="104%" height="104%">'
               '<feTurbulence type="fractalNoise" baseFrequency="0.035" numOctaves="2" seed="7" result="n"/>'
               '<feDisplacementMap in="SourceGraphic" in2="n" scale="2.4" xChannelSelector="R" yChannelSelector="G"/>'
               '</filter></defs>')
    out.append('<g filter="url(#sketch)" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">')
    for x in xs:
        out.append(f'<rect x="{x - box_w / 2:.1f}" y="{TOP}" width="{box_w:.1f}" height="{BOX_H}" rx="6"/>')
        out.append(f'<line x1="{x:.1f}" y1="{TOP + BOX_H}" x2="{x:.1f}" y2="{height - BOTTOM + 8:.1f}" stroke-dasharray="7 6" stroke-width="1.4"/>')
    y = HEAD
    open_repeat = None
    texts = []
    for s in steps:
        if s["kind"] == "repeat":
            open_repeat = (y, s["label"])
            y += 28
            continue
        if s["kind"] == "end":
            if open_repeat:
                y0, label = open_repeat
                out.append(f'<rect x="28" y="{y0:.1f}" width="{WIDTH - 56}" height="{y - y0 + 4:.1f}" rx="4" stroke-width="1.4"/>')
                texts.append(bg(44, y0 + 6, label, 15, "start"))
                texts.append(f'<text x="44" y="{y0 + 6:.1f}" font-size="15">{esc(label)}</text>')
                open_repeat = None
                y += 14
            continue
        a, b = xs[participants.index(s["src"])], xs[participants.index(s["dst"])]
        sw = 3.4 if s["problem"] else 1.8
        dash = ' stroke-dasharray="8 6"' if s["dashed"] else ""
        ay = y + 30
        if a == b:
            out.append(f'<path d="M{a:.1f} {ay - 10} h44 v20 h-38" stroke-width="{sw}"{dash}/>')
            out.append(f'<path d="M{a + 16:.1f} {ay + 2} l-10 8 l10 8" stroke-width="{sw}"/>')
            lx = a + 54
            anchor = "start"
        else:
            d = 1 if b > a else -1
            out.append(f'<line x1="{a:.1f}" y1="{ay}" x2="{b - d * 4:.1f}" y2="{ay}" stroke-width="{sw}"{dash}/>')
            out.append(f'<path d="M{b - d * 14:.1f} {ay - 8} L{b - d * 2:.1f} {ay} L{b - d * 14:.1f} {ay + 8}" stroke-width="{sw}"/>')
            lx = (a + b) / 2
            anchor = "middle"
        cx = a - 14 if (a == b or b > a) else a + 14
        out.append(f'<circle cx="{cx:.1f}" cy="{ay - 20:.1f}" r="11" stroke-width="{1.8 if not s["problem"] else 3}"/>')
        texts.append(f'<text x="{cx:.1f}" y="{ay - 15:.1f}" text-anchor="middle" font-size="15" font-weight="700">{esc(s["num"])}</text>')
        texts.append(bg(lx, ay - 8, s["label"], 16, anchor))
        texts.append(f'<text x="{lx:.1f}" y="{ay - 8:.1f}" text-anchor="{anchor}" font-size="16">{esc(s["label"])}</text>')
        if s["value"]:
            texts.append(bg(lx, ay + 20, s["value"], 15, anchor))
            texts.append(f'<text x="{lx:.1f}" y="{ay + 20:.1f}" text-anchor="{anchor}" font-size="15" font-family="ui-monospace, Menlo, monospace">{esc(s["value"])}</text>')
        y += ROW
    out.append("</g>")
    for x, p in zip(xs, participants):
        out.append(f'<text x="{x:.1f}" y="{TOP + BOX_H / 2 + 6:.1f}" text-anchor="middle" font-size="17" font-weight="700">{esc(p)}</text>')
    out.extend(texts)
    out.append("</svg>")
    return "\n".join(out)


if __name__ == "__main__":
    if len(sys.argv) != 2:
        sys.exit(__doc__)
    with open(sys.argv[1], encoding="utf-8") as f:
        participants, steps = parse(f.readlines())
    print(render(participants, steps))
