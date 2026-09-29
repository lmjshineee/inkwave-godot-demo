# INKWAVE Godot Demo v0.2.0-preview.1

下载 `INKWAVE-Godot-Demo-v0.2.0-preview.1-macOS-universal.zip`，解压后打开 `INKWAVE Demo.app`。应用包含 arm64 与 x86_64 两种架构，使用 Godot 4.8.dev6 和 GL Compatibility 构建。

## 本次更新

- 玩家与蓝队的四种武器、生命/重生及蓝队低墨量补墨规则已接入单机 1v1 演示。
- 赛前和重生时可点击武器卡片；Esc 暂停后可继续游戏或打开设置。
- 设置支持 30/45/60 FPS、90%/100%/110% 界面缩放和鼠标灵敏度，保存后立即应用并持久化。默认仍为 30 FPS。
- 接入原网页的台阶、朝向与硬着陆参数；具体手感仍需实际试玩确认。

## 已验证

- 四个数据导出器检查和 37 个无界面规则检查通过。
- 源场景一次四帧图形捕获确认赛前、设置、开局和战斗静态画面；导出的应用完成 30 帧图形窗口短启动。
- ZIP 完整性、应用签名、包内资源、arm64/x86_64 架构及应用版本 `0.2.0` 均已核对。

## 尚待验收

- 没有完成真实输入的 90 秒对局、持续帧时间或设备温度测试；30 FPS 上限不保证特定温度。
- x86_64 仅确认包含于 Universal 包，尚无 Intel Mac 实机试玩。
- 应用使用本地临时签名，未做 Apple 公证；首次打开可能需要在 macOS 安全设置中确认。

SHA-256 (`INKWAVE-Godot-Demo-v0.2.0-preview.1-macOS-universal.zip`): `75e0ef485fafd5ce2389f88030e9100ec2b086a407b7889133aaae65bb2abd8c`
