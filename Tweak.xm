#define CHECK_TARGET
#import "../PS.h"
#import "../EmojiLibrary/Header.h"
#import "../EmojiLibrary/PSEmojiUtilities.h"
#import "../PSPrefs.x"
#import <CoreText/CoreText.h>
#import <UIKit/UIScreen+Private.h>
#import <UIKit/UIPeripheralHost.h>

//CGFloat emoSize;
NSInteger row;
NSInteger col;
CGFloat margin = 8.5;
CGFloat (*UIKBKeyboardDefaultPortraitWidth)();
CGFloat (*UIKBKeyboardDefaultLandscapeWidth)();

static UIKeyboardEmojiScrollView *emojiScrollView() {
    return isiOS6Up ? (UIKeyboardEmojiScrollView *)[%c(UIKeyboardEmojiInputController) activeInputView] : (UIKeyboardEmojiScrollView *)[[%c(UIKeyboardLayoutEmoji) emojiLayout] valueForKey:@"_emojiView"];;
}

static CGSize emojiSize(BOOL portrait) {
    return [%c(UIKeyboardEmojiGraphics) emojiSize:portrait];
}

static CGSize emojiScrollViewSize() {
    UIKeyboardEmojiScrollView *scrollView = emojiScrollView();
    return scrollView ? scrollView.frame.size : CGSizeZero;
}

static CGFloat dotHeight() {
    CGFloat height = 0.0;
    UIKeyboardEmojiScrollView *scrollView = emojiScrollView();
    if (scrollView) {
        _UIEmojiPageControl *pageControl = MSHookIvar<_UIEmojiPageControl *>(scrollView, "_pageControl");
        height = pageControl ? pageControl.frame.size.height : [pageControl _pageIndicatorImage].size.height;
    }
    return height == 0.0 ? 14.0 : height;
}

static CGFloat keyboardHeight() {
    CGFloat height = emojiScrollViewSize().height;
    if (height == 0.0) {
        UIKeyboard *keyboard = [UIKeyboard activeKeyboard];
        if (keyboard)
            height = keyboard.frame.size.height - 30.0;
    }
    return height;
}

static CGFloat portraitKeyboardWidth() {
    if (UIKBKeyboardDefaultPortraitWidth)
        return UIKBKeyboardDefaultPortraitWidth();
    return [UIKeyboardImpl defaultSizeForInterfaceOrientation:1].width;
}

static CGFloat landscapeKeyboardWidth() {
    if (UIKBKeyboardDefaultLandscapeWidth)
        return UIKBKeyboardDefaultLandscapeWidth();
    if (!isiOS6Up)
        return UIScreen.mainScreen.bounds.size.height;
    return [(UIPeripheralHost *)[%c(UIPeripheralHost) sharedInstance] transformedContainerView].bounds.size.width;
}

static CGFloat offset(BOOL portrait) {
    return isiOS7Up ? [%c(UIKeyboardEmojiGraphics) emojiPageControlYOffset: portrait] : 6.0;
}

static CGFloat paddingXForPortrait() {
    CGFloat w = portraitKeyboardWidth();
    CGFloat padding = (w - (2 * margin) - (col * emojiSize(YES).width)) / (col - 1);
    return padding;
}

static CGFloat paddingYForPortrait() {
    CGFloat h = keyboardHeight();
    CGFloat padding = (h - offset(YES) - dotHeight() - (2 * margin) - (row * emojiSize(YES).height)) / (row - 1);
    if (IS_IPAD)
        padding -= 3.0;
    return padding;
}

static BOOL isPortrait() {
    if (!isiOS6Up)
        return ![NSClassFromString(@"UIKeyboardLayoutEmoji") isLandscape];
    UIKeyboardImpl *impl = [UIKeyboardImpl activeInstance];
    NSInteger orientation = MSHookIvar<NSInteger>(impl, "m_orientation");
    return orientation == 1 || orientation == 2;
}

static NSInteger bestRowForLandscape() {
    if (IS_IPAD)
        return 5;
    CGFloat h = keyboardHeight();
    CGFloat paddingX = paddingXForPortrait();
    CGFloat u = h - offset(YES) - dotHeight() - margin + paddingX;
    CGFloat d = emojiSize(NO).height + paddingX;
#if CGFLOAT_IS_DOUBLE
    NSInteger bestRow = round(u/d);
#else
    NSInteger bestRow = roundf(u/d);
#endif
    if (isiOS8Up && [[UIScreen mainScreen] _interfaceOrientedBounds].size.width > 568.0)
        bestRow++;
    return bestRow;
}

static CGFloat paddingYForLandscape() {
    CGFloat h = keyboardHeight();
    NSInteger bestRow = bestRowForLandscape();
    CGFloat padding = (h - offset(NO) - dotHeight() - margin - (bestRow * emojiSize(NO).height)) / (bestRow - 1);
    if (IS_IPAD)
        padding -= 3.0;
    return padding /*- margin*/;
}

