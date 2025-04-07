# URP Shader与Render Features学习计划

## 阶段一：URP Shader基础（4天）

### 第1天：URP Shader结构与基础
1. **URP Shader结构差异**：
   - URP管线下的Shader基本结构
   - ShaderLab与HLSL部分的区别
   - URP特有标签和渲染队列
   - CBUFFER使用与SRP Batcher优化

2. **基础纹理处理**：
   - URP纹理声明和采样方式
   - UV操作与动画
   - 简单颜色混合

3. **练习项目**：
   - 将LearnTexture.shader转换为URP版本
   - 实现URP基础纹理动画Shader

### 第2天：URP材质特性（无光照部分）
1. **Surface属性**：
   - Alpha透明与混合模式
   - Alpha剪裁（Cutout）实现
   - 纹理遮罩与混合技术

2. **顶点操作与动画**：
   - URP中的顶点变换
   - 顶点颜色使用
   - 顶点动画实现

3. **练习项目**：
   - 将LearnBasicTransparent.shader转换为URP版本
   - 实现基础材质混合效果

### 第3天：URP高级特效技术
1. **特效Shader技术**：
   - 溶解效果实现
   - 扭曲与波动效果
   - 屏幕空间效果基础

2. **细节表现技术**：
   - 细节纹理叠加
   - 噪声图应用
   - 流动效果

3. **练习项目**：
   - 将LearnDissolve.shader转换为URP版本
   - 将LearnVertexWave.shader转换为URP版本

### 第4天：URP光照模型专题
1. **URP光照基础**：
   - Universal Lit模型详解
   - 光照数据结构
   - 主光源与附加光源

2. **PBR材质设置**：
   - Metallic/Smoothness工作流
   - Normal映射实现
   - Occlusion和细节贴图

3. **自定义光照模型**：
   - 半Lambert光照模型
   - 卡通光照实现
   - 光照函数定制

4. **接收与投射阴影**：
   - URP中的阴影Pass
   - 自定义阴影接收
   - 半透明阴影处理

5. **练习项目**：
   - 创建完整PBR材质Shader
   - 将LearnBasicToonShading.shader转换为URP版本

### 第5天：URP多Pass渲染
1. **Pass结构与通信**：
   - URP Pass类型与标签
   - 多Pass间的数据传递
   - Pass执行顺序控制

2. **特殊效果组合**：
   - 描边与特效叠加
   - 轮廓高亮
   - 多层效果

3. **练习项目**：
   - 将LearnOutLine.shader完善为完整的URP版本
   - 创建多Pass特效组合Shader

## 阶段二：Scriptable Renderer Features (Unity 6)

### 第1天：Renderer Feature基础架构
1. **Renderer Feature与Render Pass关系**：
   - Scriptable Renderer Feature基本架构
   - Scriptable Render Pass核心概念
   - 两者之间的关系和选择准则

2. **创建第一个Renderer Feature**：
   - Renderer Feature类的基本框架
   - Create方法实现
   - AddRenderPasses方法
   - Dispose资源管理

3. **Render Graph API与兼容模式**：
   - RenderGraph概念介绍
   - 兼容模式(Compatibility Mode)的作用
   - 何时使用RenderGraph与何时使用兼容模式

4. **练习项目**：
   - 创建基本的Renderer Feature框架
   - 使用Inspector界面配置参数

### 第2天：Render Pass与RenderGraph API
1. **RecordRenderGraph方法**：
   - 纹理资源声明和管理
   - UniversalResourceData使用
   - ContextContainer数据访问

2. **RenderGraph中的Pass处理**：
   - RenderGraph.AddRenderPass用法
   - PassData设计模式
   - 渲染回调函数实现

3. **Blit操作实现**：
   - 使用AddBlitPass简化操作
   - BlitMaterialParameters配置
   - 自定义着色器与材质属性

4. **练习项目**：
   - 实现简单的后处理效果
   - 创建模糊或色彩调整效果

### 第3天：高级渲染技术与Volume集成
1. **多Pass链式处理**：
   - 设计多阶段渲染流程
   - 中间渲染目标管理
   - 条件性渲染控制

2. **Volume Component集成**：
   - 创建Volume Component
   - 连接Renderer Feature与Volume
   - 运行时参数调整

3. **练习项目**：
   - 创建支持Volume控制的特效
   - 实现基于摄像机距离的效果调整

### 第4天：特殊渲染资源使用
1. **深度与法线纹理**：
   - 在RenderGraph中访问特殊纹理
   - 资源读写权限管理
   - 特殊纹理采样技巧

