---@class Animation
---@field IsValid fun(self: Animation) boolean 检测是否已经失效了
---@field Clear fun(self: Animation) void 清空持有的资源
---@field IsPlaying fun(self: Animation, name: string) boolean 是否正在播放某个切片
---@field Stop fun(self: Animation, name: string) None 停止某个动画切片播放
---@field SetSpeed fun(self: Animation, name: string, speed: number) None 设置某个动画切片播放速度
---@field Rewind fun(self: Animation, name: string) None 设置某个动画从头开始播放
---@field SetWrapMode fun(self: Animation, name: string, wrap: AnimationWrapMode) None 设置某个动画切片wrap模式（动画边缘处理）
---@field GetClips fun(self: Animation) SandboxNode 获取当前animation持有的所有动画切片资源
---@field SetClips fun(self: Animation, assets: SandboxNode) None 设置当前animation持有的动画切片资源
---@field UpdateClips fun(self: Animation, resType: AssetResType, urls: Table) None 更新动画切片
---@field SetDefaultClip fun(self: Animation, node: SandboxNode) None 设置默认动画切片
---@field UpdateDefaultClip fun(self: Animation, resType: AssetResType, url: string) None 更新默认动画切片
---@field Play fun(self: Animation, name: string, playMode: AnimationPlayMode) None 播放切片
---@field Blend fun(self: Animation, name: string, targetWeight: number, time: number) None 设置切片动画混合权重
---@field CrossFade fun(self: Animation, name: string, targetWeight: number, playMode: AnimationPlayMode) None 设置切片动画渐变（fade）
---@field AddClip fun(self: Animation, node: SandboxNode, name: string, firstFrame: number, lastFrame: number, loop: boolean) None 添加一个切片动画
---@field UpdateClip fun(self: Animation, resType: AssetResType, url: string, name: string, firstFrame: number, lastFrame: number, loop: boolean) None 更新一个切片动画
---@field RemoveClip fun(self: Animation, clipname: string) None 按名称移除一个动画切片
---@field GetAutoPlay fun(self: Animation) boolean 获取是否自动播放
---@field SetAutoPlay fun(self: Animation, autoPlay: boolean) None 设置自动播放


---@class AnimationItem
---@field Play boolean 是否开启播放
---@field ClipName string 动画Name
---@field ClipResID string 动画资源ID
---@field FirstFrame number 首帧Frame
---@field LastFrame number 末帧Frame
---@field PlaySpeed number
---@field WrapMode AnimationWrapMode Wrap模式
---@field PlayMode AnimationPlayMode 播放模式



---@class Animator
---@field Pause boolean 是否暂停
---@field SkeletonAsset string 骨骼资源
---@field ControllerAsset string 动画控制器资源
---@field Speed number
---@field SkipSampleRate unumber32_t
---@field CullingMode number
---@field FixedTickTime number
---@field ModelWaitForLoaded boolean
---@field Clear fun(self: Animator) void 清空持有的资源
---@field IsValid fun(self: Animator) boolean 检测是否已经失效了
---@field SetControllerAsset fun(self: Animator, node: SandboxNode) None 设置动画控制器资源
---@field UpdateControllerAsset fun(self: Animator, restype: AssetResType, url: string) None 更新动画控制器资源
---@field NewController fun(self: Animator, type: number) SandboxNode 新建一个默认的状态机数据：1-AnimatorControllerData；2-AnimatorOverrideController；
---@field GetControllerAsset fun(self: Animator) SandboxNode 获取动画控制器资源
---@field GetSkeleton fun(self: Animator) SandboxNode 获取当前的骨骼资源
---@field SetSkeleton fun(self: Animator, node: SandboxNode) None 设置骨骼资源
---@field UpdateSkeleton fun(self: Animator, restype: AssetResType, url: string) None 更新骨骼资源
---@field Play fun(self: Animator, name: string, layer: number, normalized: number) None 播放一个state
---@field CrossFade fun(self: Animator, stateName: string, layer: number, transitionTotal: number, transitionOffset: number) None 渐变动画：淡入淡出
---@field Setnumber fun(self: Animator, key: string, value: number) None 设置animator属性的浮点数数据类型KV值
---@field Setnumber fun(self: Animator, key: string, value: number) None 设置animator属性的整数数据类型KV值
---@field SetBool fun(self: Animator, key: string, value: boolean) None 设置animator属性的布尔数据类型KV值
---@field SetTrigger fun(self: Animator, key: string) None 设置触发器
---@field Getnumber fun(self: Animator, key: string) Number 获取animator属性的浮点数数据类型KV值
---@field Getnumber fun(self: Animator, key: string) Number 获取animator属性的整数数据类型KV值
---@field GetBool fun(self: Animator, key: string) boolean 获取animator属性的布尔数据类型KV值
---@field GetTrigger fun(self: Animator, key: string) boolean 获取触发器
---@field GetLayerCount fun(self: Animator) Number 获取当前layer的个数
---@field GetLayerByIndex fun(self: Animator, index: number) SandboxNode 按照index获取层级节点
---@field SetLayerWeight fun(self: Animator, layer: number, value: number) None 设置layer层级权重
---@field GetLayerWeight fun(self: Animator, layer: number) Number 获取layer层级权重
---@field SetBoneTransform fun(self: Animator, targetBoneNode: SandboxNode, baseBoneNode: SandboxNode, translate: Vector3, rotation: Vector3, scale: Vector3) None 设置骨骼变换
---@field SetBoneModelSpaceRotate fun(self: Animator, boneName: string, pitch: number, yaw: number, roll: number) None 设置骨骼模型空间旋转
---@field GetStatePlayedTime fun(self: Animator, stateFullName: string) Number 获取状态的PlayedTime
---@field GetCurrentStatePlayedTime fun(self: Animator, layerIdx: number) Number 获取当前层级正在播放的状态的PlayedTime
---@field SetStatePauseAtNormlizedTime fun(self: Animator) boolean
---@field EventNotify fun(self: Animator, statedata: SandboxNode, name: string, layerIndex: number, state: StateMachineMessage) None 发送一个当前状态机消息的通知
---@field GetAnimationPostNotify Event 获取动画完成通知
---@field GetUpdateAssetNotify fun(self: Animator, url: string, state: boolean) None 获取更新资源通知
---@field UpdateAssetNotify fun(self: Animator, url: string, state: boolean) None 更新资源通知
---@field ClipsEventNotify fun(self: Animator, function: string, variant: ReflexVariant) None 动画切片事件通知


---@class AnimatorBase
---@field IsReplication boolean 是否主从复制
---@field IsValid fun(self: AnimatorBase) boolean 检测是否已经失效了
---@field NewAsset fun(self: AnimatorBase) SandboxNode 新建一个空动画资源
---@field ClearEffect fun(self: AnimatorBase) void 清理动画特效
---@field ValidNotify fun(self: AnimatorBase, isValid: boolean) None 有效通知


---@class AnimatorController
---@field Clear fun(self: AnimatorController) void 清空持有的资源
---@field IsValid fun(self: AnimatorController) boolean 检测是否已经失效了
---@field GetStateMachineCount fun(self: AnimatorController) Number 获取当前持有的状态机个数
---@field GetStateMachine fun(self: AnimatorController, index: number) SandboxNode 通过下标获取当前持有的状态机数据
---@field GetStateMachineByName fun(self: AnimatorController, name: string) SandboxNode 通过状态机名获取当前持有的状态机数据
---@field CreateLayer fun(self: AnimatorController, name: string) SandboxNode 新建一个AnimatorLayerData实例
---@field RemoveLayer fun(self: AnimatorController, name: string) None 通过layer名移除一个AnimatorLayerData实例


---@class AnimatorLayer
---@field Mask SandboxNode 蒙层
---@field Clear fun(self: AnimatorLayer) void 清空持有的资源
---@field IsValid fun(self: AnimatorLayer) boolean 检测是否已经失效了
---@field CreateMotion fun(self: AnimatorLayer, name: string, node: SandboxNode, isLoop: boolean) None 创建一个动画切片
---@field GetMotions fun(self: AnimatorLayer) SandboxNode 获取当前持有的动画切片
---@field MotionValid fun(self: AnimatorLayer, name: string) boolean 动画切片是否有效


---@class AnimatorLayerData
---@field Mask SandboxNode 蒙层
---@field Clear fun(self: AnimatorLayerData) void 清空持有的资源
---@field IsValid fun(self: AnimatorLayerData) boolean 检测是否已经失效了
---@field CreateMotion fun(self: AnimatorLayerData, name: string, node: SandboxNode, isLoop: boolean) None 创建一个动画切片
---@field GetMotions fun(self: AnimatorLayerData) SandboxNode 获取当前持有的动画切片
---@field MotionValid fun(self: AnimatorLayerData, name: string) boolean 动画切片是否有效


---@class AnimatorLayerItemNode
---@field Index number Index
---@field Weight number Weight值
---@field StateName string StateName
---@field NormaliedOffset number Offset



---@class AnimatorParamsItemNode
---@field ParamName string 参数名字
---@field ParamType AnimatorParameterType 参数值类型
---@field number number number值
---@field number number number值
---@field Bool boolean Bool值
---@field Trigger boolean Trigger值



---@class AnimatorStateData
---@field Speed number 速度
---@field Clear fun(self: AnimatorStateData) void 清空持有的资源
---@field IsValid fun(self: AnimatorStateData) boolean 检测是否已经失效了
---@field EventNotify fun(self: AnimatorStateData, state: StateMachineMessage) None 发送一个当前状态机消息的通知


---@class AnimatorStateMachineData
---@field Clear fun(self: AnimatorStateMachineData) void 清空持有的资源
---@field IsValid fun(self: AnimatorStateMachineData) boolean 检测是否已经失效了
---@field GetSubMachines fun(self: AnimatorStateMachineData) SandboxNode 获取当前持有的子状态机数据
---@field GetSubStateMachine fun(self: AnimatorStateMachineData, name: string) SandboxNode 获取当前持有的一个子状态机数据
---@field GetStates fun(self: AnimatorStateMachineData) SandboxNode 获取当前持有的所有状态数据
---@field CreateState fun(self: AnimatorStateMachineData, name: string) SandboxNode 创建一个状态数据
---@field GetState fun(self: AnimatorStateMachineData, name: string) SandboxNode 获取一个状态数据
---@field IsEnter fun(self: AnimatorStateMachineData) boolean 检查是否进入状态
---@field GetFullName fun(self: AnimatorStateMachineData) String
---@field EventNotify fun(self: AnimatorStateMachineData, state: StateMachineMessage) None 发送一个当前状态机消息的通知


---@class AttributeAnimation
---@field IsValid fun(self: AttributeAnimation) boolean 检测是否已经失效了


---@class BoneNode
---@field LocalPosition Vector3 局部位置
---@field LocalEuler Vector3 局部欧拉
---@field LocalScale Vector3 局部比例
---@field LocalRotation Quaternion 局部旋转
---@field GetBoneNode fun(self: BoneNode, name: string) SandboxNode 通过骨骼名获取骨骼节点
---@field GetParentBoneNode fun(self: BoneNode) SandboxNode 获取父骨骼节点


---@class HumanAnimation
---@field IsValid fun(self: HumanAnimation) boolean 检测是否已经失效了


---@class LegacyAnimation
---@field EnablePlayEvent boolean 是否开启播放事件
---@field IsValid fun(self: LegacyAnimation) boolean 检测是否已经失效了
---@field GetAnimationIDs fun(self: LegacyAnimation) Table 获取动画ID
---@field GetAnimationPriority fun(self: LegacyAnimation, seqid: number) Number 获取动画优先级
---@field SetAnimationPriority fun(self: LegacyAnimation, seqid: number, value: number) None 设置动画优先级
---@field GetAnimationWeight fun(self: LegacyAnimation, seqid: number) Number 获取动画权重
---@field SetAnimationWeight fun(self: LegacyAnimation, seqid: number, value: number) None 设置动画权重
---@field Play fun(self: LegacyAnimation, id: number, speed: number, loop: number) boolean 播放动画
---@field PlayEx fun(self: LegacyAnimation, id: number, speed: number, loop: number, priority: number, weight: number) boolean 播放动画
---@field Stop fun(self: LegacyAnimation, id: number) boolean 停止动画
---@field StopEx fun(self: LegacyAnimation, id: number, reset: boolean) boolean 停止动画
---@field StopAll fun(self: LegacyAnimation, reset: boolean) boolean 停止所有动画


---@class LegacyAnimationItem
---@field Play boolean 是否开启播放
---@field AnimationID number 动画ID
---@field Speed number 动画Speed
---@field LoopMode LegacyAnimationLoop 动画LoopMode
---@field Priority number 动画Priority
---@field Weight number 动画Weight



---@class PostProcessing
---@field BloomActive boolean 全屏泛光是否激活
---@field Bloomnumberensity number 全屏泛光强度
---@field BloomThreshold number 全屏泛光阈值
---@field DofActive boolean 自由度是否激活
---@field DofFocalRegion number 字段焦点区域深度
---@field DofNearTransitionRegion number 字段最近转换区域的深度
---@field DofFarTransitionRegion number 字段深度转换区域
---@field DofFocalDistance number 景深焦距深度
---@field DofScale number 字段比例深度
---@field AntialiasingEnable boolean 抗锯齿开启
---@field AntialiasingMethod AntialiasingMethodDesc 抗锯齿方法
---@field AntialiasingQuality AntialiasingQualityDesc 抗锯齿质量
---@field LUTsActive boolean LUTs开启
---@field LUTsTemperatureType LUTsTemperatureType LUTs温度类型
---@field LUTsWhiteTemp number LUTs白色温度
---@field LUTsWhiteTnumber number LUTs白色色调
---@field LUTsColorCorrectionShadowsMax number LUTs最大色彩校正阴影
---@field LUTsColorCorrectionHighlightsMin number LUTs最小色彩校正高亮
---@field LUTsBlueCorrection number LUTs蓝光校正
---@field LUTsExpandGamut number LUTs扩展色域
---@field LUTsToneCurveAmout number LUTs色调曲线数量
---@field LUTsFilmicToneMapSlope number LUTs电影色调映射斜率
---@field LUTsFilmicToneMapToe number LUTs电影色调映射阴影
---@field LUTsFilmicToneMapShoulder number LUTs电影色调映射高光
---@field LUTsFilmicToneMapBlackClip number LUTs电影色调映射黑色调
---@field LUTsFilmicToneMapWhiteClip number LUTs电影色调映射白色调
---@field LUTsBaseSaturation ColorQuad LUTs基础饱和颜色
---@field LUTsBaseContrast ColorQuad LUTs基础对比颜色
---@field LUTsBaseGamma ColorQuad LUTs基础γ颜色
---@field LUTsBaseGain ColorQuad LUTs基础增益颜色
---@field LUTsBaseOffset ColorQuad LUTs基础偏移颜色
---@field LUTsShadowSaturation ColorQuad LUTs阴影饱和颜色
---@field LUTsShadowContrast ColorQuad LUTs阴影对比颜色
---@field LUTsShadowGamma ColorQuad LUTs阴影γ颜色
---@field LUTsShadowGain ColorQuad LUTs阴影增益颜色
---@field LUTsShadowOffset ColorQuad LUTs阴影偏移颜色
---@field LUTsMidtoneSaturation ColorQuad LUTs中间色调饱和颜色
---@field LUTsMidtoneContrast ColorQuad LUTs中间色调对比颜色
---@field LUTsMidtoneGamma ColorQuad LUTs中间色调γ颜色
---@field LUTsMidtoneGain ColorQuad LUTs中间色调增益颜色
---@field LUTsMidtoneOffset ColorQuad LUTs中间色调偏移颜色
---@field LUTsHighlightSaturation ColorQuad LUTs高光饱和颜色
---@field LUTsHighlightContrast ColorQuad LUTs高光对比颜色
---@field LUTsHighlightGamma ColorQuad LUTs高光γ颜色
---@field LUTsHighlightGain ColorQuad LUTs高光增益颜色
---@field LUTsHighlightOffset ColorQuad LUTs高光偏移颜色
---@field LUTsColorGradingLUTPath string LUTs颜色分级表路径
---@field GTAOActive boolean GTAO开关
---@field GTAOThicknessblend number 0~1
---@field GTAOFalloffStartRatio number 0-1
---@field GTAOFalloffEnd number 0-300
---@field GTAOFadeoutDistance number 0-20000
---@field GTAOFadeoutRadius number 0-10000
---@field GTAOnumberensity number 0-1
---@field GTAOPower number 0-10
---@field ChromaticAberrationActive boolean 开关
---@field ChromaticAberrationnumberensity number 0-8
---@field ChromaticAberrationStartOffset number 0-1
---@field ChromaticAberrationIterationStep number 0.01-10
---@field ChromaticAberrationIterationSamples number 1-8
---@field VignetteActive boolean 开关
---@field Vignettenumberensity number 0-1
---@field VignetteRounded boolean 0-1
---@field VignetteSmoothness number 0-1
---@field VignetteCenter Vector2 vector2
---@field VignetteColor ColorQuad 颜色
---@field VignetteMode VignetteMode 模式
---@field VignetteRoundness number 0-1
---@field VignetteMaskTexturePath string 遮罩贴图路径,需要透明通道
---@field VignetteMaskOpacity number 0-1
---@field BloomLuminanceScale number 0-1
---@field BloomIterator number 2-4
---@field RadialFlashActive boolean 开关
---@field RadialFlashLuminance number 0-10
---@field RadialFlashRadius number 0-1
---@field RadialFlashContrast number 0-10
---@field RadialFlashThreshold number 0-1
---@field RadialFlashColor ColorQuad 颜色
---@field RadialFlashPivot Vector2 vector2
---@field RadialFlashScale Vector2
---@field RadialFlashSpeed Vector2 0-1
---@field RadialFlashNoiseTexturePath string 噪声贴图路径
---@field MaterialListActive boolean PostProcessing材质列表开关
---@field MaterialList table PostProcessing材质列表
---@field SetMaterialListParamByIndex fun(self: PostProcessing, index>材质列表的索引: number, table>需要修改的材质的参数: ReflexMap) None 设置材质列表的参数


---@class Ragdoll
---@field Activate boolean



---@class RagdollJonumber
---@field MinLimit number
---@field MaxLimit number
---@field SwingLimit number
---@field RadiusScale number
---@field Density number
---@field BindJonumberName string
---@field JonumberType RagdollBoneJonumber



---@class Sequence
---@field SequenceId string 动画序列ID
---@field Time number 动画时长



---@class SkeletonAnimation
---@field SkeletonAsset string 骨骼资源
---@field IsValid fun(self: SkeletonAnimation) boolean 检测是否已经失效了
---@field SetSkeleton fun(self: SkeletonAnimation, node: SandboxNode) None 设置骨骼
---@field UpdateSkeleton fun(self: SkeletonAnimation, node: AssetResType, url: string) None 更新骨骼


---@class TweenService
---@field Create fun(self: TweenService, node: SandboxNode, info: TweenInfo, map: table):UITween 将暂停补间动画的播放


---@class UITween
---@field Pause fun(self: UITween) void 将暂停补间动画的播放
---@field Play fun(self: UITween) void 将开始补间动画的播放
---@field Cancel fun(self: UITween) void 将停止补间动画的播放并重置它的变量
---@field Resume fun(self: UITween) void 将继续补间动画播放
---@field Completed Event<fun(self: UITween, status: TweenStatus)> None 补间动画结束时触发，会触发一个Completed通知


---@class Jonumber
---@field Attachment0 SandboxNode 连接第一个物理模型
---@field Attachment1 SandboxNode 连接第二个物理模型



---@class SandboxNode
---@field ClassType string 节点的ClassType名称（不可写）
---@field Name string 节点名
---@field Tag number 节点标签
---@field Parent SandboxNode 父节点
---@field parent SandboxNode 父节点（仅脚本可调用）
---@field Children SandboxNode[] 全部子节点。（仅脚本可调用）
---@field Enabled boolean 节点是否被禁用。被禁用后节点内逻辑，事件，通知等不生效。
---@field Visible boolean 节点是否可见。
---@field Attibutes AttributeContainer 获取属性容器。（仅脚本可调用）
---@field SyncMode NodeSyncMode 同步模式（仅主机能够设置）
---@field LocalSyncFlag NodeSyncLocalFlag 本地同步标识（本地属性，不需要同步）
---@field IgnoreSafeMode boolean 忽略安全模式
---@field ResourceLoadMode ResourceLoadMode
---@field FlagDebug unsignedlonglong
---@field ID SandboxNodeID 节点ID
---@field Clone fun(self: SandboxNode) SandboxNode 节点克隆，克隆反射属性，自定义属性，以及包含的子对象
---@field FindFirstChild fun(self: SandboxNode) SandboxNode 通过节点名找到节点对象
---@field Destroy fun(self: SandboxNode) void 销毁节点
---@field ClearAllChildren fun(self: SandboxNode) void 清除所有子节点
---@field SetParent fun(self: SandboxNode, parent: SandboxNode) None 设置父节点
---@field GetNodeid fun(self: SandboxNode) SandboxNodeID 获取节点id
---@field GetAttribute fun(self: SandboxNode, attr: string) ReflexVariant 获取attr的反射属性
---@field SetAttribute fun(self: SandboxNode, attr: string, value: ReflexVariant) boolean 设置反射的属性值
---@field AddAttribute fun(self: SandboxNode, attr: string, type: AttributeType) None 添加一条反射属性
---@field DeleteAttribute fun(self: SandboxNode, attr: string) None 通过attr名删除一条反射属性
---@field IsA fun(self: SandboxNode, value: string) boolean 判断节点的ClassType是不是属于value代表的ClassType
---@field SetReflexSyncMode fun(self: SandboxNode, rvname: string, mode: NodeSyncMode) None 设置反射同步模式（仅主机能够设置）
---@field GetReflexSyncMode fun(self: SandboxNode) NodeSyncMode 获取反射同步模式
---@field SetReflexLocalSyncFlag fun(self: SandboxNode, rvname: string, flag: NodeSyncLocalFlag) None 设置反射本地同步标记
---@field GetReflexLocalSyncFlag fun(self: SandboxNode) NodeSyncLocalFlag 获取反射本地同步标记
---@field ManualLoad fun(self: SandboxNode) void 同步
---@field ManualLoadAsync fun(self: SandboxNode) void
---@field ManualUnLoad fun(self: SandboxNode) void 主动卸载
---@field AncestryChanged Event<fun(self: SandboxNode, ancestry: SandboxNode)> 祖先节点变化时，会触发一个AncestryChanged通知
---@field ParentChanged Event<fun(self: SandboxNode, parent: SandboxNode)> 父节点 fun(或父级节点)变化时，会触发一个ParentChanged通知
---@field AttributeChanged Event<fun(self: SandboxNode, attr: string)> 属性发生变化时，会触发一个AttributeChanged通知
---@field ChildAdded Event<fun(self: SandboxNode, child: SandboxNode)> 新增子节点时，会触发一个ChildAdded通知
---@field ChildRemoved Event<fun(self: SandboxNode, child: SandboxNode)> 移除子节点时，会触发一个ChildRemoved通知
---@field CustomAttrChanged fun(self: SandboxNode, attr: string) None 自定义属性发生变化，会触发一个CustomAttrChanged通知
---@field new fun(name: string, parent: SandboxNode) SandboxNode 创建一个新节点
---@field New fun(name: string, parent: SandboxNode) SandboxNode 创建一个新节点


---@class ScriptNode
---@field luafile string 加载模式是`LoadMode::LUAFILE`时会执行设置的`luafile`的[`string`] fun(/Api/DataType/String.md)内容
---@field code string 加载模式是`LoadMode::LUACODE`时会执行设置`code`的字符串内容



---@class Transform:SandboxNode
---@field Position Vector3 全局坐标
---@field Euler Vector3 全局欧拉角
---@field Rotation Quaternion 全局旋转
---@field LocalPosition Vector3 局部坐标
---@field LocalEuler Vector3 局部欧拉角
---@field LocalScale Vector3 局部欧拉角
---@field CubeBorderEnable boolean 立方体边框是否被禁止
---@field Layer LayerIndexDesc 灯光层级
---@field ForwardDir Vector3 看向指定方向
---@field InheritParentVisible boolean 是否跟随父节点显示或者隐藏，不影响visible属性
---@field Locked boolean 是否场景操作选中
---@field GetRenderPosition fun(self: Transform) Vector3 获取渲染世界位置
---@field GetRenderRotation fun(self: Transform) Quaternion 获取渲染世界旋转
---@field GetRenderEuler fun(self: Transform) Vector3 获取渲染世界欧拉角
---@field SetLocalPosition fun(self: Transform, x: number, y: number, z: number) None 设置本地位置
---@field SetLocalScale fun(self: Transform, x: number, y: number, z: number) None 设置本地缩放
---@field SetLocalEuler fun(self: Transform, x: number, y: number, z: number) None 设置本地欧拉角
---@field SetWorldPosition fun(self: Transform, x: number, y: number, z: number) None 设置全局位置
---@field SetWorldScale fun(self: Transform, x: number, y: number, z: number) None 设置全局缩放
---@field SetWorldEuler fun(self: Transform, x: number, y: number, z: number) None 设置全局欧拉角
---@field LookAt fun(self: Transform, pos: Vector3, y: boolean) None 看向指定位置
---@field LookAtObject fun(self: Transform, x: Transform, y?: boolean) None 看向指定位置


---@class BindAttachment
---@field BoneName string 绑点名字
---@field Position Vector3 绑点坐标
---@field Euler Vector3 绑点欧拉角



---@class HingeJonumber
---@field LimitsEnable boolean 是否限制启用
---@field UpperAngle number 限制的最大角度
---@field LowerAngle number 限制的最小角度
---@field Restitution number 达到最大或最小角度后的一个回拉力
---@field Spring number 弹力
---@field Damping number 阻尼大小
---@field LimitTargetAngle number 限制的目标角度
---@field ActuatorType MotorType ）
---@field MotorAngularSpeed number motor传动参数:角速度
---@field MotorMaxTorque number ――暂时还没实现。



---@class PhysXService
---@field SetCollideInfo fun(self: PhysXService, groupID0: unumber32_t, groupID1: unumber32_t, b: boolean) boolean 设置碰撞信息
---@field GetCollideInfo fun(self: PhysXService, groupID0: unumber32_t, groupID1: unumber32_t) boolean 是否产生碰撞
---@field SetCollideInfo2D fun(self: PhysXService) boolean
---@field GetCollideInfo2D fun(self: PhysXService) boolean


---@class SpringJonumber
---@field Spring number 弹簧的弹力
---@field Damper number 弹簧的阻力
---@field MinDistance number 弹簧的最小距离
---@field MaxDistance number 弹簧的最大距离
---@field Tolerance number 弹簧的限度



---@class StickJonumber
---@field Distance number 直杆距离
---@field LimitAngle0 number 直杆接头极限角度



---@class VisibleJonumber
---@field ModelId string 模型ID
---@field TextureId string 纹理ID



---@class Weld
---@field Enable boolean 是否可用
---@field Part0Id number 部件0的Id
---@field Part1Id number 部件1的Id
---@field C0Position Vector3 C0位置
---@field C0Euler Vector3 C0扭矩



---@class Atmosphere
---@field FogType FogType 雾效类型
---@field FogColor ColorQuad 雾效颜色
---@field FogStart number 最小能见度
---@field FogEnd number 最大能见度
---@field FogOffset number 雾效偏移度



---@class Block
---@field Position WCoord 方块坐标
---@field Block Block 方块对象
---@field PlaceType BLOCKPLACETYPE 放置类型：覆盖；空气则放置；相同方块id则不覆盖；只当ID不同时覆盖，仅blockdata不同时不会覆盖；



---@class BlockMaterial



