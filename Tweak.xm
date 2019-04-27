#define CHECK_TARGET
#import "../PS.h"
#import "../EmojiLibrary/PSEmojiUtilities.h"
#import "../PSPrefs.x"
#import "PSEmojiLayout.h"
#import <UIKit/UIKeyboardImpl.h>
#import <CoreText/CoreText.h>

NSInteger row, col;

%hook UIKeyboardEmojiGraphics

+ (NSInteger)rowCount:(BOOL)portrait {
    return portrait ? row : [PSEmojiLayout bestRowForLandscape];
}

+ (NSInteger)colCount:(BOOL)portrait {
    return portrait ? col : [PSEmojiLayout bestColForLandscape];
}

+ (CGPoint)padding:(BOOL)portrait {
    return [PSEmojiLayout padding:portrait];
}

+ (CGPoint)margin:(BOOL)portrait {
    return [PSEmojiLayout margin:portrait];
}

%end

BOOL pageZero = NO;

%hook UIKeyboardEmojiPage

- (void)setEmoji:(NSArray <UIKeyboardEmoji *> *)emoji {
    BOOL portrait = NO;
    if (!pageZero && emoji.count && ((portrait = [PSEmojiLayout isPortrait]) || IS_IPAD)) {
        NSInteger Row = [NSClassFromString(@"UIKeyboardEmojiGraphics") rowCount:portrait];
        NSInteger Col = [NSClassFromString(@"UIKeyboardEmojiGraphics") colCount:portrait];
        NSMutableArray <UIKeyboardEmoji *> *reorderedEmoji = [NSMutableArray array];
        for (NSInteger i = 0; i < Row; i++) {
            for (NSInteger count = 0; count < Col; count++) {
                NSInteger emojiIndex = (count * Row) + i;
                [reorderedEmoji addObject:emojiIndex < emoji.count ? [emoji objectAtIndex:emojiIndex] : [SoftPSEmojiUtilities emojiWithString:@""]];
            }
        }
        if (reorderedEmoji.count) {
            %orig(reorderedEmoji);
            return;
        }
    }
    %orig;
}

- (UIKeyboardEmojiView *)closestForPoint:(CGPoint)point {
    UIKeyboardEmojiView *orig = %orig;
    return orig.emoji.emojiString.length == 0 ? nil : orig;
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

- (void)emojiUsed:(UIKeyboardEmoji *)emoji {
    NSString *emojiString = emoji.emojiString;
    if (!emojiString || [emojiString isEqualToString:@""])
        return;
    if ([emoji respondsToSelector:@selector(hasDingbat)] && [emoji hasDingbat])
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
        if (usageHistoryKey)
            usageHistory = (NSMutableDictionary *)CFPropertyListCreateDeepCopy(kCFAllocatorDefault, (CFPropertyListRef)usageHistoryKey, kCFPropertyListMutableContainersAndLeaves);
        else
            usageHistory = [[NSMutableDictionary alloc] initWithCapacity:10];
    }
    #define recents MSHookIvar<NSMutableArray *>(self, "_recents")
    if (recents == nil) {
        id recentsKey = emojiDefaultsController.recentsKey;
        if (recentsKey)
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
    if (recentsCount && indexOfEmojiToBeRemoved != NSNotFound)
        [recents removeObjectAtIndex:indexOfEmojiToBeRemoved];
    else if (recentsCount > maxCount) {
        UIKeyboardEmoji *lastRecentEmoji = [recents lastObject];
        double scoreOfLastRecentEmoji = [self scoreForEmoji:lastRecentEmoji];
        if (scoreForEmoji > scoreOfLastRecentEmoji)
            [recents removeLastObject];
    }
    NSUInteger idx = 0;
    if (recentsCount) {
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

+ (NSUInteger)hasVariantsForEmoji:(NSString *)emoji {
    if (!emoji || [emoji isEqualToString:@""])
        return NO;
    return %orig;
}

%end

%end

#if !__LP64__

%group iOS56

%hook EmojiPageControl

- (void)layoutSubviews {
    self.hidesForSinglePage = NO;
    %orig;
}

%end

BOOL draw = NO;

%hook UIKeyboardEmojiPage

- (void)drawRect:(CGRect)rect {
    draw = YES;
    %orig;
    draw = NO;
}

%end

%end

%group iOS6

%hookf(void, CTFontDrawGlyphs, CTFontRef font, const CGGlyph glyphs[], const CGPoint positions[], size_t count, CGContextRef context) {
    if (draw && glyphs[0] == 0)
        return;
    %orig;
}

%end

#endif

static const NSString *tweakIdentifier = @"com.PS.EmojiLayout";
static const NSString *colKey = @"columns";
static const NSString *rowKey = @"rows";

HaveCallback() {
    GetPrefs();
    GetInt2(col, IS_IPAD ? 12 : 8);
    GetInt2(row, IS_IPAD ? 3 : 5);
}

%ctor {
    if (isTarget(TargetTypeApps)) {
        HaveObserver();
        callback();
#if !TARGET_OS_SIMULATOR
        dlopen("/usr/lib/libEmojiLibrary.dylib", RTLD_LAZY);
#endif
        if (isiOS6Up) {
            %init(iOS6Up);
        }
        if (isiOS7Up) {
            %init(iOS7Up);
        }
#if !__LP64__
        else {
            %init(iOS56);
            if (isiOS6) {
                %init(iOS6);
            }
        }
#endif
        %init;
    }
}
