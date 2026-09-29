# INKWAVE Godot Demo

这是原版 [INKWAVE](https://github.com/caoxing9/inkwave-game) 的独立 Godot 单机演示版源码快照。Godot 工程在 [godot-port-prototype](godot-port-prototype/README.md)。

仓库只包含 Godot 工程及四个导出器实际需要的网页参数、地图、图标源码和 Three.js 模块；不包含原站点、服务端、账号连接代码、缓存或编译出的 Mac 应用。Mac 应用压缩包在 GitHub Releases。

## 本地使用

需要 Godot 4.8.dev6 与 Node.js 24。运行 `sh godot-port-prototype/tools/run_checks.sh` 做数据和无界面规则检查；运行 `sh godot-port-prototype/export_macos.sh` 导出 Universal Mac 应用。首次运行 Godot 会导入项目资源。

本快照基于原仓库的 Godot 分支提交 `561b40d5c439b134d45ded7a4732f6aadbcc7ca4`，网页参考基线为 `33d3388`。当前为 v0.2.0 预览版：赛前/重生可点击换武器，赛前/暂停可修改帧率、界面缩放和鼠标灵敏度；图形完整对局、帧时间、温度和 Intel Mac 实机仍待验收。
