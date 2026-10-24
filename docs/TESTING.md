# 测试与复现记录

验证日期：2026-10-24（Asia/Tokyo）。

## 环境

| 项目 | 版本 / 配置 |
| --- | --- |
| Flutter | 3.41.6 stable |
| Dart | 3.11.4 |
| iOS 模拟器 | iPhone 17 Pro，iOS 26.0 |
| 应用截图 | 1206 × 2622 PNG |
| Widget 布局尺寸 | 375 × 812、320 × 568，devicePixelRatio = 1 |
| 工程平台 | iOS、Android、Web |

## 最终结果

| 验证项 | 结果 | 覆盖范围 |
| --- | --- | --- |
| `flutter analyze` | 通过，0 issues | 所有项目 Dart 源码 |
| `flutter test` | 9 项通过 | 6 项状态测试、2 项全页面尺寸测试、1 项登录交互测试 |
| 40 个页面 × 2 种手机尺寸 | 80 次页面渲染通过 | 无 Flutter 布局溢出或构建异常 |
| iOS integration_test | 通过 | 完整购票流程与本地订单恢复 |
| 页面截图 | 45 张 PNG | 40 个页面 + 5 张长页面补充图 |
| `flutter build web --release` | 通过 | 生成 `build/web/` |

Android 工程已提供，未在本次环境执行 Android 构建或模拟器测试。iOS 验证使用模拟器，未测试真机、App Store 签名或发布。Web 已验证发布构建，未对不同浏览器逐一验收。

## 业务测试

`test/cinema_controller_test.dart` 验证：

- 整数分金额计算，优惠只作用于电影票，无效优惠码不改变金额。
- 已占座、无座位位置和非法座位不能选中；没有座位时禁止生成订单。
- 套餐数量边界为 0–9。
- 重复确认不重复出票；订单快照可序列化、重启读取与清空。
- 用户资料、收藏、通知偏好保留；选择新电影重置购票草稿。
- 本地订单 JSON 损坏时恢复为空历史。

`test/screens_test.dart` 遍历所有 40 个路由，在 375 × 812 与 320 × 568 两种尺寸下检查页面渲染；另验证空密码报错、有效输入进入引导页。

`integration_test/app_test.dart` 在 iPhone 模拟器上执行：

```text
首页 Book Ticket → 详情 Book Now → 影院场次 Continue
→ 取消 G7，确认总价 $10.00 → 重新选中 G7
→ 打开优惠码 → Redeem Code → Apply → 返回选座
→ 确认票价 $14.00 → Single Combo 增加一份
→ 确认总价 $22.00 → 电子票预览 → 支付 → Send code
→ 输入 5012 → 支付成功 → 查看电子票
→ 用新的控制器读取存储，确认订单仍为 $22.00
```

截图阶段使用固定演示订单，逐个打开 40 个路由；历史页展示三条固定样例订单。搜索、影人、电影详情、发现和结算页分别增加一张向下滚动的截图。截图行为和购票流程分开，截图中的固定价格不代表该次交互测试的最终价格。

## 复现命令

```bash
flutter pub get
flutter analyze
flutter test
flutter devices
flutter drive --driver=test_driver/integration_test.dart --target=integration_test/app_test.dart -d <设备ID>
flutter build web --release
```

本次 iOS 模拟器设备 ID：`F13309E5-4B46-45C7-8C1E-036D1DC3DF07`。另一台电脑上请使用 `flutter devices` 返回的设备 ID。

截图由 `test_driver/integration_test.dart` 保存至 `docs/screenshots/`。重新生成缩略总览需要 Pillow：

```bash
python3 -m venv .venv-gallery
.venv-gallery/bin/pip install pillow
.venv-gallery/bin/python scripts/build_gallery.py
```

欢迎流程从 01 号界面开始；若只检查某个页面，可传原稿编号：

```bash
flutter run --dart-define=SCREEN=15
```

## 验证边界

支付、短信、指纹、相机、视频和地图服务未连接真实服务，测试覆盖本地演示交互。电影票条码用于界面展示，不是可兑换票证。地图使用原稿静态图片，影院地址及历史日期为参考稿示例数据。字体与排版适配差异在 [架构说明](PROJECT_ARCHITECTURE.md) 中记录。
