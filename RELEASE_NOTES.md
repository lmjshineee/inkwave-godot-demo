# INKWAVE Godot Demo v0.1.0

这是 macOS 单机 Godot 版的首次预发布。下载 `INKWAVE-Godot-Demo-v0.1.0-macOS-universal.zip`，解压后打开 `INKWAVE Demo.app`。应用包含 arm64 和 x86_64 两种架构。

## 可玩内容

- Tidewater 地图上的 1v1、90 秒涂墨计分对局，带赛前介绍、终场裁判和结果页。
- 赛前或等待重生时选择射手、滚筒、蓄力狙、爆破枪；对局中可使用墨水炸弹和两种大招。
- 蓝队会巡逻、追击、涂墨并发射有飞行时间的射手墨弹；双方可受伤、被击倒并重生。
- `WASD` 移动，空格跳跃，鼠标瞄准，左键开火，右键投弹，`Shift` 潜墨，`F`/`Q` 使用大招，`Esc` 暂停，`R` 重开。

## 验证与限制

- 使用 Godot 4.8.dev6 构建；四个数据导出器检查和 23 个无界面规则检查通过（27/27）。应用通过本机签名校验和无界面短启动检查。
- 尚未完成导出应用的完整图形试玩、整局帧时间和设备温度测试。30 FPS 上限不保证特定温度。
- 当前使用 GL Compatibility 渲染器。Forward+ 仅在迁移规范中列为后续目标，尚未切换。
- 当前应用为本地临时签名，未做 Apple 公证；macOS 首次打开可能要求用户在系统安全设置中确认。

SHA-256 (`INKWAVE-Godot-Demo-v0.1.0-macOS-universal.zip`): `01345dfb061fe46fd4a7c1fdcb5562d62bc2ab4bf2021d10733905783ef9c38a`
