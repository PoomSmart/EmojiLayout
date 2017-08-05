#import "../EmojiLibrary/Header.h"

#define ADDITIONAL_IPAD 14.0
#define ADDITIONAL 5.0
#define DEFAULT_OFFSET 6.0
#define MARGIN 8.5
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
+ (CGSize)emojiScrollViewSize;
+ (CGSize)emojiSize:(BOOL)portrait;
+ (CGPoint)margin:(BOOL)portrait;
+ (CGPoint)padding:(BOOL)portrait col:(NSInteger)col row:(NSInteger)row;
+ (CGFloat)paddingX:(BOOL)portrait col:(NSInteger)col row:(NSInteger)row;
+ (CGFloat)paddingY:(BOOL)portrait col:(NSInteger)col row:(NSInteger)col;
+ (CGFloat)offset:(BOOL)portrait;
+ (CGFloat)dotHeight;
+ (CGFloat)keyboardWidth:(BOOL)portrait;
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
