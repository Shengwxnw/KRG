# 字体授权说明 / Font notice

## AlibabaPuHuiTi-3-55-Regular.ttf

- **字体名称:** 阿里巴巴普惠体 3.0（Alibaba PuHuiTi 3.0），字重 55 Regular
- **内部 family 名:** `阿里巴巴普惠体 3.0 55 Regular`
- **官方来源:** <https://fonts.alibabagroup.com/>
- **授权:** 阿里巴巴官方宣布**永久免费商用**（个人与企业均可免费用于商业用途），
  唯一限制是不得将字体文件本身作为商品单独出售/转售。
- **文件校验 (SHA-256):** `BE33BC8D45CED30FA5C542F6F056565BAF85003D4E079522110D76016F8A04E2`

该文件从本机已安装的字体目录复制而来，用于让游戏在任意机器上渲染一致，
不依赖目标机器是否安装该字体。

> 注意：原 `Assets/apply-newrodin-system-font.ps1` 方案使用的是 Fontworks 的
> 商业字体 **FOT-NewRodin Pro B**，不能随项目分发，也无法合法下载，因此本项目
> 改用可自由分发的阿里巴巴普惠体。NewRodin 的视觉风格更接近几何黑体，
> 如果后续拿到 NewRodin 的正式授权文件，只需替换本目录下的字体文件并在
> `project.godot` 的 `gui/theme/custom_font` 中改路径即可。

## 备选（本机已安装，可直接改用）

| 字体 | 位置 | 说明 |
|---|---|---|
| 思源黑体 Noto Sans SC | `C:\Windows\Fonts\Noto Sans SC (TrueType).otf` 等 | Regular / Medium / Bold 三个字重，OFL 授权，中文覆盖最全 |
| 得意黑 SmileySans | `%LOCALAPPDATA%\Microsoft\Windows\Fonts\SmileySans-Oblique.ttf` | OFL，斜体展示字形，适合大标题/标语，不适合正文 |
| 思源宋体 Source Han Serif SC Heavy | `C:\Windows\Fonts\Source Han Serif SC Heavy (TrueType).ttf` | OFL，衬线，适合标题与叙事文本 |
