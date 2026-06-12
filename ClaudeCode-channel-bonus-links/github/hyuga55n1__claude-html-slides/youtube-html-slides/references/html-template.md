# HTML スライド デザインパターン

## CSS 変数・フォント設定

```html
<link href="https://fonts.googleapis.com/css2?family=Shippori+Mincho+B1:wght@400;600;800&family=Noto+Sans+JP:wght@400;500;700;900&display=swap" rel="stylesheet">

<style>
:root {
  --c1:    {メインカラー};       /* 例: #42A4AF */
  --c2:    {サブカラー};         /* 例: #5DCDC4 */
  --text:  {テキストカラー};     /* 例: #333333 */
  --muted: {薄いテキスト};       /* c1 の薄め or #6b7c80 */
  --pale:  rgba({c2のRGB}, .08); /* 薄い背景 */
  --light: rgba({c2のRGB}, .15); /* やや濃い背景 */
  --border:{境界線};             /* 例: #d4ecea */
  --red:   #c0392b;
  --redbg: #fdecea;
}

body {
  font-family: 'Noto Sans JP', sans-serif;
  background: {c1を暗くした色};  /* 例: #a8cece */
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  min-height: 100vh;
  gap: 1.5vh;
}
</style>
```

---

## ステージ・スライド基本構造

```html
<div class="stage" id="stage">
  <div class="slide active" id="s1">...</div>
  <div class="slide" id="s2">...</div>
</div>

<div class="nav">
  <button id="prev" onclick="go(-1)" disabled>◀</button>
  <div class="dots" id="dots"></div>
  <button id="next" onclick="go(1)">▶</button>
  <div class="ct" id="ct"></div>
</div>
```

```css
.stage {
  width: min(95vw, 95vh * 16/9);
  aspect-ratio: 16/9;
  position: relative;
  border-radius: .5vw;
  box-shadow: 0 1vw 3vw rgba(0,0,0,.3);
  overflow: hidden;
}
.slide {
  position: absolute; inset: 0;
  background: #fff;
  display: none; flex-direction: column;
}
.slide.active { display: flex; }
```

---

## ヘッダーパターン

### グラデーションバー（細い）
```css
.topbar {
  height: .7%;
  background: linear-gradient(90deg, var(--c1), var(--c2));
  flex-shrink: 0;
}
```

### カラーヘッダー（パート+タイトル表示）
```css
.header {
  background: linear-gradient(135deg, var(--c1) 0%, var(--c2) 100%);
  flex-shrink: 0;
  padding: 0 5%; height: 9%;
  display: flex; align-items: center; gap: 2%;
}
.header .pill {
  background: rgba(255,255,255,.22); color: #fff;
  font-size: 1vw; font-weight: 700;
  padding: .3% 1.3%; border-radius: 10vw;
}
.header .ttl {
  font-family: 'Shippori Mincho B1', serif;
  font-size: 1.25vw; font-weight: 600;
  color: rgba(255,255,255,.9);
}
```

---

## ボディ・タイポグラフィ

```css
.body {
  flex: 1; padding: 4% 6%;
  display: flex; flex-direction: column;
  gap: 3%; overflow: hidden;
}

/* セクションタイトル（左ボーダー付き） */
.sec-title {
  font-family: 'Shippori Mincho B1', serif;
  font-size: 2vw; font-weight: 800; color: var(--text);
  line-height: 1.4;
  border-left: .4vw solid var(--c2); padding-left: 1.5%;
}

/* リード文 */
.lead {
  font-size: 1.25vw; color: var(--muted); line-height: 1.8;
}

/* 大きい引用テキスト */
.big {
  font-family: 'Shippori Mincho B1', serif;
  font-size: 2.6vw; font-weight: 800; color: var(--text); line-height: 1.55;
}
.big em { color: var(--c1); font-style: normal; }
```

---

## グリッド・カード

