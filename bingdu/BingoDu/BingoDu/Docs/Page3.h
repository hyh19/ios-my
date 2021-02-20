/*!
@page page3 图片资源命名规范
 
 @section page3_sec1 一、格式
 type_identifier_state\n
 1、全部用英文小写；\n
 2、不同部分用下划线分开；\n
 3、动画图片序列序号从0开始；\n
 4、2倍和3倍尺寸图片加@2x、@3x作为后缀。\n
 
 @section page3_sec2 二、说明
 
 @subsection page3_sec2_subsec1 type：类型描述，分为btn、bg、icon、ani
 1、btn：按钮，有点击事件，分多种状态；\n
 2、bg：背景，如整个界面的背景或部分界面的背景；\n
 3、icon：图标，没有点击事件，通常与文字结合使用，如在列表文字的左边加一个图片作为提示；\n
 4、ani：动画，连续的图片序列从0开始按顺序命名。\n
 
 @subsection page3_sec2_subsec2 identifier：功能描述，如add、delete、share等
 
 @subsection page3_sec2_subsec3 state：状态描述，主要是按钮使用，其它类型的图片名字可不加，没有用到的状态可不切图
 normal：正常状态，没有任何操作时的状态\n
 highlighted：高亮状态，点击按钮但还未松开时的状态\n
 disabled：不可用状态，此时按钮不可以点击，如按钮灰掉\n
 selected：选中后状态，如勾选按钮的已勾选状态\n

 @section page3_sec3 三、例子
 
 @subsection page3_sec3_subsec1 例子1：分享按钮，4种状态、3种大小
 正常状态
 @code
 btn_share_normal.png
 btn_share_normal@2x.png
 btn_share_normal@3x.png
 @endcode
 
 高亮状态
 @code
 btn_share_highlighted.png
 btn_share_highlighted@2x.png
 btn_share_highlighted@3x.png
 @endcode

 不可用状态
 @code
 btn_share_disabled.png
 btn_share_disabled@2x.png
 btn_share_disabled@3x.png
 @endcode
 
 选中后状态
 @code
 btn_share_selected.png
 btn_share_selected@2x.png
 btn_share_selected@3x.png
 @endcode
 
 @subsection page3_sec3_subsec2 例子2：启动画面的背景
 
 @code
 bg_launch.png
 bg_launch@2x.png
 bg_launch@3x.png
 @endcode
 
 @subsection page3_sec3_subsec3 例子3：清理缓存的图标
 
 @code
 icon_clear.png
 icon_clear@2x.png
 icon_clear@3x.png
 @endcode
 
 @subsection page3_sec3_subsec4 例子4：提现成功的动画
 
 1倍尺寸
 @code
 ani_withdraw_0.png
 ani_withdraw_1.png
 ani_withdraw_2.png
 ani_withdraw_3.png
 ani_withdraw_4.png
 @endcode
 
 2倍尺寸
 @code
 ani_withdraw_0@2x.png
 ani_withdraw_1@2x.png
 ani_withdraw_2@2x.png
 ani_withdraw_3@2x.png
 ani_withdraw_4@2x.png
 @endcode
 
 3倍尺寸
 @code
 ani_withdraw_0@3x.png
 ani_withdraw_1@3x.png
 ani_withdraw_2@3x.png
 ani_withdraw_3@3x.png
 ani_withdraw_4@3x.png
 @endcode
 
 */
