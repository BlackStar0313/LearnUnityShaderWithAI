# URP Shader与Render Features学习计划

## 阶段一：URP Shader基础（3天）

### 第1天：URP Shader结构与基础
1. **URP Shader结构差异**：
   - URP管线下的Shader基本结构
   - ShaderLab与HLSL部分的区别
   - URP特有标签和渲染队列

2. **URP内置光照模型**：
   - Universal Lit模型
   - Universal Unlit模型
   - 光照函数库使用

3. **练习项目**：
   - 将LearnTexture.shader转换为URP版本
   - 实现URP基础纹理Shader

### 第2天：URP材质特性
1. **Surface属性**：
   - Metallic/Smoothness设置
   - Normal映射
   - Occlusion和细节贴图

2. **渲染设置**：
   - Alpha剪裁
   - 接收阴影与投射阴影
   - 自定义光照

3. **练习项目**：
   - 将LearnBasicTransparent.shader转换为URP版本
   - 创建具有金属感的材质Shader

### 第3天：URP高级技术
1. **多Pass渲染**：
   - URP Pass结构
   - 多Pass间的数据传递
   - 描边与特效叠加

2. **URP输入结构**：
   - HLSL宏与函数库区别
   - Attributes与Varyings结构
   - URP内置变量

3. **练习项目**：
   - 将LearnVertexWave.shader转换为URP版本
   - 将LearnOutLine.shader完善为完整的URP版本

## 阶段二：URP Render Features（5天）

### 第1天：Render Feature基础
1. **URP渲染管线结构**：
   - URP渲染流程概述
   - ScriptableRenderPass与ScriptableRendererFeature
   - URP渲染事件与插入点

2. **第一个Render Feature**：
   - 基本C#类结构
   - 渲染通道配置
   - 插入渲染管线

3. **练习项目**：
   - 创建简单的颜色调整Render Feature
   - 实现场景色调映射效果

### 第2天：Blit操作与后处理
1. **Blit操作基础**：
   - CommandBuffer与RTHandle
   - Blit操作的实现方式
   - URP中的RTHandle系统

2. **基础后处理效果**：
   - 将LearnPostProcessing.shader迁移到URP
   - 添加模糊和色彩分离效果

3. **练习项目**：
   - 创建屏幕后处理Render Feature
   - 实现老电影效果

### 第3天：自定义渲染Pass
1. **自定义Pass配置**：
   - RenderTextureDescriptor设置
   - 过滤与掩码设置
   - 材质属性配置

2. **Pass执行控制**：
   - 条件性渲染
   - 相机过滤
   - 性能优化

3. **练习项目**：
   - 创建屏幕空间描边特效
   - 实现溶解效果的Render Feature

### 第4天：特殊渲染技术
1. **深度和法线纹理**：
   - 获取和使用深度纹理
   - 法线纹理采样
   - 屏幕空间效果

2. **高级技术**：
   - 描边检测
   - 轮廓提取
   - 视觉风格化

3. **练习项目**：
   - 实现基于深度的描边Render Feature
   - 创建卡通渲染风格管线

### 第5天：性能与调试
1. **性能优化**：
   - 降采样技术
   - 条件性执行
   - 资源管理

2. **调试技术**：
   - Frame Debugger使用
   - URP渲染调试
   - 性能分析

3. **练习项目**：
   - 优化现有Render Feature
   - 实现可配置的调试视图

## 阶段三：综合项目（4天）

### 第1天：高级水面系统
1. **水面Shader**：
   - 将LearnVertexWave.shader改进为URP水面
   - 添加折射和反射效果
   - 深度边缘与泡沫

2. **水面Render Feature**：
   - 平面反射实现
   - 水下扭曲效果
   - 因果波纹

### 第2天：角色特效系统
1. **角色Shader**：
   - 将LearnDissolve.shader转为URP版本
   - 角色高亮效果
   - 受击闪白效果

2. **角色Render Feature**：
   - 选中角色描边
   - 残影效果
   - 特殊状态表现

### 第3天：环境特效系统
1. **环境Shader**：
   - 风吹草动效果改进
   - 环境互动系统
   - 动态天气效果

2. **环境Render Feature**：
   - 全局雾效
   - 体积光
   - 大气散射

### 第4天：后处理特效系统
1. **将LearnBasicToonShading转为URP版**：
   - 改进卡通渲染
   - 整合描边技术
   - 添加动态效果

2. **创建完整特效管线**：
   - 管理多个Render Feature
   - 构建特效开关系统
   - 性能监控与优化

## 学习资源

1. **官方文档**：
   - Unity URP文档
   - URP Shader参考
   - URP自定义渲染指南

2. **视频教程**：
   - Unity官方URP教程
   - Catlike Coding的URP指南
   - Code Monkey的渲染Feature教程

3. **示例项目**：
   - URP示例项目
   - GitHub上的开源URP效果
   - Unity商店免费URP案例

4. **代码参考**：
   - URP源码（GitHub）
   - 示例Render Feature
   - URP Shader库

## 学习建议

1. **从简单开始**：
   - 先将单个效果从BuildIn转到URP
   - 理解基本结构变化
   - 逐步添加复杂功能

2. **实践与理论结合**：
   - 每学一个概念就实现一个小功能
   - 理解渲染管线的每个阶段
   - 善用Frame Debugger跟踪渲染过程

3. **渐进式开发**：
   - 先实现基础功能，再添加特效
   - 分析每个效果的性能影响
   - 构建可复用的功能模块

4. **调试技巧**：
   - 使用颜色调试Shader问题
   - 分离功能验证每个部分
   - 善用条件编译进行测试

## 技能水平目标

完成本学习计划后，预期达到的技术水平：

1. **URP Shader开发**：初级到中级水平，能够独立开发各类基础和特效着色器
2. **Render Features开发**：初级到中级水平，能够定制渲染通道和后处理效果
3. **综合应用**：能够将Shader和Render Features结合创建完整游戏视觉效果
4. **技术定位**：能够胜任中小型项目的渲染开发工作，或在大型团队中负责特定渲染模块

通过此学习路径，您将能够从BuildIn管线平稳过渡到URP渲染管线，并利用手写Shader和Render Features的组合创建高质量的视觉效果。