2. **屏幕空间效果实现**：
   - 屏幕空间环境光遮蔽(SSAO)
   - 边缘检测与描边
   - 屏幕空间反射

3. **练习项目**：
   - 实现基于深度的轮廓检测
   - 创建屏幕空间特效

### 第5天：优化与调试
1. **性能优化策略**：
   - 降采样技术应用
   - 资源生命周期管理
   - 避免不必要的渲染过程

2. **调试与分析**：
   - Frame Debugger中分析渲染过程
   - 排查渲染问题方法
   - 性能瓶颈识别

3. **项目整合与管理**：
   - 多个Renderer Features协同工作
   - 动态启用与禁用特定效果
   - 创建可重用的效果库

4. **练习项目**：
   - 优化已有的渲染效果
   - 创建可调试的效果控制面板

## 阶段三：综合项目（4天）

### 第1天：高级水面系统
1. **水面Shader**：
   - 创建URP水面着色器
   - 添加折射和反射效果
   - 深度边缘与泡沫

2. **水面Renderer Feature**：
   - 实现平面反射渲染
   - 水下扭曲效果
   - 波纹动态效果

3. **练习项目**：
   - 完整水体效果实现
   - 交互式水面系统

### 第2天：角色特效系统
1. **角色Shader**：
   - 创建角色溶解效果
   - 角色高亮与描边
   - 受击闪白效果

2. **角色Renderer Feature**：
   - 角色轮廓渲染
   - 残影与拖尾效果
   - 特殊状态视觉表现

3. **练习项目**：
   - 完整角色特效系统
   - 状态驱动的视觉效果

### 第3天：环境特效系统
1. **环境Shader**：
   - 风吹草动效果
   - 环境互动系统
   - 天气效果表现

2. **环境Renderer Feature**：
   - 全局雾效实现
   - 体积光渲染
   - 大气散射效果

3. **练习项目**：
   - 动态环境系统实现
   - 天气转换效果

### 第4天：完整后处理管线
1. **创建整合后处理系统**：
   - 设计完整卡通渲染管线
   - 整合多种后处理效果
   - 创建风格化渲染管线

2. **效果管理系统**：
   - 构建效果开关机制
   - 性能与质量平衡
   - 不同平台适配策略

3. **最终项目**：
   - 整合所有特效到演示场景
   - 创建效果调整与切换界面
   - 性能测试与优化

## 学习资源

1. **官方文档**：
   - [Unity 6 URP文档](https://docs.unity3d.com/6000.0/Documentation/Manual/urp/renderer-features/create-custom-renderer-feature.html)
   - [Scriptable Renderer Feature参考](https://docs.unity3d.com/Packages/com.unity.render-pipelines.universal@17.0/manual/renderer-features/create-custom-renderer-feature.html)
   - [RenderGraph API指南](https://docs.unity3d.com/6000.0/Documentation/Manual/urp/render-graph-introduction.html)

2. **视频教程**：
   - Unity官方URP教程
   - Unity 6渲染特性解析
   - 效果开发案例分析

3. **示例项目**：
   - URP示例项目与官方示例
   - GitHub上的开源URP效果
   - Unity商店免费URP案例

4. **社区资源**：
   - Unity论坛URP版块
   - Renderer Feature开源代码
   - 技术博客与文章

## 学习建议

1. **掌握基础概念**：
   - 理解Renderer Feature与Render Pass的区别
   - 掌握RenderGraph API的基本工作流程
   - 熟悉渲染管线的各个阶段

2. **从简单开始**：
   - 先实现基础功能，再添加复杂特效
   - 分离功能验证各个模块
   - 渐进式增加功能复杂度

3. **注重性能与兼容性**：
   - 考虑不同平台的性能限制
   - 合理使用资源和降采样
   - 为不同硬件提供质量选项

4. **调试与优化**：
   - 善用Frame Debugger分析渲染过程
   - 构建可视化调试工具
   - 持续进行性能分析与优化

## 技能水平目标

完成本学习计划后，预期达到的技术水平：

1. **URP Shader开发**：能够创建各类实用的URP着色器，满足项目需求
2. **Renderer Feature开发**：掌握Unity 6中的Renderer Feature开发，能实现高质量渲染效果
3. **综合应用**：能够整合Shader与Renderer Feature创建完整视觉效果系统
4. **技术定位**：能够胜任商业项目的URP渲染开发，了解最新渲染技术趋势

通过此学习路径，你将掌握Unity 6中URP渲染管线的最新技术，能够为项目创建高质量、高性能的视觉效果。