```css
.cols { display: grid; flex: 1; gap: 2.5%; align-content: stretch; align-items: stretch; }
.c2 { grid-template-columns: 1fr 1fr; }
.c3 { grid-template-columns: 1fr 1fr 1fr; }
.c4 { grid-template-columns: 1fr 1fr 1fr 1fr; }

.card {
  background: var(--pale); border-radius: .7vw;
  padding: 4% 5%;
  display: flex; flex-direction: column; gap: 5%;
}
.card.top  { border-top: .3vw solid var(--c1); }
.card.left { border-left: .35vw solid var(--c2); border-radius: 0 .7vw .7vw 0; }
.card.red  { background: var(--redbg); }

.card h3 {
  font-family: 'Shippori Mincho B1', serif;
  font-size: 1.25vw; font-weight: 800; color: var(--c1); line-height: 1.4;
}
.card h3.r { color: var(--red); }
.card p { font-size: 1.1vw; color: var(--text); line-height: 1.7; }
.card .num {
  font-family: 'Shippori Mincho B1', serif;
  font-size: 2.4vw; font-weight: 800; color: var(--c1); opacity: .18; line-height: 1;
}
```

---

## リスト・バッジ

```css
.lst { list-style: none; display: flex; flex-direction: column; gap: 3.5%; }
.lst li {
  display: flex; align-items: flex-start; gap: 2.5%;
  font-size: 1.15vw; color: var(--text); line-height: 1.6;
}
.lst li .i { font-size: 1.15vw; flex-shrink: 0; }
.lst li.ok .i { color: var(--c2); }
.lst li.ng .i { color: var(--red); }
.lst li.ng    { color: #999; }

.bdg { display: inline-block; font-size: 1.05vw; font-weight: 700; padding: .25% 1.1%; border-radius: 10vw; }
.bdg.ok { background: var(--light); color: var(--c1); }
.bdg.ng { background: var(--redbg); color: var(--red); }
.bdg.gr { background: #f0f0f0; color: #888; }
```

---

## 表・プロンプトボックス・ハイライト

```css
/* 表 */
.tbl { width:100%; border-collapse:collapse; font-size:1.15vw; }
.tbl th { background:var(--c1); color:#fff; padding:1.5% 2.5%; text-align:left; font-weight:700; }
.tbl td { padding:1.4% 2.5%; border-bottom:.1vw solid var(--border); color:var(--text); vertical-align:middle; }
.tbl tr:nth-child(even) td { background: var(--pale); }

/* プロンプトボックス */
.prompt {
  background: #f4fafa; border-left: .4vw solid var(--c1);
  border-radius: 0 .5vw .5vw 0; padding: 1.5% 2.5%;
  font-family: 'Courier New', monospace; font-size: 1.15vw; color: var(--text); line-height: 1.7;
}
.prompt .hi { color: var(--c1); font-weight: 700; }

/* ハイライトボックス */
.hlbox { background: var(--light); border-radius: .7vw; padding: 3% 5%; text-align: center; }
.hlbox .t {
  font-family: 'Shippori Mincho B1', serif;
  font-size: 1.6vw; font-weight: 800; color: var(--c1); line-height: 1.5;
}
```

---

## タイトルスライド

```css
#s1 {
  background: linear-gradient(135deg, var(--c1) 0%, var(--c2) 100%);
  justify-content: center; align-items: flex-start;
  padding: 7% 9%; gap: 2.5%;
}
#s1 .ey { font-size: 1.1vw; color: rgba(255,255,255,.75); letter-spacing: .18em; }
#s1 h1 {
  font-family: 'Shippori Mincho B1', serif;
  font-size: 4.5vw; font-weight: 800; color: #fff; line-height: 1.25;
}
#s1 .sub { font-size: 1.3vw; color: rgba(255,255,255,.78); line-height: 1.6; }
#s1 .deco {
  position: absolute; right: 6%; top: 50%; transform: translateY(-50%);
  font-size: 17vw; font-weight: 900; color: rgba(255,255,255,.07);
  font-family: 'Courier New', monospace; pointer-events: none; line-height: 1;
}
```

```html
<div class="slide" id="s1">
  <div class="ey">テーマカテゴリ × キーワード</div>
  <h1>タイトル1行目<br>タイトル2行目</h1>
  <div class="sub">サブタイトル説明文</div>
  <div class="deco">&lt;/&gt;</div>
</div>
```

