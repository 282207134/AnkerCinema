# Anker Cinema

根据 Pixso「No Image」页面的 40 张 UI 参考稿实现的 Flutter 影院购票应用。包含引导与登录、电影浏览、场次与选座、套餐、优惠码、演示支付、电子票和个人中心。

![主要界面](docs/screenshots/overview.jpg)

- [项目结构、架构与实现说明](docs/PROJECT_ARCHITECTURE.md)
- [40 个界面的截图与 Pixso 节点对照](docs/SCREENSHOTS.md)
- [测试记录](docs/TESTING.md)

## 运行

环境：Flutter 3.41.6 / Dart 3.11.4。项目包含 iOS、Android 与 Web 工程。

```bash
flutter pub get
flutter run
```

直接打开电影首页：

```bash
flutter run --dart-define=SCREEN=12
```

`SCREEN` 支持 1–40，对应原稿编号。默认首次启动显示欢迎页；本地演示登录后，再次启动进入电影首页。欢迎页可左滑或点击底部分页点前进。

## 演示操作

1. 点击 `Log In`，输入有效格式的邮箱和至少 6 位密码，即可进入本地演示账户。
2. 首页选择电影，依次进入详情、影院、场次和选座。默认选中 G7、G8。
3. 可输入优惠码 `ANKER30`，票价减免 30%；套餐不参与优惠。
4. 选择套餐数量，确认电子票预览，选择演示 Visa 支付。
5. 点击 `Send code` 后输入 `5012`，生成订单；也可点击指纹图标确认演示订单。
6. 从菜单进入 `History` 查看已保存的订单；在 `Profile` 修改资料。

其他卡片表单只接受演示卡号 `4242 4242 4242 4242`，有效期填写未来的 `MM/YY`，CVV 填 3 位数字。

## 验证与截图

```bash
flutter analyze
flutter test
flutter drive --driver=test_driver/integration_test.dart --target=integration_test/app_test.dart -d <设备ID>
```

最后一个命令会运行购票流程，并将 40 张页面截图和 5 张长页面补充截图保存至 `docs/screenshots/`。详细命令见 [测试记录](docs/TESTING.md)。

## 实现范围

这是可交互、可离线运行的 UI 与业务流程演示。电影、影院、场次、通知为示例数据；登录、支付、短信、指纹、相机与视频尚未接入真实服务。订单与偏好保存在当前设备，不产生真实扣款，电子票不能用于入场。

参考稿的海报与头像为灰色占位，应用保留该设定。插画与静态地图来自原稿，所有运行素材均已本地化。字体来源及后续接入点见架构文档。