---@class BlockService
---@field DropBlockAsItem fun(self: BlockService, workspace: SandboxNode_Ref, pos: Vector3, droptype: number, chance: number, useToolId: number) None 将方块从道具栏丢弃
---@field SetBlock fun(self: BlockService, workspace: SandboxNode_Ref, pos: Vector3, blockid: number, dir: number) None 修改方块朝向
---@field ReplaceBlock fun(self: BlockService, workspace: SandboxNode_Ref, pos: Vector3, srcId: number, destId: number) None 替换方块
---@field DestroyBlock fun(self: BlockService, workspace: SandboxNode_Ref, pos: Vector3, bDropItem: boolean) None 销毁方块
---@field SetBlockAttrState fun(self: BlockService, workspace: SandboxNode_Ref, blockid: number, attrType: number, bActive: boolean) None 设置方块属性状态
---@field SetFunctionBlockTrigger fun(self: BlockService, workspace: SandboxNode_Ref, pos: Vector3, bActive: boolean) None 设置功能方块触发器（区域笔刷）
---@field AreaFillBlock fun(self: BlockService, workspace: SandboxNode_Ref, areaNode: SandboxNode_Ref, blockid: number) None 区域内填充方块
---@field AreaClearBlock fun(self: BlockService, workspace: SandboxNode_Ref, areaNode: SandboxNode_Ref) None 区域内删除方块
---@field AreaReplaceBlock fun(self: BlockService, workspace: SandboxNode_Ref, areaNode: SandboxNode_Ref, srcId: number, destId: number) None 区域替换方块
---@field AreaCopyBlock fun(self: BlockService, workspace: SandboxNode_Ref, areaNode: SandboxNode_Ref, destPos: Vector3) None 区域拷贝方块
---@field SetBlockSettingAttState fun(self: BlockService, workspace: SandboxNode_Ref, blockid: number, attr: number, bOpen: boolean) None 设置方块的属性设置状态
---@field GetRayBlock fun(self: BlockService, workspace: SandboxNode_Ref, vector3: Vector3, face: number, distance: number) Number 获取方块光线
---@field IsSolidBlock fun(self: BlockService, workspace: SandboxNode_Ref, vector3: Vector3) boolean 是否固体方块
---@field IsLiquidBlock fun(self: BlockService, workspace: SandboxNode_Ref, vector3: Vector3) boolean 是否液体方块
---@field IsAirBlock fun(self: BlockService, workspace: SandboxNode_Ref, vector3: Vector3) boolean 是否空气方块
---@field GetBlockData fun(self: BlockService, workspace: SandboxNode_Ref, vector3: Vector3) Number 获取方块朝向数据
---@field GetBlockMaterial fun(self: BlockService, workspace: SandboxNode_Ref, vector3: Vector3) SandboxNode_Ref 获取方块材质
---@field GetBlockNode fun(self: BlockService, workspace: SandboxNode_Ref, vector3: Vector3) SandboxNode_Ref 获取方块节点


---@class BluePrnumber
---@field Path string 蓝图所在路径
---@field RotateType RotateTypeEnum 旋转类型
---@field Create boolean 是否创建
---@field BuildRate number 建筑率



---@class Environment
---@field Weather EnumWeather 设置天气类型:晴天、雨天、打雷和自定义
---@field Gravity number 环境重力效果设置
---@field TimeHour number 时间设置
---@field LockTimeHour boolean 是否锁定时间
---@field LockTime fun(self: Environment, timehour: number) None 锁定时间（兼容旧版，应该废弃）
---@field WeatherChanged fun(self: Environment, weather: number) None 当天气改变时，会触发一个WeatherChanged通知
---@field GravityChanged fun(self: Environment, gravity: number) None 当重力改变时，会触发一个GravityChanged通知
---@field TimeChanged fun(self: Environment, timehour: number) None 当时间改变时，会触发一个TimeChanged通知


---@class GeoSolid
---@field GeoSolidShape GeoSolidShape 基本形状
---@field Hollow boolean 是否是镂空的模型



---@class Light
---@field LightColor ColorQuad 光源颜色
---@field Active boolean 光源激活
---@field RadiusRange number 半径范围
---@field InnerConeAngle number 内锥角
---@field OuterConeAngle number 外锥角
---@field FallOff number 散开
---@field SpecularScale number 镜面反射比例
---@field ShadowBias number 阴影偏移
---@field ShadowSlopeBias number 阴影倾斜光栅
---@field CullingMasks table 灯光层级剔除



---@class Material
---@field DepthFunc DepthFunc 深度检测
---@field DepthWrite DepthWrite 深度写入
---@field RenderGroup Unumber8 实体渲染
---@field CullMode CullMode 消隐模式
---@field BaseMaterial BaseMaterial 基础材料
---@field Manumberexture string 主纹理
---@field ManumberextureTileScale Vector2 主纹理平铺比例
---@field ManumberextureTileOffset Vector2 主纹理平铺偏移
---@field SpecScale number 规格比例
---@field Specnumberensity number 规格强度
---@field ShadowColor ColorQuad 阴影颜色
---@field AlphaTransparent number 透明度
---@field RGBATransparent number RGB透明度
---@field EnableEmissive boolean 启用发射
---@field EmissiveTexture string 发射纹理
---@field EmissiveTextureColor ColorQuad 发射纹理颜色
---@field GlitterSpeed number 闪光速度
---@field GlitterPower number 闪光功率
---@field ShadowPowerMin number 阴影调解系数最小值
---@field ShadowPowerMax number 阴影调解系数最大值
---@field Brightness number 亮度：发光体 fun(反光体)表面发光 fun(反光)强弱的物理量
---@field StepAmount number 渐变Amount
---@field OnStep number 渐变
---@field InnerColor ColorQuad 内发光的颜色
---@field EnableRimColor boolean 是否外发光
---@field RimWidth number 发光区域
---@field Rimnumberensity number 边缘光强度
---@field RimColor ColorQuad 外发光的颜色
---@field NormalTexture string 法线纹理
---@field DiffuseIns number 漫反射光照模型
---@field ShadowIns number ShadowIns



---@class SelecterService
---@field OnNodeBeSelected fun(self: SelecterService, uin: number, sceneid: number, node: SandboxNode) None 被选中节点
---@field OnNodeUnselected fun(self: SelecterService, uin: number, sceneid: number, node: SandboxNode) None 未被选中节点
---@field OnBlockBeSelected fun(self: SelecterService, uin: number, sceneid: number, block: WCoord) None 被选中的方块
---@field OnBlockUnselected fun(self: SelecterService, uin: number, sceneid: number, block: WCoord) None 未被选中的方块
---@field OnAllUnselected fun(self: SelecterService, uin: number, sceneid: number) None 所有未选中
---@field OnBlockPosChanged fun(self: SelecterService, uin: number, sceneid: number, posSrc: WCoord, posDst: WCoord) None 方块坐标更改
---@field OnSelectType fun(self: SelecterService, uin: number, sceneid: number, type: number) None 选中类型
---@field OnBlockBeSelectedVec fun(self: SelecterService, uin: number, sceneid: number, blocks: Table) None 被批量选中的方块
---@field OnBlockUnselectedVec fun(self: SelecterService, uin: number, sceneid: number, blocks: Table) None 未被批量选中的方块


---@class SkyDome
---@field HazeColor ColorQuad 薄雾
---@field HorizonColor ColorQuad 水平颜色
---@field ZenithColor ColorQuad 天顶颜色
---@field SkyBoxType SkyBoxType 天空盒类型
---@field CloudsEnable boolean 是否启用云层
---@field ShadowColor ColorQuad 阴影颜色
---@field ShadowDarkColor ColorQuad 阴影深色
---@field CloudsCoverage number 云层覆盖率
---@field Lightnumberensity number 光强度
---@field CloudsSpeed number 云的移动速度
---@field CloudsAlpha number 云的透明度
---@field StarsAmount number 星星数量
---@field CubeAssetID string 天空盒资源ID



---@class SkyLight



---@class SunLight
---@field numberensity number 光源强度
---@field Color ColorQuad 光源颜色
---@field LockTimeDir boolean 是否锁定时间
---@field Euler Vector3 光源欧拉角
---@field ShadowBias number 阴影偏移
---@field ShadowSlopeBias number 阴影倾斜光栅
---@field ShadowDistance number 阴影长度
---@field SunRaysActive boolean 太阳光线是否激活
---@field SunRaysScale number 太阳光线比例
---@field SunRaysThreahold number 太阳光线阈值
---@field SunRaysColor ColorQuad 太阳光线颜色
---@field UseCustomSunAndMoonTex boolean 是否使用自定义太阳和月亮纹理资源
---@field SunTex string 太阳资源纹理
---@field SunScale Vector2 太阳比例
---@field MoonTex string 月亮资源纹理
---@field MoonScale Vector2 月亮比例
---@field ShadowCascadeCount ShadowCascadeCount 阴影层叠数



---@class Terrain
---@field IsAirBlock fun(self: Terrain, x: number, y: number, z: number) boolean 位置在（x,y,z）的方块是否是空气方块
---@field SetBlockAll fun(self: Terrain, x: number, y: number, z: number, blockid方块id: number, blockdata方块data: number) None 设置位置（x,y,z）为XXX方块，并且设置该位置的blockdata
---@field GetBlockMaterial fun(self: Terrain, x: number, y: number, z: number) SandboxNode 获取位置（x,y,z）的方块
---@field GetBlockNode fun(self: Terrain, x: number, y: number, z: number) SandboxNode 获取位置（x,y,z）的方块实例


---@class Asset
---@field AssetId string 资源id
---@field AssetResType AssetResType 资源类型



---@class AssetContent
---@field Ready fun(self: AssetContent) boolean 是否准备就绪
---@field Load fun(self: AssetContent, loadType: AssetResType, assetId: string) None 通过资源类型和id加载该资源
---@field Clear fun(self: AssetContent) void 该资源清除
---@field IsLoadSuccess fun(self: AssetContent) boolean 该资源模型是否已经加载完成
---@field GetLoadAssetId fun(self: AssetContent) String 获取加载的资源id
---@field GetResType fun(self: AssetContent) AssetResType 获取加载的资源类型
---@field LoadFinish fun(self: AssetContent, isFinish: boolean) None 资源加载完成时触发


---@class CloudKVStore
---@field GetTopSync fun(self: CloudKVStore, count: number) Number 获取排行榜Top数据
---@field GetBottomSync fun(self: CloudKVStore, count: number) Number 获取排行榜Bottom数据
---@field GetRangeSync fun(self: CloudKVStore) Number
---@field GetOrderDataIndex fun(self: CloudKVStore, bAscend: boolean, nIndex: number) Number 获取排行榜名次
---@field CleanOrderDataList fun(self: CloudKVStore) void replace
---@field Clean fun(self: CloudKVStore) void 清理排行榜数据
---@field SetValue fun(self: CloudKVStore, key: string, name: string, value: number) Number 设置同步kv值
---@field GetValue fun(self: CloudKVStore, key: string, name: string) Number 获取同步kv值
---@field SetValueAsync fun(self: CloudKVStore, key: string, name: string, value: number, func: function) Number 设置异步kv值
---@field GetValueAsync fun(self: CloudKVStore, key: string, value: string, func: function) Number 获取异步kv值
---@field RemoveKey fun(self: CloudKVStore, key: string) Number 同步移除kv值
---@field RemoveKeyAsync fun(self: CloudKVStore, key: string, arg2: function) Number 异步移除kv值


---@class DefaultEffect
---@field EffectType EnumDefaultEffect 特效效果类型,有烟雾、爆炸、光效、粒子、火焰、环境和提示
---@field EffectIndex number 特效效果序列
---@field Scale number 整体缩放比例
---@field Visible boolean 是否显示视觉效果
---@field MaxTime number 特效持续时长
---@field VisibleDistance number 特效最大可见距离
---@field AssetID string 资源ID
---@field CullLayer CullLayer 消隐层



---@class EffectObject : Transform
---@field AssetID string 特效资源id
---@field Duration number 特效持续时间
---@field Looping boolean 特效是否循环
---@field Material string 轨迹材质路径
---@field Rate number 特效进度
---@field TexturePath string 纹理路径
---@field TrailsMode EmitterTrailsMode 轨迹模式
---@field TrailsTextureMode EmitterTrailsTextureMode 轨迹纹理模式
---@field SizeAffectsWidth boolean 尺寸影响宽度
---@field InheritParticleColor boolean 继承粒子颜色
---@field ColorOverTrails ColorQuad 彩色覆盖轨迹
---@field TrailsTexturePath string 轨迹纹理路径
---@field SimulationSpeed number 播放速度
---@field AutoDestory boolean 自动销毁
---@field ColorOverLifeTimeMode EmitterColorOverLifeTimeMode \t颜色随生命周期内变化模式
---@field ColorOverLifeTimeMinColor ColorQuad \t颜色随生命周期内变化的最小颜色值
---@field ColorOverLifeTimeMaxColor ColorQuad \t颜色随生命周期内变化的最大颜色值
---@field Prewarm boolean 预热
---@field SimulationSpace ParticleSystemSimulationSpace 移动坐标系
---@field DeltaTime boolean 单位时间
---@field ScalingMode ParticleSystemScalingMode 缩放模式
---@field PlayOnAwake boolean 创建时启动
---@field MaxParticles number 最大粒子数量
---@field AutoRandomSeed boolean 自动随机种子
---@field RandomSeed number 随机种子
---@field CullingMode ParticleSystemCullingMode 裁剪模式
---@field RingBufferMode ParticleSystemRingBufferMode
---@field LoopRange Vector2 粒子循环生命区间
---@field StartColorGradient ParticleEmitterColorGradient
---@field TrailMaterial string
---@field Brust ParticleEmissionBurst （爆发），产生粒子爆发的效果，通过Time（时间）、Count（数量）、Cycles（周期）、numbererval（间隔）四个参数调整。
---@field EnableSizeOverLifeTime boolean
---@field OverLifeTimeSize Vector3
---@field EnableRotationOverLifeTime boolean
---@field EnableUV boolean 开启uv模块
---@field UVMode ParticleSystemUVMode uv模式
---@field Tiles Vector2 Y（垂直）方向上划分的区块数量。
---@field Animation ParticleSystemUVGridType 动画模式
---@field RowMode ParticleSystemUVRowMode
---@field CustomRow number
---@field TimeMode ParticleSystemUVTimeMode
---@field SpeedRange Vector2
---@field FPS number 根据指定的每秒帧数值对帧进行采样
---@field Cycles number 动画序列在粒子生命周期内重复的次数。
---@field EnableVelocityOverLifetime boolean 是否开启
---@field VelocityOverLifeTimeSpace ParticleVelocityOverLifetimeSpaceMode
---@field EnableLimitVelocityOverLifetime boolean 是否开启
---@field EnableSeparateAxes ParticleLimitVelocityOverLifetimeSeparateAxes 分量。
---@field LimitVelocityOverLifeTimeSpace ParticleLimitVelocityOverLifetimeSpaceMode
---@field LimitVelocityOverLifeTimeDampen number
---@field MultiplyBySize boolean 启用此属性后，较大的粒子会更大程度上受到阻力系数的影响。
---@field MultiplyByVelocity boolean 启用此属性后，较快的粒子会更大程度上受到阻力系数的影响。
---@field TrailsRatio number 随机分配轨迹，因此该值表示概率。
---@field TrailsMinVertexDistance number 定义粒子在其轨迹接收新顶点之前必须经过的距离。
---@field TrailsWorldSpace boolean Space__，轨迹顶点也不会相对于粒子系统的游戏对象移动。相反，轨迹顶点将被置于世界空间中，并忽略粒子系统的任何移动
---@field TrailsDieWithParticles boolean 轨迹会在粒子死亡时立即消失
---@field TrailsRibbonCount number 选择要在整个粒子系统中渲染的轨迹带数量
---@field TrailsSplitSubEmitterRibbons boolean 在用作子发射器的系统上启用此属性时，从同一父系统粒子生成的粒子将共享一个轨迹带
---@field TrailsAttachRibbonsToTransform boolean
---@field TrailsSizeAffectsLifetime boolean 如果启用此属性（选中复选框），则轨迹生命周期受粒子大小影响。
---@field TrailsOverLifetimeColorMode ParticleSystemGradientMode 通过一条曲线控制整个轨迹在其附着粒子的整个生命周期内的颜色。
---@field TrailsOverMode ParticleSystemGradientMode 通过一条曲线控制轨迹沿其长度的颜色。
---@field TrailsOverGradient ParticleEmitterColorGradient 通过一条曲线控制轨迹沿其长度的颜色。。
---@field TrailsGenerateLightingData boolean 通过启用此属性（选中复选框），可在构建轨迹几何体时包含法线和切线。这样允许它们使用具有场景光照的材质，例如通过标准着色器，或通过使用自定义着色器。
---@field TrailsShadowBias number
---@field TrailsAlignment ParticleLineAlignment
---@field EnableColorBySpeed boolean
---@field ColorBySpeedGradient ParticleEmitterColorGradient 在速度范围内定义的粒子的颜色渐变。
---@field ColorBySpeedRange Vector2 颜色渐变映射到的速度范围的下限和上限（超出范围的速度将映射到渐变的端点）。。
---@field EnableSizeBySpeed boolean
---@field SizeBySpeedRange Vector2 大小曲线映射到的速度范围的下限和上限（超出范围的速度将映射到曲线的端点）。
---@field EnableRotationBySpeed boolean
---@field RotationBySpeedRange Vector2 大小曲线映射到的速度范围的下限和上限（超出范围的速度将映射到曲线的端点）。
---@field EnableNoise boolean
---@field NoiseFrequency number 此属性可控制粒子改变行进方向的频率以及方向变化的突然程度。
---@field NoiseDamping boolean 启用此属性后，强度与频率成正比。
---@field NoiseOctaveCount number 指定组合多少层重叠噪声来产生最终噪声值。
---@field NoiseOctaveMultiplier number 对于每个附加的噪声层，按此比例降低强度。
---@field NoiseOctaveScale number 对于每个附加的噪声层，按此乘数调整频率。
---@field NoiseQuality ParticleQualityDropdown 较低的质量设置可显著降低性能成本，但也会影响噪声的有趣程度。请使用能为您提供所需行为的最低质量以获得最佳性能。
---@field NoiseRemapEnabled boolean 将最终噪声值重新映射到不同的范围。
---@field EnableCustomData boolean
---@field CustomDataMode1 ParticleCustomDataMode
---@field CustomDataColorMode1 ParticleSystemGradientMode
---@field CustomDataMode2 ParticleCustomDataMode
---@field CustomDataColorMode2 ParticleSystemGradientMode
---@field EnableShape boolean
---@field ShapeType EmitterShape 特效类型
---@field ShapeRadius number 形状的圆形半径
---@field ShapeRadiusMode ParticleShapeMeshSpawnMode 如何在形状的弧形周围生成粒子
---@field ShapeRadiusSpread number 弧形周围可产生粒子的离散间隔
---@field ShapeRadiusThickness number 发射粒子的体积比例
---@field ShapeArc number 形成发射器形状的整圆的角部。
---@field ShapeArcMode ParticleShapeMeshSpawnMode 如何在形状的弧形周围生成粒子
---@field ShapeArcSpread number 弧形周围可产生粒子的离散间隔
---@field ShapeAngle number 锥体在其顶点处的角度
---@field ShapeLength number 锥体的长度
---@field ShapeConeType ParticleShapeConeType Cone类型
---@field ShapeDonutRadius number 外圆环的粗度
---@field ShapeBoxType ParticleShapeBoxType Box类型
---@field ShapeBoxThickness Vector3 发射粒子的体积比例
---@field ShapeMeshType ParticleShapeMeshType mesh类型
---@field ShapeMeshSpawnMode ParticleShapeMeshSpawnMode 如何在形状的弧形周围生成粒子
---@field ShapeMeshSpawnSpread number 弧形周围可产生粒子的离散间隔
---@field StartLifetimeState ParticleSystemCurveMode 特效生命周期
---@field StartSpeedState ParticleSystemCurveMode 开始速度
---@field GravityModifierState ParticleSystemCurveMode 重力
---@field RateOverTimeState ParticleSystemCurveMode （随时间的速率），每单位时间发射的粒子数量
---@field RateOverDistanceState ParticleSystemCurveMode （通过距离的速率），每单位距离发射的粒子数量
---@field FrameOverTimeState ParticleSystemCurveMode 通过一条曲线指定动画帧随着时间的推移如何增加
---@field VelocityOverLifeTimeLinearState ParticleSystemCurveMode X，Y和Z轴的速度
---@field VelocityOverLifeTimeOrbitalState ParticleSystemCurveMode 轴的轨道速度。
---@field VelocityOverLifeTimeOffsetState ParticleSystemCurveMode 轨道中心的位置，适用于轨道运行粒子。
---@field VelocityOverLifeTimeRadialState ParticleSystemCurveMode 粒子远离/朝向中心位置的径向速度。
---@field VelocityOverLifeTimeSpeedModifierState ParticleSystemCurveMode 在当前行进方向上/周围向粒子的速度应用一个乘数。
---@field TrailsLifetimeState ParticleSystemCurveMode 轨迹中每个顶点的生命周期，表示为所属粒子的生命周期的乘数。当每个新顶点添加到轨迹时，该顶点将在其存在时间超过其总生命周期后消失。
---@field WidthOverTrailsState ParticleSystemCurveMode 轨迹上方的宽度
---@field NoiseScrollSpeedState ParticleSystemCurveMode 随着时间的推移而移动噪声场可产生更不可预测和不稳定的粒子移动
---@field NoiseRemapState ParticleSystemCurveMode 将最终噪声值重新映射到不同的范围
---@field NoisePositionAmountState ParticleSystemCurveMode 用于控制噪声对粒子位置影响程度的乘数
---@field NoiseRotationAmountState ParticleSystemCurveMode 用于控制噪声对粒子旋转（以度/秒为单位）影响程度的乘数。
---@field NoiseSizeAmountState ParticleSystemCurveMode 用于控制噪声对粒子大小影响程度的乘数
---@field ShapeRadiusSpeedState ParticleSystemCurveMode 发射位置围绕弧形移动的速度
---@field ShapeArcSpeedState ParticleSystemCurveMode 发射位置围绕弧形移动的速度
---@field ShapeMeshSpawnSpeedState ParticleSystemCurveMode 发射位置围绕弧形移动的速度
---@field CustomDataVectorX1State ParticleSystemCurveMode
---@field CustomDataVectorY1State ParticleSystemCurveMode
---@field CustomDataVectorZ1State ParticleSystemCurveMode
---@field CustomDataVectorW1State ParticleSystemCurveMode
---@field CustomDataVectorX2State ParticleSystemCurveMode
---@field CustomDataVectorY2State ParticleSystemCurveMode
---@field CustomDataVectorZ2State ParticleSystemCurveMode
---@field CustomDataVectorW2State ParticleSystemCurveMode
---@field CullLayer CullLayer 消隐层
---@field IgnoreStreamSync boolean 忽略流同步
---@field ChildAutoPlay boolean 子节点是否自动播放
---@field StartDelayState EnumParticleSystemOnlyConstantCurveMode 开始延迟配置
---@field StartDelayConstant number 开始延迟单常量
---@field StartDelayTwoConstant RangeInfo 开始延迟双常量
---@field StartLifeTimeConstant number 开始生命周期单常量
---@field StartLifeTimeTwoConstant RangeInfo 开始生命周期双常量
---@field StartLifeTimeCurve FloatCurve开始生命周期双常量
---@field StartLifeTimeTwoCurve RangeFloatCurve 开始生命周期双常量
---@field StartSpeedConstant number 开始速度单常量
---@field StartSpeedTwoConstant RangeInfo 开始速度双常量
---@field StartSpeedOneCurve FloatCurve
---@field StartSpeedTwoCurve RangeFloatCurve 开始速度双曲线
---@field Start3DSizeSeparate boolean
---@field Start3DSizeState ParticleSystemCurveMode 特效尺寸
---@field Start3DSizeXConstant number
---@field Start3DSizeXTwoConstant RangeInfo
---@field Start3DSizeXCurve numberCurve
---@field Start3DSizeXTwoCurve RangeFloatCurve
---@field Start3DSizeYConstant number
---@field Start3DSizeYTwoConstant RangeInfo
---@field Start3DSizeYCurve numberCurve
---@field Start3DSizeYTwoCurve RangeFloatCurve
---@field Start3DSizeZConstant number
---@field Start3DSizeZTwoConstant RangeInfo
---@field Start3DSizeZCurve numberCurve
---@field Start3DSizeZTwoCurve RangeFloatCurve
---@field Start3DRotationSeparate boolean
---@field Start3DRotationState ParticleSystemCurveMode 特效尺寸
---@field Start3DRotationZConstant number
---@field Start3DRotationZTwoConstant RangeInfo
---@field Start3DRotationZCurve numberCurve
---@field Start3DRotationZTwoCurve RangeFloatCurve
---@field Start3DRotationYConstant number
---@field Start3DRotationYTwoConstant RangeInfo
---@field Start3DRotationYCurve numberCurve
---@field Start3DRotationYTwoCurve RangeFloatCurve
---@field Start3DRotationXConstant number
---@field Start3DRotationXTwoConstant RangeInfo
---@field Start3DRotationXCurve numberCurve
---@field Start3DRotationXTwoCurve RangeFloatCurve
---@field FlipRotation number
---@field StartColorState ParticleSystemGradientMode 粒子颜色方式
---@field StartColorQuad ColorQuad
---@field StartColorQuad2 ColorQuad
---@field StartColorGradient2 ParticleEmitterColorGradient
---@field GravityModifierConstant number
---@field GravityModifierTwoConstant RangeInfo
---@field GravityModifierOneCurve FloatCurve
---@field GravityModifierTwoCurve RangeFloatCurve
---@field RateOverTimeConstant number
---@field RateOverTimeTwoConstant RangeInfo
---@field RateOverTimeOneCurve FloatCurve
---@field RateOverTimeTwoCurve RangeFloatCurve
---@field RateOverDistanceConstant number
---@field RateOverDistanceTwoConstant RangeInfo
---@field RateOverDistanceOneCurve FloatCurve
---@field RateOverDistanceTwoCurve RangeFloatCurve
---@field ShapeRadiusSpeedConstant number
---@field ShapeRadiusSpeedTwoConstant RangeInfo
---@field ShapeRadiusSpeedOneCurve FloatCurve
---@field ShapeRadiusSpeedTwoCurve RangeFloatCurve
---@field ShapeArcSpeedConstant number
---@field ShapeArcSpeedTwoConstant RangeInfo
---@field ShapeArcSpeedOneCurve FloatCurve
---@field ShapeArcSpeedTwoCurve RangeFloatCurve
---@field ShapeMeshSpawnSpeedConstant number
---@field ShapeMeshSpawnSpeedTwoConstant RangeInfo
---@field ShapeMeshSpawnSpeedOneCurve FloatCurve
---@field ShapeMeshSpawnSpeedTwoCurve RangeFloatCurve
---@field VelocityOverLifeTimeLinearConstant Vector3
---@field VelocityOverLifeTimeLinearTwoConstant Vector3
---@field VelocityOverLifeTimeLinearXOneCurve FloatCurve
---@field VelocityOverLifeTimeLinearXTwoCurve RangeFloatCurve
---@field VelocityOverLifeTimeLinearYOneCurve FloatCurve
---@field VelocityOverLifeTimeLinearYTwoCurve RangeFloatCurve
---@field VelocityOverLifeTimeLinearZOneCurve FloatCurve
---@field VelocityOverLifeTimeLinearZTwoCurve RangeFloatCurve
---@field VelocityOverLifeTimeOrbitalConstant Vector3
---@field VelocityOverLifeTimeOrbitalTwoConstant Vector3
---@field VelocityOverLifeTimeOrbitalXOneCurve FloatCurve
---@field VelocityOverLifeTimeOrbitalXTwoCurve RangeFloatCurve
---@field VelocityOverLifeTimeOrbitalYOneCurve FloatCurve
---@field VelocityOverLifeTimeOrbitalYTwoCurve RangeFloatCurve
---@field VelocityOverLifeTimeOrbitalZOneCurve FloatCurve
---@field VelocityOverLifeTimeOrbitalZTwoCurve RangeFloatCurve
---@field VelocityOverLifeTimeOffsetConstant Vector3
---@field VelocityOverLifeTimeOffsetTwoConstant Vector3
---@field VelocityOverLifeTimeOffsetXOneCurve FloatCurve
---@field VelocityOverLifeTimeOffsetXTwoCurve RangeFloatCurve
---@field VelocityOverLifeTimeOffsetYOneCurve FloatCurve
---@field VelocityOverLifeTimeOffsetYTwoCurve RangeFloatCurve
---@field VelocityOverLifeTimeOffsetZOneCurve FloatCurve
---@field VelocityOverLifeTimeOffsetZTwoCurve RangeFloatCurve
---@field VelocityOverLifeTimeRadialConstant number
---@field VelocityOverLifeTimeRadialTwoConstant RangeInfo
---@field VelocityOverLifeTimeRadialOneCurve FloatCurve
---@field VelocityOverLifeTimeRadialTwoCurve RangeFloatCurve
---@field VelocityOverLifeTimeSpeedModifierConstant number
---@field VelocityOverLifeTimeSpeedModifierTwoConstant RangeInfo
---@field VelocityOverLifeTimeSpeedModifierOneCurve FloatCurve
---@field VelocityOverLifeTimeSpeedModifierTwoCurve RangeFloatCurve
---@field LimitVelocitySpeedState ParticleSystemCurveMode
---@field LimitVelocitySpeedConstant number
---@field LimitVelocitySpeedTwoConstant RangeInfo
---@field LimitVelocitySpeedOneCurve FloatCurve
---@field LimitVelocitySpeedTwoCurve RangeFloatCurve
---@field LimitVelocitySeparateSpeedState ParticleSystemCurveMode
---@field LimitVelocitySeparateSpeedConstant Vector3
---@field LimitVelocitySeparateSpeedTwoConstant Vector3
---@field LimitVelocitySeparateSpeedXOneCurve FloatCurve
---@field LimitVelocitySeparateSpeedXTwoCurve RangeFloatCurve
---@field LimitVelocitySeparateSpeedYOneCurve FloatCurve
---@field LimitVelocitySeparateSpeedYTwoCurve RangeFloatCurve
---@field LimitVelocitySeparateSpeedZOneCurve FloatCurve
---@field LimitVelocitySeparateSpeedZTwoCurve RangeFloatCurve
---@field LimitVelocityDragState ParticleSystemCurveMode
---@field LimitVelocityDragConstant number
---@field LimitVelocityDragTwoConstant RangeInfo
---@field LimitVelocityDragOneCurve FloatCurve
---@field LimitVelocityDragTwoCurve RangeFloatCurve
---@field ColorBySpeedState ParticleSystemGradientMode
---@field ColorBySpeedQuad ColorQuad
---@field ColorBySpeedQuad2 ColorQuad
---@field ColorBySpeedGradient2 ParticleEmitterColorGradient
---@field SizeOverLifeState ParticleSystemCurveMode
---@field SizeOverLifeConstant Vector3
---@field SizeOverLifeTwoConstant Vector3
---@field SizeOverLifeXOneCurve FloatCurve
---@field SizeOverLifeXTwoCurve RangeFloatCurve
---@field SizeOverLifeYOneCurve FloatCurve
---@field SizeOverLifeYTwoCurve RangeFloatCurve
---@field SizeOverLifeZOneCurve FloatCurve
---@field SizeOverLifeZTwoCurve RangeFloatCurve
---@field EnableSizeOverLifeSeparateAxes boolean
---@field SizeBySpeedState ParticleSystemCurveMode
---@field SizeBySpeedConstant Vector3
---@field SizeBySpeedTwoConstant Vector3
---@field SizeBySpeedXOneCurve FloatCurve
---@field SizeBySpeedXTwoCurve RangeFloatCurve
---@field SizeBySpeedYOneCurve FloatCurve
---@field SizeBySpeedYTwoCurve RangeFloatCurve
---@field SizeBySpeedZOneCurve FloatCurve
---@field SizeBySpeedZTwoCurve RangeFloatCurve
---@field RotationOverLifeState ParticleSystemCurveMode
---@field RotationOverLifeConstant Vector3
---@field RotationOverLifeTwoConstant Vector3
---@field RotationOverLifeXOneCurve FloatCurve
---@field RotationOverLifeXTwoCurve RangeFloatCurve
---@field RotationOverLifeYOneCurve FloatCurve
---@field RotationOverLifeYTwoCurve RangeFloatCurve
---@field RotationOverLifeZOneCurve FloatCurve
---@field RotationOverLifeZTwoCurve RangeFloatCurve
---@field RotationBySpeedState ParticleSystemCurveMode
---@field RotationBySpeedConstant Vector3
---@field RotationBySpeedTwoConstant Vector3
---@field RotationBySpeedXOneCurve FloatCurve
---@field RotationBySpeedXTwoCurve RangeFloatCurve
---@field RotationBySpeedYOneCurve FloatCurve
---@field RotationBySpeedYTwoCurve RangeFloatCurve
---@field RotationBySpeedZOneCurve FloatCurve
---@field RotationBySpeedZTwoCurve RangeFloatCurve
---@field NoiseStrengthState ParticleSystemCurveMode
---@field NoiseStrengthConstant Vector3
---@field NoiseStrengthTwoConstant Vector3
---@field NoiseStrengthXOneCurve FloatCurve
---@field NoiseStrengthXTwoCurve RangeFloatCurve
---@field NoiseStrengthYOneCurve FloatCurve
---@field NoiseStrengthYTwoCurve RangeFloatCurve
---@field NoiseStrengthZOneCurve FloatCurve
---@field NoiseStrengthZTwoCurve RangeFloatCurve
---@field NoiseScrollSpeedConstant number
---@field NoiseScrollSpeedTwoConstant RangeInfo
---@field NoiseScrollSpeedOneCurve FloatCurve
---@field NoiseScrollSpeedTwoCurve RangeFloatCurve
---@field NoiseRemapConstant Vector3
---@field NoiseRemapTwoConstant Vector3
---@field NoiseRemapXOneCurve FloatCurve
---@field NoiseRemapXTwoCurve RangeFloatCurve
---@field NoiseRemapYOneCurve FloatCurve
---@field NoiseRemapYTwoCurve RangeFloatCurve
---@field NoiseRemapZOneCurve FloatCurve
---@field NoiseRemapZTwoCurve RangeFloatCurve
---@field NoisePositionAmountConstant number
---@field NoisePositionAmountTwoConstant RangeInfo
---@field NoisePositionAmountOneCurve FloatCurve
---@field NoisePositionAmountTwoCurve RangeFloatCurve
---@field NoiseRotationAmountConstant number
---@field NoiseRotationAmountTwoConstant RangeInfo
---@field NoiseRotationAmountOneCurve FloatCurve
---@field NoiseRotationAmountTwoCurve RangeFloatCurve
---@field NoiseSizeAmountConstant number
---@field NoiseSizeAmountTwoConstant RangeInfo
---@field NoiseSizeAmountOneCurve FloatCurve
---@field NoiseSizeAmountTwoCurve RangeFloatCurve
---@field FrameOverTimeConstant number
---@field FrameOverTimeTwoConstant RangeInfo
---@field FrameOverTimeOneCurve FloatCurve
---@field FrameOverTimeTwoCurve RangeFloatCurve
---@field UVStartFrameState EnumParticleSystemOnlyConstantCurveMode
---@field UVStartFrameConstant number
---@field UVStartFrameTwoConstant RangeInfo
---@field TrailsLifetimeConstant number
---@field TrailsLifetimeTwoConstant RangeInfo
---@field TrailsLifetimeOneCurve FloatCurve
---@field TrailsLifetimeTwoCurve RangeFloatCurve
---@field TrailsOverLifetimeColorQuad ColorQuad
---@field TrailsOverLifetimeColorGradient ParticleEmitterColorGradient
---@field TrailsOverLifetimeQuad2 ColorQuad
---@field TrailsOverLifetimeGradient2 ParticleEmitterColorGradient
---@field WidthOverTrailsConstant number
---@field WidthOverTrailsTwoConstant RangeInfo
---@field WidthOverTrailsOneCurve FloatCurve
---@field WidthOverTrailsTwoCurve RangeFloatCurve
---@field TrailsOverQuad ColorQuad
---@field TrailsOverGradient ParticleEmitterColorGradient 通过一条曲线控制轨迹沿其长度的颜色。。
---@field TrailsOverQuad2 ColorQuad
---@field TrailsOverGradient2 ParticleEmitterColorGradient
---@field CustomData1ColorQuad ColorQuad
---@field CustomData1ColorGradient ParticleEmitterColorGradient
---@field CustomData1ColorQuad2 ColorQuad
---@field CustomData1ColorGradient2 ParticleEmitterColorGradient
---@field CustomData1XConstant number
---@field CustomData1XTwoConstant RangeInfo
---@field CustomData1XOneCurve FloatCurve
---@field CustomData1XTwoCurve RangeFloatCurve
---@field CustomData1YConstant number
---@field CustomData1YTwoConstant RangeInfo
---@field CustomData1YOneCurve FloatCurve
---@field CustomData1YTwoCurve RangeFloatCurve
---@field CustomData1ZConstant number
---@field CustomData1ZTwoConstant RangeInfo
---@field CustomData1ZOneCurve FloatCurve
---@field CustomData1ZTwoCurve RangeFloatCurve
---@field CustomData1WConstant number
---@field CustomData1WTwoConstant RangeInfo
---@field CustomData1WOneCurve FloatCurve
---@field CustomData1WTwoCurve RangeFloatCurve
---@field CustomData2ColorQuad ColorQuad
---@field CustomData2ColorGradient ParticleEmitterColorGradient
---@field CustomData2ColorQuad2 ColorQuad
---@field CustomData2ColorGradient2 ParticleEmitterColorGradient
---@field CustomData2XConstant number
---@field CustomData2XTwoConstant RangeInfo
---@field CustomData2XOneCurve FloatCurve
---@field CustomData2XTwoCurve RangeFloatCurve
---@field CustomData2YConstant number
---@field CustomData2YTwoConstant RangeInfo
---@field CustomData2YOneCurve FloatCurve
---@field CustomData2YTwoCurve RangeFloatCurve
---@field CustomData2ZConstant number
---@field CustomData2ZTwoConstant RangeInfo
---@field CustomData2ZOneCurve FloatCurve
---@field CustomData2ZTwoCurve RangeFloatCurve
---@field CustomData2WConstant number
---@field CustomData2WTwoConstant RangeInfo
---@field CustomData2WOneCurve FloatCurve
---@field CustomData2WTwoCurve RangeFloatCurve
---@field Test fun(self: EffectObject) void 测试
---@field SetAssetID fun(self: EffectObject, assetID: string, callback: function) None 设置资源id
---@field Start fun(self: EffectObject) void 特效开始播放
---@field Pause fun(self: EffectObject) void 特效暂停播放
---@field ReStart fun(self: EffectObject) void 特效重新开始播放
---@field Stop fun(self: EffectObject, behavior: number) None 特效停止播放
---@field SetCOLTMinGradientColors fun(self: EffectObject, idx: number, time: number, color: ColorQuad) None 修改ColorOverLifeTime的minGradient的_colors
---@field SetCOLTMaxGradientColors fun(self: EffectObject, idx: number, time: number, color: ColorQuad) None 修改ColorOverLifeTime的maxGradient的_colors
---@field SetCOLTMinGradientAlphas fun(self: EffectObject, idx: number, time: number, alpha: number) None 修改ColorOverLifeTime的minGradient的_alphas
---@field SetCOLTMaxGradientAlphas fun(self: EffectObject, idx: number, time: number, alpha: number) None 修改ColorOverLifeTime的maxGradient的_alphas
---@field SetCOLTMinGradientModeAndKey fun(self: EffectObject, mode: number, colorkey: number, alphakey: number) None 修改ColorOverLifeTime的minGradient的mode
---@field SetCOLTMaxGradientModeAndKey fun(self: EffectObject, mode: number, colorkey: number, alphakey: number) None 修改ColorOverLifeTime的maxGradient的mode
---@field StopPlaying fun(self: EffectObject, isStop: boolean) None 停止播放时触发


