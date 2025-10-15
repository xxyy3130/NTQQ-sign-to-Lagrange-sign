@echo off
echo 准备用 x64dbg 打开 9.9.12-25493 的 wrapper.node
echo.
echo 文件路径：
echo C:\Users\admin\Documents\qqnt\9912\resources\app\versions\9.9.12-25493\wrapper.node
echo.
echo 请按照以下步骤操作：
echo.
echo 1. 启动 x64dbg (x64 版本)
echo 2. 点击 "文件" → "打开"
echo 3. 浏览到上述路径并打开 wrapper.node
echo.
echo 加载后：
echo - 查看顶部状态栏的模块基址
echo - 或查看 CPU 窗口第一行地址（通常就是基址）
echo - 记录下来，例如：180000000
echo.
pause

start "" "C:\Users\admin\Documents\qqnt\9912\resources\app\versions\9.9.12-25493\wrapper.node"
