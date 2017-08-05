#define UIFUNCTIONS_NOT_C
#import "../EmojiLibrary/Header.h"
#import "PSEmojiLayout.h"
#import <UIKit/UIScreen+Private.h>
#import <UIKit/UIPeripheralHost.h>

@implementation PSEmojiLayout

+ (BOOL)isPortrait {
 #if !__LP64__
    if (!isiOS6Up)
        return ![NSClassFromString(@"UIKeyboardLayoutEmoji") isLandscape];
 #endif
    NSInteger orientation = [UIKeyboardImpl.activeInstance interfaceOrientation];
    return orientation == 1 || orientation == 2;
}

+ (UIKeyboardEmojiScrollView *)emojiScrollView {
    return isiOS6Up ? (UIKeyboardEmojiScrollView *)[NSClassFromString(@"UIKeyboardEmojiInputController") activeInputView] : (UIKeyboardEmojiScrollView *)[[NSClassFromString(@"UIKeyboardLayoutEmoji") emojiLayout] valueForKey:@"_emojiView"];
}

+ (CGSize)emojiScrollViewSize {
    return [self emojiScrollView].frame.size;
}

+ (CGSize)emojiSize:(BOOL)portrait {
    return [NSClassFromString(@"UIKeyboardEmojiGraphics") emojiSize:portrait];
}

+ (CGPoint)margin:(BOOL)portrait {
    return CGPointMake(MARGIN, [self dotHeight] + (IS_IPAD ? ADDITIONAL_IPAD : ADDITIONAL));
}

+ (CGFloat)offset:(BOOL)portrait {
    return isiOS7Up ? [NSClassFromString(@"UIKeyboardEmojiGraphics") emojiPageControlYOffset:portrait] : DEFAULT_OFFSET;
}

+ (CGFloat)dotHeight {
    CGFloat height = 0.0;
    UIKeyboardEmojiScrollView *scrollView = [self emojiScrollView];
    if (scrollView) {
        _UIEmojiPageControl *pageControl = (_UIEmojiPageControl *)[scrollView valueForKey:@"_pageControl"];
        height = pageControl ? pageControl.frame.size.height : [pageControl _pageIndicatorImage].size.height;
    }
    return height == 0.0 ? DOT_HEIGHT : height;
}

+ (CGFloat)_scrollViewHeight:(BOOL)portrait {
    return [self scrollViewHeight:portrait ? @"" : @"Landscape"];
}

+ (CGFloat)keyboardWidth:(BOOL)portrait {
    if (isiOS8Up)
        return [(UIPeripheralHost *)[NSClassFromString(@"UIPeripheralHost") sharedInstance] transformedContainerView].bounds.size.width;
    CGRect screenRect = UIScreen.mainScreen.bounds;
    return portrait ? screenRect.size.width : screenRect.size.height;
}

+ (NSInteger)bestRowForLandscape {
    return IS_IPAD ? BEST_ROW_IPAD : BEST_ROW;
}

+ (NSInteger)bestColForLandscape {
    if (IS_IPAD)
        return BEST_COL_IPAD;
    CGFloat w = [self keyboardWidth:NO];
    if (w >= 736.0)
        return BEST_COL_6S;
    if (w >= 568.0)
        return BEST_COL_NON4S;
    return BEST_COL;
}

+ (CGFloat)paddingX:(BOOL)portrait col:(NSInteger)col row:(NSInteger)row {
    CGFloat w = [self keyboardWidth:portrait];
    NSInteger _col = portrait ? col : [self bestColForLandscape];
    CGFloat padding = (w - (2 * [self margin:portrait].x) - (_col * [self emojiSize:portrait].width)) / (_col - 1);
    return padding;
}

+ (CGFloat)paddingY:(BOOL)portrait col:(NSInteger)col row:(NSInteger)row {
    CGFloat h = [self _scrollViewHeight:portrait];
    NSInteger _row = portrait ? row : [self bestRowForLandscape];
    CGFloat padding = (h - [self offset:portrait] - [self margin:portrait].y - (_row * [self emojiSize:portrait].height)) / (_row - 1);
    if (IS_IPAD)
        padding *= 0.9;
    return padding;
}

+ (CGPoint)padding:(BOOL)portrait col:(NSInteger)col row:(NSInteger)row {
    CGPoint point = CGPointMake([self paddingX:portrait col:col row:row], [self paddingY:portrait col:col row:row]);
    return point;
}

@end