---@class Exposion



---@class Particle
---@field Enable boolean 是否可用
---@field Speed number 速度
---@field Texture string 纹理
---@field Max_particles number 最大粒子数
---@field Spread number 传播
---@field Gravity_direction Vector3 重力方向
---@field Gravity number 重力
---@field Lifespan number 持续时长
---@field Mid_point number 中点
---@field Emitrate number 发射的
---@field Length number 长
---@field Width number 宽
---@field Color_key table 颜色组合
---@field Opacity number 透明度
---@field Blend_mode_type number 混合模式类型
---@field Emitter_type number 发射器类型
---@field Particle_dir_type number 粒子方向类型
---@field Local_coord boolean 本地命令
---@field Tile_mode number 平铺模式
---@field Tile_rows number 平铺行
---@field Tile_cols number 平铺列
---@field Tile_seconds number 平铺秒数
---@field Speed_var number 速度变量
---@field Spread_offset number 排列偏移量
---@field Latitude number 纬度
---@field Resistance number 阻力
---@field Life_var number 声明周期
---@field Random_spread number 随机排列
---@field Size_var number 尺寸
---@field Size_keys table 尺寸组合
---@field Aspect_keys table 面组合



---@class ParticleSmoke



---@class PostEffectService
---@field AddPostEffect fun(self: PostEffectService, szName: string, szMaterial: string, szShader: string) None 添加后期特效
---@field RemovePostEffect fun(self: PostEffectService, szKey: string) None 通过特效key移除后期特效
---@field SetParamValue fun(self: PostEffectService, szEffectName: string, szName: string, fValue: number) None 设置后期特效参数


---@class Projectile
---@field ProjectileNum number 投射物数量



---@class Area
---@field Beg Vector3 起始位置世界坐标
---@field End Vector3 结束位置世界坐标
---@field EffectWidth number 效果宽度
---@field Show boolean 是否显示
---@field ShowMode SceneEffectFrameShowMode 显示模式的枚举
---@field Color ColorQuad 区域颜色
---@field EnterNode Event 节点进入该区域时触发
---@field LeaveNode Event 节点离开该区域时触发



---@class Backpack
---@field CoreUiEnabled boolean 是否显示默认的快捷栏UI，默认值为false
---@field GetTool fun(self: Backpack, index: number) SandboxNode 获取某个键位对应的道具，index从1开始
---@field SetTool fun(self: Backpack, index: number, tool: SandboxNode) None 设置道具到具体的物品栏按键位置
---@field RemoveTool fun(self: Backpack, index: number) None 移除某物品栏道具
---@field GetCurEquipedTool fun(self: Backpack) SandboxNode 获取当前装备的道具
---@field FindTool fun(self: Backpack, tool: SandboxNode) Number 查询道具是否已经放在物品栏中，返回下标


---@class Camera : Transform
---@field PickPosition Vector3 摄像机跟随鼠标在游戏内指向的三维坐标
---@field LookFocus Vector3 摄像机焦点，镜头所看向的点
---@field ZNear number 摄像机的近平面
---@field ZFar number 摄像机的远平面
---@field FieldOfView number 设置摄像机垂直视野的角度
---@field CameraType CameraType 摄像机类型
---@field CameraSubject SandboxNode 摄像机子节点
---@field ViewportSize Vector2 描述客户端视口的尺寸（以像素为单位）
---@field ViewportPointToRay fun(self: Camera, x: number, y: number, depth: number):Ray 以朝向摄像机的方向，通过给定的距摄像机的深度，在视口上的某个位置创建单位射线（以像素为单位）
---@field WorldToViewportPonumber fun(self: Camera, position: Vector3) Vector3 将一个世界坐标position转换到摄像机视口坐标
---@field WorldToUIPonumber fun(self: Camera, position: Vector3) Vector3 将3D节点世界坐标position转UI节点坐标


---@class Chat
---@field DefaultChat boolean 是否加载默认聊天
---@field IsUserChatEnable fun(self: Chat, userid: number) boolean 是否允许聊天
---@field SendChatText fun(self: Chat, text: string, type: number, targetuin: number, language: number) None 发送文本消息
---@field SendSystemMsg fun(self: Chat, text: string, targetuin: number) None 发送系统消息
---@field SendChat fun(self: Chat, text: string, targetuin: number) None 发送文本消息
---@field GetFilterString fun(self: Chat, text: string) String 过滤文本
---@field ShowChatBubble fun(self: Chat, text: string, isShow: boolean, bubble: number, position: Vector3, chatBubbleId: longlong) longlong 显示聊天气泡
---@field ShowEditorChatBubble fun(self: Chat, text: string, bgIndex: number, bgPath: string, position: Vector3) longlong 显示工具端聊天气泡
---@field UpdateEditorChatBubblePosition fun(self: Chat, chatBubbleId: longlong, position: Vector3) None 更新工具端聊天气泡位置
---@field SetActorShowEditorChatBubble fun(self: Chat, actorShowEditorBubble: boolean) None 设置角色聊天显示的聊天气泡是否是工具聊天气泡


---@class GameSetting
---@field GameStartMode GameStartMode 游戏开始模式
---@field CanCunIn boolean 游戏可否切入
---@field CountDown number 倒数读秒
---@field NeedPlayerCount number 最少玩家数
---@field BackgroundMusicIndex GameBackGroundMusic 背景音乐索引
---@field HideCursor boolean 隐藏光标
---@field Shadow ShadowDesc 光影开关
---@field WaterReflected WaterReflectedDesc 水面反射开关
---@field ToolActiveMode ToolActiveMode 道具激活方式
---@field LAYER1 number 第1层
---@field LAYER2 number 第2层
---@field LAYER3 number 第3层
---@field LAYER4 number 第4层
---@field LAYER5 number 第5层
---@field SyncStream boolean 同步流
---@field MusicOpen boolean 控制地图内背景音乐开关
---@field SafeSyncMode boolean 同步安全模式
---@field ViewRange CoreUIViewRange 视野
---@field UseMnSkin boolean 使用迷你皮肤
---@field Sensitivity number 镜头的是否碰撞
---@field AvatarPolicy string policy
---@field WithoutCharacter boolean
---@field CameraCollide boolean
---@field LoadingCustomPartTime number 自定义加载条超时时间 fun(毫秒)，0表示不开启
---@field StartScene EMultiScenesAPI 启动场景
---@field LightActor boolean 轻量Actor
---@field PhysicsFrames PhysicsFrames
---@field PlayerIgnoreStream boolean player不启用流式加载
---@field ComputeActornumbereractions boolean
---@field AvoidnumbereractionsSpeedFactor number
---@field ShowAssetLoading boolean 显示正在加载的资源
---@field GetRunningInEditor fun(self: GameSetting) boolean 是否在编辑器中运行
---@field SetLoadingCustomPartFinished fun(self: GameSetting, arg1: boolean) None 设置loading自定义部分加载是否完成
---@field SetLoadingCustomPartLog fun(self: GameSetting, arg1: string) None log
---@field OpenAssetPoolGoCache fun(self: GameSetting) None


---@class MiniPlayer : Actor
---@field Character SandboxNode 玩家行为
---@field Neutral boolean 是否中立
---@field Team SandboxNode 隶属的队伍
---@field TeamColor ColorQuad 隶属的队伍颜色
---@field UserId number 玩家的用户Id
---@field Backpack SandboxNode 背包
---@field Nickname string 玩家昵称
---@field CameraMode CameraModel 玩家的相机模式（第一人称或第三人称视角）
---@field CameraMaxZoomDistance number 玩家镜头的最大视距
---@field CameraMinZoomDistance number 玩家镜头的最小视距
---@field PlayerStateEnable boolean 玩家状态是否显示
---@field GameplayPaused boolean 游戏暂停
---@field PCMovementMode DevPCMovementMode 玩家在PC端移动模式
---@field TouchMovementMode DevTouchMovementMode 玩家在触摸屏端移动模式
---@field Position Vector3 玩家位置
---@field Rotation Quaternion 玩家旋转角度
---@field NameDisplayDistance number 其他Humanoid名称对当前玩家的可见距离。设置为0时将隐藏所有名称
---@field TeamId number 玩家的队伍Id
---@field ViewRange CoreUIViewRange 玩家视野范围
---@field DefaultDie boolean
---@field AvatarInfo ReflexTuple
---@field EyePos fun(self: Player, pos: Vector3, dir: Vector3, dist: number) Vector3 校准碰撞视线位置
---@field EyePosWithFilter fun(self: Player, pos: Vector3, dir: Vector3, filter: number, dist: number) Vector3 校准碰撞视线位置
---@field EquipTool fun(self: Player, node: SandboxNode) None 给玩家装备上指定的道具
---@field UnequipTools fun(self: Player) void 解除玩家的装备
---@field DropTool fun(self: Player) void 丢弃装备
---@field FindTool fun(self: Player, node: SandboxNode) Number 查询该道具是否已经装备，返回下标
---@field Idle fun(self: Player, time: number) None 通常在游戏引擎将玩家定类为闲置状态的两分钟后进行触发。Time（时间）为此时点后所经历的秒数


---@class PlayerGui


---@class Players
---@field LocalPlayer SandboxNode 是一个只读属性，指的是其客户端正在运行体验的玩家
---@field GetPlayerByUserId fun(self: Players, userid: number) SandboxNode 在Players中搜索每个玩家，以查找其player.UserId与给定UserId匹配的玩家
---@field GetPlayers fun(self: Players) SandboxNode 返回当前连接的所有玩家的表
---@field HideTouchUI fun(self: Players) void 隐藏触摸UI
---@field HideJump fun(self: Players) void 隐藏跳跃
---@field HideRocker fun(self: Players) void 隐藏摇杆
---@field SendFriendApply fun(self: Players, nUin1: number, nUin2: number) boolean 申请好友
---@field HasFriend fun(self: Players, nUin1: number, nUin2: number, func: function) None 判断好友
---@field PlayerAdded Event<fun(self: Players, player: SandboxNode)> None 避免分发事件时还没执行脚本监听代码。建议放于StartPlayer.StarterPlayerScripts下的脚本节点的头部。
---@field PlayerRemoving Event<fun(self: Players, player: SandboxNode)> None 玩家移除事件，在玩家离开游戏之前立即触发。由于它在实际移除Player之前激发，因此此事件对于需要存储玩家数据非常有用


---@class SpawnLocation
---@field Neutral boolean 是否隶属与特定队伍，设置为true之后，任意队伍中的任意Player可以在此位置重生
---@field AllowTeamChangeOnTouch boolean 是否允许Player通过Touch触摸该Location来加入对应TeamColor的Team队伍
---@field TeamColor ColorQuad 队伍颜色 fun(ColorQuad)，跟TeamColor可对应
---@field RandR number
---@field MainSpawn boolean 主城出生点，玩家进入游戏第一次设置的位置



---@class SpawnService
---@field SetSpawnLocation fun(self: SpawnService, playernode: SandboxNode) None 设置玩家出生点


---@class StartPlayer
---@field PCMovementMode DevPCMovementMode 玩家在PC端移动模式
---@field TouchMovementMode DevTouchMovementMode 玩家在触摸屏端移动模式
---@field CameraMaxZoomDistance number 玩家镜头的最大视距
---@field CameraMinZoomDistance number 玩家镜头的最小视距
---@field CameraMode CameraModel 玩家的相机模式（第一人称或第三人称视角）



---@class TalkService



---@class Team
---@field AutoAssignable boolean 此属性用来决定加入游戏的Player是否允许自动分配到该队伍
---@field TeamColor ColorQuad  fun(ColorQuad)
---@field PlayerAdded Event 新增一个玩家
---@field PlayerRemoved Event 移除一个玩家



---@class Teams
---@field GetTeams fun(self: Teams) SandboxNode 获取游戏Team对象的表格


---@class TeleportService
---@field Teleport fun(self: TeleportService, playernode: SandboxNode, pos: Vector3) None 地图内将玩家传送到指定位置
---@field TeleportSuccess fun(self: TeleportService) Event 玩家传送成功触发，会触发一个TeleportSuccess通知
---@field TeleportFail fun(self: TeleportService) Event 玩家传送失败，会触发一个TeleportFail通知


---@class Tool
---@field CanBeDropped boolean 可否丢弃道具，默认不可以丢弃
---@field Enabled boolean 决定道具能否被使用，默认可以使用
---@field GripPos Vector3 夹点位置
---@field GripEuler Vector3 夹点的欧拉
---@field ToolTip string 道具提示信息
---@field TextureId string 默认快捷栏界面，显示的图标资源
---@field ActivationOnly boolean 仅激活
---@field Activate fun(self: Tool) boolean 已装备的的工具，模拟点击使用，会触发Activated事件。
---@field Deactivate fun(self: Tool) boolean 模拟工具的结束使用。
---@field Activated fun(self: Tool) Event 玩家已装备工具，点击鼠标左键时触发
---@field Deactivated fun(self: Tool) Event 当鼠标左键松开时触发
---@field Equipped fun(self: Tool) Event 当装备道具时触发
---@field Unequipped fun(self: Tool) Event 当卸载道具时触发。


---@class TriggerBox:Transform
---@field Size Vector3 触发器包围盒尺寸
---@field Touched Event 触发器被触碰时，触发通知
---@field TouchEnded Event 触发器被触碰结束时，触发通知



---@class VoiceChannel
---@field ChannelID string 语音频道ID。它是一个只读属性
---@field JoinChannel Event 加入某语音频道
---@field LeaveChannel Event 退出语音频道



---@class VoiceChatRemoteService



---@class VoiceChatService
---@field ChannelType ChannelType 语音频道类型
---@field IsSingleChannel fun(self: VoiceChatService, bCheck: boolean) boolean 是否单频道
---@field JoinVoiceChannel fun(self: VoiceChatService, uin: number, channelID: CHANNEL_ID) boolean 加入某语音频道
---@field AssignVoiceChannel fun(self: VoiceChatService, uin: number, channelID: CHANNEL_ID) boolean 分配某语音频道
---@field QuitVoiceChannel fun(self: VoiceChatService, uin: number, channelID: CHANNEL_ID) boolean 退出某语音频道
---@field QuitAllVoiceChannel fun(self: VoiceChatService, uin: number) boolean 退出所有语音频道
---@field SetSpeakerStatus fun(self: VoiceChatService, uin: number, bActive: boolean) None 设置扬声器状态
---@field GetSpeakerStatus fun(self: VoiceChatService, uin: number) boolean 获取扬声器状态
---@field SetMicroPhoneStatus fun(self: VoiceChatService, uin: number, bActive: boolean) None 设置麦克风状态
---@field GetMicroPhoneStatus fun(self: VoiceChatService, uin: number) boolean 获取麦克风状态
---@field SetVolume fun(self: VoiceChatService, uin: number, val: number) None 调节音量
---@field GetVolume fun(self: VoiceChatService, uin: number) Number 获取音量
---@field SetListenOther fun(self: VoiceChatService, setUin: number, otherUin: number, bListen: boolean) boolean 聆听他人
---@field MicroPhoneSwitchBtn fun(self: VoiceChatService) void 麦克风开关按钮
---@field SpeakerSwitchBtn fun(self: VoiceChatService) void 扬声器开关按钮
---@field QuitAllVoiceChannelClient fun(self: VoiceChatService) void 退出所有语音频道
---@field SetSpeakerStatusClient fun(self: VoiceChatService, arg1: boolean) None 设置扬声器状态 fun(客户端方法)
---@field GetSpeakerStatusClient fun(self: VoiceChatService) boolean 获取扬声器状态 fun(客户端方法)
---@field SetMicroPhoneStatusClient fun(self: VoiceChatService, arg1: boolean) None 设置麦克风状态 fun(客户端方法)
---@field GetMicroPhoneStatusClient fun(self: VoiceChatService) boolean 获取麦克风状态 fun(客户端方法)


---@class ReflexMap
---@field normal Vector3 击中时的法线
---@field obj SandboxNode 击中的对象
---@field isHit boolean 是否击中
---@field distance number 击中距离
---@field position Vector3 击中位置

