Shader "Custom/firstShader" //Shader名称 这个名称会显示在Unity材质的Shader选择下拉菜单中 , Unlit 表示这个Shader是一个无光照的Shader
{
  // Properties块定义在Inspector中可以调整的属性
  Properties
  {
      // 声明一个名为_Color的颜色属性
      // 格式为：_Color("显示的名字", Color) = (R,G,B,A)默认颜色值
      //Color：属性类型（这里是颜色）
      //(1,1,1,1)：默认颜色值
      _Color ("Color", Color) = (1,1,1,1)
  }
  // SubShader块定义了Shader的实际渲染过程
  SubShader
  {
      Tags { "RenderType"="Opaque" } // 定义渲染类型为不透明对象
      // Pass块定义了渲染过程的每个阶段
      Pass
      {
          CGPROGRAM
          // 声明顶点着色器函数
          #pragma vertex vert
          // 声明片元着色器函数
          #pragma fragment frag
          // 包含UnityCG.cginc文件，提供了一些常用的函数和宏
          #include "UnityCG.cginc"

          // 声明与Properties中相同名字的变量
          fixed4 _Color;

          // 顶点着色器输入结构体
          struct appdata
          {
              float4 vertex : POSITION; // POSITION语义告诉Unity，顶点的位置数据存储在vertex变量中
          };

          // 顶点着色器输出结构体   （vertex to fragment）结构体定义了从顶点着色器传递到片元着色器的数据
          struct v2f
          {
              float4 pos : SV_POSITION; // SV_POSITION语义告诉Unity，pos变量存储了顶点的裁剪空间位置
          };

          // 顶点着色器
          v2f vert (appdata v)
          {
              v2f o;
              o.pos = UnityObjectToClipPos(v.vertex);  // 将顶点位置从模型空间转换为裁剪空间
              return o;
          }

          // 片元着色器
          fixed4 frag (v2f i) : SV_Target // SV_Target语义告诉Unity，片元着色器输出的颜色值存储在SV_Target变量中
          {
              // 直接返回颜色值
              return _Color;
          }
          ENDCG
      }
  } 
}