static NSInteger bestColForLandscape() {
    if (IS_IPAD)
        return 16;
    CGFloat w = landscapeKeyboardWidth();
    CGFloat px = paddingXForPortrait();
    CGFloat u = (w - (2 * margin) + px);
    CGFloat d = emojiSize(NO).width + px;
#if CGFLOAT_IS_DOUBLE
    NSInteger bestCol = round(u/d);
#else
    NSInteger bestCol = roundf(u/d);
#endif
    return bestCol;
}

static CGFloat paddingXForLandscape() {
    CGFloat w = landscapeKeyboardWidth();
    NSInteger bestCol = bestColForLandscape();
    CGFloat padding = (w - (2 * margin) - (bestCol * emojiSize(NO).width)) / (bestCol - 1);
    return padding;
}

static CGPoint padding(BOOL portrait) {
    CGPoint point;
    if (portrait)
        point = CGPointMake(paddingXForPortrait(), paddingYForPortrait());
    else
        point = CGPointMake(paddingXForLandscape(), paddingYForLandscape());
    if (portrait && !IS_IPAD)
        point.y += 2.0;
    return point;
}

%hook UIKeyboardEmojiGraphics

/*+ (CGSize)emojiSize: (BOOL)portrait {
    return CGSizeMake(emoSize, emoSize);
   }*/

+ (NSInteger)rowCount: (BOOL)portrait {
    return portrait ? row : bestRowForLandscape();
}

+ (NSInteger)colCount:(BOOL)portrait {
    return portrait ? col : bestColForLandscape();
}

+ (CGPoint)padding:(BOOL)portrait {
    return padding(portrait);
}

+ (CGPoint)margin:(BOOL)portrait {
    return CGPointMake(margin, dotHeight() + offset(portrait));
}

%end

BOOL pageZero = NO;

%hook UIKeyboardEmojiPage

- (void)setEmoji: (NSArray <UIKeyboardEmoji *> *)emoji {
    BOOL Portrait = isPortrait();
    BOOL iPadLandscape = IS_IPAD && !Portrait;
    if (emoji.count && !pageZero && (Portrait || iPadLandscape)) {
        NSInteger Row = row;
        NSInteger Col = col;
        if (iPadLandscape) {
            Row = bestRowForLandscape();
            Col = bestColForLandscape();
        }
        NSMutableArray <UIKeyboardEmoji *> *reorderedEmoji = [NSMutableArray array];
        for (NSInteger _row = 0; _row < Row; _row++) {
            for (NSInteger count = 0; count < Col; count++) {
                NSInteger emojiIndex = (count * Row) + _row;
                if (emojiIndex < emoji.count) {
                    UIKeyboardEmoji *emo = [emoji objectAtIndex:emojiIndex];
                    [reorderedEmoji addObject:emo];
                } else
                    [reorderedEmoji addObject:[SoftPSEmojiUtilities emojiWithString:@""]];
            }
        }
        if (reorderedEmoji.count > 0) {
            %orig(reorderedEmoji);
            return;
        }
    }
    %orig;
}

- (UIKeyboardEmojiView *)closestForPoint:(CGPoint)point {
    UIKeyboardEmojiView *orig = %orig;
    return orig && orig.emoji.emojiString.length == 0 ? nil : orig;
}

%end

%hook UIKeyboardEmojiScrollView

- (void)layoutRecents {
    pageZero = YES;
    %orig;
    pageZero = NO;
}

- (void)layoutPages {
    if (MSHookIvar<NSInteger>(self, "_currentPage") >= MSHookIvar<NSMutableArray *>(self, "_pages").count)
        MSHookIvar<NSInteger>(self, "_currentPage") = 0;
    %orig;
}

%end

%group iOS6Up

%hook UIKeyboardEmojiInputController