---@class WorldService
---@field PrnumberLog fun(self: WorldService, szLog: string) None 打印日志
---@field GetRangeXZ fun(self: WorldService) ReflexTuple 的坐标
---@field GetUIScale fun(self: WorldService) Vector2 获取UI布局的缩放尺寸
---@field RaycastClosest fun(self: WorldService, origin: Vector3, unitDir: Vector3, distance: number, isIgnoreTrigger: boolean, filterGroup: Table):ReflexMap 射线段检测，返回最近的碰撞物
---@field RaycastAll fun(self: WorldService, origin: Vector3, unitDir: Vector3, distance: number, isIgnoreTrigger: boolean, filterGroup: Table):ReflexMap 射线段检测，返回所有碰撞物，最多128个
---@field SweepBoxAll fun(self: WorldService, center: Vector3, shape: Vector3, direction: Vector3, angle: Vector3, distance: number, isIgnoreTrigger: boolean, filterGroup: Table) ReflexMap 扫描全部
---@field SweepCapsuleAll fun(self: WorldService, radius: number, p0: Vector3, p1: Vector3, dir: Vector3, distance: number, isIgnoreTrigger: boolean, filterGroup: Table) ReflexMap 扫描胶囊全部
---@field SweepSphereAll fun(self: WorldService, radius: number, center: Vector3, direction: Vector3, distance: number, isIgnoreTrigger: boolean, filterGroup: Table) ReflexMap 扫描球全部
---@field OverlapBox fun(self: WorldService, shape: Vector3, pos: Vector3, angle: Vector3, isIgnoreTrigger: boolean, filterGroup: Table) ReflexMap 重叠框
---@field OverlapCapsule fun(self: WorldService, radius: number, p0: Vector3, p1: Vector3, isIgnoreTrigger: boolean, filterGroup: Table) ReflexMap 重叠胶囊
---@field OverlapSphere fun(self: WorldService, radius: number, pos: Vector3, isIgnoreTrigger: boolean, filterGroup: Table) ReflexMap 重叠球体
---@field SetMainFrameShow fun(self: WorldService, isShow: boolean) None 用于隐藏显示游戏内置UI
---@field GetUISize fun(self: WorldService) Vector2 获取UI布局的尺寸
---@field EmitMiniGameESCKey fun(self: WorldService) Number 流程
---@field TeleportPlayer fun(self: WorldService, mapid: number) None 传送玩家到地图
---@field SetActorHp fun(self: WorldService, actornode: SandboxNode, hp: number) None 设置生物血量
---@field SetActorMotion fun(self: WorldService, actornode: SandboxNode, motion: Vector3) None 设置生物动作
---@field AttackTarget fun(self: WorldService, actornode: SandboxNode) None 设置攻击目标
---@field NavigateTo fun(self: WorldService, size: Vector3, src: Vector3, target: Vector3) Table 自动寻路至指定位置，会自动寻找最佳路径移动至指定点 fun(接口已经废弃,请用CreatePath)
---@field CreatePath fun(self: WorldService, Radius,Heigh,StepOffset,SlopLimit,CollideGroupID: ReflexMap) SandboxNode 创建一个路径基于想要模拟的actor的参数.
---@field SetSceneId fun(self: WorldService, id: number) boolean 设置当前worldservice的world的SceneId
---@field GetSceneId fun(self: WorldService) Number 获取当前worldservice的world的SceneId
---@field DoGmCmd fun(self: WorldService) None


---@class ClickDetector



---@class ContextActionService
---@field BindActivate fun(self: ContextActionService, userInputTypeForActivate: number, keyCodeForActivate: number) None 绑定激活
---@field UnbindActivate fun(self: ContextActionService, userInputTypeForActivate: number, keyCodeForActivate: number) None 解绑激活
---@field GetAllBoundActionInfo fun(self: ContextActionService) ReflexMap 获取当前所有绑定的事件信息
---@field GetBoundActionInfo fun(self: ContextActionService, actionName: string) ReflexMap 获取当前绑定actionName的事件信息
---@field GetButton fun(self: ContextActionService, actionName: string) SandboxNode 通过绑定名称获取该按钮节点
---@field GetCurrentLocalToolIcon fun(self: ContextActionService) String 获取当前本地tool图片
---@field SetDescription fun(self: ContextActionService, actionName: string, description: string) None 设置描述
---@field SetImage fun(self: ContextActionService, actionName: string, image: string) None 设置图片
---@field SetPosition fun(self: ContextActionService, actionName: string, position: Vector2) None 设置位置
---@field SetTitle fun(self: ContextActionService, actionName: string, title: string) None 设置标题
---@field BindContext fun(self: ContextActionService, actionname: string, func: function, createTouchBtn: boolean, hotkey: ReflexVariant) None 绑定一个回调函数到指定输入上
---@field BindContextAtPriority fun(self: ContextActionService, actionname: string, func: function, createTouchBtn: boolean, priority: number, hotkey: ReflexVariant) None 绑定一个回调函数到指定输入上，并指定优先级
---@field UnbindContext fun(self: ContextActionService, actionname: string) None 取消指定的用户绑定
---@field UnbindAllContext fun(self: ContextActionService) void 移除所有的函数绑定
---@field CallFunction fun(self: ContextActionService, actionName: string, state: UserInputState, inputObject: SandboxNode) None lua回调函数
---@field BindAction fun(self: ContextActionService, actionName: string, func: function, nActionType: number, nSubType: number) None 这套新接口)
---@field BindActionWithButton fun(self: ContextActionService, actionName: string, func: function, nActionType: number, nSubType: number) None 这套新接口)
---@field BindActionAtPriority fun(self: ContextActionService, actionName: string, func: function, priority: number, nActionType: number, nSubType: number) None 这套新接口)
---@field UnbindAction fun(self: ContextActionService, actionName: string) None 这套新接口)
---@field UnbindAllActions fun(self: ContextActionService) void 这套新接口)
---@field BoundActionChanged fun(self: ContextActionService, actionName: string, propname: string, table: ReflexMap) None 当绑定行为发生改变时，会触发一个BoundActionChanged时间
---@field BoundActionAdded fun(self: ContextActionService, actionName: string, bCreateTouchBtn: boolean, table: ReflexMap) None 新增某绑定行为
---@field BoundActionRemoved fun(self: ContextActionService, actionName: string, table: ReflexMap) None 移除某绑定行为


---@class InputObject
---@field Delta Vector2 时间增量
---@field Position Vector3 鼠标相关的事件中，描述鼠标的位置
---@field KeyCode KeyCode 按键事件触发时，对应的按键码，等于枚举UserInputKeyCode中的某个值
---@field UserInputState UserInputState 描述输入状态（开始，结束等）等于枚举UserInputState中的某个值
---@field UserInputType UserInputType 等于枚举UserInputType中的某个值
---@field TouchId number 触摸事件触发
---@field IsModifierKeyDown fun(self: InputObject, vkey: number) boolean 按键是否按下
---@field GetTouchCount fun(self: InputObject) Number 获取触摸次数
---@field GetTouch fun(self: InputObject, index: number) ReflexMap 获取触摸事件


---@class InputObjectSignal



---@class UserInputService
---@field TouchEnabled boolean 当前的设备是否启用触摸屏
---@field KeyboardEnabled boolean 当前的设备是否启用键盘
---@field MouseEnabled boolean 当前的设备是否启用鼠标
---@field AccelerometerEnabled boolean 设备是否带启用加速器
---@field GamepadEnabled boolean 用户正在使用的设备是否启用可用的游戏手柄
---@field GyroscopeEnabled boolean 用户的设备是否启用陀螺仪
---@field OnScreenKeyboardVisible boolean 屏幕键盘当前是否在用户的屏幕上可见
---@field VREnabled boolean 用户是否正在使用头戴虚拟现实设备
---@field OnScreenKeyboardPosition Vector2 屏幕键盘的位置
---@field MouseIconEnabled boolean 决定Mouse的图标是否可见
---@field ModalEnabled boolean 切换迷你世界Studio的移动控制是否在移动设备上隐藏
---@field MouseDeltaSensitivity number 缩放用户的Mouse的Delta（位置改变）输出
---@field MouseBehavior MouseBehavior 用户的鼠标可以自由移动或是被锁定
---@field InputBegan Event<fun(inputObj: InputObject, bGameProcessd: boolean)> 开始输入
---@field InputChanged Event<fun(inputObj: InputObject, bGameProcessd: boolean)> 输入改变
---@field InputEnded Event<fun(inputObj: InputObject, bGameProcessd: boolean)> 输入结束
---@field TouchStarted Event<fun(inputObj: InputObject, bGameProcessd: boolean)> 触摸开始
---@field TouchMoved Event<fun(inputObj: InputObject, bGameProcessd: boolean)> 触摸移动
---@field TouchEnded Event<fun(inputObj: InputObject, bGameProcessd: boolean)> 触摸结束
---@field PickObjects fun(self: UserInputService, mouseX: number, mouseY: number, objects: Table) SandboxNode 从给定的obj列表中，根据传入的2D屏幕坐标，拾取指定对象
---@field PickObjectsEx fun(self: UserInputService) SandboxNode
---@field IsKeyDown fun(self: UserInputService, key: number) boolean 按键是否按下
---@field IsRemoteSession fun(self: UserInputService) boolean 识别当前是否是远程桌面模式
---@field GetInputObject fun(self: UserInputService, type: UserInputType) SandboxNode 获取输入对象


---@class ArcPlateMaterial



---@class AssetObject
---@field AssetId string
---@field AssetResType AssetResType



---@class Canvas
---@field TextureId string 设置模型的材质，即资源id
---@field ShowGridLine boolean
---@field Visible boolean



---@class CloudServerConfigService



---@class CustomConfig
---@field ClassNode NodeLinker



---@class CylindricalJonumber
---@field LinearLimitsEnable boolean
---@field LinearLowerlimit number
---@field LinearRestitution number
---@field LinearUpperLimit number
---@field AngleLimitsEnable boolean
---@field AngleLowerlimit number
---@field AngleRestitution number
---@field AngleUpperLimit number
---@field LinearActuatorType MotorType
---@field LinearDamping number
---@field LinearMotorMaxForce number
---@field LinearVelocity number
---@field LinearResponsiveness number
---@field LinearServoMaxForce number
---@field LinearSpeed number
---@field TargetPosition number
---@field AngleActuatorType MotorType
---@field AngleDamping number
---@field AngleMotorMaxForce number
---@field AngleVelocity number
---@field AngleResponsiveness number
---@field AngleServoMaxForce number
---@field AngleSpeed number
---@field TargetAngle number



---@class DebuggerLogRemoteService



---@class DebugService
---@field ServerViewRange number
---@field LocalrViewRange number



---@class DynamicBone
---@field ConfigUrl table
---@field IsReplace boolean



---@class FriendInviteRemoteService



---@class FriendInviteService
---@field GetFriendList fun(self: FriendInviteService, nUin: number, func: function) None 获取好友列表
---@field IsNewToThisMap fun(self: FriendInviteService, nUin: number, nMapID: longlong, func: function) None 新玩家判断
---@field SetInvitePlayer fun(self: FriendInviteService, nUin1: number, nUin2: number, nMapID: longlong) None 邀请者设置
---@field GetInvitePlayer fun(self: FriendInviteService, nUin1: number, nMapID: longlong, func: function) None 邀请者查询
---@field SetInvitedPlayerList fun(self: FriendInviteService, nUin: number, nMapID: longlong, userData: table, nCound: number) None 被邀请者设置
---@field GetInvitedPlayerList fun(self: FriendInviteService, nUin: number, nMapID: longlong, func: function) None 被邀请者查询
---@field FriendFollow fun(self: FriendInviteService, nUin1: number, nUin2: number) None 好友跟随
---@field OpenInviterList fun(self: FriendInviteService) None 打开邀请列表 fun(客机操作)


---@class HorizontalArcHalfPlateMaterial



---@class LocalizationTable
---@field FullStatusSync table
---@field CSVFile unumberptr_t
---@field LocaleNum number



---@class LuaProfileService



---@class Model2D
---@field Size Vector2 模型的包围盒大小
---@field Center Vector2 模型的中心点所在世界坐标
---@field TextureId string 设置模型的材质，即资源id
---@field Color ColorQuad 模型的颜色
---@field EnableGravity boolean 是否开启重力
---@field Anchored boolean 是否锚定
---@field Gravity number 重力
---@field Mass number 密度
---@field Density number
---@field Restitution number 弹性
---@field Friction number 马擦力
---@field Velocity Vector2 速度
---@field AngleVelocity number 角速度
---@field CanCollide boolean 是否可以产生物理碰撞
---@field CanTouch boolean 是否可以碰撞回调
---@field GroupID number 设置碰撞组
---@field EnablePhysics boolean 是否生效
---@field EnableCCD boolean 会影响性能，所以默认不开启
---@field EnableDrawCollider boolean
---@field PhysXType PHYSX2D_TYPE
---@field FlippedX boolean
---@field FlippedY boolean
---@field Touched Event 模型被其他模型碰撞时，会触发一个Touched通知
---@field TouchEnded Event 模型被其他模型碰撞结束时，会触发一个TouchEnded通知



---@class ModelData
---@field Skeleton string 骨骼
---@field Meshs table 网格
---@field Materials table 材质
---@field Meshs table 网格
---@field Materials table 材质
---@field LoadAssetNotify Event 单个资源加载事件完成，触发通知事件
---@field LoadAssetFinishNotify Event 材质是否全部加载完成，触发通知事件



---@class ModelPartNode



---@class MotorJonumber
---@field Start boolean
---@field Clockwise boolean
---@field MaxAngleSpeed number
---@field MaxForce number
---@field Damp number
---@field Lock boolean



---@class OnlineService
---@field HostKickClient fun(self: OnlineService, arg1: number) None 主机主动踢客机


---@class Particle2D
---@field AssetID string plist资源id
---@field Duration number -1表示无限长
---@field Life number -1表示无限长
---@field LifeVar number 单位秒
---@field StartSize number 粒子初始大小
---@field StartSizeVar number 粒子初始大小变化率
---@field EndSize number 粒子结束大小
---@field EndSizeVar number 粒子结束大小变化率
---@field Angle number 粒子初始角度
---@field StartSpin number 粒子初始旋转速度
---@field EndSpin number 粒子结束旋转速度
---@field EmissionRate number 粒子发射速率
---@field StartColor ColorQuad 设置粒子初始颜色
---@field StartColorVar ColorQuad 设置粒子初始颜色变化率
---@field EndColor ColorQuad 设置粒子结束颜色
---@field EndColorVar ColorQuad 设置粒子结束颜色变化率
---@field TexAssetID string 纹理资源id
---@field StartSpinVar number 设置粒子初始旋转速度变化率
---@field EndSpinVar number 设置粒子结束旋转速度变化率
---@field SetTexAssetID fun(self: Particle2D, assetID: string, callback: function) None 设置资源id
---@field SetAssetID fun(self: Particle2D, assetID: string, callback: function) None 设置plist资源id
---@field Play fun(self: Particle2D) void 播放暂停的特效
---@field Stop fun(self: Particle2D) void 停止特效
---@field ReStart fun(self: Particle2D) void 重新播放特效
---@field Pause fun(self: Particle2D) void 暂停特效


---@class Path
---@field GeneratePaths fun(self: Path, start: Vector3, finish: Vector3) boolean 同步生成路径
---@field GetPaths fun(self: Path) Vector3 获取生成的路径
---@field GenerateNavMeshAsync fun(self: Path) void 异步生成导航网格,并持续持有,不会被释放。
---@field ClearNavMesh fun(self: Path) void 清理导航网格,不再继续持有,随系统定期gc释放


---@class PrismaticJonumber
---@field LimitsEnable boolean
---@field Lowerlimit number
---@field Restitution number
---@field UpperLimit number
---@field ActuatorType MotorType
---@field MotorMaxAcceleration number
---@field MotorMaxForce number
---@field Velocity number
---@field LinearResponsiveness number
---@field LinearServoMaxForce number
---@field Speed number
---@field TargetPosition number



---@class PyramidMaterial



---@class RopeJonumber
---@field Length number 绳子的长度
---@field Restitution number 绳子的弹力
---@field Thickness number 绳子的粗细
---@field Color ColorQuad 模型的颜色
---@field ModelId string
---@field TextureId string



---@class SandboxBallSocketJonumber
---@field LimitsEnable boolean
---@field Anglelimit number
---@field Restitution number
---@field TwistLimitEnable boolean
---@field TwistLowerAngleLimit number
---@field TwistUpperAngleLimit number



---@class SandboxClickDetectorObject



---@class SandboxHeadNode
---@field Uin string



---@class SandboxLocalizationService
---@field LocaleIdConfig string
---@field LocaleIdConfigField unumberptr_t
---@field LocaleIdNum number
---@field PlayerLocaleId LocaleId
---@field PlayerLocaleIdNotify Event



---@class SandBoxPlayersRemoteService



---@class SandboxSceneMgrService
---@field SceneConfigs table
---@field CurDefaultStartScene EMultiScenes 动态场景配置
---@field NextDefaultStartScene EMultiScenes
---@field DynamicSceneConfigs table
---@field SwitchScene nil 切换场景 fun(客户端)切换结果SceneOpResult通知回调
---@field AddDynamicScene nil 添加动态场景 fun(服务端)添加结果DynamicSceneOpResultServer通知回调
---@field RemoveDynamicScene nil 删除动态场景 fun(服务端)删除结果DynamicSceneOpResultServer通知回调
---@field DynamicSwitchScene nil 切换结果DynamicSceneOpResultServer通知回调
---@field SceneSwitchStart Event 切换场景开始通知 fun(客户端)
---@field SceneOpResult Event 场景操作结果通知 fun(客户端)
---@field DynamicSceneOpResultServer Event 动态场景操作结果通知 fun(服务端)



---@class SandboxUISnapshotNode
---@field IsSnapFinish boolean 是否截屏完毕
---@field OnSnapFinish Event 截屏完毕时，触发一个OnSnapFinish通知



---@class Skeleton2D
---@field BonesDataAssetID string 骨骼数据资源ID（zip/资源包）
---@field SlotEnum DragonBonesSlot
---@field SkinEnum DragonBonesSkin
---@field Armature string
---@field Animation string 动画名称
---@field Skin string 皮肤名称
---@field Slot string 插槽名称
---@field DisplayOffset Vector2
---@field SetBonesDataAssetID fun(self: Skeleton2D, assetID: string, callback: function) None 设置骨骼数据资源ID
---@field LoadExtraBonesDataAsset fun(self: Skeleton2D, assetID: string, callback: function) None 加载额外骨骼数据资源ID（不会重复load相同资源）
---@field ReplaceSlotDisplay fun(self: Skeleton2D) None
---@field SetSlotDisplayIndex fun(self: Skeleton2D, slotName: string, displayIndex: number) None 替换插槽
---@field ReplaceSkin fun(self: Skeleton2D, slotName: string) None 替换皮肤


---@class SkeletonPart
---@field SkeletonId string



---@class SyncCoord
---@field BindCoord WCoord 绑定坐标
---@field Uin number 用户Uin



---@class TimelineClip



---@class TimelineCustomTrack



---@class TimelineNodePlayer



---@class TimelineObject
---@field PlayAsync fun(self: TimelineObject) void 开始播放
---@field IsPlaying fun(self: TimelineObject) boolean 是否播放中
---@field Pause fun(self: TimelineObject) boolean 记录当前播放进度
---@field Stop fun(self: TimelineObject) boolean 丢失当前播放进度.
---@field StopPlaying fun(self: TimelineObject, isStop: boolean) None 停止播放时触发


---@class TimelinePlayer
---@field PlayAsync fun(self: TimelinePlayer) void 开始播放
---@field IsPlaying fun(self: TimelinePlayer) boolean 是否播放中
---@field Pause fun(self: TimelinePlayer) boolean 记录当前播放进度
---@field Stop fun(self: TimelinePlayer) boolean 丢失当前播放进度.
---@field StopPlaying fun(self: TimelinePlayer) Event 停止或者中断播放时触发


---@class TimelineTrack



---@class Transform2D
---@field Position Vector2 全局坐标
---@field Rotation number 全局旋转
---@field LocalPosition Vector2 局部坐标
---@field LocalScale Vector2 局部大小
---@field LocalRotation number 局部旋转
---@field Visible boolean 是否显示
---@field Order number



---@class Translator
---@field LocaleId LocaleId



---@class TriangularPrismMaterial



---@class UIBackGround
---@field Icon string 资源
---@field scale Vector2 缩放
---@field offset Vector2 偏移
---@field HorizontalAlignment HorizontalAlignmentType 水平对齐方式
---@field VerticalAlignment VerticalAlignment 垂直对齐方式



---@class UIBMLabel
---@field BMText string 文本内容
---@field BMFonts string 字体
---@field BMPng string 资源
---@field TargetID number 跟随目标
---@field Grayed boolean 置灰
---@field Animable boolean 支持动画
---@field Offset Vector3
---@field Alpha number 透明度
---@field BMColor Vector3 文本颜色
---@field GradientDir BMGradientDirType 渐变色起始色
---@field GradientOrigin Vector3
---@field GradientTarget Vector3
---@field GetLabelNum fun(self: UIBMLabel) Number 获取Label数量
---@field GetLabel fun(self: UIBMLabel) SandboxNode 获取第N个Label节点
---@field SetLoadedCallback fun(self: UIBMLabel, arg1: function) None 纹理字加载完成
---@field FollowTarget fun(self: UIBMLabel, arg1: SandboxNode) None 跟随对象


---@class UIBMNode
---@field Position Vector2 位置
---@field Scale Vector2 缩放
---@field Visible boolean 是否可见
---@field Alpha number 透明度
---@field GetBMSize fun(self: UIBMNode) Vector2 获取尺寸


---@class UIListLayout
---@field FillDirectionType FillDirectionType 排列方式
---@field HorizontalAlignmentType HorizontalAlignmentType 水平对齐方式
---@field VerticalAlignment VerticalAlignment 竖直对齐方式
---@field Offset number 间隔偏移



---@class UIManageService



---@class UIMiniCoin
---@field IconSize Vector2
---@field TextLabelSize Vector2
---@field Scale Vector2 UI节点缩放倍数
---@field Rotation number UI节点旋转度数
---@field Position Vector2 UI节点坐标
---@field Distance Vector2
---@field Pivot Vector2 UI节点锚点（0~1），（0.5,0.5）为中点
---@field LineColor ColorQuad UI节点边线颜色设置
---@field FillColor ColorQuad UI节点填充颜色设置
---@field LineSize number UI节点边线像素和尺寸大小
---@field LayoutHRelation EnumLayoutHRelation 水平关联方式，包括左关联、中线关联和右关联。设置后，当父节点（若父节点为UIRoot则为屏幕）变化时，UI与关联位置的相对距离将保持不变
---@field LayoutVRelation EnumLayoutVRelation 垂直关联方式，包括上关联、中线关联和下关联。设置后，当父节点（若父节点为UIRoot则为屏幕）变化时，UI与关联位置的相对距离将保持不变
---@field OutlineEnable boolean 是否显示描边
---@field OutlineColor ColorQuad 描边颜色
---@field OutlineSize number 描边宽度
---@field FontSize number 字体大小
---@field TitleColor ColorQuad 字体颜色



---@class UIPanel
---@field Round number



---@class UIProgressBar
---@field Value number 进度值 fun(0-100)



---@class UIRoot3D:Transform
---@field Scale Vector2 UI节点缩放倍数
---@field Rotation number UI节点旋转度数
---@field UIPosition Vector2
---@field Mode Mode
---@field Visible boolean UI容器是否可见
---@field CullLayer CullLayer 消隐层
---@field IgnoreStreamSync boolean 忽略流同步



---@class UISliderBar
---@field Value number 进度值 fun(0-100)



---@class UniversalJonumber
---@field LimitsEnable boolean
---@field Anglelimit number
---@field Restitution number



---@class VerticalArcHalfPlateMaterial



---@class Actor: Model, Transform
---@field Movespeed number 生物的移动速度
---@field MaxHealth number 生物的最大血量
---@field Health number 生物的当前血量
---@field AutoRotate boolean 自动旋转
---@field NoPath boolean actor是否具有寻路路径
---@field Gravity number actor受到的重力
---@field StepOffset number 玩家可以攀越的高度
---@field CanAutoJump boolean 可以自由跳跃
---@field SkinId number 通过玩家控制的角色获取玩家迷你皮肤id
---@field SlopeLimit number 玩家可行走的坡度
---@field JumpBaseSpeed number 玩家跳跃起始速度
---@field JumpContinueSpeed number 持续按住跳跃键减缓降落速度使用
---@field RunSpeedFactor number 给Movespeed加倍
---@field RunState boolean 是否为跑步状态
---@field CanPushOthers boolean
---@field MoveDirection Vector3 移动的方向
---@field PhysXRoleType PhysicsRoleType 物理类型
---@field StandardSkeleton StandardSkeleton
---@field SetMoveEndTime fun(self: Actor, endtime: number) None 设定移动结束时间
---@field MoveTo fun(self: Actor, target: Vector3) None actor朝某个位置进行移动
---@field MoveStep fun(self: Actor, vec: Vector3) None actor移动vec向量的位移
---@field Move fun(self: Actor, dir: Vector3, relativeToCamera: boolean) None actor朝指定方向进行移动
---@field StopMove fun(self: Actor) void 停止调用Move或MoveTo接口的运行
---@field Jump fun(self: Actor, jump: boolean) None actor跳跃函数，将参数设置为true时，actor将会跳跃
---@field SetJumpInfo fun(self: Actor, baseSpeed: number, continueSpeed: number) None 跳跃设置
---@field NavigateTo fun(self: Actor, target: Vector3) None 自动寻路至指定位置，会自动寻找最佳路径移动至指定点,本函数立即返回
---@field JumpCDTime fun(self: Actor, time: number) None 跳跃间隔，处于跳跃间隔内时无法跳跃
---@field SetEnableContinueJump fun(self: Actor, enable: boolean) None 设置是否能够连续跳跃
---@field StopNavigate fun(self: Actor) void 停止自动寻路
---@field GetCurMoveState fun(self: Actor) BehaviorState 获取当前行为状态。见枚举BehaviorState
---@field FindNearestPolygonCenter fun(self: Actor) Vector3 同步找到一个可以寻路过去的点
---@field UseDefaultAnimation fun(self: Actor, use: boolean) None 是否使用默认动作
---@field BindCustomPlayerSkin fun(self: Actor) void 自定义绑定玩家皮肤给actor
---@field Walking Event<fun(self: Actor, isWalking: boolean)> None 当开始行走时会发送一次事件，停止行走时会发送一次通知
---@field Standing Event<fun(self: Actor, isStanding: boolean)> None 结束站立时会发送一次事件，开始站立时会发送一次通知
---@field Jumping Event<fun(self: Actor, isJumping: boolean)> None 跳跃开始时会发送一次事件，跳跃结束时会发送一次通知
---@field Flying Event<fun(self: Actor, isFlying: boolean)> None 飞行开始时会发送一次事件，飞行结束时会发送一次通知
---@field Died Event<fun(self: Actor, isDied: boolean)> None 死亡开始时会发送一次事件
---@field MoveStateChange fun(self: Actor, beforeState: BehaviorState, afterState: BehaviorState) None 当actor移动状态发送变化时会发送一次事件
---@field NavigateFinished fun(self: Actor, isFinished: boolean) None 自动寻路结束后发送事件
---@field MoveFinished fun(self: Actor, isMoveFinished: boolean) None 移动MoveTo结束后触发


---@class AIBase
---@field TickRate number tick速率



---@class AITaskEntry
---@field CanRun boolean 是否可以继续
---@field Run Event lua任务运行时触发
---@field Start Event lua任务开始执行时触发
---@field Ready Event lua任务完成时触发
---@field Tick Event lua任务循环时触发
---@field Reset Event lua任务重置时触发
---@field Destroy Event lua任务销毁时触发



---@class AvatarGroupPart



---@class AvatarPart
---@field PartType PartType 部件位置
---@field ModelResId string 部件资源id
---@field DiffuseTexResId string 部件贴图资源id
---@field EmissiveTexResId string 部件贴图资源id
---@field Show boolean 是否显示



---@class BehaviorGroupBase



---@class BehaviorItem



---@class CommonBehaviorGroup



