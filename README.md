# LavaWeight · 流光体重

[![License: MIT](https://img.shields.io/badge/License-MIT-purple.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android%207.0%2B-brightgreen.svg)](android)
[![Flutter](https://img.shields.io/badge/Flutter-3.x-blue.svg)](https://flutter.dev)
[![Build Status](https://img.shields.io/github/actions/workflow/status/YXX168/LavaWeight/build.yml?branch=main&label=Build%20%26%20CI)](https://github.com/YXX168/LavaWeight/actions)

> 炫酷、沉浸、治愈的液态灯美学 Android 体重记录与趋势分析应用。
> 告别枯燥单调的体检打卡表，让每一次身体变化都成为有光流动的数据艺术。

---

## 视觉概念与设计语言

![LavaWeight Approved Design](assets/images/approved_concept.png)

LavaWeight 灵感源自经典熔岩灯（Lava Lamp）与流光玻璃艺术：
- **深曜石紫黑背景**：告别刺眼白光，在夜间与晨起时都能带来舒适柔和的护眼视觉体验。
- **透光熔融液态质感**：粉橙桃红的液团自下而上缓缓呼吸，内部透出温暖的光泽。
- **真实毛玻璃拟态**：多层实时高斯模糊、微光高亮边缘与轻盈半透明悬浮卡片。
- **平滑贝塞尔趋势曲面**：动态连贯的体重波动轨迹，支持手指触摸滑动探针实时查看历史每一笔记录。

---

## 核心功能

### 1. 今日概览 (Home)
- **大字号焦点数值**：清晰展示当日体重与较上一次称重的差值波动（增减动态指示）。
- **目标与初始进度**：直观对比起始体重、目标体重与累计减重成果。
- **BMI 健康评估**：根据个人身高实时计算 BMI 数值并标明健康区间。
- **近 7 次迷你趋势**：快速浏览最近波动态势。

### 2. 趋势轨迹 (Trends)
- **多维度周期切换**：支持「周」、「月」、「全部」区间无缝切换。
- **区间统计看板**：自动统计区间净变化量、打卡达成率、区间日均体重。
- **交互式贝塞尔曲线**：在图表区域任意滑动，即可高亮十字准星并弹出该时刻的确切时间与体重。
- **明细时间线管理**：支持长按或点击删除异常误录数据。

### 3. 极速记录 (Record)
- **悬浮液态球交互**：体重数值悬浮于居中液态光球之上。
- **触感刻度尺 (Lava Ruler)**：支持横向惯性平滑滑动，同时配备 `+0.1kg` / `-0.1kg` 极速微调步进按钮。
- **单位一键切换**：支持 `kg` 与 `斤` 双单位无感切换。
- **状态与心境标签**：记录称重时的状态（⚡ 充满活力、✨ 状态不错、🌱 平平常常、🌙 有点疲劳）。
- **随手备注**：可记录是否空腹、锻炼前后、饮食等环境因素。

### 4. 个人与隐私设置 (Settings)
- **健康体重测算**：根据医学健康标准（BMI 18.5 ~ 23.9）计算您的理想体重范围。
- **100% 纯本地离线**：无登录、无云端追踪、无需联网，完全保护您的私人健康隐私。
- **备份与迁移**：一键将完整历史数据导出为标准 JSON 复制到剪贴板，支持在任何设备上导入恢复。
- **演示数据预置**：内置一键填充 18 天拟真减重变化数据，方便随时体验与演示。

---

## 工程结构

```text
LavaWeight/
├── .github/workflows/
│   └── build.yml               # GitHub Actions CI：自动化代码格式检查、静态分析、测试及 APK 构建
├── android/                    # Android 原生工程（Kotlin DSL、自适应图标、全屏沉浸式主题）
├── assets/images/              # 原画设计稿与高分辨率全屏液态灯背景切图
│   ├── approved_concept.png    # 原创三屏设计稿参考
│   ├── home_lava.png           # 首页流光背景
│   ├── trends_lava.png         # 趋势页流光背景
│   └── record_lava.png         # 记录页中心光球背景
├── lib/
│   ├── main.dart               # 入口程序与沉浸式状态栏配置
│   ├── models/                 # 数据模型 (WeightRecord, UserProfile)
│   ├── services/               # 核心逻辑 (StorageService, BMICalculator)
│   ├── theme/                  # 视觉系统 (LavaTheme 配色、光效渐变、毛玻璃装饰)
│   ├── widgets/                # 定制组件 (GlassCard, GlowingButton, LavaRuler, LavaTrendChart)
│   └── views/                  # 业务页面 (HomeView, TrendsView, RecordView, SettingsView, MainScaffold)
└── test/                       # 完整的单元测试与组件冒烟测试
```

---

## 本地编译与运行

### 环境要求
- Flutter SDK `>= 3.24.0` (推荐 3.29.1 或更高)
- Android SDK API 21+ (Android 5.0+)
- Java 17

### 快速启动
```bash
# 1. 克隆代码仓库
git clone https://github.com/YXX168/LavaWeight.git
cd LavaWeight

# 2. 获取依赖
flutter pub get

# 3. 运行自动化测试
flutter test

# 4. 构建 Android Debug 安装包
flutter build apk --debug --target-platform android-arm64

# 5. 构建 Android Release 安装包
flutter build apk --release --target-platform android-arm64
```

构建产物将保存在 `build/app/outputs/flutter-apk/` 目录中。

---

## 开源协议

本项目采用 [MIT License](LICENSE) 开源协议。
