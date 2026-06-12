#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
runway-mcp-prompts-100 ビルドスクリプト

単一ソース (PROMPTS データ) から、人間用 PROMPTS.md と機械用 prompts.json を
同期ズレなく生成する。プロンプトを追記・修正したらこのファイルだけを編集し、
`python3 build.py` を実行すれば両方の出力が更新される。

prompt は Runway Gen-4 系の動画生成に最適化した英語の完成文（キーワード羅列ではなく
被写体＋動き＋カメラワーク＋光＋スタイルを1〜2文で記述）。note は日本語の用途・ねらい。
"""

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parent

# カテゴリ表示名（出力の章立て順を兼ねる）
CATEGORIES = [
    ("cinematic", "シネマティック / 映画的ショット"),
    ("camera", "カメラワーク / ダイナミックムーブ"),
    ("nature", "自然・風景の動き"),
    ("people", "人物・ポートレートの動き"),
    ("product", "プロダクト・コマーシャル"),
    ("urban", "都市・建築・空撮"),
    ("fantasy", "ファンタジー・SF"),
    ("action", "アクション・スポーツ"),
    ("anime", "アニメ・イラスト調モーション"),
    ("abstract", "抽象・モーショングラフィックス"),
    ("food", "料理・フード"),
    ("mood", "天候・時間帯・ムード転換"),
]

# id は最後にまとめて採番するのでここでは順序だけ意識して並べる
PROMPTS = [
    # === cinematic (12) ===
    dict(category="cinematic", ratio="16:9", duration="10s",
         prompt="A lone traveler stands at the edge of a cliff at dawn, the camera slowly pushing in from behind as warm golden light spreads across a sea of clouds below, gentle wind moving the coat, anamorphic lens with soft flares, epic cinematic mood.",
         note="用途: 映画的オープニング。ねらい: 背後からの緩いプッシュイン＋雲海で壮大さを演出。"),
    dict(category="cinematic", ratio="16:9", duration="10s",
         prompt="Interior of a quiet cafe in late afternoon, a woman reads by the window while dust particles drift through a shaft of warm sunlight, the camera drifts in a slow lateral dolly, shallow depth of field, 35mm film grain, intimate and nostalgic.",
         note="用途: ドラマの日常シーン。ねらい: 横ドリー＋逆光の塵で空気感と情緒を出す。"),
    dict(category="cinematic", ratio="16:9", duration="10s",
         prompt="A detective walks down a rain-slicked neon alley at night, reflections shimmering on the wet asphalt, the camera tracking backward to lead him, volumetric haze, teal and magenta color grade, moody neo-noir atmosphere.",
         note="用途: ネオノワール。ねらい: バックトラッキングで主役を導き、濡れた路面の反射で質感UP。"),
    dict(category="cinematic", ratio="16:9", duration="10s",
         prompt="Two figures sit across a candlelit table in a dim restaurant, the camera performs a slow arc around them, flickering warm light on their faces, soft bokeh in the background, romantic and tense cinematic tone.",
         note="用途: 対話・緊張シーン。ねらい: ゆっくりアーク(オービット)で二人の関係性を強調。"),
    dict(category="cinematic", ratio="16:9", duration="10s",
         prompt="A wide establishing shot of a lighthouse on a stormy coast, waves crashing against the rocks, the camera slowly cranes upward to reveal the full cliff, dramatic overcast light, desaturated cool palette, somber epic feel.",
         note="用途: 物語の場面転換(エスタブリッシング)。ねらい: クレーンアップで全景を開示。"),
    dict(category="cinematic", ratio="16:9", duration="5s",
         prompt="Extreme close-up of an old man's weathered eyes slowly opening, faint reflection of a fire in the pupils, the camera holds almost still with a barely perceptible push-in, warm low-key lighting, deeply emotional and quiet.",
         note="用途: 感情の決め画。ねらい: 微速プッシュインで瞳の反射に視線を集める。"),
    dict(category="cinematic", ratio="16:9", duration="10s",
         prompt="A vintage train cuts through a misty autumn valley at golden hour, the camera follows in a sweeping side-tracking shot from a parallel track, steam trailing behind, warm amber light, romantic period-film aesthetic.",
         note="用途: ピリオド作品。ねらい: 並走サイドトラッキングでスピードと郷愁を両立。"),
    dict(category="cinematic", ratio="16:9", duration="10s",
         prompt="A child runs through a field of tall golden wheat toward the setting sun, the camera tracks low and fast just behind, stalks brushing the lens, lens flare blooming, hopeful and nostalgic cinematic tone.",
         note="用途: 感動系CM/MV。ねらい: 低い追走＋穂が掠めるレンズで没入感。"),
    dict(category="cinematic", ratio="2.39:1", duration="10s",
         prompt="A samurai stands motionless in a bamboo forest as wind sweeps through the leaves, the camera slowly orbits to reveal his silhouette against shafts of light, particles floating, anamorphic widescreen, meditative and tense.",
         note="用途: 時代劇/アクション前の静。ねらい: オービットで緊張を溜める一枚絵。"),
    dict(category="cinematic", ratio="16:9", duration="10s",
         prompt="A solitary car drives along an empty desert highway at dusk, shot from a high three-quarter angle, the camera slowly descending toward road level, long shadows stretching, warm-to-cool gradient sky, road-movie mood.",
         note="用途: ロードムービー。ねらい: 俯瞰→路面へ降りるカメラで孤独感と移動感。"),
    dict(category="cinematic", ratio="16:9", duration="5s",
         prompt="Slow motion close-up of a single tear rolling down a cheek under soft window light, the camera holds steady, shallow focus, muted color grade, raw and intimate emotional beat.",
         note="用途: 感情のクライマックス。ねらい: スローモーション＋浅い被写界深度で繊細さを。"),
    dict(category="cinematic", ratio="16:9", duration="10s",
         prompt="A grand ballroom seen from above as couples waltz in unison, the camera spirals slowly downward into the crowd, chandeliers glowing, elegant warm light, sweeping romantic period atmosphere.",
         note="用途: 華やかな群衆シーン。ねらい: 俯瞰からの螺旋降下で優雅さとスケール。"),

    # === camera (12) ===
    dict(category="camera", ratio="16:9", duration="5s",
         prompt="Fast dolly-in toward a closed wooden door at the end of a dark hallway, the door slowly creaking open to reveal soft light beyond, handheld micro-shake, suspenseful build-up.",
         note="用途: サスペンスの引き。ねらい: 高速ドリーイン＋微ブレで緊張を作る。"),
    dict(category="camera", ratio="16:9", duration="5s",
         prompt="Smooth crane-up from a street-level view of a busy market to a sweeping overhead shot of the whole plaza, people moving below, continuous motion, bright daylight, energetic reveal.",
         note="用途: 規模の開示。ねらい: クレーンアップで地上→俯瞰の連続移動。"),
    dict(category="camera", ratio="16:9", duration="5s",
         prompt="360-degree orbit around a parked sports car on a rooftop at sunset, reflections sweeping across the glossy paint, the city skyline rotating behind, smooth gimbal motion, premium commercial look.",
         note="用途: 車/プロダクトCM。ねらい: 360°オービットで全周のディテールを見せる。"),
    dict(category="camera", ratio="9:16", duration="5s",
         prompt="Vertical FPV drone shot diving down a forested mountainside and pulling up just above a river, fast continuous motion, motion blur on the edges, exhilarating first-person speed.",
         note="用途: 縦型ショート/旅。ねらい: FPVドローンの一気のダイブで爽快感。9:16。"),
    dict(category="camera", ratio="16:9", duration="5s",
         prompt="Whip pan transition from a spinning coin on a table to a busy casino floor, motion-blurred sweep connecting the two, energetic and slick, neon ambient light.",
         note="用途: 場面転換トランジション。ねらい: ウィップパンで2カットを繋ぐ。"),
    dict(category="camera", ratio="16:9", duration="5s",
         prompt="Slow vertical tilt from a character's muddy boots up to their determined face, rain falling, the camera steady and deliberate, dramatic low-key lighting, heroic reveal.",
         note="用途: キャラ登場。ねらい: 足元→顔のティルトアップで主役を印象づける。"),
    dict(category="camera", ratio="16:9", duration="5s",
         prompt="Dolly-zoom (vertigo effect) on a man standing frozen on a bridge as the background stretches and warps behind him, unsettling perspective shift, cool overcast light, psychological tension.",
         note="用途: 心理的動揺の表現。ねらい: ドリーズーム(めまいショット)で不安感を視覚化。"),
    dict(category="camera", ratio="16:9", duration="10s",
         prompt="Continuous one-take following a waiter as he weaves through a crowded kitchen and out into a dining hall, the camera gliding smoothly behind, warm practical lights, immersive long-take energy.",
         note="用途: 没入ワンカット。ねらい: 長回し追走で空間の連続性と臨場感。"),
    dict(category="camera", ratio="16:9", duration="5s",
         prompt="Low-angle tracking shot racing alongside running feet on wet pavement, water splashing toward the lens, fast lateral motion, gritty urban energy, shallow focus.",
         note="用途: 疾走感。ねらい: ローアングル並走＋水しぶきでスピードを強調。"),
    dict(category="camera", ratio="16:9", duration="5s",
         prompt="Overhead top-down shot slowly rotating above a chef plating a dish on a marble counter, hands moving precisely, soft even light, satisfying symmetrical composition.",
         note="用途: 料理/作業の俯瞰。ねらい: トップダウン回転で手元の所作を魅せる。"),
    dict(category="camera", ratio="9:16", duration="5s",
         prompt="Vertical push-in from a wide shot of a person on a train platform to a tight close-up of their face as a train rushes past behind, hair blown by the wind, dramatic urban moment.",
         note="用途: 縦型ドラマ。ねらい: 引き→寄りのプッシュインで感情に接近。9:16。"),
    dict(category="camera", ratio="16:9", duration="5s",
         prompt="Handheld over-the-shoulder shot following two friends walking and talking through a sunlit park, natural sway and breathing motion, dappled light, documentary realism.",
         note="用途: 自然な会話シーン。ねらい: 手持ちOTSでドキュメンタリー的リアリティ。"),

    # === nature (10) ===
    dict(category="nature", ratio="16:9", duration="10s",
         prompt="Time-lapse of storm clouds rolling over a green mountain range, shadows sweeping across the valleys, light beams breaking through, the camera holds a wide static frame, awe-inspiring scale.",
         note="用途: 自然ドキュメンタリー。ねらい: 雲のタイムラプス＋光芒でダイナミズム。"),
    dict(category="nature", ratio="16:9", duration="10s",
         prompt="A waterfall cascading into a turquoise pool deep in a misty jungle, water spray catching the light, the camera slowly tracks forward through hanging vines, lush and serene.",
         note="用途: 旅/癒し系。ねらい: 蔓を抜ける前進移動で奥行きと神秘性。"),
    dict(category="nature", ratio="16:9", duration="10s",
         prompt="Aerial shot gliding low over a calm ocean at sunrise, gentle waves rippling, the camera skimming just above the surface toward the glowing horizon, warm reflections, tranquil and vast.",
         note="用途: オープニング/瞑想系。ねらい: 海面すれすれの低空飛行で広がりと静けさ。"),
    dict(category="nature", ratio="16:9", duration="5s",
         prompt="Macro shot of a dewdrop trembling on a green leaf at dawn, tiny reflections of the sky inside it, the camera slowly pulling back to reveal a spider web glistening, delicate and quiet.",
         note="用途: イントロ/質感カット。ねらい: マクロ→引きで小宇宙感を演出。"),
    dict(category="nature", ratio="16:9", duration="10s",
         prompt="Northern lights swirling in green and violet over a snowy pine forest, stars twinkling, the camera slowly tilting up from the trees to the sky, cold crisp air, magical and calm.",
         note="用途: 絶景/神秘。ねらい: 樹木→空のティルトアップでオーロラを開示。"),
    dict(category="nature", ratio="16:9", duration="10s",
         prompt="A field of lavender swaying in the wind under a bright summer sky, bees drifting between the flowers, the camera tracking slowly sideways at flower height, vivid colors, peaceful.",
         note="用途: 季節/CM。ねらい: 花の高さの横移動で揺れと色彩を活かす。"),
    dict(category="nature", ratio="16:9", duration="5s",
         prompt="Slow motion of autumn leaves falling and swirling in a gentle gust along a forest path, warm amber and red tones, the camera drifting backward down the trail, nostalgic.",
         note="用途: 秋の情景。ねらい: スロー＋後退移動で落葉の舞いを丁寧に。"),
    dict(category="nature", ratio="16:9", duration="10s",
         prompt="A desert at night under a vast star-filled sky, the Milky Way arcing overhead, gentle time-lapse motion of the stars, the camera static on rolling dunes, silent and infinite.",
         note="用途: 宇宙/瞑想。ねらい: 星の微速タイムラプスで時間の流れを感じさせる。"),
    dict(category="nature", ratio="16:9", duration="10s",
         prompt="Underwater shot drifting through a vibrant coral reef as schools of fish part around the camera, sunlight rays filtering from the surface, slow graceful forward motion, serene and colorful.",
         note="用途: 海洋/癒し。ねらい: 前進移動＋魚群の分かれでスケール感。"),
    dict(category="nature", ratio="16:9", duration="10s",
         prompt="A volcano at twilight with glowing lava flows tracing down its slopes, embers rising into the dark sky, the camera slowly craning up for a wider view, dramatic and primal.",
         note="用途: 迫力の自然。ねらい: クレーンアップで溶岩流の規模を見せる。"),

    # === people (10) ===
    dict(category="people", ratio="9:16", duration="5s",
         prompt="A young woman laughs and turns toward the camera as her hair catches the golden afternoon light, soft natural skin tones, gentle push-in, shallow depth of field, warm and authentic.",
         note="用途: 縦型ポートレート/SNS。ねらい: 振り向き＋逆光でナチュラルな魅力。9:16。"),
    dict(category="people", ratio="16:9", duration="5s",
         prompt="Close-up of a musician closing their eyes while singing into a vintage microphone, warm stage light from the side, subtle head motion, smoky atmosphere, soulful and intimate.",
         note="用途: MV/アーティスト。ねらい: サイド光＋微動で没入する歌唱を表現。"),
    dict(category="people", ratio="16:9", duration="5s",
         prompt="An elderly craftsman carefully carves wood at his workbench, sawdust drifting in warm window light, the camera slowly tracking across the table to his focused hands, documentary warmth.",
         note="用途: 職人/ブランドストーリー。ねらい: 手元への横移動で丁寧さを伝える。"),
    dict(category="people", ratio="9:16", duration="5s",
         prompt="A dancer spins in an empty studio as sunlight streams through tall windows, fabric flowing with the motion, the camera orbiting to follow the turn, airy and graceful.",
         note="用途: ダンス/縦型。ねらい: オービットで回転を追い、布の流れを活かす。9:16。"),
    dict(category="people", ratio="16:9", duration="5s",
         prompt="A businesswoman walks confidently through a glass office lobby, reflections sliding across the panels, the camera tracking backward to lead her, crisp daylight, sleek corporate tone.",
         note="用途: 企業/採用。ねらい: バックトラッキングで自信ある歩みを主役化。"),
    dict(category="people", ratio="16:9", duration="5s",
         prompt="Two children build a sandcastle on a beach at sunset, the camera at low angle slowly pushing in, warm rim light on their hair, gentle waves behind, heartfelt and candid.",
         note="用途: 家族/感動CM。ねらい: ローアングルのプッシュインで子供目線の温かさ。"),
    dict(category="people", ratio="16:9", duration="5s",
         prompt="A barista steams milk and pours latte art in a cozy cafe, the camera drifting from their focused face down to the cup, warm ambient light, inviting lifestyle mood.",
         note="用途: カフェ/ライフスタイル。ねらい: 顔→手元のドリフトで物語性を。"),
    dict(category="people", ratio="9:16", duration="5s",
         prompt="A skateboarder leans against a graffiti wall and looks into the camera with a slight smile, urban breeze moving their clothes, subtle handheld motion, gritty street-style portrait.",
         note="用途: ストリート/縦型。ねらい: 軽い手持ち＋視線でストリートの空気感。9:16。"),
    dict(category="people", ratio="16:9", duration="5s",
         prompt="A scientist in a lab examines a glowing sample under blue light, reflections in their glasses, the camera slowly arcing around them, cool clinical palette, focused and futuristic.",
         note="用途: テック/医療。ねらい: アーク移動＋青光で先進性と集中を演出。"),
    dict(category="people", ratio="16:9", duration="10s",
         prompt="A couple shares an umbrella while walking down a rainy city street at night, neon reflections on the pavement, the camera tracking ahead of them, warm and cool contrast, romantic.",
         note="用途: ロマンス/MV。ねらい: 前方トラッキング＋雨夜のネオンで情緒。"),

    # === product (12) ===
    dict(category="product", ratio="1:1", duration="5s",
         prompt="A sleek wireless earbud case slowly opens on a reflective black surface, soft studio light sweeping across the glossy finish, the camera performing a tight slow orbit, premium tech commercial look.",
         note="用途: ガジェット広告(正方形)。ねらい: 開閉動作＋スローオービットで高級感。1:1。"),
    dict(category="product", ratio="9:16", duration="5s",
         prompt="A bottle of perfume rotates on a marble pedestal as golden light glints off the glass, soft petals falling in the background in slow motion, elegant and luxurious, vertical format.",
         note="用途: コスメ縦型広告。ねらい: 回転＋スロー花弁で上質さを。9:16。"),
    dict(category="product", ratio="16:9", duration="5s",
         prompt="A running shoe splashes through a shallow puddle in slow motion, water droplets frozen mid-air catching the light, the camera tracking laterally with the motion, dynamic sportswear commercial.",
         note="用途: スポーツ用品。ねらい: スロー水しぶき＋横移動で躍動感。"),
    dict(category="product", ratio="1:1", duration="5s",
         prompt="A cup of coffee with rising steam sits on a wooden table, the camera slowly pushing in as morning light shifts across the surface, warm inviting tones, cozy beverage ad.",
         note="用途: 飲料/カフェ広告。ねらい: 湯気＋プッシュインで温かさと香りを想起。1:1。"),
    dict(category="product", ratio="16:9", duration="5s",
         prompt="A luxury watch face catches a sweeping beam of light against a dark background, the second hand ticking, the camera doing an extreme macro slow orbit, refined and premium.",
         note="用途: 時計広告。ねらい: マクロ＋光のスイープで精密さと高級感。"),
    dict(category="product", ratio="9:16", duration="5s",
         prompt="A skincare serum dropper releases a single glistening drop in slow motion against a soft pastel backdrop, gentle ripples spreading, clean and fresh, vertical beauty ad.",
         note="用途: スキンケア縦型。ねらい: スロー液滴で清潔感と効能イメージ。9:16。"),
    dict(category="product", ratio="16:9", duration="5s",
         prompt="A smartphone floats and slowly rotates in a minimalist white studio, the screen lighting up with a soft glow, clean diffused light, the camera holding a steady frame, modern tech ad.",
         note="用途: スマホ/家電。ねらい: 浮遊回転＋画面点灯で機能を主役化。"),
    dict(category="product", ratio="1:1", duration="5s",
         prompt="Fresh ingredients tumble in slow motion into a glass bowl against a bright kitchen backdrop, vibrant colors, the camera locked off, appetizing food-brand commercial.",
         note="用途: 食品ブランド。ねらい: スロー投入で新鮮さとシズル感。1:1。"),
    dict(category="product", ratio="16:9", duration="5s",
         prompt="A pair of designer sunglasses rests on warm sand as a wave gently recedes around it, sunlight glinting off the lenses, the camera slowly pushing in, summer lifestyle ad.",
         note="用途: アパレル/夏物。ねらい: 波の引き＋プッシュインで季節感とブランド世界観。"),
    dict(category="product", ratio="9:16", duration="5s",
         prompt="A can of sparkling drink is cracked open and condensation droplets slide down the cold surface in slow motion, bubbles rising, bright energetic light, refreshing vertical ad.",
         note="用途: 炭酸飲料縦型。ねらい: 結露＋気泡のスローで冷涼感。9:16。"),
    dict(category="product", ratio="16:9", duration="5s",
         prompt="A laptop opens by itself on a clean desk as warm sunrise light fills the room, the screen glowing to life, the camera slowly craning down, aspirational productivity ad.",
         note="用途: PC/SaaS。ねらい: 自動開閉＋朝光で『始まり』の前向きさ。"),
    dict(category="product", ratio="1:1", duration="5s",
         prompt="Chocolate sauce drizzles over a dessert in slow motion under soft studio light, glossy ribbons folding over the surface, rich indulgent tones, mouth-watering food ad.",
         note="用途: スイーツ広告。ねらい: スローのドリズルで濃厚なシズル感。1:1。"),

    # === urban (8) ===
    dict(category="urban", ratio="16:9", duration="10s",
         prompt="Aerial drone shot rising above a dense city skyline at blue hour, thousands of windows glowing, traffic streaking on the streets below, smooth ascending motion, vast metropolitan scale.",
         note="用途: 都市オープニング。ねらい: ドローン上昇で街の規模と光を見せる。"),
    dict(category="urban", ratio="16:9", duration="10s",
         prompt="Hyperlapse moving forward through a busy nighttime intersection, light trails of cars streaking past, neon signs blurring, fast continuous motion, energetic cyberpunk city vibe.",
         note="用途: 都市の躍動。ねらい: ハイパーラプス＋光跡でスピードとエネルギー。"),
    dict(category="urban", ratio="16:9", duration="5s",
         prompt="Low-angle shot looking up at towering glass skyscrapers as clouds drift overhead, the camera slowly rotating, sunlight glinting between the buildings, awe and ambition.",
         note="用途: ビジネス/野心。ねらい: ローアングル回転で高層の威圧感とスケール。"),
    dict(category="urban", ratio="9:16", duration="5s",
         prompt="Vertical shot tracking up a vibrant street market alley strung with colorful lanterns, steam rising from food stalls, people bustling, warm lively atmosphere, travel vlog energy.",
         note="用途: 旅/縦型Vlog。ねらい: 路地を進む縦移動で活気と異国情緒。9:16。"),
    dict(category="urban", ratio="16:9", duration="10s",
         prompt="Drone shot gliding over a coastal city at sunset, the camera banking gently around a hillside of terracotta rooftops toward the sea, warm golden light, idyllic and cinematic.",
         note="用途: 旅行/不動産。ねらい: バンク旋回で街と海の関係を美しく。"),
    dict(category="urban", ratio="16:9", duration="5s",
         prompt="A subway train rushes into a station as the camera holds on the platform, motion blur streaking across the frame, fluorescent light, gritty realistic urban transit moment.",
         note="用途: 都市のリアル。ねらい: 進入する車両のブラーで日常の疾走感。"),
    dict(category="urban", ratio="16:9", duration="10s",
         prompt="Time-lapse of a city square from day to night, crowds flowing like rivers, shadows rotating, lights flickering on as the sky shifts color, dynamic passage of time.",
         note="用途: 時間の経過。ねらい: 昼夜タイムラプスで群衆と光の変化を圧縮。"),
    dict(category="urban", ratio="16:9", duration="5s",
         prompt="A cyclist rides through empty city streets at dawn, long shadows on the asphalt, the camera tracking alongside at street level, soft pink morning light, calm and free.",
         note="用途: 朝/自由。ねらい: 並走トラッキング＋朝光で静かな解放感。"),

    # === fantasy (10) ===
    dict(category="fantasy", ratio="16:9", duration="10s",
         prompt="A glowing dragon soars over a misty mountain range at dawn, its wings beating slowly, the camera flying alongside it through the clouds, epic fantasy scale, warm sunrise light.",
         note="用途: ファンタジー予告。ねらい: 並走飛行で龍のスケールと迫力を。"),
    dict(category="fantasy", ratio="16:9", duration="10s",
         prompt="A floating island with cascading waterfalls drifts among the clouds, ancient ruins glowing on its surface, the camera slowly orbiting the island, dreamlike and majestic.",
         note="用途: 世界観紹介。ねらい: オービットで浮遊島の全貌と神秘を開示。"),
    dict(category="fantasy", ratio="16:9", duration="10s",
         prompt="A spaceship descends through swirling orange clouds toward an alien planet's surface, engines glowing, dust kicking up on landing, the camera tracking the descent, epic sci-fi arrival.",
         note="用途: SF着陸シーン。ねらい: 降下追従＋着地の砂塵で重量感。"),
    dict(category="fantasy", ratio="16:9", duration="10s",
         prompt="A wizard raises a glowing staff in a dark forest as magical particles swirl upward into a vortex of blue light, the camera slowly pushing in, mystical and powerful.",
         note="用途: 魔法発動。ねらい: 粒子の渦＋プッシュインで力の高まりを表現。"),
    dict(category="fantasy", ratio="16:9", duration="10s",
         prompt="A vast futuristic city of glass towers and flying vehicles at twilight, holographic billboards glowing, the camera gliding forward between the buildings, sleek cyberpunk grandeur.",
         note="用途: 近未来都市。ねらい: ビル間の前進飛行でサイバーパンク世界に没入。"),
    dict(category="fantasy", ratio="16:9", duration="5s",
         prompt="A portal of shimmering energy tears open in mid-air in an empty desert, light spilling out and rippling the sand, the camera holding steady, otherworldly and tense.",
         note="用途: 異世界転移。ねらい: ポータル展開＋砂の波紋で超常感。"),
    dict(category="fantasy", ratio="16:9", duration="10s",
         prompt="An enchanted forest at night where glowing mushrooms and floating spirits drift between ancient trees, soft bioluminescent light, the camera slowly weaving through, magical and serene.",
         note="用途: 幻想森。ねらい: 木々を縫う移動＋発光体で幻想的な静けさ。"),
    dict(category="fantasy", ratio="16:9", duration="10s",
         prompt="A lone knight in ornate armor stands before a colossal ancient gate carved with runes, mist swirling at his feet, the camera craning up to reveal the gate's immense scale, epic and foreboding.",
         note="用途: ボス前/関門。ねらい: クレーンアップで巨大さと畏怖を演出。"),
    dict(category="fantasy", ratio="16:9", duration="10s",
         prompt="A mermaid swims gracefully through a sunken temple underwater, beams of light piercing the blue depths, fish darting around her, the camera following in a slow glide, ethereal fantasy.",
         note="用途: 海中ファンタジー。ねらい: 追従グライドで優美さと神秘を両立。"),
    dict(category="fantasy", ratio="16:9", duration="10s",
         prompt="A galaxy-filled nebula of purple and teal gas clouds with stars being born, the camera slowly drifting forward through the cosmic dust, awe-inspiring deep-space spectacle.",
         note="用途: 宇宙/オープニング。ねらい: 星雲内の前進で深宇宙の荘厳さ。"),

    # === action (8) ===
    dict(category="action", ratio="16:9", duration="5s",
         prompt="A motorcyclist leans hard into a sharp mountain curve at high speed, sparks flying from the footpeg, the camera tracking tightly alongside, motion blur on the background, adrenaline-charged.",
         note="用途: バイク/スポーツ。ねらい: 接近並走＋火花で限界のスピード感。"),
    dict(category="action", ratio="16:9", duration="5s",
         prompt="A parkour athlete leaps across a gap between rooftops, the camera following in a fast arc as the city spreads out below, golden hour light, exhilarating and bold.",
         note="用途: パルクール。ねらい: 高速アーク追従で跳躍のスリル。"),
    dict(category="action", ratio="9:16", duration="5s",
         prompt="A surfer carves through the barrel of a massive wave, spray exploding behind, the camera riding low alongside inside the curl, bright ocean light, vertical action energy.",
         note="用途: 縦型スポーツ。ねらい: チューブ内の低い並走で迫力の波。9:16。"),
    dict(category="action", ratio="16:9", duration="5s",
         prompt="Two fighters clash in a neon-lit arena, one throwing a spinning kick in slow motion as sweat sprays into the light, the camera orbiting the impact, intense and dynamic.",
         note="用途: 格闘/対戦。ねらい: スロー＋衝撃点オービットで決定的瞬間。"),
    dict(category="action", ratio="16:9", duration="5s",
         prompt="A race car drifts around a hairpin turn, tire smoke billowing, the camera panning fast to follow, sunlight cutting through the haze, high-octane motorsport excitement.",
         note="用途: モータースポーツ。ねらい: 高速パン＋タイヤスモークで臨場感。"),
    dict(category="action", ratio="16:9", duration="5s",
         prompt="A snowboarder launches off a cliff edge into deep powder, snow spraying into the air, the camera tilting up to follow the jump against a blue sky, freezing crisp light, thrilling.",
         note="用途: ウィンタースポーツ。ねらい: 跳躍をティルトアップで追い開放感。"),
    dict(category="action", ratio="16:9", duration="5s",
         prompt="A sprinter explodes out of the blocks on a track, muscles tensed, the camera tracking laterally at full speed beside them, stadium lights flaring, powerful and fast.",
         note="用途: 陸上/CM。ねらい: 全力並走で爆発的なスタートを切り取る。"),
    dict(category="action", ratio="16:9", duration="5s",
         prompt="A helicopter banks sharply over a canyon at sunset, rotor wash rippling the river below, the camera following in a sweeping chase, dramatic warm light, cinematic action.",
         note="用途: アクション/予告。ねらい: 追跡スイープで峡谷の規模とスピード。"),

    # === anime (6) ===
    dict(category="anime", ratio="16:9", duration="5s",
         prompt="Anime-style scene of a girl with flowing hair standing on a hill as cherry blossoms swirl around her in the wind, the camera slowly pushing in, soft pastel colors, Makoto Shinkai-inspired light.",
         note="用途: アニメMV/OP。ねらい: 桜の舞い＋プッシュインで叙情的な一枚。"),
    dict(category="anime", ratio="16:9", duration="5s",
         prompt="2D anime style, a robot and a child walk together along a railway at sunset, long shadows, the camera tracking sideways, warm nostalgic palette, gentle Ghibli-like atmosphere.",
         note="用途: アニメ物語。ねらい: 横トラッキング＋夕陽でジブリ的な郷愁。"),
    dict(category="anime", ratio="9:16", duration="5s",
         prompt="Anime style, a magical girl spins as her outfit transforms in a burst of sparkles and ribbons, vibrant saturated colors, the camera orbiting her, energetic vertical idol scene.",
         note="用途: 変身/縦型。ねらい: オービット＋キラ粒子で変身バンクの華やかさ。9:16。"),
    dict(category="anime", ratio="16:9", duration="5s",
         prompt="Anime cityscape at night in the rain, a lone character holds an umbrella under glowing signs, reflections on the wet street, subtle rain motion, moody lo-fi anime aesthetic.",
         note="用途: Lo-fi/雰囲気。ねらい: 雨の反射＋微動で落ち着いたアニメの空気。"),
    dict(category="anime", ratio="16:9", duration="5s",
         prompt="Dynamic anime action, a swordsman dashes forward leaving speed lines as energy crackles around the blade, dramatic low angle, the camera snapping to follow, shonen battle intensity.",
         note="用途: バトルアニメ。ねらい: スピード線＋スナップ追従で少年漫画的な勢い。"),
    dict(category="anime", ratio="16:9", duration="5s",
         prompt="Cozy anime interior, steam rising from a bowl of ramen on a wooden counter as warm light glows, gentle camera push-in, detailed food animation, comforting slice-of-life mood.",
         note="用途: 日常/グルメアニメ。ねらい: 湯気＋プッシュインで温かい日常感。"),

    # === abstract (6) ===
    dict(category="abstract", ratio="16:9", duration="5s",
         prompt="Flowing liquid metal morphs and ripples in slow motion, chrome reflections shifting with rainbow highlights, the camera slowly drifting across the surface, hypnotic abstract motion graphics.",
         note="用途: ロゴ前/背景。ねらい: 液体金属のモーフで高級感ある抽象モーション。"),
    dict(category="abstract", ratio="16:9", duration="5s",
         prompt="Colorful ink diffuses and blooms through clear water in slow motion, tendrils swirling into intricate patterns, soft backlight, mesmerizing and organic.",
         note="用途: トランジション/背景。ねらい: インクの拡散で有機的な色彩美。"),
    dict(category="abstract", ratio="16:9", duration="5s",
         prompt="A field of glowing particles flows and reforms into shifting waves of light, deep blue and gold tones, the camera gliding through the cloud, elegant data-visualization aesthetic.",
         note="用途: テック/オープナー。ねらい: 粒子流でデータ的・先進的な雰囲気。"),
    dict(category="abstract", ratio="16:9", duration="5s",
         prompt="Geometric shapes fold and unfold in a satisfying loop against a clean gradient background, soft shadows, smooth easing motion, minimalist 3D motion design.",
         note="用途: 説明/ループ素材。ねらい: 幾何形状の折り畳みでミニマルな動き。"),
    dict(category="abstract", ratio="9:16", duration="5s",
         prompt="Neon light trails weave and pulse in sync to an invisible beat against black, vibrant magenta and cyan, the camera slowly rotating, energetic vertical music visualizer.",
         note="用途: 音楽/縦型ビジュアライザ。ねらい: ネオン軌跡の脈動でビート感。9:16。"),
    dict(category="abstract", ratio="16:9", duration="5s",
         prompt="Slow motion of paint splattering and colliding mid-air in vivid colors against a white void, droplets suspended, the camera drifting around the splash, bold artistic energy.",
         note="用途: アート/CM。ねらい: 空中の絵具衝突で大胆な色のエネルギー。"),

    # === food (3) ===
    dict(category="food", ratio="1:1", duration="5s",
         prompt="A juicy burger is assembled in slow motion as ingredients stack one by one, melted cheese stretching, warm appetizing light, the camera slowly pushing in, mouth-watering food ad.",
         note="用途: フード広告。ねらい: スロー積層＋チーズの伸びでシズル感。1:1。"),
    dict(category="food", ratio="9:16", duration="5s",
         prompt="Pancakes stacked high with butter melting and syrup pouring down in slow motion, steam rising, bright cozy breakfast light, the camera tilting down the stack, vertical food reel.",
         note="用途: 縦型グルメReel。ねらい: シロップの流下で食欲を刺激。9:16。"),
    dict(category="food", ratio="16:9", duration="5s",
         prompt="A knife slices through a perfectly cooked steak revealing a juicy pink interior, steam curling up, warm restaurant light, the camera holding a tight macro, premium culinary shot.",
         note="用途: レストラン/高級食材。ねらい: 断面マクロで火入れの完璧さを見せる。"),

    # === mood (3) ===
    dict(category="mood", ratio="16:9", duration="10s",
         prompt="A quiet room transitions from stormy gray afternoon to warm golden sunset as clouds part outside the window, light slowly creeping across the floor, contemplative passage of mood.",
         note="用途: 心情の転換。ねらい: 光の移ろいで暗→明の感情変化を表現。"),
    dict(category="mood", ratio="16:9", duration="10s",
         prompt="Rain streaks down a window pane at night while city lights blur softly beyond the glass, droplets racing and merging, the camera holding still, melancholic and cozy lo-fi mood.",
         note="用途: Lo-fi/作業用。ねらい: 雨粒のレースで落ち着いた憂いのある雰囲気。"),
    dict(category="mood", ratio="16:9", duration="10s",
         prompt="Morning fog slowly lifts over a still lake to reveal mountains and soft reflections, a single bird gliding across, the camera gently pushing in, peaceful and hopeful awakening.",
         note="用途: 始まり/希望。ねらい: 霧の晴れ＋プッシュインで清々しい目覚め。"),
]


def assign_ids(items):
    out = []
    for i, p in enumerate(items, start=1):
        rec = {"id": f"{i:03d}"}
        rec.update(p)
        out.append(rec)
    return out


def build_json(items):
    payload = {
        "title": "runway-mcp-prompts-100",
        "description": "Runway Gen-4 系の動画生成向け オリジナル英語プロンプト100選（日本語解説つき）",
        "version": "1.0.0",
        "count": len(items),
        "categories": {key: name for key, name in CATEGORIES},
        "prompts": items,
    }
    (ROOT / "prompts.json").write_text(
        json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )


def build_markdown(items):
    by_cat = {}
    for p in items:
        by_cat.setdefault(p["category"], []).append(p)

    lines = []
    lines.append("# プロンプト100選（動画中心・Runway Gen-4 向け）\n")
    lines.append(
        "> オリジナルの英語プロンプト＋日本語解説。すべて新規作成（既存記事の転載ではありません）。\n"
        "> Runway は完成した英語の文（被写体＋動き＋カメラワーク＋光＋スタイル）に強いので、"
        "プロンプト本文は英語のまま使うのを推奨します。\n"
    )
    lines.append("## 目次\n")
    for key, name in CATEGORIES:
        n = len(by_cat.get(key, []))
        anchor = key
        lines.append(f"- [{name}](#{anchor}) （{n}件）")
    lines.append("")

    for key, name in CATEGORIES:
        group = by_cat.get(key, [])
        if not group:
            continue
        lines.append(f'<a id="{key}"></a>\n')
        lines.append(f"## {name}\n")
        for p in group:
            lines.append(f"### {p['id']}  `{p['ratio']}` / `{p['duration']}`\n")
            lines.append("```text")
            lines.append(p["prompt"])
            lines.append("```")
            lines.append(f"{p['note']}\n")
        lines.append("")

    (ROOT / "PROMPTS.md").write_text("\n".join(lines) + "\n", encoding="utf-8")


def main():
    items = assign_ids(PROMPTS)
    assert len(items) == 100, f"プロンプト数が100ではありません: {len(items)}"
    build_json(items)
    build_markdown(items)
    print(f"OK: {len(items)} prompts -> PROMPTS.md, prompts.json")


if __name__ == "__main__":
    main()