---@class Model
---@field DimensionUnit DimensionUnit 模型尺寸
---@field MaterialType MaterialTemplate 材料类型
---@field TextureId string 设置模型的材质，即资源id
---@field Color ColorQuad 模型的颜色
---@field ModelId string 模型id，即资源id
---@field Gravity number 模型重力
---@field Friction number 模型摩擦力
---@field Restitution number 模型反弹力，比如物体撞击在地面上会根据此值来计算反弹高度
---@field Mass number 模型质量
---@field Velocity Vector3 模型移动速度
---@field AngleVelocity Vector3 模型角速度
---@field Size Vector3 模型的包围盒大小
---@field Center Vector3 模型的中心点所在世界坐标
---@field EnableGravity boolean 模型是否支持重力
---@field Anchored boolean 锚定状态，为true时此物体不受外部环境物理影响，但是会给外部提供物理输入。例如：有外来物体撞击到此物体，此物体不会产生移动，但是会对外来物体产生碰撞反弹力。
---@field PhysXType PhysicsType 物理类型
---@field EnablePhysics boolean 开启此物体的物理状态。为true时物体的物理属性可以使用
---@field CanCollide boolean 是否可以碰撞。设为false时为trigger状态
---@field CanTouch boolean 是否触发碰撞回调函数：Touched和TouchEnded事件
---@field CollideGroupID number number)，可以通过PhysXService:SetCollideInfo函数设置任意两个组之间是否会产生碰撞
---@field CullLayer CullLayer 消隐层
---@field IgnoreStreamSync boolean 忽略流同步
---@field TextureOverride boolean 材质贴图覆盖
---@field CastShadow boolean 是否打开阴影
---@field CanRideOn boolean 能否跟着走
---@field DrawPhysicsCollider boolean 显示物理包围盒
---@field ReceiveShadow boolean 是否接受投影
---@field CanBePushed boolean
---@field IsStatic boolean
---@field OutlineActive boolean 是否激活描边
---@field OutlineColorIndex number
---@field PlayAnimation fun(self: Model, id: string, speed: number, loop: number) boolean 播放动画
---@field PlayAnimationEx fun(self: Model, id: string, speed: number, loop: number, priority: number, weight: number) boolean 播放动画Ex
---@field StopAnimation fun(self: Model, id: string) boolean 停止动画
---@field StopAnimationEx fun(self: Model, id: string, reset: boolean) boolean 停止动画Ex
---@field StopAllAnimation fun(self: Model, reset: boolean) boolean 停止所有动画
---@field EnableAnimationEvent fun(self: Model, enable: boolean) None 开启或关闭动画事件
---@field GetAnimationIDs fun(self: Model) Table 获取动画ID
---@field GetAnimationPriority fun(self: Model, seqid: number) Number 获取动画优先级
---@field SetAnimationPriority fun(self: Model, seqid: number, value: number) None 设置动画优先级
---@field GetAnimationWeight fun(self: Model, seqid: number) Number 获取动画权重
---@field SetAnimationWeight fun(self: Model, seqid: number, value: number) None 设置动画权重
---@field GetBones fun(self: Model) Table 获取动画骨骼
---@field SetBoneRotate fun(self: Model, boneName: string, qua: Quaternion, scale: number) None 设置骨骼动画旋转
---@field AnchorWorldPos fun(self: Model, id: number, offset: Vector3) Vector3 获取锚点世界坐标（仅脚本可用）
---@field IsBinded fun(self: Model, set: boolean) boolean 是否绑定
---@field AddForce fun(self: Model, force: Vector3) None 添加力
---@field AddTorque fun(self: Model, torque: Vector3) None 添加扭矩
---@field AddForceAtPosition fun(self: Model, force: Vector3, position: Vector3, mode: number) None 添加力位置
---@field SetMaterial fun(self: Model, skinMeshRenderCompName: string, materialid: string, index: number) None 设置材质
---@field SetMaterialNew fun(self: Model, meshRenderCompName: string, materialid: string, index: number, callback: function) Number 设置材质
---@field GetMaterialByNameOrIndex fun(self: Model, findKey: string, byName: boolean, isSkinMeshRender: boolean, materialIndex: number) SandboxNode 获取材质节点
---@field SetMaterialByNameOrIndex fun(self: Model, findKey: string, byName: boolean, isSkinMeshRender: boolean, materialIndex: number, resId: string, callback: function) None 设置材质
---@field GetLegacyAnimation fun(self: Model) SandboxNode 获取骨骼动画
---@field GetAnimation fun(self: Model) SandboxNode 获取模型动画
---@field GetAttributeAnimation fun(self: Model) SandboxNode 获取属性动画
---@field GetSkeletonAnimation fun(self: Model) SandboxNode 获取骨骼动画
---@field GetHumanAnimation fun(self: Model) SandboxNode 获取人形动画
---@field GetAnimator fun(self: Model) SandboxNode 获取动画制作器
---@field GetMaterialInstance fun(self: Model, ids: Table, idx: unumber32_t) SandboxNode 获取材料实例
---@field IsLoadFinish fun(self: Model) boolean 是否加载完成
---@field GetRenderPosition fun(self: Model) Vector3 获取渲染位置
---@field GetRenderRotation fun(self: Model) Quaternion 获取渲染旋转
---@field GetRenderEuler fun(self: Model) Vector3 获取渲染欧拉角
---@field GetBoneNodeChildByName fun(self: Model, parentBoneNode: SandboxNode, name: string) SandboxNode 通过节点名查询该骨骼节点对象
---@field GetBoneNodeByName fun(self: Model, name: string) SandboxNode 按名称获取骨骼节点
---@field SetMaterialResId fun(self: Model, materialResId: string) None 设置材质资源实例
---@field GetLoadedResType fun(self: Model) 0,1,2 获取已经加载的资源类型
---@field GetAssetContent fun(self: Model) SandboxNode
---@field SetAssetContent fun(self: Model) boolean
---@field GetSnapShot fun(self: Model) SandboxNode
---@field SetRenderersShadow fun(self: Model) None
---@field SetRendererShadow fun(self: Model) None
---@field Touched fun(self: Model, node: SandboxNode, pos: Vector3, normal: Vector3) None 模型被其他模型碰撞时，会触发一个Touched通知
---@field TouchEnded fun(self: Model, node: SandboxNode) None 模型被其他模型碰撞结束时，会触发一个TouchEnded通知
---@field AnimationEvent fun(self: Model, a: number, b: number) None 模型触发动画事件时发送一个AnimationEvent通知
---@field AnimationFrameEvent fun(self: Model, a: number, b: string, c: number) None 动画帧事件触发
---@field LoadFinish fun(self: Model, isFinish: boolean) None 加载完成时触发事件


---@class OnlyOneBehaviorGroup



---@class CoreUI
---@field HideBtnExit boolean 是否隐藏退出按钮
---@field HideBtnMsg boolean 是否隐藏消息按钮
---@field HideViewRoomInfo boolean 是否隐藏房间信息视图
---@field MicUnMute boolean 麦克风是否静音
---@field HornUnMute boolean 喇叭是否静音
---@field HideBtnSet boolean 是否隐藏设置按钮
---@field ExitGame fun(self: CoreUI) void 退出游戏
---@field MicSwitchBtn fun(self: CoreUI) void 麦克风开关按钮
---@field HornSwitchBtn fun(self: CoreUI) void 喇叭开关按钮
---@field GetHeadNode fun(self: CoreUI, uin: string) SandboxNode 获取用户头像
---@field CheckEnv fun(self: CoreUI, bCheck: boolean) boolean 检查环境
---@field GetRandomNickName fun(self: CoreUI, nSex: number) String 获取随机昵称
---@field GetRandomAvatar fun(self: CoreUI) String 获取随机头像
---@field CheckCoreUiHide fun(self: CoreUI, val: CoreUiComponent) boolean 检测ui是否被隐藏
---@field HideCoreUi fun(self: CoreUI, val: CoreUiComponent) None 屏蔽CoreUi默认组件
---@field OpenWareHouse fun(self: CoreUI) void 打开玩家仓库皮肤界面
---@field GetSnapshot fun(self: CoreUI, val: number) SandboxNode 获取截屏
---@field DoSnapshot fun(self: CoreUI) None
---@field UiChange fun(self: CoreUI) Event UI发生变化时，会触发一个UiChange通知
---@field SnapshotFinish fun(self: CoreUI) None


---@class Decal
---@field Width number 贴花的宽
---@field Height number 贴花的高
---@field Length number 贴花的长
---@field Cullback boolean 贴花设置的回调
---@field TextureId string 贴花的纹理 fun(图片)路径
---@field CullLayer CullLayer 消隐层



---@class Surface
---@field Surface Surface 模型表面
---@field TextureId string 模型表面纹理
---@field Color ColorQuad 模型表面颜色
---@field MaterialType MaterialTemplate 模型表面材质



---@class ViewBase
---@field RenderIndex number UI渲染层级（值越大，渲染越靠后，越处于上层）
---@field UIVisibleNode boolean



---@class UIBillboard:UIComponent



---@class UIButton:UIComponent
---@field Icon string 按钮资源路径
---@field Title string 按钮文字
---@field TitleSize number 按钮文本字体大小
---@field DownEffectValue number 按钮按下效果变化值
---@field DownEffect DownEffect 按钮按下效果，有缩放，颜色变化
---@field Alpha number 为1时不透明
---@field OutlineEnable boolean 按钮边框是否显示
---@field OutlineColor ColorQuad 按钮边框颜色
---@field OutlineSize number 按钮边框宽度
---@field ShadowEnable boolean 开启按钮阴影
---@field ShadowColor ColorQuad 按钮阴影颜色
---@field ShadowOffset Vector2 按钮阴影偏移
---@field IsAutoSize boolean 自动大小。为true时，将节点大小调整为图片原本大小
---@field IconColor ColorQuad 按钮图片颜色
---@field ResourceSize Vector2 资源尺寸
---@field ScaleType ScaleType 按钮图片显示类型：伸缩；裁剪
---@field Scale9Grid Vector4 按钮图片九宫格展示
---@field EditAutoSize Button
---@field TitleColor ColorQuad 字体颜色
---@field TextVAlignment TextVAlignment 上下对齐，有向上、中间和向下对齐
---@field TextHAlignment TextHAlignment 左右对齐，有向左、中间和向右对齐
---@field Press SandboxNode_Ref button按下时候的音效
---@field Release SandboxNode_Ref button抬起时候的音效



---@class UIComponent:SandboxNode
---@field Size Vector2 UI节点像素和尺寸大小
---@field Scale Vector2 UI节点缩放倍数
---@field Rotation number UI节点旋转度数
---@field Position Vector2 UI节点坐标
---@field RenderIndex number UI渲染层级（值越大，渲染越靠后，越处于上层）
---@field Pivot Vector2 UI节点锚点（0~1），（0.5,0.5）为中点
---@field IsKeepPosWhenPivotChange boolean 更新锚点时是否保持位置不变
---@field IsNotifyEventStop boolean 是否将触摸事件传递给父节点（为true时不传递）
---@field LineColor ColorQuad UI节点边线颜色设置
---@field FillColor ColorQuad UI节点填充颜色设置
---@field LineSize number UI节点边线像素和尺寸大小
---@field ClickPass boolean 是否将点击事件穿透给场景
---@field LayoutHRelation EnumLayoutHRelation 水平关联方式，包括左关联、中线关联和右关联。设置后，当父节点（若父节点为UIRoot则为屏幕）变化时，UI与关联位置的相对距离将保持不变
---@field LayoutVRelation EnumLayoutVRelation 垂直关联方式，包括上关联、中线关联和下关联。设置后，当父节点（若父节点为UIRoot则为屏幕）变化时，UI与关联位置的相对距离将保持不变
---@field LayoutSizeRelation EnumLayoutSizeRelation 宽高关联，包括无关联，宽关联，高关联和全关联，当父节点宽高改变时，UI宽高随之变化
---@field SetFullViewSize Button 设置全视图大小
---@field Active boolean 是否激活 fun(响应点击时间)
---@field SetLeftAlign Button
---@field SetRightAlign Button
---@field SetHorizontalAlign Button
---@field SetTopAlign Button
---@field SetBottomAlign Button
---@field SetVerticalAlign Button
---@field SetEqualWidth Button
---@field SetEqualHeight Button
---@field Grayed boolean 置灰
---@field GetGlobalPos fun(self: UIComponent) Vector2 获取UI的全局位置
---@field RollOver Event<fun(self: UIComponent, node: SandboxNode, isOver: boolean, vector2: Vector2)> 鼠标进入UI范围
---@field RollOut Event<fun(self: UIComponent, node: SandboxNode, isOut: boolean, vector2: Vector2)> 鼠标超出UI范围
---@field TouchBegin Event<fun(self: UIComponent, node: SandboxNode, isTouchBegin: boolean, vector2: Vector2, number: number)> 触摸事件开始
---@field TouchEnd Event<fun(self: UIComponent, node: SandboxNode, isTouchEnd: boolean, vector2: Vector2, number: number)> 触摸事件结束
---@field TouchMove Event<fun(self: UIComponent, node: SandboxNode, isTouchMove: boolean, vector2: Vector2, number: number)> 触摸移动
---@field Click Event<fun(self: UIComponent, node: SandboxNode, isClick: boolean, vector2: Vector2)> 点击事件


---@class UIDropDownBox:UIComponent
---@field TitleColor ColorQuad 文本颜色
---@field TitleFontSize number 文本字体大小
---@field SelectedIndex number 选中的下标
---@field GetValue fun(self: UIDropDownBox) String 获取下拉框选中的内容
---@field GetItem fun(self: UIDropDownBox) String 获取下拉框某item项
---@field AddItemWithValue fun(self: UIDropDownBox, item: string, value: string) Number 给下拉框新增一项item
---@field AddItem fun(self: UIDropDownBox, item: string) Number 给下拉框添加一项item
---@field RemoveItem fun(self: UIDropDownBox, index: number) None 通过下标移除下拉框中某项item
---@field GetItemByIndex fun(self: UIDropDownBox, index: number) String 通过下标获取下拉框中某项item的key
---@field GetValueByIndex fun(self: UIDropDownBox, index: number) String 通过下标获取下拉框中某项item的value
---@field GetIndexByItem fun(self: UIDropDownBox) Number
---@field SelectIndexChange fun(self: UIDropDownBox, node: SandboxNode, index: number) None 索引切换事件


---@class UIImage:UIComponent
---@field Icon string 图片资源路径
---@field FillMethod EnumFillMethod 填充模式
---@field FillOrigin EnumFillOrigin 填充原点（仅在Horizontal与Vertical填充模式下适用）
---@field FillClockwise boolean 顺时针填充（仅在Radial360模式下适用），为true时以上方中点为起点，根据FillAmount比例顺时针渲染，否则为逆时针
---@field FillAmount number 填充比例（0~1），填充显示的部分占原来大小的比例
---@field IsAutoSize boolean 自动大小。为true时，将节点大小调整为图片原本大小
---@field Alpha number 为1时不透明
---@field ResourceSize Vector2 资源大小
---@field ScaleType ScaleType 比例类型
---@field Scale9Grid Vector4 图片比例九宫格
---@field AutoTranslator boolean 是否开启自动翻译
---@field BlurFilter boolean 是否开启高斯模糊
---@field BlurSigma number 高斯模糊sigma fun(取值范围1-5)
---@field UIMaskMode boolean
---@field EditAutoSize Button
---@field TextureRect Vector4



---@class UIList:UIComponent
---@field OverflowType OverflowType 溢出处理，设置ScrollType时，需要将该属性同步修改（如设置横向流动，此处需设置HORIZONTAL）才能达到效果
---@field ScrollType ListLayoutType 排列方式，需要与OverflowType配套使用才有效果
---@field LineCount number 行数
---@field ColumnCount number 列数
---@field LineGap number 行距
---@field ColumnGap number 列距
---@field HorizontalAlign TextHAlignment 水平对齐方式
---@field VerticalAlign TextVAlignment 垂直对齐方式
---@field AutoResizeItem boolean 自动调整列表项目大小，如果勾选:列表布局为单列，则列表项目的宽度自动设置为列表显示区域的宽度；列表布局为单行，则列表项目的高度自动设置为列表显示区域的高度；列表布局为水平流动，且设置了列数时，则每行内的列表项目的宽度自动调整使行宽与列表显示区域的宽度相等；列表布局为垂直流动，且设置了行数时，则每列内的项目的高度自动调整使行高与列表显示区域的高度相等；列表布局为分页，则3、4规则均适用;
---@field Padding Vector4 边界值
---@field ScrollPercent Vector2
---@field FoldInvisibleItems boolean Item隐藏时是否取消预留空位
---@field Bounceback boolean
---@field ContentSize Vector2 获取内容大小
---@field ScrollItemToViewOnClick boolean 点击item是否显示全
---@field SetVirtual fun(self: UIList, arg1: SandboxNode) boolean 设置虚拟列表，只为可视范围内的item创建实体对象（不可取消）
---@field SetVirtualAndLoop fun(self: UIList) void 设置循环列表（同时也是虚拟列表），头尾相接（不可取消）
---@field SetVirtualItemNum fun(self: UIList) void
---@field ScrollToTop fun(self: UIList, ani: boolean) None 滚动到顶部（允许垂直滚动时可用）
---@field ScrollToBottom fun(self: UIList, ani: boolean) None 滚动到底部（允许垂直滚动时可用）
---@field ScrollToLeft fun(self: UIList, ani: boolean) None 滚动到最左边（允许水平滚动时可用）
---@field ScrollToRight fun(self: UIList, ani: boolean) None 滚动到最右边（允许水平滚动时可用）
---@field ScrollToView fun(self: UIList, arg2: boolean, arg3: boolean) None 滚动到list某一个项
---@field ScrollToPercentX fun(self: UIList, value: number, ani: boolean) None 滚动到水平百分比位置（允许水平滚动时可用）
---@field ScrollToPercentY fun(self: UIList, value: number, ani: boolean) None 滚动到垂直百分比位置（允许垂直滚动时可用）
---@field NotifyItemRefresh fun(self: UIList, node: SandboxNode, index: number) None Item刷新内容通知
---@field NotifyItemRegister fun(self: UIList, node: SandboxNode) None Item注册通知


---@class UIModelView:UIComponent
---@field CanCameraMove boolean 是否启用视角拖拽（拖拽UI时相机围绕模型旋转）
---@field CameraDist number 相机与原点距离
---@field ResetCameraBtn Button 重置相机按钮
---@field LookAtPosition Vector3 锁定相机位置
---@field CameraLockX boolean 视角拖拽时是否锁定X轴方向
---@field CameraLockY boolean 视角拖拽时是否锁定Y轴方向
---@field CameraPitch number 相机俯仰角
---@field CameraYaw number 相机偏航角
---@field EnablePostProcessing boolean 开启后处理
---@field BloomActive boolean 全屏泛光是否激活
---@field Bloomnumberensity number 全屏泛光强度
---@field BloomThreshold number 全屏泛光阈值
---@field DofActive boolean 自由度是否激活
---@field DofFocalRegion number 字段焦点区域深度
---@field DofNearTransitionRegion number 字段最近转换区域的深度
---@field DofFarTransitionRegion number 字段深度转换区域
---@field DofFocalDistance number 景深焦距深度
---@field DofScale number 字段比例深度
---@field AntialiasingEnable boolean 抗锯齿开启
---@field AntialiasingMethod AntialiasingMethodDesc 抗锯齿方法
---@field AntialiasingQuality AntialiasingQualityDesc 抗锯齿质量
---@field LUTsActive boolean LUTs开启
---@field LUTsTemperatureType LUTsTemperatureType LUTs温度类型
---@field LUTsWhiteTemp number LUTs白色温度
---@field LUTsWhiteTnumber number LUTs白色色调
---@field LUTsColorCorrectionShadowsMax number LUTs最大色彩校正阴影
---@field LUTsColorCorrectionHighlightsMin number LUTs最小色彩校正高亮
---@field LUTsBlueCorrection number LUTs蓝光校正
---@field LUTsExpandGamut number LUTs扩展色域
---@field LUTsToneCurveAmout number LUTs色调曲线数量
---@field LUTsFilmicToneMapSlope number LUTs电影色调映射斜率
---@field LUTsFilmicToneMapToe number LUTs电影色调映射阴影
---@field LUTsFilmicToneMapShoulder number LUTs电影色调映射高光
---@field LUTsFilmicToneMapBlackClip number LUTs电影色调映射黑色调
---@field LUTsFilmicToneMapWhiteClip number LUTs电影色调映射白色调
---@field LUTsBaseSaturation ColorQuad LUTs基础饱和颜色
---@field LUTsBaseContrast ColorQuad LUTs基础对比颜色
---@field LUTsBaseGamma ColorQuad LUTs基础γ颜色
---@field LUTsBaseGain ColorQuad LUTs基础增益颜色
---@field LUTsBaseOffset ColorQuad LUTs基础偏移颜色
---@field LUTsShadowSaturation ColorQuad LUTs阴影饱和颜色
---@field LUTsShadowContrast ColorQuad LUTs阴影对比颜色
---@field LUTsShadowGamma ColorQuad LUTs阴影γ颜色
---@field LUTsShadowGain ColorQuad LUTs阴影增益颜色
---@field LUTsShadowOffset ColorQuad LUTs阴影偏移颜色
---@field LUTsMidtoneSaturation ColorQuad LUTs中间色调饱和颜色
---@field LUTsMidtoneContrast ColorQuad LUTs中间色调对比颜色
---@field LUTsMidtoneGamma ColorQuad LUTs中间色调γ颜色
---@field LUTsMidtoneGain ColorQuad LUTs中间色调增益颜色
---@field LUTsMidtoneOffset ColorQuad LUTs中间色调偏移颜色
---@field LUTsHighlightSaturation ColorQuad LUTs高光饱和颜色
---@field LUTsHighlightContrast ColorQuad LUTs高光对比颜色
---@field LUTsHighlightGamma ColorQuad LUTs高光γ颜色
---@field LUTsHighlightGain ColorQuad LUTs高光增益颜色
---@field LUTsHighlightOffset ColorQuad LUTs高光偏移颜色
---@field LUTsColorGradingLUTPath string LUTs颜色分级表路径
---@field GTAOActive boolean GTAO开关
---@field GTAOThicknessblend number 0~1
---@field GTAOFalloffStartRatio number 0-1
---@field GTAOFalloffEnd number 0-300
---@field GTAOFadeoutDistance number 0-20000
---@field GTAOFadeoutRadius number 0-10000
---@field GTAOnumberensity number 0-1
---@field GTAOPower number 0-10
---@field ChromaticAberrationActive boolean 开关
---@field ChromaticAberrationnumberensity number 0-8
---@field ChromaticAberrationStartOffset number 0-1
---@field ChromaticAberrationIterationStep number 0.01-10
---@field ChromaticAberrationIterationSamples number 1-8
---@field DisEnableDefaultLight boolean 是否关闭默认光照
---@field SkyLight string
---@field SkyLightCubeAssetID string
---@field SkyLightnumberensity number
---@field SkyLightColor ColorQuad
---@field SkyLightBlendAmount number
---@field SkyLightAmbientSkyColor ColorQuad
---@field SkyLightAmbientEquatorColor ColorQuad
---@field SkyLightAmbientGroundColor ColorQuad
---@field SkyLightAmbientColor ColorQuad
---@field FogType MODELVIEW_FogType
---@field FogColor ColorQuad
---@field FogStart number
---@field FogEnd number
---@field Atmosphere number
---@field LightEuler Vector3
---@field Lightnumberensity number
---@field LightActive boolean
---@field EnableShadow boolean
---@field SkyLightType UIMODLEVIEW_SkyLightType
---@field ResetCamera fun(self: UIModelView) void 重置相机


---@class UIMovieClip:UIComponent
---@field GifPath string Gif资源路径
---@field AutoSize boolean 自适应尺寸
---@field IsPlaying boolean 是否正在播放
---@field CilpFrame number 剪辑尺寸
---@field RepeatDelay number 重复延迟
---@field DelayPer number 延迟时间
---@field Swing boolean 振幅
---@field AddTex fun(self: UIMovieClip, value: string) None 添加资源
---@field ClearTex fun(self: UIMovieClip) void 清空资源


---@class UITextInput:UIComponent
---@field TitleColor ColorQuad 字体颜色
---@field TextVAlignment TextVAlignment 上下对齐，有向上、中间和向下对齐
---@field TextHAlignment TextHAlignment 左右对齐，有向左、中间和向右对齐
---@field MaxLength number 限制输入文本长度
---@field FontSize number 字体大小
---@field Title string 输入的文本内容
---@field Input InputMode
---@field Return Event 输入完成时触发



---@class UITextLabel:UIComponent
---@field TitleColor ColorQuad 字体颜色
---@field TextVAlignment TextVAlignment 上下对齐，有向上、中间和向下对齐
---@field TextHAlignment TextHAlignment 左右对齐，有向左、中间和向右对齐
---@field FontSize number 字体大小
---@field Title string 文本内容
---@field IsAutoSize AutoSizeType 自动调整节点大小为字体大小
---@field OutlineEnable boolean 是否显示边框
---@field OutlineColor ColorQuad 边框颜色
---@field OutlineSize number 边框宽度
---@field ShadowEnable boolean 是否显示阴影
---@field ShadowColor ColorQuad 阴影颜色
---@field ShadowOffset Vector2 阴影偏移值
---@field RichText boolean 超文本
---@field LineSpacing number 行间距
---@field AutoTranslator boolean 是否开启自动翻译
---@field LetterSpacing number 字间距
---@field GetTextSize fun(self: UITextLabel) Vector2 获取文本宽高尺寸


---@class UIVideoImage:UIComponent
---@field FileName string 视频影像资源路径
---@field Loop number 循环播放
---@field Play boolean 播放



---@class WorkSpace:SandboxNode
---@field CurrentCamera Camera 当前相机（临时用）
---@field SceneId number 当前SceneId（仅编辑器展示）
---@field CoordBlockPosition fun(self: WorkSpace, pos: Vector3) WCoord 方块坐标
---@field GetBlockID fun(self: WorkSpace, blockpos: WCoord) Number 获取方块id
---@field GetBlockBright fun(self: WorkSpace, blockpos: WCoord) Number 获取方块光照
---@field FindModelsInRadius fun(self: WorkSpace, position: Vector3, radius: number) SandboxNode 在半径中查找模型
---@field GetTerrainNode fun(self: WorkSpace) SandboxNode 获取地形节点


---@class CustomFunction
---@field OnInvoke function



---@class CustomNotify



---@class LocalScript



---@class ModuleScript



---@class RemoteEvent



---@class RemoteFunction



---@class Script



---@class ScriptService



---@class ServerScriptService



---@class ServerStorage



---@class StarterCharacterScripts



---@class StarterPlayerScripts



---@class Scheduler : SandboxNode
---@field Callback function lua回调方法
---@field Delay number 首次延迟执行的时间
---@field Loop boolean 是否循环执行
---@field Interval number 计时间隔时间
---@field Start fun(self: Scheduler) void 开始执行
---@field Pause fun(self: Scheduler) void 暂停。需要在开始执行后调用
---@field Resume fun(self: Scheduler) void 恢复。需要在暂停后调用
---@field Stop fun(self: Scheduler) void 停止。需要在开始执行后调用
---@field StartEx fun(self: Scheduler, delay: number, loop: boolean, numbererval: number, cb: function) None 开始执行。附带初始化的参数此服务器中可以容纳的最大玩家数量
---@field GetRunState fun(self: Scheduler) TimerRunState 获取定时器运行状态


---@class AdvertisementService
---@field PlayAdvertising fun(self: AdvertisementService, uin: number, success: boolean) None 指定用户播放广告
---@field PlayAdvertisingCallback fun(self: AdvertisementService, callback: function) None 广告播放接口回调


---@class AnalyticsService
---@field ReportData fun(self: AnalyticsService, dataMap: ReflexMap) None 数据埋点上报

