/*!
@page page7 版本号管理
 
 @section page7_sec1 Version
 
 用数字表示，如1.4.0，1.4.1，1.5.0，2.1.0等。
 
 @section page7_sec2 Build
 
 用数字表示，如10，11，12等，每次打包自动递增一次。
 
 添加以下Shell脚本代码到对应Target的Run Script Build Phases，打包时会自动递增，普通编译不会自动递增。
 
 @code
 
 if [ "${CONFIGURATION}" = "Release" ]; then
 buildNumber=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" "${TARGET_BUILD_DIR}/${INFOPLIST_PATH}")
 buildNumber=$(($buildNumber + 1))
 
 /usr/libexec/PlistBuddy -c "Set :CFBundleVersion $buildNumber" "$INFOPLIST_FILE"
 /usr/libexec/PlistBuddy -c "Set :CFBundleVersion $buildNumber" "${TARGET_BUILD_DIR}/${INFOPLIST_PATH}"
 fi
 
 @endcode
 
 @section page7_sec3 Others
 
 @subsection page7_sec3_subsec1 添加编译时间信息
 
 添加以下Shell脚本代码到对应Target的Run Script Build Phases，编译的时候自动添加BuildDateString到info.plist，然后可以在代码里读取。
 
 @code
 
 infoplist="$BUILT_PRODUCTS_DIR/$INFOPLIST_PATH"
 builddate=`date`
 if [[ -n "$builddate" ]]; then
 # if BuildDateString doesn't exist, add it
 /usr/libexec/PlistBuddy -c "Add :BuildDateString string $builddate" "${infoplist}"
 # and if BuildDateString already existed, update it
 /usr/libexec/PlistBuddy -c "Set :BuildDateString $builddate" "${infoplist}"
 fi
 
 @endcode
 
 @code
 
 [[NSBundle mainBundle] objectForInfoDictionaryKey:@"BuildDateString"];
 
 @endcode
 
 提示：长按关于并读界面可以查看App版本、设备型号、系统版本、运营商、网络环境、编译时间等信息，便于快速解决用户反馈的信息。
 
 相关教程：
 - <A HREF="http://www.runscriptbuildphase.com">How to Add a Run Script Build Phase</A>
 
*/
