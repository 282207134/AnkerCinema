"""Build a portable screenshot index and contact sheets. Requires Pillow."""
import json
import re
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
SHOTS = ROOT / 'docs/screenshots'
font = ImageFont.truetype(str(ROOT / 'assets/fonts/Futura.ttf'), 16)
screens = re.findall(r"^  (\w+)\('([^']*)'\)", (ROOT / 'lib/core/screens.dart').read_text(), re.M)
frames = {f['name']: f for f in json.loads((ROOT / 'docs/design/frames.json').read_text())}
assert len(screens) == 40

def sheet(items, columns, width, height, target):
    rows = (len(items) + columns - 1) // columns
    canvas = Image.new('RGB', (columns * width, rows * height), '#15151b')
    draw = ImageDraw.Draw(canvas)
    for i, (name, path) in enumerate(items):
        image = Image.open(path).convert('RGB')
        image.thumbnail((width - 16, height - 48), Image.Resampling.LANCZOS)
        x, y = (i % columns) * width, (i // columns) * height
        canvas.paste(image, (x + (width - image.width) // 2, y + 35))
        draw.text((x + 8, y + 7), name, font=font, fill='white')
    canvas.save(target, quality=90)

for start in (1, 11, 21, 31):
    items = [(f'{i:02} {screens[i-1][0]}', SHOTS / f'{i:02}-{screens[i-1][0]}.png') for i in range(start, start + 10)]
    sheet(items, 5, 224, 550, SHOTS / f'contact_{start:02}.jpg')

major = [(12, 'MOVIES'), (13, 'MOVIE DETAILS'), (15, 'CHOOSE SEATS'), (17, 'TICKET'), (40, 'CHECKOUT'), (32, 'BOOKING SUCCESS')]
sheet([(name, SHOTS / f'{i:02}-{screens[i-1][0]}.png') for i, name in major], 3, 272, 625, SHOTS / 'overview.jpg')

lines = ['# 页面截图与 Pixso 对照', '',
    '应用截图来自 iPhone 17 Pro / iOS 26.0 模拟器，由 Flutter integration_test 原生截图接口采集。每张 PNG 为 1206 × 2622；系统状态栏是否出现在图片中由该原生截图接口决定。', '',
    '包含 40 张页面截图，另有搜索、影人、电影详情、发现和结算页面的 5 张滚动补充图。截图使用固定演示订单；不是生产支付结果。原稿图来自 Pixso「No Image」页，编号保持一致。', '',
    '## 主要页面', '', '![主要界面](screenshots/overview.jpg)', '',
    '## 全页面索引', '', '| 编号 | 页面 | 应用路由 | Pixso 节点 | 应用截图 | 原稿 |', '| --- | --- | --- | --- | --- | --- |']
for i, (name, title) in enumerate(screens, 1):
    n = f'{i:02}'
    lines.append(f'| {n} | {title} | `/{name}` | `{frames[n]["id"]}` | [PNG](screenshots/{n}-{name}.png) | [PNG](design/{n}.png) |')
lines += ['', '## 长页面补充图', '']
for path in sorted(SHOTS.glob('*-detail.png')):
    lines.append(f'- [{path.stem}](screenshots/{path.name})')
lines += ['', '## 全页面缩略总览', '']
for start in (1, 11, 21, 31):
    lines += [f'### {start:02}–{start+9:02}', '', f'![页面 {start:02}–{start+9:02}](screenshots/contact_{start:02}.jpg)', '']
(ROOT / 'docs/SCREENSHOTS.md').write_text('\n'.join(lines))
print('Generated overview, 4 contact sheets, and 40-row screenshot index.')