---@class CloudService
---@field SetValue fun(self: CloudService, self : CloudService, key: string, name: string, value: string) 设置同步value值
---@field GetValue fun(self: CloudService, key: string, name: string) None 获取同步value值
---@field SetValueAsync fun(self: CloudService, key: string, name: string, value: string, func: function) None 设置异步value值
---@field GetValueAsync fun(self: CloudService, key: string, name: string, func: function) None 获取异步value值
---@field GetOrderDataCloud fun(self: CloudService, tableName: string) SandboxNode 获取订单数据云节点
---@field SetTable fun(self: CloudService, key: string, value: table) None 设置同步table值
---@field GetTable fun(self: CloudService, key: string) None 获取同步table值
---@field SetTableAsync fun(self: CloudService, key: string, value: table, func: function) None 设置异步table值
---@field GetTableAsync fun(self: CloudService, key: string, func: function) None 获取异步table值
---@field GetTableOrEmpty fun(self: CloudService, key: string) None 获取同步table值
---@field GetTableOrEmptyAsync fun(self: CloudService, key: string, func: function) None 获取异步table值
---@field RemoveKey fun(self: CloudService, key: string) None 同步移除key
---@field RemoveKeyAsync fun(self: CloudService, key: string, func: function) None 获取移除key
---@field PublishAsync fun(self: CloudService, topic: string, message: MNJsonVal, serverid: string) boolean 房间上报分发请求（仅云服主机可用）
---@field PublishAsync fun(self: CloudService, topic: string, message: MNJsonVal, serverid: string) boolean 房间上报分发请求（仅云服主机可用）
---@field SubscribeAsync fun(self: CloudService, topic: string, callback: function) None 房间监听消息（仅云服主机可用）
---@field TeleportToMap fun(self: CloudService, mapid: longlong, uin: number, teleportData: MNJsonVal, reportData: ReflexMap, false跳过确认框: boolean) boolean 跳转到地图
---@field TeleportToMap fun(self: CloudService, mapid: longlong, uin: number, teleportData: MNJsonVal, reportData: ReflexMap, false跳过确认框: boolean) boolean 跳转到地图
---@field TeleportToMap fun(self: CloudService, mapid: longlong, uin: number, teleportData: MNJsonVal, reportData: ReflexMap, false跳过确认框: boolean) boolean 跳转到地图
---@field TeleportToServer fun(self: CloudService, serverid: string, uin: number, teleportData: MNJsonVal, reportData: ReflexMap) boolean 跳转到房间
---@field TeleportToServer fun(self: CloudService, serverid: string, uin: number, teleportData: MNJsonVal, reportData: ReflexMap) boolean 跳转到房间
---@field GetPlayerServer fun(self: CloudService, uin: number, callback根据指定玩家的状态返回其Uin以及所在的mapid和serveridfunc: function) None 查询玩家所在房间 fun(仅云服主机可用)
---@field ReserveServer fun(self: CloudService, uin: number, mapid: longlong, serverData: MNJsonVal, teleportData: MNJsonVal, reportData: ReflexMap) boolean 开启并跳转到新房间
---@field ReserveServer fun(self: CloudService, uin: number, mapid: longlong, serverData: MNJsonVal, teleportData: MNJsonVal, reportData: ReflexMap) boolean 开启并跳转到新房间
---@field GetServerRoomType fun(self: CloudService) MNJsonVal any
---@field GetServerID fun(self: CloudService) String 获取服务ID
---@field GetPlayerTeleportInfo fun(self: CloudService) MNJsonVal
---@field GetServerPlayerTeleportInfo fun(self: CloudService, uin: number) MNJsonVal 获取玩家进入房间时伴随的自定义数据（如果有）
---@field SetForbidJoin fun(self: CloudService) boolean
---@field SetDataListByKey fun(self: CloudService, name: string, key: string, value: LuaArguments) Number 存储带表名name得kv
---@field SetDataListByKeyAsync fun(self: CloudService, name: string, key: string, value: LuaArguments, func: function) Number 存储带表名name得kv
---@field GetDataListByKey fun(self: CloudService, name: string, key: string) Number 获取表名name，键值k存储得值
---@field GetDataListByKeyAsync fun(self: CloudService, name: string, key: string, func: function) Number 获取表名name，键值k存储得值
---@field RemoveDataListByKey fun(self: CloudService, name: string, key: string) Number 移除表名name，键值k存储得值
---@field RemoveDataListByKeyAsync fun(self: CloudService, name: string, key: string, func: function) Number 移除表名name，键值k存储得值
---@field ClearDataList fun(self: CloudService, name: string) Number 的全部kv
---@field ClearDataListAsync fun(self: CloudService, name: string, arg2: function) Number 的全部kv
---@field GetCenterServerAsync fun(self: CloudService, string: string, string: string, callback: function) None 查询/开启标识为key的中心服，回调函数返回serverid（房间ID）,同key中心服不会开启两个，除非上一个已关闭
---@field GetCenterServerKey fun(self: CloudService) String 获取当前中心服的标识key，如果不是中心服，返回""
---@field ShutdownServer fun(self: CloudService, string: string) None 关闭当前云服（任何云服），要确保玩家正确下线（一般房间云服）
---@field SendMessage fun(self: CloudService, vector: table, arg2: ReflexTuple) boolean 向roomids数组指定的房间发送tcp直连消息
---@field NotifyOnMessage fun(self: CloudService, string: string, ReflexTuple: ReflexTuple) None 接收所有tcp直连消息的事件


---@class CollectionService
---@field AddTag fun(self: CollectionService, node: SandboxNode, tag: string) None 新增节点标签
---@field RemoveTag fun(self: CollectionService, node: SandboxNode, tag: string) None 移除节点标签
---@field GetTagged fun(self: CollectionService, tag: string) SandboxNode 获取该标签的所有节点
---@field GetTags fun(self: CollectionService, node: SandboxNode) Table 获取该节点的所有标签
---@field HasTag fun(self: CollectionService, node: SandboxNode, tag: string) boolean 该节点是否有标签
---@field GetNodeAddedSignal fun(self: CollectionService, tag: string) Event 获取该标签新增的沙盒信号
---@field GetNodeRemovedSignal fun(self: CollectionService, tag: string) Event 获取该标签移除的沙盒信号


---@class ContentService
---@field RequestQueueSize number 请求队列的大小
---@field PreloadAsync fun(self: ContentService, func: function, reflexTuple: ReflexTuple) None 异步预加载
---@field GetAssetFetchStatus fun(self: ContentService, assetid: string) AssetFetchStatus 获取资源加载状态
---@field GetAssetFetchStatusChangedSignal fun(self: ContentService, assetid: string) Event 资源加载状态变更的信号
---@field GetAssetStatusInfo fun(self: ContentService, assetid: string) String 获取资源加载状态信息
---@field NotifyAssetFetchStatus fun(self: ContentService, assetid: string, status: AssetFetchStatus) None 资源加载状态变更时，会触发一个NotifyAssetFetchStatus通知
---@field NotifyAssetStatusLoading fun(self: ContentService, assetid: string, curNum: number, maxNum: number) None 资源加载Loading时通知


---@class DeveloperStoreService
---@field GetDeveloperStoreItems fun(self: DeveloperStoreService) void 查询当前地图开发者商店列表
---@field GetPlayerDeveloperProducts fun(self: DeveloperStoreService) void 查询指定玩家的购买商品信息
---@field ServiceGetPlayerDeveloperProducts fun(self: DeveloperStoreService) void 云服查询指定玩家的购买商品信息
---@field GetProductInfo fun(self: DeveloperStoreService, productid: number) ReflexMap 查询指定商品 fun(开发者商店中商品)的信息
---@field BuyGoods fun(self: DeveloperStoreService, goodsid: number, goodsdesc: string, goodsnum: number, extraDesc: string) None 弹出购买弹窗
---@field BuyGoods fun(self: DeveloperStoreService, goodsid: number, goodsdesc: string, goodsnum: number, extraDesc: string) None 弹出购买弹窗
---@field MiniCoinRecharge fun(self: DeveloperStoreService) void 打开Mini币充值弹窗
---@field GetPlayerDeveloperSingleProducts fun(self: DeveloperStoreService) void 查询指定玩家的购买单个商品信息
---@field ServiceGetPlayerDeveloperSingleProducts fun(self: DeveloperStoreService) void
---@field GetAllStoreItems fun(self: DeveloperStoreService) void 查询所有仓库内商品
---@field GetStoreItemsByID fun(self: DeveloperStoreService) void 按ID查询仓库内商品的数量
---@field DeleteStoreItems fun(self: DeveloperStoreService) void 删除仓库ID位置的物品
---@field AddStoreItemsArguments fun(self: DeveloperStoreService) void 备注字段，给仓库id位置的物品添加一段参数。


---@class FriendsService
---@field GetSize fun(self: FriendsService) Number 获取好友数量
---@field GetFriendsInfoByIndex fun(self: FriendsService, index: number) ReflexTuple 根据好友的序列号拿到好友信息


---@class GameNode
---@field Name string 服务名
---@field Loaded SandboxNode 加载完的服务
---@field GetService fun(self: GameNode, name: string) SandboxNode 通过名称获取该服务节点
---@field BindToClose fun(self: GameNode, luaf: function) None 关闭绑定
---@field GetWorkSpace fun(self: GameNode, sceneid: number) SandboxNode 通过sceneid获取workspace


---@class LoadedService
---@field WaitLoaded fun(self: LoadedService) void 等待加载


---@class MainStorage
---@field VersionCache boolean 运行时不应该再动态改变。
---@field OnlyInitSync boolean 开启后则仅仅在客户端加入服务器时,服务器会发送数据。完成后后续变化不会再同步。



---@class MaterialService



---@class MouseService
---@field IsSight fun(self: MouseService) boolean 是否视觉范围内
---@field SetMode fun(self: MouseService, nModeType: number) None 设置鼠标模式
---@field GetCursorPick fun(self: MouseService, mouseX: number, mouseY: number, range: number) ReflexMap 获取光标拾取


---@class NetService
---@field OpenBrowserUrl fun(self: NetService, url: string, type: number) None 打开指定url网页


---@class RunService
---@field LogicFPS number 逻辑帧数
---@field UpdateFPS number 上传帧
---@field IsClient fun(self: RunService) boolean 当前的环境是否运行在客户端上
---@field IsServer fun(self: RunService) boolean 当前的环境是否运行在服务器上
---@field IsStudio fun(self: RunService) boolean 当前的环境是否运行在studio上
---@field IsMobile fun(self: RunService) boolean 当前的环境是否运行在手机端上
---@field IsPC fun(self: RunService) boolean 当前的环境是否运行在电脑端上
---@field IsRemote fun(self: RunService) boolean 当前的环境是否远程环境
---@field IsEdit fun(self: RunService) boolean 当前运行环境是否为Edit（编辑)模式
---@field IsRunMode fun(self: RunService) boolean 当前运行环境是否为Running模式
---@field Pause fun(self: RunService) void 如果游戏在运行则暂停游戏的模拟，暂停物理运算和脚本
---@field BindToRenderStep fun(self: RunService, szKey: string, priority: number, func: function) None 绑定RenderStep事件的Lua函数。RenderPriority为当前游戏内渲染层级，可根据需要进行插入
---@field UnbindFromRenderStep fun(self: RunService, szKey: string) None 解除绑定RenderStep事件的Lua函数
---@field CurrentSteadyTimeStampMS fun(self: RunService) double 获取当前时间戳，精确到毫秒。不随本地时间修改而改变。9位
---@field SetAutoTick fun(self: RunService, set: boolean) None 设置自动tick间隙
---@field IsAutoTick fun(self: RunService) boolean 是否自动tick
---@field DriveTick fun(self: RunService) void 驱动tick
---@field GetFramePerSecond fun(self: RunService) Number 每秒获取帧数
---@field SetFramePerSecond fun(self: RunService, fps: number) None 设置每秒帧数值
---@field GetMiniGameVersion fun(self: RunService) String 获取游戏端版本号
---@field GetAppPlatformName fun(self: RunService) String 获取游戏平台名称
---@field BindToTickRegister fun(self: RunService, szKey: string, priority: number, func: function) None 函数
---@field UnBindFromTickRegister fun(self: RunService, szKey: string) None 解除绑定Tick事件的Lua函数
---@field BindToRenderRegister fun(self: RunService, szKey: string, priority: number, func: function) None 函数
---@field UnBindFromRenderRegister fun(self: RunService, szKey: string) None 解除绑定Render事件的Lua函数
---@field GetCurMapOwid fun(self: RunService) String 获取当前地图ID
---@field GetCurMapUpdateTimestamp fun(self: RunService) Number 获取当前地图更新时间（上传时间）
---@field HeartBeat fun(self: RunService, time: double) None 心跳事件
---@field RenderStepped Event<fun(step: number)> None 渲染步幅事件，每次Update触发RenderStepped事件
---@field Stepped Event<fun()> Event 步幅事件，每次Tick触发Stepped事件
---@field SystemStepped Event<fun()> Event 步幅事件，每次系统Tick触发SystemStepped事件


---@class SandboxSceneMgrService
---@field SceneConfigs table
---@field CurDefaultStartScene EMultiScenes 动态场景配置
---@field NextDefaultStartScene EMultiScenes
---@field DynamicSceneConfigs table
---@field SwitchScene fun(self: SandboxSceneMgrService) void 切换场景 fun(客户端)切换结果SceneOpResult通知回调
---@field AddDynamicScene fun(self: SandboxSceneMgrService) void 添加动态场景 fun(服务端)添加结果DynamicSceneOpResultServer通知回调
---@field AddDynamicSceneWithoutBlock fun(self: SandboxSceneMgrService) void 添加动态场景 fun(服务端)添加结果DynamicSceneOpResultServer通知回调
---@field RemoveDynamicScene fun(self: SandboxSceneMgrService) void 删除动态场景 fun(服务端)删除结果DynamicSceneOpResultServer通知回调
---@field DynamicSwitchScene fun(self: SandboxSceneMgrService) void 切换结果DynamicSceneOpResultServer通知回调
---@field SceneSwitchStart fun(self: SandboxSceneMgrService) Event 切换场景开始通知 fun(客户端)
---@field SceneOpResult fun(self: SandboxSceneMgrService, type: unsignedchar, sceneid: number, result: number) None 场景操作结果通知 fun(客户端)
---@field DynamicSceneOpResultServer fun(self: SandboxSceneMgrService, type: unsignedchar, sceneid: number, result: number, uid: number) None 动态场景操作结果通知 fun(服务端)


---@class Service
---@field Name string 服务节点名（临时使用）



---@class Setting



---@class StarterGui
---@field IsRockerEnable boolean 摇杆是否启用
---@field WalkZone number 步行区
---@field BackGroundIcon string 背景图标
---@field DotIcon string 点图标
---@field DotScale number 点比例
---@field InactiveAlpha number 透明度是否激活
---@field Alpha number 透明度
---@field RockerPosition Vector2 摇杆位置
---@field RockerSize Vector2 摇杆尺寸
---@field BackGroundScaleType ScaleType 背景比例尺类型
---@field BackGroundSliceCenter Vector4 背景切片中心
---@field DotScaleType ScaleType 点刻度类型
---@field DotSliceCenter Vector4 点切片中心
---@field JumpIcon string 跳转图标
---@field JumpIconShow boolean 跳转图标显示
---@field NotifyRockerChange Event 摇杆切换会触发一个事件



---@class StarterPack



---@class UtilService
---@field GetGlobalUniqueID fun(self: UtilService) String 使用本地算法，计算并返回一个全球唯一的ID
---@field GeneralTaskReported fun(self: UtilService, arg1: number, arg2: number, arg3: number, arg4: number, arg5: number) None 通用任务分发方法
---@field SetJumpToTownValue fun(self: UtilService, arg1: string, arg2: boolean) None 设置跳转城镇bool
---@field GetJumpToTownValue fun(self: UtilService, arg1: string) boolean 获取跳转城镇bool
---@field CallMiniWorldfunction fun(self: UtilService) None
---@field CallMiniWorldfunctionRet fun(self: UtilService) ReflexMap
---@field CallMiniWoldfunctionWithClassName fun(self: UtilService) None
---@field GetPlayerLikeMapState fun(self: UtilService) None bool
---@field GetPlayerCollectedMapStateByUin fun(self: UtilService) None
---@field GetPlayerProfileByUin fun(self: UtilService, uin: number) None 获取玩家信息
---@field UploadAllCloudAsset fun(self: UtilService) None
---@field SyncAllCloudAsset fun(self: UtilService) None
---@field QueryAllCloudAsset fun(self: UtilService) None
---@field GameVibrateWithTimeAmplitude fun(self: UtilService, time: number, amplitude: number) None 手机振动
---@field GameVibrateStop fun(self: UtilService) None 停止手机振动
---@field OpenFriendsUIWithParams fun(self: UtilService) None 打开好友界面UI
---@field GetPlayerHeadInfoAndProfileByUin fun(self: UtilService) None 获取指定玩家的头像,avatar,profile信息
---@field SetCustomPlanarReflectionEnable fun(self: UtilService) None
---@field GetCustomPlanarReflectionEnable fun(self: UtilService) boolean
---@field SetCustomPlanarReflectionTextureSize fun(self: UtilService) None
---@field GetCustomPlanarReflectionTextureSize fun(self: UtilService) Number
---@field SetCustomPlanarReflectionHeight fun(self: UtilService) None
---@field GetCustomPlanarReflectionHeight fun(self: UtilService) Number
---@field SetCustomPlanarReflectionCameraLayer fun(self: UtilService) None
---@field GetCustomPlanarReflectionCameraLayer fun(self: UtilService) Number


---@class DefaultSound
---@field SoundType EnumDefaultSound 默认声音类型枚举：脚步、行为、受击、待机、技能、环境、背景音乐、提示和其他
---@field EffectIndex number 音效效果序列



---@class Sound
---@field SoundPath string 声音资源路径
---@field Play Button 试听
---@field Volume number 声音音量大小
---@field IsLoop boolean 该声音是否重复播放
---@field PlayOnRemove boolean 设置为true时，会在移除节点后播放一次声音
---@field TransObject SandboxNode 设置为某个Transform节点后，Sound将在该节点的位置播放（3D声音），若Transform与FixPos均未设置，则为全局播放（2D声音）
---@field FixPos Vector3 设置后，若没有指定Transform，则在指定位置 fun(Vector3)播放3D声音
---@field IsFixPosPlay boolean 为true时代表正在FixPos属性所指位置播放3D声音
---@field RollOffMode EnumRollOffMode 声音衰减模式，包括逆衰减（默认），线性衰减，线性平方衰减，锥型逆衰减模式
---@field RollOffMaxDistance number 声音衰减最大距离
---@field RollOffMinDistance number 声音衰减最小距离
---@field SoundPosition number 声音播放位置（以毫秒为单位）
---@field PlaySound fun(self: Sound) void 播放/继续播放声音（调用后IsPlaying为true，IsPaused为false）
---@field StopSound fun(self: Sound) void 停止播放声音（调用后IsPlaying为false）
---@field ResumeSound fun(self: Sound) void 重新播放声音（声音将从头开始播放）
---@field PauseSound fun(self: Sound) void 暂停声音（调用后IsPaused为true）
---@field SoundSyncMode fun(self: Sound) void 设置同步模式
---@field PlayFinish fun(self: Sound, node: SandboxNode) None Sound实例播放结束时触发该事件


---@class SoundGroup
---@field PlaySound fun(self: SoundGroup) void 播放/继续播放组内声音
---@field StopSound fun(self: SoundGroup) void 停止播放组内声音
---@field ResumeSound fun(self: SoundGroup) void 重新播放组内声音（声音将从头开始播放）
---@field PauseSound fun(self: SoundGroup) void 暂停组内声音
---@field ChangeVolume fun(self: SoundGroup, value: number) None 按比例改变组内声音音量（0~1），如：传入0.5会将组内Sound节点音量减半


---@class SoundService
---@field RolloffScale number 3D声音衰减速度
---@field DistanceFactor number 3D声音衰减距离
---@field DopplerScale number 3D声音多普勒效应强度
---@field GlobalVolume number 全局音量
---@field MusicOpen boolean 打开游戏内背景音乐
---@field SetListener fun(self: SoundService, type: EnumListenerType, object: SandboxNode) None 设置监听类型与监听者
---@field PlayerLocalSound fun(self: SoundService, sound: SandboxNode) None 在本地播放声音（2D，不会同步）
---@field SetSoundOpen fun(self: SoundService, value: boolean) None 在本地开关声音（包括游戏本身的声音节点）


---@class Bool



---@class ColorQuad
---@field New ColorQuad 构造
---@field R number 红
---@field G number 绿
---@field B number 蓝
---@field A number 透明度



---@class ColorValue
---@field New ColorValue 构造
---@field R number 红
---@field G number 绿
---@field B number 蓝
---@field A number 透明度



---@class Matrix3f
---@field New Matrix3f 构造



---@class Matrix4f
---@field New Matrix3f 构造



---@class MNJsonVal



---@class string



---@class Nil



---@class Notify



---@class Number（数字）



---@class Quaternion
---@field x number x坐标
---@field y number y坐标
---@field z number z坐标
---@field w number w坐标
---@field New fun(x: number, y: number, z: number, w: number) Quaternion 构造一个四元数，x,y,z,w必须满足四元数的基本规则，
---@field LookAt fun(self: Quaternion, forward: Vector3, up: Vector3) Quaternion 通过指定forward方向和upward创建一个旋转, forward表示旋转之后的正前方方向，up表示旋转之后的正上方方向
---@field FromEuler fun(x: number, y: number,z: number) Quaternion 使用欧拉角（角度）来构建一个四元数 fun(旋转顺序是ZXY)
---@field FromAxisAngle fun(self: Quaternion, axis: Vector3, angle: number) Vector3 通过轴角来构建一个四元数, angle是旋转角度（角度，非弧度）， axis旋转轴（需要归一化）
---@field Lerp fun(self: Quaternion, a: Quaternion, b: Quaternion, progress: number) Quaternion 使用t控制a和b之间插值，然后对结果进行归一化
---@field Lerp Quaternion 通过t在a和b之间插值，然后对结果进行归一化
---@field RotateAxisAngle Quaternion 绕axis轴旋转angle角度
---@field LookDir Vector3 创建具有指定向前和向上方向的旋转
---@field RotateToDir Vector3 从from到to旋转一个旋转



---@class RangeInfo
---@field New RangeInfo 构造
---@field Min number 范围最小值
---@field Max number 范围最大值



---@class Ray
---@field New Ray 构造
---@field Origin Vector3 射线起点
---@field Direction Vector3 射线方向
---@field Unit Ray 单位射线
---@field ClosestPonumber Vector3 获取碰撞位置
---@field Distance number 射线距离
---@field ClosestPonumber Vector3 [Vector3] fun(/Api/DataType/Vector3.md)
---@field Distance number [number] fun(/Api/DataType/Number.md)|||距离



---@class Rect
---@field New Rect 构造
---@field Left number 矩形左边的X坐标
---@field Right number 矩形右边的X坐标
---@field Top number 矩形顶部的Y坐标
---@field Bottom number 矩形底部的Y坐标



---@class ReflexTuple



---@class ReflexVariant



---@class SBXConnection
---@field IsConnected boolean 判断与事件是否还有连接
---@field Disconnect nil 断开与事件的连接



---@class Event



---@class String



---@class Table



---@class TweenInfo
---@field New fun(duration:number, style?:EasingStyle, direction?:EasingDirection, delayTime?:number, repeatCount?:number, reverse?:boolean) TweenInfo 构造
---@field EasingDirection number 缓动方向
---@field Time number 缓动时间
---@field DelayTime number 延迟时间
---@field RepeatCount number 循环次数。小于零时 tween 会无限循环
---@field EasingStyle number 释放样式
---@field Reverses boolean tween 完成目标后会否反转



---@class Vector2
---@field x number x坐标
---@field y number y坐标
---@field New fun(x: number, y: number) Vector2 构造
---@field Normalize fun(self: Vector2) Vector2 归一化向量（向量方向计算）


---@class Vector3
---@field x number x坐标
---@field y number y坐标
---@field z number z坐标
---@field New fun(x: number, y: number, z: number) Vector3 构造
---@field Normalize fun(self: Vector3) Vector3 归一化向量（向量方向计算）



---@class Vector4
---@field New Vector4 构造
---@field x number x坐标
---@field y number y坐标
---@field z number z坐标
---@field w number w坐标
---@field Normalize fun(self: Vector4) Vector4 归一化向量（向量方向计算）



---@class void



---@class WCoord
---@field New WCoord 构造
---@field X number x坐标
---@field Y number y坐标
---@field Z number z坐标

---@class Enum
---@field Value number 实际数字值

---@class Action :Enum
---@field KEYBOARD Action 1 键盘输入
---@field MOUSE Action 2 鼠标输入
---@field GAMEPAD Action 3 游戏手柄输入
---@field CAMERA_INPUT Action 4 相机输入


---@class ActorBehaviorItemEvent :Enum
---@field OnEnter ActorBehaviorItemEvent 1 进入
---@field OnExit ActorBehaviorItemEvent 2 退出
---@field OnEffect ActorBehaviorItemEvent 3 生效


---@class AnimationPlayMode :Enum
---@field StopSameLayer AnimationPlayMode 1 停止同一层
---@field AddToQueue_Deprecated AnimationPlayMode 2 添加到队列 fun(已废弃)
---@field Mixed_Deprecated AnimationPlayMode 3 混合播放 fun(已废弃)
---@field StopAll AnimationPlayMode 4 停止播放


---@class AnimationWrapMode :Enum
---@field Default AnimationWrapMode 1 默认播放
---@field Clamp AnimationWrapMode 2 卡在最后一帧停止
---@field Repeat AnimationWrapMode 3 重复循环播放
---@field PingPong AnimationWrapMode 4 来回循环播放
---@field ClampForever AnimationWrapMode 5 永久播放


---@class AnimatorCullingMode :Enum
---@field None AnimatorCullingMode 1 无裁剪
---@field All AnimatorCullingMode 2 disablefullstop


---@class AnimatorParameterType :Enum
---@field number AnimatorParameterType 1 number类型
---@field number AnimatorParameterType 2 number类型
---@field Bool AnimatorParameterType 3 Bool类型
---@field Trigger AnimatorParameterType 4 Trigger类型


---@class AntialiasingMethodDesc :Enum
---@field kAntialiasingMethodFXAA AntialiasingMethodDesc 1 FXAA
---@field kAntialiasingMethodSMAA AntialiasingMethodDesc 2 SMAA


---@class AntialiasingQualityDesc :Enum
---@field kAntialiasingQualityLow AntialiasingQualityDesc 1 Low
---@field kAntialiasingQualityMedium AntialiasingQualityDesc 2 Medium
---@field kAntialiasingQualityHigh AntialiasingQualityDesc 3 High


---@class AssetFetchStatus :Enum
---@field None AssetFetchStatus 1 无状态
---@field Success AssetFetchStatus 2 加载成功
---@field Failed AssetFetchStatus 3 加载失败
---@field Loading AssetFetchStatus 4 正在加载


---@class AssetResType :Enum
---@field Unknown AssetResType 1 未知
---@field Texture AssetResType 2 图片
---@field Bone AssetResType 3 骨头
---@field Audio AssetResType 4 音频
---@field Video AssetResType 5 视频
---@field Preload AssetResType 6 预制体
---@field Material AssetResType 7 材质
---@field Particle AssetResType 8 粒子
---@field Light AssetResType 9 光源
---@field Cubemap AssetResType 10 立方体贴图
---@field Blue AssetResType 11 蓝图
---@field Skeleton AssetResType 12 骨骼
---@field AnimController AssetResType 13 动画控制
---@field AnimOverrideController AssetResType 14 动画Override控制
---@field AnimAvatarMask AssetResType 15 Avatar遮罩
---@field AnimClip AssetResType 16 动画切片
---@field AnimSkClip AssetResType 17 骨骼动画切片
---@field AnimBlendTree AssetResType 18 动画混合树
---@field NodePacket AssetResType 19 节点包
---@field Gif AssetResType 20 Gif图
---@field Mesh AssetResType 21
---@field ModelData AssetResType 22
---@field Font AssetResType 23
---@field DynamicBoneConfig AssetResType 24
---@field DragonBone AssetResType 25


