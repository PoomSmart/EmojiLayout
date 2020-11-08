#import "../EmojiLibrary/Header.h"
#import "PSEmojiLayout.h"
#import <UIKit/UIScreen+Private.h>
#import <UIKit/UIKeyboardImpl.h>
#import <UIKit/UIPeripheralHost.h>
#import <theos/IOSMacros.h>
#import <version.h>

@implementation PSEmojiLayout

+ (BOOL)isPortrait {
    NSInteger orientation = [UIKeyboardImpl.activeInstance interfaceOrientation];
    return orientation == 1 || orientation == 2;
}

+ (UIKeyboardEmojiScrollView *)emojiScrollView {
    return (UIKeyboardEmojiScrollView *)[NSClassFromString(@"UIKeyboardEmojiInputController") activeInputView];
}

+ (NSInteger)rowCount:(BOOL)portrait {
    return [NSClassFromString(@"UIKeyboardEmojiGraphics") rowCount:portrait];
}

+ (NSInteger)colCount:(BOOL)portrait {
    return [NSClassFromString(@"UIKeyboardEmojiGraphics") colCount:portrait];
}

+ (CGSize)emojiSize:(BOOL)portrait {
    return [NSClassFromString(@"UIKeyboardEmojiGraphics") emojiSize:portrait];
}

+ (CGPoint)margin:(BOOL)portrait {
    return CGPointMake(IS_IPAD ? (portrait ? MARGIN_IPAD_PORTRAIT : MARGIN_IPAD) : MARGIN, [self dotHeight]);
}

+ (CGFloat)marginBottom:(BOOL)portrait {
    return IS_IPAD ? (portrait ? MARGIN_BOTTOM_IPAD_PORTRAIT : MARGIN_BOTTOM_IPAD) : MARGIN_BOTTOM;
}

+ (CGFloat)offset:(BOOL)portrait {
    return IS_IOS_OR_NEWER(iOS_7_0) ? [NSClassFromString(@"UIKeyboardEmojiGraphics") emojiPageControlYOffset:portrait] : DEFAULT_OFFSET;
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

+ (CGFloat)_screenWidth {
    CGSize screenSize = UIScreen.mainScreen.bounds.size;
    return MIN(screenSize.width, screenSize.height);
}

+ (CGFloat)_scrollViewHeight:(BOOL)portrait {
    NSString *type = portrait ? @"" : @"Landscape";
    if (!IS_IPAD) {
        CGFloat screenWidth = [self _screenWidth];
        if (screenWidth >= 414.0)
            type = [type stringByAppendingString:@"Truffle"];
        else if (screenWidth >= 375.0)
            type = [type stringByAppendingString:@"Choco"];
    }
    return [self scrollViewHeight:type];
}

+ (CGFloat)keyboardWidth:(BOOL)portrait {
    if (IS_IOS_OR_NEWER(iOS_8_0))
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

+ (CGFloat)paddingX:(BOOL)portrait {
    CGFloat w = [self keyboardWidth:portrait];
    NSInteger col = [self colCount:portrait];
    CGFloat padding = (w - (2 * [self margin:portrait].x) - (col * [self emojiSize:portrait].width)) / (col - 1);
    return padding;
}

+ (CGFloat)paddingY:(BOOL)portrait {
    CGFloat h = [self _scrollViewHeight:portrait];
    NSInteger row = [self rowCount:portrait];
    CGFloat padding = (h - [self margin:portrait].y - [self offset:portrait] - [self marginBottom:portrait] - (row * [self emojiSize:portrait].height)) / (row - 1);
    return padding;
}

+ (CGPoint)padding:(BOOL)portrait {
    return CGPointMake([self paddingX:portrait], [self paddingY:portrait]);
}

@end
