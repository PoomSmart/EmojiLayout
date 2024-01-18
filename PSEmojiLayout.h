#import <EmojiLibrary/Header.h>
#import "../../PSPrefs/PSPrefs.x"

#define DEFAULT_OFFSET 6.0
#define MARGIN 8.5
#define MARGIN_IPAD 10.0
#define MARGIN_IPAD_PORTRAIT 12.0
#define MARGIN_BOTTOM 6.0
#define MARGIN_BOTTOM_IPAD 10.0
#define MARGIN_BOTTOM_IPAD_PORTRAIT 14.0
#define DOT_HEIGHT 14.0

#define BEST_ROW_IPAD 5
#define BEST_ROW 3
#define BEST_COL_IPAD 16
#define BEST_COL_6S 15
#define BEST_COL_NON4S 14
#define BEST_COL 12

@interface PSEmojiLayout : NSObject
@end

@interface PSEmojiLayout (Layout)
+ (BOOL)isPortrait;
+ (UIKeyboardEmojiScrollView *)emojiScrollView;
+ (CGSize)emojiSize:(BOOL)portrait;
+ (CGPoint)margin:(BOOL)portrait;
+ (CGPoint)padding:(BOOL)portrait;
+ (CGFloat)paddingX:(BOOL)portrait;
+ (CGFloat)paddingY:(BOOL)portrait;
+ (CGFloat)offset:(BOOL)portrait;
+ (CGFloat)marginBottom:(BOOL)portrait;
+ (CGFloat)dotHeight;
+ (CGFloat)keyboardWidth:(BOOL)portrait;
+ (NSInteger)rowCount:(BOOL)portrait;
+ (NSInteger)colCount:(BOOL)portrait;
+ (NSInteger)bestRowForLandscape;
+ (NSInteger)bestColForLandscape;
@end

@interface PSEmojiLayout (KBResize)
+ (CGFloat)getHeight:(NSString *)name chocoL:(CGFloat)chocoL chocoP:(CGFloat)chocoP truffleL:(CGFloat)truffleL truffleP:(CGFloat)truffleP l:(CGFloat)l p:(CGFloat)p padL:(CGFloat)padL padP:(CGFloat)padP;
+ (CGFloat)barHeight:(NSString *)name;
+ (CGFloat)keyboardHeight:(NSString *)name;
+ (CGFloat)scrollViewHeight:(NSString *)name;
@end

#define SoftPSEmojiLayout NSClassFromString(@"PSEmojiLayout")