---@class AttributeType :Enum
---@field IDLE AttributeType 1 闲置
---@field Number AttributeType 2 数值
---@field Bool AttributeType 3 布尔
---@field String AttributeType 4 字符串
---@field Vector3 AttributeType 5 Vector3
---@field Vector2 AttributeType 6 Vector2
---@field Vector4 AttributeType 7 Vector4
---@field Color AttributeType 8 Color
---@field Rect AttributeType 9 Rect
---@field NumberSequence AttributeType 10 数字序列
---@field ColorSequence AttributeType 11 颜色序列


---@class AutoSizeType :Enum
---@field NONE AutoSizeType 1 不调整文本显示
---@field BOTH AutoSizeType 2 根据宽高自适应调整文本显示
---@field HEIGHT AutoSizeType 3 根据高度调整文本显示
---@field SHRINK AutoSizeType 4 根据宽度调整文本显示


---@class BaseMaterial :Enum


---@class BehaviorState :Enum
---@field ZERO BehaviorState 1 无
---@field Jump BehaviorState 2 跳
---@field Jumping BehaviorState 3 跳跃
---@field Stand BehaviorState 4 站立
---@field Walk BehaviorState 5 行走
---@field Fly BehaviorState 6 飞行
---@field Died BehaviorState 7 死亡


---@class BlendModeType :Enum
---@field BLEND_OPAQUE BlendModeType 1 不透明,disable
---@field BLEND_ALPHATEST BlendModeType 2 Alpha测试
---@field BLEND_ALPHABLEND BlendModeType 3 Alpha混合
---@field BLEND_ADDBLEND BlendModeType 4 相加混合
---@field BLEND_ADD BlendModeType 5 相加
---@field BLEND_MODULATE BlendModeType 6 和背景相乘


---@class BlockCollide :Enum
---@field Air BlockCollide 1
---@field Solid BlockCollide 2
---@field Liquid BlockCollide 3
---@field NoProjectile BlockCollide 4
---@field NoActor BlockCollide 5


---@class BlockPlaceType :Enum
---@field COVER BlockPlaceType 1 覆盖：当前位置有方块，也会将方块替换掉（默认）
---@field AIR BlockPlaceType 2 空气：当前位置如果为空才会放置方块，若有则不放置
---@field NOT_SAME BlockPlaceType 3 若方块id相同不覆盖


---@class BMGradientDirType :Enum
---@field NONE BMGradientDirType 1
---@field VERTICAL BMGradientDirType 2
---@field HORIZONTAL BMGradientDirType 3


---@class BrowserType :Enum
---@field NativeBrowser BrowserType 1
---@field BuiltinWebView BrowserType 2
---@field PersistWebView BrowserType 3


---@class CameraModel :Enum
---@field Classic CameraModel 1 经典模式
---@field LockFirstPerson CameraModel 1 经典模式


---@class CameraType :Enum
---@field Fixed CameraType 1 为静止状态
---@field Attach CameraType 2 以一固定的偏移随Camera移动，并在对象旋转时也旋转
---@field Watch CameraType 3 为静止状态，但会旋转以保持Camera在视野正中
---@field Track CameraType 4 随Camera移动，但不会自动旋转
---@field Follow CameraType 5 随Camera移动，并会旋转以保持对象在视野正中
---@field Custom CameraType 6 默认自定义
---@field Scriptable CameraType 7 没有默认的行为模式。用于开发人员编写自己自定的表现模式
---@field Orthographic CameraType 8 正交摄像机，2D游戏模式


---@class ChannelType :Enum
---@field SingleChannel ChannelType 1 单频道
---@field MultiChannel ChannelType 2 多频道


---@class ContextActionPriority :Enum
---@field Low ContextActionPriority 1 低优先级
---@field Medium ContextActionPriority 2 中等优先级
---@field Default ContextActionPriority 3 默认优先级
---@field High ContextActionPriority 4 高优先级


---@class ContextActionResult :Enum
---@field Sink ContextActionResult 1 如果ContextActionService:BindAction的functionToBind返回了Enum.ContextActionResult.Sink，那么输入事件就会停止于该函数，而其他位于其下的绑定动作则不会停止。这是默认的行为，前提是functionToBind没有返回任何值或者没有产生任何结果
---@field Pass ContextActionResult 2 如果ContextActionService:BindAction的functionToBind返回了Enum.ContextActionResult.Pass，那么就认为输入事件没有被functionToBind处理过，就会继续将输入事件传送到与相同的输入类型绑定的动作上。


---@class ContextActionType :Enum
---@field UserInputType ContextActionType 1 用户输入。对应Enum.UserInputType
---@field KeyBoard ContextActionType 2 键盘输入，对应Enum.KeyCode


---@class CoreUiComponent :Enum
---@field None CoreUiComponent 1 无
---@field All CoreUiComponent 2 全部
---@field BtnExit CoreUiComponent 3 退出按钮
---@field BtnMsg CoreUiComponent 4 消息按钮
---@field BtnRoomInfo CoreUiComponent 5 房间信息按钮
---@field BtnSet CoreUiComponent 6 设置按钮
---@field BtnMic CoreUiComponent 7 麦克按钮
---@field BtnLoudSpeaker CoreUiComponent 8 喇叭按钮
---@field SocialBtn CoreUiComponent 9 社交按钮


---@class CoreUIViewRange :Enum
---@field None CoreUIViewRange 1 无
---@field Near CoreUIViewRange 2 近
---@field Medium CoreUIViewRange 3 中
---@field Far CoreUIViewRange 4 中
---@field Farther CoreUIViewRange 5 远
---@field Farthest CoreUIViewRange 6 最远


---@class CullLayer :Enum
---@field DEFAULT CullLayer 1 默认
---@field LAYER1 CullLayer 2 第1层
---@field LAYER2 CullLayer 3 第2层
---@field LAYER3 CullLayer 4 第3层
---@field LAYER4 CullLayer 5 第4层
---@field LAYER5 CullLayer 6 第5层


---@class CullMode :Enum
---@field kCullOff CullMode 1 剔除
---@field kCullFront CullMode 2 剔除前
---@field kCullBack CullMode 3 剔除后


---@class DepthFunc :Enum
---@field NearEqual DepthFunc 1 深度小于等于
---@field Near DepthFunc 2 深度小于
---@field FartherEqual DepthFunc 3 深度大于等于
---@field Farther DepthFunc 4 深度大于
---@field Equal DepthFunc 5 深度等于
---@field NotEqual DepthFunc 6 深度不等于
---@field Never DepthFunc 7 深度一直不等于
---@field Always DepthFunc 8 深度一直等于


---@class DepthWrite :Enum
---@field kDepthWriteNone DepthWrite 1 深度写入无
---@field kDepthWriteEnable DepthWrite 2 深度写入启用
---@field kDepthWriteDisable DepthWrite 3 深度写入禁用


---@class DeviceRendererType :Enum
---@field OpenGLES2 DeviceRendererType 1 OpenGLES2
---@field OpenGLES3 DeviceRendererType 2 OpenGLES3
---@field OpenGLCore DeviceRendererType 3 OpenGLCore
---@field D3D11 DeviceRendererType 4 D3D11
---@field D3D12 DeviceRendererType 5 D3D12


---@class DeviceType :Enum
---@field UNKNOWN DeviceType 1 未知
---@field ANDROID DeviceType 2 安卓
---@field IOS DeviceType 3 iOS
---@field WIN DeviceType 4 Windows


---@class DevPCMovementMode :Enum
---@field UserChoice DevPCMovementMode 1 用户选择
---@field KeyboardMouse DevPCMovementMode 2 键盘鼠标
---@field ClickToMove DevPCMovementMode 3 单击移动
---@field Scriptable DevPCMovementMode 4 脚本


---@class DevTouchMovementMode :Enum
---@field UserChoice DevTouchMovementMode 1 用户选择
---@field Thumbstick DevTouchMovementMode 2 拇指操纵杆
---@field DPad DevTouchMovementMode 3 DPad板
---@field Thumbpad DevTouchMovementMode 4 拇指板
---@field ClickToMove DevTouchMovementMode 5 单击移动
---@field Scriptable DevTouchMovementMode 6 脚本
---@field DynamicThumbstick DevTouchMovementMode 7 动态拇指操纵杆


---@class DimensionUnit :Enum
---@field cenimeter DimensionUnit 1 厘米
---@field diameter DimensionUnit 2 直径
---@field meter DimensionUnit 3 米


---@class DownEffect :Enum
---@field NoEffect DownEffect 1 无效果
---@field ColorEffect DownEffect 2 颜色变化效果
---@field ScaledEffect DownEffect 3 缩放效果


---@class DragonBonesAnimation :Enum


---@class DragonBonesArmatureDisplay :Enum


---@class DragonBonesSkin :Enum


---@class DragonBonesSlot :Enum


---@class EasingDirection :Enum
---@field In EasingDirection 1 缓动风格是向前应用的
---@field Out EasingDirection 2 缓动风格是向后应用的
---@field In_Out EasingDirection 3 缓动风格在前半段向前应用，在后半段向后应用


---@class EasingStyle :Enum
---@field Linear EasingStyle 1 以恒定速度移动
---@field Sine EasingStyle 2 运动速度由正弦波决定
---@field Back EasingStyle 3 调整移动回原位或移出原位
---@field Quad EasingStyle 4 类似于Quart和Qunumber，但速度不同
---@field Quart EasingStyle 5 类似于Quad和Qunumber，但速度不同
---@field Qunumber EasingStyle 6 类似于Quad和Quart，但速度不同
---@field Bounce EasingStyle 7 移动时，就像tween的开始或结束位置是有弹性的一样
---@field Elastic EasingStyle 8 移动时就像GUI元素连接到橡皮筋一样


---@class EEmitterType :Enum
---@field EMITTER_PLANE EEmitterType 1 平面粒子发射器
---@field EMITTER_SPHERE EEmitterType 2 球形粒子发射器


---@class Effect :Enum
---@field Smoke Effect 1 烟雾
---@field Exposion Effect 2 爆炸
---@field Light Effect 3 光效
---@field Particle Effect 4 粒子
---@field Fire Effect 5 火焰
---@field Enviroment Effect 6 环境


---@class EmissionDIr :Enum
---@field Back EmissionDIr 1 向后发射
---@field Bottom EmissionDIr 2 向下发射
---@field Front EmissionDIr 3 向前发射
---@field Left EmissionDIr 4 向左发射
---@field Right EmissionDIr 5 向右发射
---@field Top EmissionDIr 6 向上发射


---@class EmitterColorOverLifeTimeMode :Enum
---@field Disable EmitterColorOverLifeTimeMode 1 无效
---@field Color EmitterColorOverLifeTimeMode 2 单一颜色
---@field Gradient EmitterColorOverLifeTimeMode 3 颜色梯度
---@field RandomBetweenTwoColors EmitterColorOverLifeTimeMode 4 两个颜色间随机
---@field RandomBetweenTwoGradients EmitterColorOverLifeTimeMode 5 两个颜色梯度间随机


---@class EmitterShape :Enum
---@field Sphere EmitterShape 1 球
---@field Hemisphere EmitterShape 2 半球
---@field Cone EmitterShape 3 圆锥
---@field Box EmitterShape 4 盒
---@field Mesh EmitterShape 5 网格
---@field ConeVolume EmitterShape 6 锥体体积
---@field Circle EmitterShape 7 圆圈
---@field SingleSidedEdge EmitterShape 8 单面边缘
---@field MeshRenderer EmitterShape 9 单面边缘
---@field SkinnedMeshRenderer EmitterShape 10 单面边缘
---@field BoxShell EmitterShape 11 长方体边缘
---@field BoxEdge EmitterShape 12 长方体边缘
---@field Donut EmitterShape 13 甜甜圈
---@field Rectangle EmitterShape 14 甜甜圈
---@field Sprite EmitterShape 15 甜甜圈
---@field SpriteRenderer EmitterShape 16 甜甜圈


---@class EmitterTrailsMode :Enum
---@field Particle EmitterTrailsMode 1 微粒
---@field Ribbon EmitterTrailsMode 2 带状


---@class EmitterTrailsTextureMode :Enum
---@field Stretch EmitterTrailsTextureMode 1 伸展
---@field Tile EmitterTrailsTextureMode 2 平铺
---@field DistributePerSegment EmitterTrailsTextureMode 3 分发


---@class EMultiScenes :Enum
---@field WorkSpace EMultiScenes 1


---@class EMultiScenesAPI :Enum
---@field SelectedScene EMultiScenesAPI 1


---@class EnumParticleSystemOnlyConstantCurveMode
---@field Constant EnumParticleSystemOnlyConstantCurveMode 1
---@field RandomBetweenTwoConstants EnumParticleSystemOnlyConstantCurveMode 2


---@class EnumUIType
---@field Default EnumUIType 1
---@field UIMain EnumUIType 2
---@field Rocker EnumUIType 3
---@field RockerDot EnumUIType 4
---@field SetBtn EnumUIType 5
---@field ChatFrame EnumUIType 6
---@field MiniMap EnumUIType 7


---@class ExplosionType :Enum
---@field NoCrater ExplosionType 1 无火山口
---@field Crater ExplosionType 2 火山口


---@class FillDirectionType :Enum
---@field Vertical FillDirectionType 1 竖直排列
---@field Horizontal FillDirectionType 2 水平排列


---@class FillMethod :Enum
---@field None FillMethod 1 无，不会应用填充属性
---@field Horizontal FillMethod 2 水平填充
---@field Vertical FillMethod 3 垂直填充
---@field Radial360 FillMethod 4 以图片上方中点为起点，360度填充


---@class FillOrigin :Enum
---@field Top FillOrigin 1 从上方开始填充（水平模式下为左边）
---@field Bottom FillOrigin 2 从下方开始填充（水平模式下为右边）


---@class FogType :Enum
---@field Disable FogType 1 无效


---@class GameBackGroundMusic :Enum
---@field ID_NO_MUSIC GameBackGroundMusic 1 没有音乐
---@field ID_DEFAULT GameBackGroundMusic 2 默认音乐
---@field ID_1 GameBackGroundMusic 3 系统音乐1
---@field ID_2 GameBackGroundMusic 4 系统音乐2
---@field ID_3 GameBackGroundMusic 5 系统音乐3
---@field ID_4 GameBackGroundMusic 6 系统音乐4
---@field ID_5 GameBackGroundMusic 7 系统音乐5
---@field ID_6 GameBackGroundMusic 8 系统音乐6
---@field ID_7 GameBackGroundMusic 9 系统音乐7
---@field ID_8 GameBackGroundMusic 10 系统音乐8


---@class GamePlayMode :Enum
---@field MINIGAME GamePlayMode 1 小游戏 fun(hakoniwa箱庭)
---@field SCROLLMAP GamePlayMode 2 卷轴型地图
---@field SURVIVE GamePlayMode 3 大世界冒险


---@class GAMESTAGE :Enum
---@field IDLE GAMESTAGE 1 闲置状态
---@field INIT GAMESTAGE 2 初始化状态
---@field LOADED GAMESTAGE 3 加载完成状态
---@field READY GAMESTAGE 4 准备状态
---@field RUN GAMESTAGE 5 运行状态
---@field END GAMESTAGE 6 结束状态


---@class GameStartMode :Enum
---@field OWNER_OPEN GameStartMode 1 房主开启
---@field ENOUGH_AUTO_OPEN GameStartMode 2 达到人数自动开启
---@field NO_LIMIT GameStartMode 3 不限条件自动开启


---@class GeoSolidShape :Enum
---@field Cuboid GeoSolidShape 1 立方体
---@field Wedge GeoSolidShape 2 楔型、直三棱柱
---@field Pyramid GeoSolidShape 3 金字塔、直四棱锥
---@field Cylinder GeoSolidShape 4 圆柱
---@field Cone GeoSolidShape 5 圆锥
---@field Sphere GeoSolidShape 6 球体
---@field Composite GeoSolidShape 7 组合
---@field Rectangle GeoSolidShape 8 组合


---@class GraphicsPlatform :Enum
---@field Mobile GraphicsPlatform 1 手机
---@field PC GraphicsPlatform 2 电脑
---@field Count GraphicsPlatform 3 上限值


---@class GraphicsQuality :Enum
---@field Low GraphicsQuality 1 低质量
---@field Medium GraphicsQuality 2 中质量
---@field High GraphicsQuality 3 高质量
---@field Ultra GraphicsQuality 4 极高质量
---@field Count GraphicsQuality 5 上限值


---@class HorizontalAlignmentType :Enum
---@field Center HorizontalAlignmentType 1 居中对齐
---@field Left HorizontalAlignmentType 2 左对齐
---@field Right HorizontalAlignmentType 3 右对齐


---@class InputMode :Enum
---@field Multiline InputMode 1 输入框支持多行
---@field Singleline InputMode 2 输入框只支持单行


---@class numbereractMethod :Enum
---@field Union numbereractMethod 1
---@field numberersect numbereractMethod 2
---@field Hollow numbereractMethod 3
---@field SimplyUnion numbereractMethod 4


---@class KeyCode :Enum
---@field Unknown KeyCode 1 未知输入
---@field Backspace KeyCode 2 Backspace
---@field Tab KeyCode 3 Tab
---@field Clear KeyCode 4 Clear
---@field Return KeyCode 5 Return
---@field Pause KeyCode 6 Pause
---@field Escape KeyCode 7 Escape
---@field Space KeyCode 8 Space
---@field QuotedDouble KeyCode 9 QuotedDouble
---@field Hash KeyCode 10 Hash
---@field Dollar KeyCode 11 Dollar
---@field Percent KeyCode 12 Percent
---@field Ampersand KeyCode 13 Ampersand
---@field Quote KeyCode 14 Quote
---@field LeftParenthesis KeyCode 15 LeftParenthesis
---@field RightParenthesis KeyCode 16 RightParenthesis
---@field Asterisk KeyCode 17 Asterisk
---@field Plus KeyCode 18 Plus
---@field Comma KeyCode 19 Comma
---@field Minus KeyCode 20 Minus
---@field Period KeyCode 21 Period
---@field Slash KeyCode 22 Slash
---@field Zero KeyCode 23 Zero
---@field One KeyCode 24 One
---@field Two KeyCode 25 Two
---@field Three KeyCode 26 Three
---@field Four KeyCode 27 Four
---@field Five KeyCode 28 Five
---@field Six KeyCode 29 Six
---@field Seven KeyCode 30 Seven
---@field Eight KeyCode 31 Eight
---@field Nine KeyCode 32 Nine
---@field Colon KeyCode 33 Colon
---@field Semicolon KeyCode 34 Semicolon
---@field LessThan KeyCode 35 LessThan
---@field Equals KeyCode 36 Equals
---@field GreaterThan KeyCode 37 GreaterThan
---@field Question KeyCode 38 Question
---@field At KeyCode 39 At
---@field LeftBracket KeyCode 40 LeftBracket
---@field BackSlash KeyCode 41 BackSlash
---@field RightBracket KeyCode 42 RightBracket
---@field Caret KeyCode 43 Caret
---@field Underscore KeyCode 44 Underscore
---@field Backquote KeyCode 45 Backquote
---@field A KeyCode 46
---@field B KeyCode 47
---@field C KeyCode 48
---@field D KeyCode 49
---@field E KeyCode 50
---@field F KeyCode 51
---@field G KeyCode 52
---@field H KeyCode 53
---@field I KeyCode 54
---@field J KeyCode 55
---@field K KeyCode 56
---@field L KeyCode 57
---@field M KeyCode 58
---@field N KeyCode 59
---@field O KeyCode 60
---@field P KeyCode 61
---@field Q KeyCode 62
---@field R KeyCode 63
---@field S KeyCode 64
---@field T KeyCode 65
---@field U KeyCode 66
---@field V KeyCode 67
---@field W KeyCode 68
---@field X KeyCode 69
---@field Y KeyCode 70
---@field Z KeyCode 71
---@field LeftCurly KeyCode 72
---@field Pipe KeyCode 73
---@field RightCurly KeyCode 74
---@field Tilde KeyCode 75
---@field Delete KeyCode 76
---@field KeypadZero KeyCode 77
---@field KeypadOne KeyCode 78
---@field KeypadTwo KeyCode 79
---@field KeypadThree KeyCode 80
---@field KeypadFour KeyCode 81
---@field KeypadFive KeyCode 82
---@field KeypadSix KeyCode 83
---@field KeypadSeven KeyCode 84
---@field KeypadEight KeyCode 85
---@field KeypadNine KeyCode 86
---@field KeypadPeriod KeyCode 87
---@field KeypadDivide KeyCode 88
---@field KeypadMultiply KeyCode 89
---@field KeypadMinus KeyCode 90
---@field KeypadPlus KeyCode 91
---@field KeypadEnter KeyCode 92
---@field KeypadEquals KeyCode 93
---@field Up KeyCode 94
---@field Down KeyCode 95
---@field Right KeyCode 96
---@field Left KeyCode 97
---@field Insert KeyCode 98
---@field Home KeyCode 99
---@field End KeyCode 100
---@field PageUp KeyCode 101
---@field PageDown KeyCode 102
---@field LeftShift KeyCode 103
---@field RightShift KeyCode 104
---@field LeftMeta KeyCode 105
---@field RightMeta KeyCode 106
---@field LeftAlt KeyCode 107
---@field RightAlt KeyCode 108
---@field LeftControl KeyCode 109
---@field RightControl KeyCode 110
---@field CapsLock KeyCode 111
---@field NumLock KeyCode 112
---@field ScrollLock KeyCode 113
---@field LeftSuper KeyCode 114
---@field RightSuper KeyCode 115
---@field Mode KeyCode 116
---@field Compose KeyCode 117
---@field Help KeyCode 118
---@field Prnumber KeyCode 119
---@field SysReq KeyCode 120
---@field Break KeyCode 121
---@field Menu KeyCode 122
---@field Power KeyCode 123
---@field Euro KeyCode 124
---@field Undo KeyCode 125
---@field F1 KeyCode 126
---@field F2 KeyCode 127
---@field F3 KeyCode 128
---@field F4 KeyCode 129
---@field F5 KeyCode 130
---@field F6 KeyCode 131
---@field F7 KeyCode 132
---@field F8 KeyCode 133
---@field F9 KeyCode 134
---@field F10 KeyCode 135
---@field F11 KeyCode 136
---@field F12 KeyCode 137
---@field F13 KeyCode 138
---@field F14 KeyCode 139
---@field F15 KeyCode 140
---@field World0 KeyCode 141
---@field World1 KeyCode 142
---@field World2 KeyCode 143
---@field World3 KeyCode 144
---@field World4 KeyCode 145
---@field World5 KeyCode 146
---@field World6 KeyCode 147
---@field World7 KeyCode 148
---@field World8 KeyCode 149
---@field World9 KeyCode 150
---@field World10 KeyCode 151
---@field World11 KeyCode 152
---@field World12 KeyCode 153
---@field World13 KeyCode 154
---@field World14 KeyCode 155
---@field World15 KeyCode 156
---@field World16 KeyCode 157
---@field World17 KeyCode 158
---@field World18 KeyCode 159
---@field World19 KeyCode 160
---@field World20 KeyCode 161
---@field World21 KeyCode 162
---@field World22 KeyCode 163
---@field World23 KeyCode 164
---@field World24 KeyCode 165
---@field World25 KeyCode 166
---@field World26 KeyCode 167
---@field World27 KeyCode 168
---@field World28 KeyCode 169
---@field World29 KeyCode 170
---@field World30 KeyCode 171
---@field World31 KeyCode 172
---@field World32 KeyCode 173
---@field World33 KeyCode 174
---@field World34 KeyCode 175
---@field World35 KeyCode 176
---@field World36 KeyCode 177
---@field World37 KeyCode 178
---@field World38 KeyCode 179
---@field World39 KeyCode 180
---@field World40 KeyCode 181
---@field World41 KeyCode 182
---@field World42 KeyCode 183
---@field World43 KeyCode 184
---@field World44 KeyCode 185
---@field World45 KeyCode 186
---@field World46 KeyCode 187
---@field World47 KeyCode 188
---@field World48 KeyCode 189
---@field World49 KeyCode 190
---@field World50 KeyCode 191
---@field World51 KeyCode 192
---@field World52 KeyCode 193
---@field World53 KeyCode 194
---@field World54 KeyCode 195
---@field World55 KeyCode 196
---@field World56 KeyCode 197
---@field World57 KeyCode 198
---@field World58 KeyCode 199
---@field World59 KeyCode 200
---@field World60 KeyCode 201
---@field World61 KeyCode 202
---@field World62 KeyCode 203
---@field World63 KeyCode 204
---@field World64 KeyCode 205
---@field World65 KeyCode 206
---@field World66 KeyCode 207
---@field World67 KeyCode 208
---@field World68 KeyCode 209
---@field World69 KeyCode 210
---@field World70 KeyCode 211
---@field World71 KeyCode 212
---@field World72 KeyCode 213
---@field World73 KeyCode 214
---@field World74 KeyCode 215
---@field World75 KeyCode 216
---@field World76 KeyCode 217
---@field World77 KeyCode 218
---@field World78 KeyCode 219
---@field World79 KeyCode 220
---@field World80 KeyCode 221
---@field World81 KeyCode 222
---@field World82 KeyCode 223
---@field World83 KeyCode 224
---@field World84 KeyCode 225
---@field World85 KeyCode 226
---@field World86 KeyCode 227
---@field World87 KeyCode 228
---@field World88 KeyCode 229
---@field World89 KeyCode 230
---@field World90 KeyCode 231
---@field World91 KeyCode 232
---@field World92 KeyCode 233
---@field World93 KeyCode 234
---@field World94 KeyCode 235
---@field World95 KeyCode 236
---@field ButtonX KeyCode 237
---@field ButtonY KeyCode 238
---@field ButtonA KeyCode 239
---@field ButtonB KeyCode 240
---@field ButtonR1 KeyCode 241
---@field ButtonL1 KeyCode 242
---@field ButtonR2 KeyCode 243
---@field ButtonL2 KeyCode 244
---@field ButtonR3 KeyCode 245
---@field ButtonL3 KeyCode 246
---@field ButtonStart KeyCode 247
---@field ButtonSelect KeyCode 248
---@field DPadLeft KeyCode 249
---@field DPadRight KeyCode 250
---@field DPadUp KeyCode 251
---@field DPadDown KeyCode 252
---@field Thumbstick1 KeyCode 253
---@field Thumbstick2 KeyCode 254


---@class LayerIndexDesc :Enum


---@class LayoutHRelation :Enum
---@field Left LayoutHRelation 1 左关联，保持与父节点（屏幕）左侧的相对位置
---@field Middle LayoutHRelation 2 中线关联，保持与父节点（屏幕）中线的相对位置
---@field Right LayoutHRelation 3 右关联，保持与父节点（屏幕）右侧的相对位置


---@class LayoutSizeRelation :Enum
---@field None LayoutSizeRelation 1 无关联
---@field Height LayoutSizeRelation 2 高关联
---@field Width LayoutSizeRelation 3 宽关联
---@field Both LayoutSizeRelation 4 宽高关联


---@class LayoutVRelation :Enum
---@field Top LayoutVRelation 1 上关联，保持与父节点（屏幕）顶部的相对位置
---@field Middle LayoutVRelation 2 中线关联，保持与父节点（屏幕）中线的相对位置
---@field Bottom LayoutVRelation 3 下关联，保持与父节点（屏幕）底部的相对位置


---@class LegacyAnimationLoop :Enum
---@field LOOP_MODE LegacyAnimationLoop 1 循环
---@field ONCE_MODE LegacyAnimationLoop 2 一次
---@field ONCE_STOP_MODE LegacyAnimationLoop 3 一次且不重置


---@class LightType :Enum
---@field Direction LightType 1 线形
---@field Ponumber LightType 2 点
---@field Spot LightType 3 斑点
---@field UnKnow LightType 4 未知