- (void)emojiUsed: (UIKeyboardEmoji *)emoji {
    NSString *emojiString = emoji.emojiString;
    if (!emojiString || [emojiString isEqualToString:@""])
        return;
    if (isiOS7Up && [emoji hasDingbat])
        emojiString = [NSString stringWithFormat:@"%@%@", emojiString, FE0F];
    UIKeyboardImpl *kbImpl = [UIKeyboardImpl sharedInstance];
    if ([kbImpl acceptInputString:emojiString]) {
        if (isiOS7Up) {
            [kbImpl.taskQueue addTask:^{
                [kbImpl addInputString:emojiString withFlags:0 executionContext:kbImpl.taskQueue.executionContext];
            }];
        } else
            [kbImpl addInputString:emojiString fromVariantKey:0];
    }
    #define usageHistory MSHookIvar<NSMutableDictionary *>(self, "_usageHistory")
    UIKeyboardEmojiDefaultsController *emojiDefaultsController = [%c(UIKeyboardEmojiDefaultsController) sharedController];
    if (usageHistory == nil) {
        id usageHistoryKey = emojiDefaultsController.usageHistoryKey;
        if (usageHistoryKey != nil)
            usageHistory = (NSMutableDictionary *)CFPropertyListCreateDeepCopy(kCFAllocatorDefault, (CFPropertyListRef)usageHistoryKey, kCFPropertyListMutableContainersAndLeaves);
        else
            usageHistory = [[NSMutableDictionary alloc] initWithCapacity:10];
    }
    #define recents MSHookIvar<NSMutableArray *>(self, "_recents")
    if (recents == nil) {
        id recentsKey = emojiDefaultsController.recentsKey;
        if (recentsKey != nil)
            recents = (NSMutableArray *)CFPropertyListCreateDeepCopy(kCFAllocatorDefault, (CFPropertyListRef)recentsKey, kCFPropertyListMutableContainersAndLeaves);
        else
            recents = [[NSMutableArray alloc] initWithCapacity:10];
    }
    #define currentSequence MSHookIvar<NSInteger>(self, "_currentSequence")
    emojiDefaultsController.currentSequenceKey = currentSequence;
    NSNumber *sequence_num = [NSNumber numberWithInt:currentSequence++];
    NSString *emojiString2 = emoji.emojiString;
    NSMutableArray *emojiInHistory = usageHistory[emojiString2];
    if (emojiInHistory == nil)
        emojiInHistory = [NSMutableArray arrayWithCapacity:0];
    [emojiInHistory addObject:sequence_num];
    [usageHistory setObject:emojiInHistory forKey:emojiString2];
    emojiDefaultsController.usageHistoryKey = usageHistory;
    double scoreForEmoji = [self scoreForEmoji:emoji];
    NSUInteger recentsCount = recents.count;
    NSUInteger maxCount = [%c(UIKeyboardEmojiGraphics) rowCount:YES] * [%c(UIKeyboardEmojiGraphics) colCount: YES];
    NSUInteger indexOfEmojiToBeRemoved = [recents indexOfObject:emoji];
    if (recentsCount > 0 && indexOfEmojiToBeRemoved != NSNotFound)
        [recents removeObjectAtIndex:indexOfEmojiToBeRemoved];
    else if (recentsCount > maxCount) {
        UIKeyboardEmoji *lastRecentEmoji = [recents lastObject];
        double scoreOfLastRecentEmoji = [self scoreForEmoji:lastRecentEmoji];
        if (scoreForEmoji > scoreOfLastRecentEmoji)
            [recents removeLastObject];
    }
    NSUInteger idx = 0;
    if (recentsCount > 0) {
        do {
            UIKeyboardEmoji *emojiAtIndex = recents[idx];
            double scoreOfEmojiAtIndex = [self scoreForEmoji:emojiAtIndex];
            if (scoreForEmoji > scoreOfEmojiAtIndex)
                break;
        } while (++idx != recentsCount);
    }
    [recents insertObject:emoji atIndex:idx];
    emojiDefaultsController.recentsKey = recents;
    ((UIKeyboardEmojiCategory *)[%c(UIKeyboardEmojiCategory) categoryForType : 0]).emoji = recents;
}

%end

%end

%group iOS7Up

%hook _UIEmojiPageControl

- (void)layoutSubviews {
    self.hidesForSinglePage = NO;
    %orig;
}

%end

%hook UIKeyboardEmojiCategory

+ (NSUInteger)hasVariantsForEmoji: (NSString *)emoji {
    if (!emoji || [emoji isEqualToString:@""])
        return NO;
    return %orig;
}

%end

%end

%group iOS56

%hook EmojiPageControl

- (void)layoutSubviews {
    self.hidesForSinglePage = NO;
    %orig;
}

%end

BOOL draw = NO;

%hook UIKeyboardEmojiPage

- (void)drawRect: (CGRect)rect {
    draw = YES;
    %orig;
    draw = NO;
}

%end

%hookf(void, CTFontDrawGlyphs, CTFontRef font, const CGGlyph glyphs[], const CGPoint positions[], size_t count, CGContextRef context) {
    if (draw && glyphs[0] == 0)
        return;
    %orig;
}

%end

static const NSString *tweakIdentifier = @"com.PS.EmojiLayout";
static const NSString *colKey = @"columns";
static const NSString *rowKey = @"rows";
//static const NSString *emoSizeKey = @"size";

HaveCallback() {
    GetPrefs()
    GetInt2(col, IS_IPAD ? 12 : 8)
    GetInt2(row, IS_IPAD ? 3 : 5)
    //GetCGFloat2(emoSize, 16.0)
}

%ctor {
    if (isTarget(TargetTypeGUINoExtension)) {
        HaveObserver();
        callback();
        dlopen("/usr/lib/libEmojiLibrary.dylib", RTLD_LAZY);
        MSImageRef ref = MSGetImageByName(realPath2(@"/System/Library/Frameworks/UIKit.framework/UIKit"));
        UIKBKeyboardDefaultPortraitWidth = (CGFloat (*)())MSFindSymbol(ref, "_UIKBKeyboardDefaultPortraitWidth");
        if (!isiOS8Up)
            UIKBKeyboardDefaultLandscapeWidth = (CGFloat (*)())MSFindSymbol(ref, "_UIKBKeyboardDefaultLandscapeWidth");
        if (isiOS6Up) {
            %init(iOS6Up);
        }
        if (isiOS7Up) {
            %init(iOS7Up);
        } else {
            %init(iOS56);
        }
        %init;
    }
}
