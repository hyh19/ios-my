/*!
@page page1 编码规范
 
 @tableofcontents

@section page1_sec1 Controller类文件编码规范
 
 @subsection page1_sec1_subsec1 一、文件和类命名格式
 
 格式：ZW+Identifier+Viewcontroller\n
 ZW：南华智闻缩写\n
 Identifier：类文件功能描述\n
 例子：\n
 
 @code
 ZWHelloWorldViewcontroller
 @endcode

 注意：严禁使用如VC、VCtrl、ViewCtrl、NC、NavCtrl等不规范缩写。\n

 @subsection page1_sec1_subsec2 二、编码规范
 
 1、方法分组管理\n
 常用的方法分组如下，不在以下分组之列的，应根据相关功能进行命名。\n
 \n
 初始化方法：
 @code
 #pragma mark - Init
 @endcode
 
 属性访问方法\n
 @code
 #pragma mark - Getter & Setter
 @endcode
 
 视图控制器生命周期方法\n
 @code
 #pragma mark - Life cycle
 @endcode
 
 网络交互方法\n
 @code
 #pragma mark - Network management
 @endcode
 
 数据管理方法\n
 @code
 #pragma mark - Data management
 @endcode
 
 UI管理方法\n
 @code
 #pragma mark - UI management
 @endcode
 
 事件处理方法：主要以UI控件所触发的方法为主，非UI控件所触发的事件处理方法也可以放在该分组。\n
 @code
 #pragma mark - Event handler
 @endcode
 
 委托协议方法，此类方法应该按不同委托协议单独分组\n
 如：
 @code
 #pragma mark - UITableViewDataSource
 #pragma mark - UITableViewDelegate
 #pragma mark – UIScrollViewDelegate
 @endcode
 
 工具辅助方法\n
 @code
 #pragma mark - Helper
 @endcode
 
 2、方法命名规范\n
 初始化方法：\n
 所有初始化方法一律按iOS官方规范以init开头\n
 \n
 属性访问器方法：\n
 所有属性访问器方法一律按iOS官方规范命名\n
 \n
 网络交互方法命名规范，主要是发送网路请求：\n
 格式：sendRequestForDoingSomething\n

 如：
 @code
 sendRequestForLogining
 sendRequestForLoadingNewsList
 sendRequestForUploadingImage
 @endcode
 
 事件处理方法命名规范，主要是UI控件触发的方法，非UI控件所触发的事件处理方法应根据实际功能进行命名：\n
 \n
 Touch事件：onTouch+控件类型+doSomething，如：
 @code
 onTouchButtonShowDetail
 @endcode
 
 Tap事件：onTap+控件类型+doSomething，如：\n
 @code
 onTapImageShowDialog
 @endcode
 
 Swipe事件：onSwipe+控件类型+doSomething，如：\n
 @code
 onSwipeViewGoBack
 @endcode
 
 Drag事件：onDrag+控件类型+doSomething，如：\n
 @code
 onDragScrollViewReloadData
 @endcode
 
 ValueChanged事件：onValueChanged+doSomething，如：\n
 @code
 onValueChangedRefreshProgress
 @endcode
 
 TextEditing事件：onTextEditing+doSomething，如：\n
 @code
 onTextEditingFormatText
 @endcode

 其它方法根据代码功能进行合理命名。

@section page1_sec2 Category类文件编码规范
 
 @subsection page1_sec2_subsec1 一、文件命名格式
 
 Class+NHZW\n
 Class：要拓展的类\n
 NHZW：南华智闻首字母缩写\n
 
 例子：
 @code
 UIViewController+NHZW.h
 UIViewController+NHZW.m
 @endcode
 
 @code
 NSString+NHZW.h
 NSString+NHZW.m
 @endcode
 
 @code
 UIColor+NHZW.h
 UIColor+NHZW.m
 @endcode
 
 对第三方类库某些类的拓展，原则上不允许在其内部进行修改，应该新建一个Category，如对第三方通讯录类库Address Book Wrappers某些类的拓展可新建以下类文件：
 
 @code
 ABContactsHelper+NHZW.h
 ABContactsHelper+NHZW.h
 @endcode
 
 @code
 ABContact+NHZW.h
 ABContact+NHZW.m
 @endcode
 
 @code
 ABGroup+NHZW.h
 ABGroup+NHZW.m
 @endcode
 
 @subsection page1_sec2_subsec2 二、编码规范
 
 1、如果一个Category类文件内部涉及到多个功能模块，应该在该类文件下新建多个Category，原则上不允许新建多个Category类文件。\n
 例如：NSString+NHZW类文件内部有字符串RSA加密、字符串校验和字符串格式化三个功能模块，则应该新建三个Category\n
 
 @code
 // 字符串RSA加密
 @interface NSString (RSACrypto)
 @end
 @endcode
 
 @code
 // 字符串校验
 @interface NSString (Validation)
 @end
 @endcode
 
 @code
 // 字符串格式化
 @interface NSString (Formatting)
 @end
 @endcode
 
 @section page1_sec3 View类文件编码规范
 
 @subsection page1_sec3_subsec1 一、文件和类命名格式
 
 ZW+Identifier+SuperClass\n
 ZW：南华智闻缩写\n
 Identifier：控件的功能描述\n
 SuperClass：父类名称\n
 如：
 @code
 ZWHelpView
 @endcode

 @section page1_sec4 Network类文件编码规范
 
 @subsection page1_sec4_subsec1 一、文件和类命名格式
 
 ZW+Identifier+NetworkManager\n
 ZW：南华智闻缩写\n
 Identifier：网络交互管理器的功能描述\n
 NetworkManager：网络交互管理器\n
 如：
 @code
 ZWNewsNetworkManager
 ZWContactsNetworkManager
 ZWMoneyNetworkManager
 @endcode
 
 @section page1_sec5 Model类文件编码规范
 
 @subsection page1_sec5_subsec1 一、文件和类命名格式
 
 数据管理器命名格式：\n
 ZW+Identifier+DataManager\n
 ZW：南华智闻缩写\n
 Identifier：数据管理器的功能描述\n
 DataManager：数据管理器\n
 如：
 @code
 ZWPointDataManager
 ZWMoneyDataManager
 @endcode
 
 数据模型命名格式：\n
 ZW+Identifier+Model\n
 ZW：南华智闻缩写\n
 Identifier：数据模型的功能描述\n
 Model：数据模型\n
 如：
 @code
 ZWNewsModel
 ZWBankModel
 @endcode
 
 @section page1_sec6 第三方类库编码规范
 1、引入第三方类库必须对该类库的功能进行说明，并附加该类库的下载地址；\n
 2、原则上不允许修改第三方类库文件，需要拓展的应该通过Category或继承方式进行，确实需要修改的必须向主管进行汇报，并确定修改方案和填写修改记录；\n
 3、第三方类库文件必须统一放在ThirdParty文件夹下，已经不再使用的必须删除。

*/
