#ifndef Constants_Font_h
#define Constants_Font_h

///-----------------------------------------------------------------------------
/// @name 字体大小
///-----------------------------------------------------------------------------
#pragma mark - 字体大小 -

#define FONT_SIZE_SYSTEM(v) [UIFont systemFontOfSize:v]

#define FONT_SIZE_10 FONT_SIZE_SYSTEM(10)

#define FONT_SIZE_11 FONT_SIZE_SYSTEM(11)

#define FONT_SIZE_12 FONT_SIZE_SYSTEM(12)

#define FONT_SIZE_13 FONT_SIZE_SYSTEM(13)

#define FONT_SIZE_14 FONT_SIZE_SYSTEM(14)

#define FONT_SIZE_15 FONT_SIZE_SYSTEM(15)

#define FONT_SIZE_16 FONT_SIZE_SYSTEM(16)

#define FONT_SIZE_17 FONT_SIZE_SYSTEM(17)

///-----------------------------------------------------------------------------
/// @name 单行UILabel的高度
///-----------------------------------------------------------------------------
#pragma mark - 单行UILabel的高度 -

#define LABEL_HEIGHT_FONT_SIZE_11 14

#define LABEL_HEIGHT_FONT_SIZE_12 15

#define LABEL_HEIGHT_FONT_SIZE_13 16

#define LABEL_HEIGHT_FONT_SIZE_14 17

#define LABEL_HEIGHT_FONT_SIZE_15 18

#define LABEL_HEIGHT_FONT_SIZE_16 20

#define LABEL_HEIGHT_FONT_SIZE_17 21

/** 从字体配置文件读取 */
#define FONT_SIZE(primaryKey, secondaryKey) [ZWFontManager sizeWithPrimaryKey:primaryKey andSecondaryKey:secondaryKey]

#endif