---@class ListenerType :Enum
---@field Camrea ListenerType 1 以相机位置作为监听位置
---@field TransObject ListenerType 2 以玩家指定的Transform作为监听位置
---@field Player ListenerType 3 以玩家模型作为监听位置


---@class ListLayoutType :Enum
---@field SINGLE_COLUMN ListLayoutType 1 单列，每行一个item，竖向排列
---@field SINGLE_ROW ListLayoutType 2 单行，每列一个item，横向排列
---@field FLOW_HORIZONTAL ListLayoutType 3 横向流动，item横向依次排列，到底视口右侧边缘或到达指定的列数，自动换行继续排列
---@field FLOW_VERTICAL ListLayoutType 4 竖向流动，item竖向依次排列，到底视口底部边缘或到达指定的行数，返回顶部开启新的一列继续排列
---@field PAGINATION ListLayoutType 5 分页，视口宽度x视口高度作为单页大小，横向排列各个页面。每页中，item横向依次排列


---@class LUTsTemperatureType :Enum
---@field WhilteBalance LUTsTemperatureType 1 WhilteBalance
---@field Color LUTsTemperatureType 2 Color


---@class MaterialTemplate :Enum


---@class Mode :Enum
---@field Plane Mode 1 普通的3D面片
---@field Billboard Mode 2 公告板，一直朝向摄像机，进大远小（3D渲染方式）
---@field AlwaysOnTop Mode 3 公告板，一直朝向摄像机，一直保持大小（2D渲染方式）srptite3D目前还没支持2D渲染方式


---@class Model :Enum
---@field Plane Model 1 普通的3D面片
---@field Billboard Model 2 公告板，一直朝向摄像机，进大远小（3D渲染方式）
---@field AlwaysOnTop Model 3 公告板，一直朝向摄像机，一直保持大小（2D渲染方式）srptite3D目前还没支持2D渲染方式


---@class MODELVIEW_FogType :Enum
---@field Disable MODELVIEW_FogType 1


---@class ModifierKey :Enum
---@field Shift ModifierKey 1
---@field Ctrl ModifierKey 2
---@field Alt ModifierKey 3
---@field Meta ModifierKey 4


---@class MotorType :Enum
---@field NONE MotorType 1 无
---@field MOTOR MotorType 2 电动机
---@field SERVO MotorType 3


---@class MouseBehavior :Enum
---@field Default MouseBehavior 1 自由移动
---@field LockCenter MouseBehavior 2 锁定在中间
---@field LockCurrentPosition MouseBehavior 3 锁定当前位置


---@class MSAALevelDesc :Enum
---@field kMSAALevelNone MSAALevelDesc 1 无MSAA层级
---@field kMSAALevel2x MSAALevelDesc 2 2x层级
---@field kMSAALevel4x MSAALevelDesc 3 4x层级
---@field kMSAALevel8x MSAALevelDesc 4 8x层级


---@class NodeSyncLocalFlag :Enum
---@field ENABLE NodeSyncLocalFlag 1 可使用
---@field DISABLE NodeSyncLocalFlag 2 禁用
---@field NO_SEND NodeSyncLocalFlag 3 不发送
---@field NO_RECEIVE NodeSyncLocalFlag 4 不接收


---@class NodeSyncMode :Enum
---@field NORMAL NodeSyncMode 1 普通的
---@field DISABLE NodeSyncMode 2 禁用
---@field ONLYHOST NodeSyncMode 3 唯一主机
---@field ONLYREMOTE NodeSyncMode 4 唯一远程


---@class OutlineThickness :Enum
---@field eLevel0 OutlineThickness 1 描边不模糊
---@field eLevel1 OutlineThickness 2 描边模糊等级1
---@field eLevel2 OutlineThickness 3 描边模糊等级2
---@field eLevel3 OutlineThickness 4 描边模糊等级3
---@field eLevel4 OutlineThickness 5 描边模糊等级4


---@class OverflowType :Enum
---@field VISIBLE OverflowType 1 溢出部分正常显示（无拖动效果）
---@field HIDDEN OverflowType 2 溢出部分隐藏（无拖动效果）
---@field HORIZONTAL OverflowType 3 水平滚动，支持鼠标拖拽，滑轮方式水平拖动
---@field VERTICAL OverflowType 4 垂直滚动，支持鼠标拖拽，滑轮方式垂直拖动
---@field BOTH OverflowType 5 自由滚动，支持鼠标拖拽，滑轮方式任意方向拖动


---@class ParticleCustomDataMode :Enum
---@field Disabled ParticleCustomDataMode 1
---@field Vector ParticleCustomDataMode 2
---@field Color ParticleCustomDataMode 3


---@class ParticleLimitVelocityOverLifetimeSeparateAxes :Enum
---@field Enable ParticleLimitVelocityOverLifetimeSeparateAxes 1
---@field Disable ParticleLimitVelocityOverLifetimeSeparateAxes 2


---@class ParticleLimitVelocityOverLifetimeSpaceMode :Enum
---@field Local ParticleLimitVelocityOverLifetimeSpaceMode 1
---@field World ParticleLimitVelocityOverLifetimeSpaceMode 2


---@class ParticleLineAlignment :Enum
---@field View ParticleLineAlignment 1
---@field TransformZ ParticleLineAlignment 2


---@class ParticleQualityDropdown :Enum
---@field Low ParticleQualityDropdown 1
---@field Medium ParticleQualityDropdown 2
---@field High ParticleQualityDropdown 3


---@class ParticleRenderMode :Enum
---@field Billboard ParticleRenderMode 1
---@field Stretch3D ParticleRenderMode 2
---@field BillboardFixedHorizontal ParticleRenderMode 3
---@field BillboardFixedVertical ParticleRenderMode 4
---@field Mesh ParticleRenderMode 5
---@field None ParticleRenderMode 6


---@class ParticleRenderSpace :Enum
---@field View ParticleRenderSpace 1
---@field World ParticleRenderSpace 2
---@field Local ParticleRenderSpace 3
---@field Facing ParticleRenderSpace 4
---@field Velocity ParticleRenderSpace 5


---@class ParticleShapeBoxType :Enum
---@field Volume ParticleShapeBoxType 1
---@field Shell ParticleShapeBoxType 2
---@field Edge ParticleShapeBoxType 3


---@class ParticleShapeConeType :Enum
---@field Base ParticleShapeConeType 1
---@field Volume ParticleShapeConeType 2


---@class ParticleShapeMeshSpawnMode :Enum
---@field Random ParticleShapeMeshSpawnMode 1
---@field Loop ParticleShapeMeshSpawnMode 2
---@field PingPong ParticleShapeMeshSpawnMode 3


---@class ParticleShapeMeshType :Enum
---@field Vertex ParticleShapeMeshType 1
---@field Edge ParticleShapeMeshType 2
---@field Triangle ParticleShapeMeshType 3


---@class ParticleSortMode :Enum
---@field None ParticleSortMode 1
---@field ByDistance ParticleSortMode 2
---@field OldestInFront ParticleSortMode 3
---@field YoungestInFront ParticleSortMode 4


---@class ParticleSystemCullingMode :Enum
---@field Automatic ParticleSystemCullingMode 1 自动裁剪
---@field PauseAndCatchup ParticleSystemCullingMode 2 若粒子发射器包围盒不在摄像机的可见范围内，粒子暂停模拟。若恢复可见，则粒子会以当前的时间开始模拟
---@field Pause ParticleSystemCullingMode 3 若粒子发射器包围盒不在摄像机的可见范围内，粒子暂停模拟。若恢复可见，则粒子会接着上次暂停的时间继续模拟
---@field AlwaysSimulate ParticleSystemCullingMode 4 无论粒子发射器包围盒是否在摄像机的可见范围内，粒子都会一直模拟，只是不在摄像机的可见范围内时不进行渲染


---@class ParticleSystemCurveMode :Enum
---@field Constant ParticleSystemCurveMode 1
---@field Curve ParticleSystemCurveMode 2
---@field RandomBetweenTwoConstants ParticleSystemCurveMode 3
---@field RandomBetweenTwoCurves ParticleSystemCurveMode 4


---@class ParticleSystemGradientMode :Enum
---@field Color ParticleSystemGradientMode 1 对MinMaxGradient使用单个颜色
---@field Gradient ParticleSystemGradientMode 2 对MinMaxGradient使用单个颜色渐变
---@field RandomBetweenTwoColors ParticleSystemGradientMode 3
---@field RandomBetweenGradients ParticleSystemGradientMode 4
---@field RandomColor ParticleSystemGradientMode 5


---@class ParticleSystemRingBufferMode :Enum
---@field Disabled ParticleSystemRingBufferMode 1 当粒子的存活时间超过它们的生命周期时，将移除粒子
---@field PauseUntilReplaced ParticleSystemRingBufferMode 2 创建新粒子会超过MaxParticles属性时将移除粒子
---@field LoopUntilReplaced ParticleSystemRingBufferMode 3 创建新粒子会超过MaxParticles属性时将移除粒子。在移除粒子之前，粒子保持存活，直到它们的存活时间超过它们的生命周期


---@class ParticleSystemScalingMode :Enum
---@field Hierarchy ParticleSystemScalingMode 1 层级模式
---@field Local ParticleSystemScalingMode 2 独立模式
---@field Shape ParticleSystemScalingMode 3 形状模式


---@class ParticleSystemSimulationSpace :Enum
---@field Local ParticleSystemSimulationSpace 1 在本地空间中模拟粒子
---@field World ParticleSystemSimulationSpace 2 在世界空间中模拟粒子
---@field Custom ParticleSystemSimulationSpace 3 模拟相对于自定义变换组件的粒子


---@class ParticleSystemUVGridType :Enum
---@field WholeSheet ParticleSystemUVGridType 1
---@field SingleRow ParticleSystemUVGridType 2


---@class ParticleSystemUVMode :Enum
---@field Grid ParticleSystemUVMode 1
---@field Sprites ParticleSystemUVMode 2


---@class ParticleSystemUVRowMode :Enum
---@field Custom ParticleSystemUVRowMode 1
---@field Random ParticleSystemUVRowMode 2
---@field MeshIndex ParticleSystemUVRowMode 3


---@class ParticleSystemUVTimeMode :Enum
---@field Lifetime ParticleSystemUVTimeMode 1
---@field Speed ParticleSystemUVTimeMode 2
---@field FPS ParticleSystemUVTimeMode 3


---@class ParticleVelocityOverLifetimeSpaceMode :Enum
---@field Local ParticleVelocityOverLifetimeSpaceMode 1
---@field World ParticleVelocityOverLifetimeSpaceMode 2


---@class PartType :Enum
---@field BODY PartType 1 身体
---@field HEAD PartType 2 头部
---@field FACE PartType 3 面部
---@field FACE_ORNAMENT PartType 4 面部装饰
---@field JACKET PartType 5 上衣
---@field HAND_ORNAMENT PartType 6 手饰
---@field TROUSERS PartType 7 裤子
---@field SHOE PartType 8 鞋
---@field BACK_ORNAMENT PartType 9 背部装饰
---@field FOOTPRnumber PartType 10 脚印
---@field SKIN PartType 11 皮肤
---@field RIGHT_HAND PartType 12 右手
---@field RIGHT_SHOE PartType 13 右脚


---@class PhysicsFrames :Enum
---@field 30Hz PhysicsFrames 1
---@field 60Hz PhysicsFrames 2


---@class PhysicsRoleType :Enum
---@field BOX PhysicsRoleType 1 包围盒
---@field CAPSULE PhysicsRoleType 2 胶囊体


---@class PhysicsType :Enum
---@field BOX PhysicsType 1 包围盒
---@field TRIANGLE_MESH PhysicsType 2 三角形网格


---@class PHYSX2D_TYPE :Enum
---@field BOX PHYSX2D_TYPE 1 方形
---@field CIRCLE PHYSX2D_TYPE 2 圆形
---@field CONCAVEPOLYGON PHYSX2D_TYPE 3 多边形


---@class PlanarReflectionTextureSize :Enum
---@field e256 PlanarReflectionTextureSize 1 256x256贴图精度
---@field e512 PlanarReflectionTextureSize 2 512x512贴图精度
---@field e768 PlanarReflectionTextureSize 3 768x768贴图精度
---@field e1024 PlanarReflectionTextureSize 4 1024x1024贴图精度


---@class PostprocessQuality :Enum
---@field Disable PostprocessQuality 1 无效
---@field Low PostprocessQuality 2 低质量
---@field Medium PostprocessQuality 3 中质量
---@field High PostprocessQuality 4 高质量
---@field Count PostprocessQuality 5 上限值


---@class PParticleDirType :Enum
---@field PR_FACE_CAMERA PParticleDirType 1 面向相机
---@field PR_ROT_ABOUT_UP PParticleDirType 2 绕y轴旋转
---@field PR_FACE_UP PParticleDirType 3 面向y轴
---@field PR_ROT_ABOUT_DIR PParticleDirType 4 绕运动方向旋转
---@field PR_FACE_DIR PParticleDirType 5 面向运动方向


---@class PreZMode :Enum
---@field None PreZMode 1 无
---@field Maked PreZMode 2 蒙层
---@field OpaqueAndMasked PreZMode 3 不透明且蒙层


---@class RagdollBoneJonumber :Enum
---@field Pelvis RagdollBoneJonumber 1 骨盆
---@field Left_Hips RagdollBoneJonumber 2 左臀部
---@field Right_Hips RagdollBoneJonumber 3 右臀部
---@field Left_Knee RagdollBoneJonumber 4 左膝
---@field Right_Knee RagdollBoneJonumber 5 右膝
---@field Middle_Spine RagdollBoneJonumber 6 中脊柱
---@field Left_Arm RagdollBoneJonumber 7 左臂
---@field Right_Arm RagdollBoneJonumber 8 右臂
---@field Left_Elbow RagdollBoneJonumber 9 左肘
---@field Right_Elbow RagdollBoneJonumber 10 右肘
---@field Head RagdollBoneJonumber 11 头
---@field Custom RagdollBoneJonumber 12 自定义


---@class RenderPriority :Enum
---@field First RenderPriority 1 优先运行
---@field Input RenderPriority 2 此项应当第2位运行
---@field Camera RenderPriority 3 在Input（输入）后运行
---@field Character RenderPriority 4 在Camera（镜头）后运行


---@class ResolutionLevel :Enum
---@field R1X ResolutionLevel 1 1倍分辨率
---@field R2X ResolutionLevel 2 2倍分辨率
---@field R4X ResolutionLevel 3 4倍分辨率


---@class ResourceLoadMode :Enum
---@field Default ResourceLoadMode 1
---@field Manual ResourceLoadMode 2
---@field Dynamic ResourceLoadMode 3


---@class RollOffMode :Enum
---@field Inverse RollOffMode 1 该声音将遵循逆衰减模型，其中mindistance=全音量，maxdistance=声音停止衰减，衰减根据全局衰减系数
---@field Linear RollOffMode 2 该声音将遵循线性衰减模型，其中mindistance=全音量，maxdistance=静音
---@field LinearSquare RollOffMode 3 该声音将遵循线性平方衰减模型，其中mindistance=全音量，maxdistance=静音
---@field InverseTapered RollOffMode 4 在距离接近mindistance时，该声音将遵循逆衰减模型，在距离接近maxdistance的情况下，该声音会遵循线性平方衰减模型


---@class RotateType :Enum
---@field ROTATE_0 RotateType 1 逆时针旋转0°
---@field ROTATE_90 RotateType 2 逆时针旋转90°
---@field ROTATE_180 RotateType 3 逆时针旋转180°
---@field ROTATE_270 RotateType 4 逆时针旋转270°
---@field MIRROR_0 RotateType 5 取0°镜像
---@field MIRROR_180 RotateType 6 取180°镜像
---@field MIRROR_90 RotateType 7 取90°镜像


---@class ScaleType :Enum
---@field Stretch ScaleType 1 伸缩
---@field Slice ScaleType 2 裁剪


---@class SceneEffectFrameShowMode :Enum
---@field X SceneEffectFrameShowMode 1 X轴
---@field Y SceneEffectFrameShowMode 2 Y轴
---@field Z SceneEffectFrameShowMode 3 Z轴
---@field XY SceneEffectFrameShowMode 4 XY轴
---@field XZ SceneEffectFrameShowMode 5 XZ轴
---@field YZ SceneEffectFrameShowMode 6 YZ轴
---@field XYZ SceneEffectFrameShowMode 7 XYZ轴


---@class ShadowCascadeCount :Enum
---@field ONE ShadowCascadeCount 1 一层
---@field TWO ShadowCascadeCount 2 二层
---@field THREE ShadowCascadeCount 3 三层


---@class ShadowDesc :Enum
---@field Invalid ShadowDesc 1 无效的
---@field Open ShadowDesc 2 开启
---@field Close ShadowDesc 3 关闭


---@class ShadowQuality :Enum
---@field Level0 ShadowQuality 1 阴影质量0级
---@field Level1 ShadowQuality 2 阴影质量1级
---@field Level2 ShadowQuality 3 阴影质量2级
---@field Level3 ShadowQuality 4 阴影质量3级


---@class SkyBoxType :Enum
---@field Game SkyBoxType 1 游戏系统自带
---@field Custom SkyBoxType 2 用户自定义
---@field Advance SkyBoxType 3 自定义材质
---@field Disable SkyBoxType 4 关闭天空盒


---@class SkyLightType :Enum
---@field Skybox SkyLightType 1 天空盒
---@field Color SkyLightType 2 颜色
---@field Gradient SkyLightType 3 渐变


---@class SkyPlanet :Enum
---@field Custom SkyPlanet 1 地球（默认）
---@field Earth SkyPlanet 2 萌眼星
---@field Twinkle SkyPlanet 3 烈焰星
---@field Flame SkyPlanet 4 火山


---@class Sound :Enum
---@field FootStep Sound 1 脚步
---@field Behivior Sound 2 行为
---@field Behit Sound 3 受击
---@field Idle Sound 4 待机
---@field Skill Sound 5 技能
---@field Enviroment Sound 6 环境
---@field Background Sound 7 背景音乐
---@field Hnumber Sound 8 提示
---@field Other Sound 9 其他


---@class StandardSkeleton :Enum
---@field None StandardSkeleton 1 无骨骼
---@field Legacy StandardSkeleton 2 官方旧骨骼
---@field Offical_Player12 StandardSkeleton 3 官方新骨骼12


---@class StateMachineMessage :Enum
---@field kOnStateEnter StateMachineMessage 1 输入状态
---@field kOnStateExit StateMachineMessage 2 退出状态
---@field kOnStateUpdate StateMachineMessage 3 更新状态
---@field kOnStateMove StateMachineMessage 4 移动状态
---@field kOnStateIK StateMachineMessage 5 启用状态
---@field kOnStateMachineEnter StateMachineMessage 6 在状态机上输入
---@field kOnStateMachineExit StateMachineMessage 7 状态机退出


---@class SUBSTAGE_INIT :Enum
---@field READY SUBSTAGE_INIT 1


---@class SUBSTAGE_LOADED :Enum
---@field READY SUBSTAGE_LOADED 1
---@field REMOTE_READYNODECREATE SUBSTAGE_LOADED 2
---@field HOST_LOADNODES SUBSTAGE_LOADED 3
---@field REMOTE_ASSETCONFIG SUBSTAGE_LOADED 4
---@field CLIENT_LOCALPLAYER SUBSTAGE_LOADED 5
---@field REMOTE_SYNCFINISH SUBSTAGE_LOADED 6
---@field REMOTE_ALLSCRIPTS SUBSTAGE_LOADED 7


---@class SUBSTAGE_READY :Enum
---@field READY SUBSTAGE_READY 1
---@field REMOTE_PREPARE SUBSTAGE_READY 2
---@field REMOTE_HOSTREADY SUBSTAGE_READY 3
---@field CLIENT_ASSETOBJ SUBSTAGE_READY 4


---@class SUBSTAGE_RUN :Enum
---@field READY SUBSTAGE_RUN 1
---@field HOST_GAMEMODE SUBSTAGE_RUN 2
---@field REMOTE_HOSTREADY SUBSTAGE_RUN 3
---@field SURVIVEGAME SUBSTAGE_RUN 4


---@class Surface :Enum
---@field FACE1 Surface 1
---@field FACE2 Surface 2
---@field FACE3 Surface 3
---@field FACE4 Surface 4
---@field FACE5 Surface 5
---@field FACE6 Surface 6
---@field FACE7 Surface 7
---@field FACE8 Surface 8
---@field FACE9 Surface 9


---@class TextHAlignment :Enum
---@field Right TextHAlignment 1 文字居右
---@field Center TextHAlignment 2 文字居中
---@field Left TextHAlignment 3 文字居左


---@class TextureBlend :Enum
---@field OnlyAlpha TextureBlend 1 透明的
---@field Add TextureBlend 2 添加


---@class TextureMode :Enum
---@field Stretch TextureMode 1 伸展
---@field Tile TextureMode 2 平铺


---@class TextVAlignment :Enum
---@field Top TextVAlignment 1 文字居上
---@field Center TextVAlignment 2 文字居中
---@field Bottom TextVAlignment 3 文字居下


---@class TimelineCustomEvent :Enum
---@field TimelineStart TimelineCustomEvent 1 timeline开始播放
---@field TimelineEnd TimelineCustomEvent 2 timeline结束播放
---@field ClipStart TimelineCustomEvent 3 片段开始
---@field ClipEnd TimelineCustomEvent 4 片段结束
---@field ClipTick TimelineCustomEvent 5 片段tick
---@field EditorUpdateTime TimelineCustomEvent 6 Editor修改timeline的时间


---@class TimelineTrackType :Enum
---@field Invalid TimelineTrackType 1 无效
---@field Visible TimelineTrackType 2 可见轨道
---@field SkeletonAnimation TimelineTrackType 3 骨骼动画
---@field NodeAnimation TimelineTrackType 4 节点属性动画
---@field Audio TimelineTrackType 5 音频
---@field Custom TimelineTrackType 6 自定义


---@class TimerRunState :Enum
---@field IDLE TimerRunState 1 空闲状态。未开始运行，或者运行结束
---@field RUNNING TimerRunState 2 运行状态


---@class ToolActiveMode :Enum
---@field MouseLeft ToolActiveMode 1 鼠标左键
---@field MouseRight ToolActiveMode 2 鼠标右键


---@class TweenStatus :Enum
---@field Begin TweenStatus 1 UITween开始
---@field Delayed TweenStatus 2 UITween延迟播放
---@field Playing TweenStatus 3 UITween开始播放
---@field Paused TweenStatus 4 UITween在完成前暂停了
---@field Canceled TweenStatus 5 UITween在完成前就被取消了
---@field Completed TweenStatus 6 UITween顺利完成了


---@class UIMODLEVIEW_SkyLightType :Enum
---@field Skybox UIMODLEVIEW_SkyLightType 1
---@field Color UIMODLEVIEW_SkyLightType 2
---@field Gradient UIMODLEVIEW_SkyLightType 3


---@class UserInputKeyCode :Enum
---@field KeyCodeUnknown UserInputKeyCode 1
---@field KeyCodeA UserInputKeyCode 2
---@field KeyCodeD UserInputKeyCode 3
---@field KeyCodeS UserInputKeyCode 4
---@field KeyCodeW UserInputKeyCode 5


---@class UserInputState :Enum
---@field InputBegin UserInputState 1
---@field InputChange UserInputState 2
---@field InputEnd UserInputState 3
---@field InputCancel UserInputState 4


---@class UserInputType :Enum
---@field MouseButton1 UserInputType 1
---@field MouseButton2 UserInputType 2
---@field MouseButton3 UserInputType 3
---@field MouseWheel UserInputType 4
---@field MouseMovement UserInputType 5
---@field MouseOut UserInputType 6
---@field MouseIn UserInputType 7
---@field Touch UserInputType 8
---@field MouseIdle UserInputType 9
---@field MouseDelta UserInputType 10
---@field Keyboard UserInputType 11
---@field ACCELEROMETER UserInputType 12
---@field GYRO UserInputType 13
---@field GamePad1 UserInputType 14
---@field GamePad2 UserInputType 15
---@field GamePad3 UserInputType 16
---@field GamePad4 UserInputType 17
---@field GamePad5 UserInputType 18
---@field GamePad6 UserInputType 19
---@field GamePad7 UserInputType 20
---@field GamePad8 UserInputType 21
---@field GetFocus UserInputType 22
---@field LostFocus UserInputType 23
---@field TextInput UserInputType 24
---@field WinSize UserInputType 25


---@class VerticalAlignment :Enum
---@field Bottom VerticalAlignment 1 下对齐
---@field Center VerticalAlignment 2 居中对齐
---@field Top VerticalAlignment 3 上对齐


---@class ViewRange :Enum
---@field None ViewRange 1 无
---@field Near ViewRange 2 近
---@field Medium ViewRange 3 中
---@field Far ViewRange 4 中
---@field Farther ViewRange 5 远
---@field Farthest ViewRange 6 最远
---@field Max ViewRange 7 max


---@class VignetteMode :Enum
---@field Classic VignetteMode 1 Classic
---@field Masked VignetteMode 2 Masked


---@class WaterReflectedDesc :Enum
---@field Invalid WaterReflectedDesc 1 无效的
---@field Open WaterReflectedDesc 2 开启
---@field Close WaterReflectedDesc 3 关闭


---@class Event :Enum
---@field Connect fun(self: Event, callback: function)  -- 连接事件，回调类型为 T

---@class Weather :Enum
---@field Sunny Weather 1 晴天
---@field Rain Weather 2 雨天
---@field Thunder Weather 3 打雷

---@class ChatService
---@field NewInputContent Event

---@class GameService
---@field UserInputService UserInputService
---@field Workspace WorkSpace 工作区
---@field Players SandboxNode 玩家
---@field ServerStorage SandboxNode 服务器存储
---@field Tween TweenService
---@field WorkSpace WorkSpace 玩家
---@field MouseService MouseService
---@field Assets SandboxNode 素材
---@field WorldService WorldService
---@field RunService RunService
---@field GetService fun(self: GameService, name: string) SandboxNode 获取服务
---@field Chat ChatService 聊天服务
---@field StarterGui SandboxNode UI
game = {} ---@type GameService

Vector3 = {} ---@type Vector3

SandboxNode = {} ---@type SandboxNode
Vector2 = {} ---@type Vector2
Vector4 = {} ---@type Vector4

---@class Enum
---@field PhysicsRoleType PhysicsRoleType
---@field NodeSyncLocalFlag NodeSyncLocalFlag
---@field UserInputType UserInputType
---@field KeyCode KeyCode
---@field ResolutionLevel ResolutionLevel
---@field LayoutHRelation LayoutHRelation
---@field LayoutVRelation LayoutVRelation
---@field FillMethod FillMethod
---@field CameraType CameraType
---@field EasingStyle EasingStyle
---@field EasingDirection EasingDirection
---@field NodeSyncMode NodeSyncMode
---@field CameraModel CameraModel
Enum = {} ---@type Enum

Quaternion = {} ---@type Quaternion
ColorQuad = {} ---@type ColorQuad

script = {} ---@type SandboxNode
TweenInfo = {} ---@type TweenInfo
-- -- 所有参数为默认的 TweenInfo
-- local default = TweenInfo.New() 
-- -- 时间设置为 0.5 秒的 TweenInfo
-- local timeChanged = TweenInfo.New(0.5) 
-- -- 释放样式设置为 Back 的 TweenInfo
-- local easingStyled = TweenInfo.New(0.5, Enum.EasingStyle.Back, 0, 0, 0, false) 
-- -- 释放方向设置为 In 的 TweenInfo
-- local easingDirected = TweenInfo.New(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In, 0, 0, false)
-- -- 自身重复 4 次的 TweenInfo
-- local repeated = TweenInfo.New(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In, 0, 4, false)
-- -- 完成目标后会反向其插值的 TweenInfo
-- local reverses = TweenInfo.New(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In, 0, 4, true)
-- -- 无限循环的 TweenInfo
-- local reverses = TweenInfo.New(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In, 0, -1,  true)
-- -- 各插值之间有 1 秒延迟的 TweenInfo
-- local delayed = TweenInfo.New(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In, 1, 4, true)