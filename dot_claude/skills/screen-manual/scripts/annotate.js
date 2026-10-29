// ページに注釈を重ねるヘルパー。javascript_tool でこのファイルの中身をそのまま評価して window.__annot を定義する。
// ページ遷移（フルロード）で消えるため、遷移後は再度注入する。SPA 内の遷移では残る。
window.__annot = {
  numerals: ['①', '②', '③', '④', '⑤', '⑥', '⑦', '⑧', '⑨'],

  // すべての注釈とマスクを消す。撮影が終わるたびに呼ぶ。
  clear() {
    document.querySelectorAll('.__annot').forEach((e) => e.remove());
  },

  // el を赤枠で囲み、丸数字のラベルを付ける。
  // pos が 'left' なら枠の左に縦中央でラベルを置く（フォーム項目向け。項目名と入力欄の間の余白に収まる）。
  // それ以外は枠の上に置き、右端にはみ出すときは左へ寄せ、上にはみ出すときは枠の下に置く（ボタン・リンク向け）。
  // el には getBoundingClientRect を持つ任意のオブジェクトを渡せるので、複数要素をまとめて囲むときは矩形を自作して渡す。
  box(el, num, label, pos) {
    const r = el.getBoundingClientRect();
    const pad = 6;
    const b = document.createElement('div');
    b.className = '__annot';
    Object.assign(b.style, {
      position: 'fixed', left: (r.left - pad) + 'px', top: (r.top - pad) + 'px',
      width: (r.width + pad * 2) + 'px', height: (r.height + pad * 2) + 'px',
      border: '3px solid #d32f2f', borderRadius: '4px', zIndex: 99999,
      pointerEvents: 'none', boxSizing: 'border-box',
    });
    document.body.appendChild(b);
    const n = document.createElement('div');
    n.className = '__annot';
    n.textContent = this.numerals[num - 1] + (label ? ' ' + label : '');
    Object.assign(n.style, {
      position: 'fixed', left: '0px', top: '0px', background: '#d32f2f', color: '#fff',
      font: 'bold 16px/26px sans-serif', padding: '0 8px', borderRadius: '4px',
      zIndex: 99999, pointerEvents: 'none', whiteSpace: 'nowrap',
    });
    document.body.appendChild(n);
    const w = n.getBoundingClientRect().width;
    let left;
    let top;
    if (pos === 'left') {
      left = r.left - pad - w - 10;
      top = r.top + (r.height - 26) / 2;
    } else {
      left = r.left - pad;
      if (left + w > innerWidth - 8) left = innerWidth - 8 - w;
      top = r.top - pad - 30;
      if (top < 0) top = r.bottom + pad + 4;
    }
    n.style.left = left + 'px';
    n.style.top = top + 'px';
  },

  // el をグレーで塗りつぶす。個人が分かる表示を隠す。
  mask(el) {
    const r = el.getBoundingClientRect();
    const m = document.createElement('div');
    m.className = '__annot';
    Object.assign(m.style, {
      position: 'fixed', left: r.left + 'px', top: r.top + 'px',
      width: r.width + 'px', height: r.height + 'px',
      background: '#9e9e9e', zIndex: 99998, pointerEvents: 'none',
    });
    document.body.appendChild(m);
  },

  // 表示テキストが text と一致する末端要素を隠す。ヘッダーのユーザー名など。
  maskText(text) {
    const el = [...document.querySelectorAll('body *')]
      .find((e) => e.children.length === 0 && e.textContent.trim() === text);
    if (el) this.mask(el);
    return !!el;
  },

  // ラベル文字列から入力欄を引き、MUI の枠（.MuiInputBase-root）があればそれを囲む。
  // aria-label か <label> の文字で一致させる。
  field(labelText) {
    const inp = [...document.querySelectorAll('input,textarea')].find((i) =>
      (i.getAttribute('aria-label') || '') === labelText
      || (i.labels && [...i.labels].some((l) => l.textContent.trim() === labelText)));
    return inp ? (inp.closest('.MuiInputBase-root') || inp) : null;
  },

  // 表示テキストが text と一致するボタンかリンクを返す。
  button(text) {
    return [...document.querySelectorAll('a,button,[role=button]')]
      .find((e) => e.textContent.trim() === text) || null;
  },

  // 複数要素をまとめて囲むための矩形を作る。
  rect(left, top, right, bottom) {
    return { getBoundingClientRect: () => ({ left, top, right, bottom, width: right - left, height: bottom - top }) };
  },
};
'annot ready';