---

## パート見出しスライド

```css
.part-slide {
  justify-content: center; align-items: flex-start;
  padding: 7% 9%; gap: 2%;
}
.part-slide::before {
  content: ''; position: absolute; top: 0; left: 0; right: 0; height: .7%;
  background: linear-gradient(90deg, var(--c1), var(--c2));
}
.part-slide .pl { font-size: 1.1vw; font-weight: 700; color: var(--c2); letter-spacing: .15em; }
.part-slide h2 {
  font-family: 'Shippori Mincho B1', serif;
  font-size: 3.8vw; font-weight: 800; color: var(--text); line-height: 1.3;
}
.part-slide h2 em { color: var(--c1); font-style: normal; }
.part-slide .desc { font-size: 1.25vw; color: var(--muted); line-height: 1.7; max-width: 65%; }
.part-slide .pdeco {
  position: absolute; right: 6%; bottom: 4%;
  font-family: 'Shippori Mincho B1', serif;
  font-size: 11vw; font-weight: 800; color: var(--c2); opacity: .09; line-height: 1; pointer-events: none;
}
```

```html
<div class="slide part-slide" id="sX">
  <div class="pl">Part N</div>
  <h2>パートタイトル<br><em>強調キーワード</em></h2>
  <div class="desc">このパートで伝えること</div>
  <div class="pdeco">0N</div>
</div>
```

---

## ナビゲーション（JS含む）

```html
<div class="nav">
  <button id="prev" onclick="go(-1)" disabled>◀</button>
  <div class="dots" id="dots"></div>
  <button id="next" onclick="go(1)">▶</button>
  <div class="ct" id="ct"></div>
</div>

<script>
const slides = document.querySelectorAll('.slide');
const total = slides.length;
let cur = 0;
const dotsEl = document.getElementById('dots');
slides.forEach((_, i) => {
  const d = document.createElement('div');
  d.className = 'dot' + (i === 0 ? ' active' : '');
  d.onclick = () => jump(i);
  dotsEl.appendChild(d);
});
function update() {
  slides.forEach((s, i) => s.classList.toggle('active', i === cur));
  document.querySelectorAll('.dot').forEach((d, i) => d.classList.toggle('active', i === cur));
  document.getElementById('prev').disabled = cur === 0;
  document.getElementById('next').disabled = cur === total - 1;
  document.getElementById('ct').textContent = (cur + 1) + ' / ' + total;
}
function go(d) { jump(cur + d); }
function jump(n) { cur = Math.max(0, Math.min(total - 1, n)); update(); }
document.addEventListener('keydown', e => {
  if (e.key === 'ArrowRight' || e.key === 'ArrowDown') go(1);
  if (e.key === 'ArrowLeft'  || e.key === 'ArrowUp')   go(-1);
});
update();
</script>
```

```css
/* ナビ共通 */
.nav { display: flex; align-items: center; gap: 1.5vw; }
.nav button {
  background: var(--c1); border: none; color: #fff;
  font-size: 1.1vw; padding: .5vw 1.6vw; border-radius: .4vw; cursor: pointer;
}
.nav button:hover { opacity: .75; }
.nav button:disabled { opacity: .2; cursor: default; }
.nav .ct { font-size: 1vw; color: #fff; min-width: 5vw; text-align: center; opacity: .8; }
.dots { display: flex; gap: .45vw; align-items: center; flex-wrap: wrap; justify-content: center; max-width: 45vw; }
.dot { width: .55vw; height: .55vw; border-radius: 50%; background: rgba(255,255,255,.4); cursor: pointer; flex-shrink: 0; }
.dot.active { background: #fff; transform: scale(1.5); }
```

---

## よくある落とし穴

- `flex:1` をカラムに使うとき、親の `.body` も `flex-direction:column` で高さが確定していること
- カード内テキストが溢れるとき → `font-size` を `vw` 単位で小さくする（例: 1.1vw → 1vw）
- スライドが上に偏るとき → `.body` に `justify-content: space-between` か `gap` を調整
- グリッドカードの高さが揃わないとき → `.cols` に `align-items: stretch` を追加
