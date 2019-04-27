#import "PSEmojiLayout.h"

@implementation PSEmojiLayout (KBResize)

+ (CGFloat)getHeight:(NSString *)name chocoL:(CGFloat)chocoL chocoP:(CGFloat)chocoP truffleL:(CGFloat)truffleL truffleP:(CGFloat)truffleP l:(CGFloat)l p:(CGFloat)p padL:(CGFloat)padL padP:(CGFloat)padP {
    CGFloat height = 0.0;
    BOOL isLandscape = [name rangeOfString:@"Landscape"].location != NSNotFound || [name rangeOfString:@"Caymen"].location != NSNotFound || (!isiOS7Up && [name rangeOfString:@"3587139855"].location != NSNotFound);
    if ([name rangeOfString:@"Choco"].location != NSNotFound) {
        // iPhone 6
        height = isLandscape ? chocoL : chocoP;
    } else if ([name rangeOfString:@"Truffle"].location != NSNotFound) {
        // iPhone 6+
        height = isLandscape ? truffleL : truffleP;
    } else {
        // 3.5, 4-inches iDevices or iPad
        if (IS_IPAD)
            height = isLandscape ? padL : padP;
        else
            height = isLandscape ? l : p;
    }
    return height;
}

+ (CGFloat)barHeight:(NSString *)name {
    return [self getHeight:name chocoL:37.0 chocoP:47.0 truffleL:40.0 truffleP:50.0 l:32.0 p:40.0 padL:56.0 padP:56.0];
}

+ (CGFloat)keyboardHeight:(NSString *)name {
    return [self getHeight:name chocoL:194.0 chocoP:258.0 truffleL:194.0 truffleP:271.0 l:162.0 p:253.0 padL:398.0 padP:313.0];
}

+ (CGFloat)scrollViewHeight:(NSString *)name {
    return [self keyboardHeight:name] - [self barHeight:name];
}

@end
