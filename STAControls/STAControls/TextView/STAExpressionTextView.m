//
//  STAExpressionTextView.m
//  STATextField
//
//  Created by Aaron Jubbal on 12/24/14.
//  Copyright (c) 2014 Aaron Jubbal. All rights reserved.
//

#import "STAExpressionTextView.h"
#import "STATextView+PrivateHeaders.h"
#import "NSMutableAttributedString+STAControls.h"
#import "NSAttributedString+STAUtils.h"
#import "NSMutableAttributedString+STAUtils.h"
#import "UITextView+STAControls.h"

@interface STAExpressionTextView ()

@property (assign) BOOL internallyChangingSelection;

@end

@implementation STAExpressionTextView

- (void)setSelectedRange:(NSRange)selectedRange {
    [super setSelectedRange:selectedRange];
    NSLog(@"set range %@", NSStringFromRange(selectedRange));
}

- (void)setSelectedTextRange:(UITextRange *)selectedTextRange {
    [super setSelectedTextRange:selectedTextRange];
    
    NSLog(@"text range: %@", selectedTextRange);
    
    __block NSRange foundRange = {NSNotFound, NSNotFound};
    
    NSRange selectedRange= self.selectedRange;
    NSRange convertedSelectedTextRange = [self selectedTextRangeToRange];
    NSLog(@"=== range %@", NSStringFromRange(convertedSelectedTextRange));
//    NSMutableAttributedString *subStringLeftOfCursor = [[self.attributedText attributedSubstringFromRange:NSMakeRange(0, self.selectedRange.location)] mutableCopy];
    NSMutableAttributedString *subStringLeftOfCursor = [self.attributedText mutableCopy];
    [subStringLeftOfCursor enumerateAttribute:NSForegroundColorAttributeName inRange:NSMakeRange(0, convertedSelectedTextRange.location) options:0
                                   usingBlock:^(id value, NSRange range, BOOL *stop) {
                                       if (value) {
                                           foundRange = range;
                                           UIColor *fontColor = (UIColor *)value;
                                           if ([fontColor isEqual:[UIColor grayColor]]) {
                                               //                 [subStringLeftOfCursor removeAttribute:NSForegroundColorAttributeName range:NSMakeRange(self.selectedRange.location, 1)];
                                               //                 [subStringLeftOfCursor addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(self.selectedRange.location, 1)];
                                               
                                               
                                               *stop = YES;
                                           }
                                       }
                                   }];
    if (foundRange.location != NSNotFound) {
        [subStringLeftOfCursor setAttributes:@{NSForegroundColorAttributeName : [UIColor blackColor],
                                               NSFontAttributeName : self.font}
                                       range:foundRange];
    }
    self.attributedText = subStringLeftOfCursor;
    self.selectedRange = selectedRange;
}
/*
- (void)textViewDidChangeSelection:(UITextView *)textView {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    if (self.internallyChangingSelection) {
        return;
    }
    
//    NSRange initialSelectedRange = self.selectedRange;
    NSLog(@"my range is %@", NSStringFromRange(self.selectedRange));
    __block NSRange foundRange = {NSNotFound, NSNotFound};
    
//    NSMutableAttributedString *subStringLeftOfCursor = [[self.attributedText attributedSubstringFromRange:NSMakeRange(0, self.selectedRange.location)] mutableCopy];
    NSMutableAttributedString *subStringLeftOfCursor = [self.attributedText mutableCopy];
    [subStringLeftOfCursor enumerateAttribute:NSForegroundColorAttributeName inRange:NSMakeRange(0, self.selectedRange.location) options:0
     usingBlock:^(id value, NSRange range, BOOL *stop) {
         if (value) {
             foundRange = range;
             UIColor *fontColor = (UIColor *)value;
             if ([fontColor isEqual:[UIColor grayColor]]) {
//                 [subStringLeftOfCursor removeAttribute:NSForegroundColorAttributeName range:NSMakeRange(self.selectedRange.location, 1)];
//                 [subStringLeftOfCursor addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(self.selectedRange.location, 1)];
                 
                 
                 *stop = YES;
             }
         }
     }];
    if (foundRange.location != NSNotFound) {
        [subStringLeftOfCursor setAttributes:@{NSForegroundColorAttributeName : [UIColor blackColor],
                                               NSFontAttributeName : self.font}
                                       range:NSMakeRange(foundRange.location, 1)];
    }
    
//    self.selectedRange = initialSelectedRange;
    self.attributedText = subStringLeftOfCursor;
//    self.internallyChangingSelection = YES;
//    [self performSelector:@selector(setInternallyChangingSelection:) withObject:@NO afterDelay:0.01];
}*/

- (NSMutableAttributedString *)attributedStringByReplacingCharactersInRange:(NSRange)range withString:(NSString *)newString {
    
//    self.internallyChangingSelection = YES;
    
    NSRange limitRange;
    limitRange = NSMakeRange(0, [self.attributedText length]);
    
    NSMutableAttributedString *attributedString;
    if (!self.attributedText) {
        NSString *newText = [self.text stringByReplacingCharactersInRange:range withString:newString];
        attributedString = [[NSMutableAttributedString alloc] initWithString:newText
                                                                  attributes:@{NSFontAttributeName : self.font}];
//        self.internallyChangingSelection = NO;
        return attributedString;
    } else {
        attributedString = [self.attributedText mutableCopy];
    }
    [attributedString enumerateAttributesInRange:limitRange
                                         options:0
                                      usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
                                          if (attrs) {
//                                              [attributedString removeAttributesInDictionary:attrs forRange:range];
                                          }
                                      }];
//    self.internallyChangingSelection = NO;
    return attributedString;
}

- (NSAttributedString *)textView:(UITextView *)textView
attributedStringForChangeOfTextinRange:(NSRange)range
                 replacementText:(NSString *)text
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    self.internallyChangingSelection = YES;
    
    if (text.length == 0) { // deletion
        if ([[[self.attributedText characterLeftOfLocation:self.selectedRange.location] string] isEqualToString:@"("]) {
            
            NSMutableAttributedString *mutableAttributedString = [self.attributedText mutableCopy];
            [mutableAttributedString removeFirstOccuranceOfSubstring:@")"
                                                      beyondLocation:self.selectedRange.location];
            self.attributedText = mutableAttributedString;
            self.selectedRange = NSMakeRange(range.location, range.length);
        }
        self.internallyChangingSelection = NO;
        return nil;
    }
    
    NSString *newText = [self.text stringByReplacingCharactersInRange:range withString:text];
    
    NSMutableAttributedString *attributedString;
    NSCharacterSet *expressionCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789.+-*/()"];
    if (text.length > 0 && [expressionCharacterSet characterIsMember:[text characterAtIndex:0]]) {
        if ([text isEqualToString:@"("]) {
            newText = [newText stringByAppendingString:@")"];
            
            if (self.attributedText.length == 0) {
                attributedString = [[NSMutableAttributedString alloc] initWithString:newText
                                                                          attributes:@{NSFontAttributeName : self.font}];
            } else {
                NSMutableAttributedString *mutableAttributedString = [self.attributedText mutableCopy];
                [mutableAttributedString replaceCharactersInRange:range withString:text];
                [mutableAttributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@")"
                                                                                                       attributes:@{NSFontAttributeName : self.font,
                                                                                                                    NSForegroundColorAttributeName : [UIColor grayColor]}]];
                attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:mutableAttributedString];
            }
            [attributedString addAttribute:NSForegroundColorAttributeName
                                     value:[UIColor grayColor]
                                     range:NSMakeRange(attributedString.length - 1, 1)];
            self.attributedText = attributedString;
            self.selectedRange = NSMakeRange(range.location + 1, range.length);
        } else if ([text isEqualToString:@")"]) { // consume grayed-out ")"
            
            NSAttributedString *characterRightOfSelected = [self.attributedText characterRightOfLocation:self.selectedRange.location - 1];
            UIColor *foregroundColor = (UIColor *)[characterRightOfSelected attribute:NSForegroundColorAttributeName atIndex:0 effectiveRange:NULL];
            if ([[characterRightOfSelected string] isEqualToString:@")"] && [foregroundColor isEqual:[UIColor grayColor]]) {
                NSMutableAttributedString *mutableAttributedString = [self.attributedText mutableCopy];
                [mutableAttributedString setAttributes:@{NSForegroundColorAttributeName : [UIColor blackColor],
                                                         NSFontAttributeName : self.font}
                                                 range:NSMakeRange(self.selectedRange.location, 1)];
                self.attributedText = mutableAttributedString;
                self.selectedRange = NSMakeRange(range.location + 1, range.length);
            } else {
                NSMutableAttributedString *mutableAttributedString = [self.attributedText mutableCopy];
                [mutableAttributedString replaceCharactersInRange:range withString:text];
                self.attributedText = mutableAttributedString;
                self.selectedRange = NSMakeRange(range.location + 1, range.length);
            }
            
        } else {
            NSMutableAttributedString *mutableAttributedString = [self.attributedText mutableCopy];
            [mutableAttributedString replaceCharactersInRange:range withString:text];
            self.attributedText = mutableAttributedString;
        }
    }
    self.internallyChangingSelection = NO;
    return attributedString;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    [super textView:textView shouldChangeTextInRange:range replacementText:text];
    
    NSString *oldText = self.text;
    NSString *newText = [self.text stringByReplacingCharactersInRange:range withString:text];
    
    NSRange limitRange;
    NSRange effectiveRange;
    limitRange = NSMakeRange(0, [self.attributedText length]);
    
    NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc] initWithString:newText
                                                                                                attributes:@{NSFontAttributeName : self.font}];
    
    if (text.length == 0) return YES; // deletion case
    
    NSCharacterSet *expressionCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789.+-*/()"];
    
    return NO;
}

- (void)textViewDidChange:(UITextView *)textView {
    NSLog(@"selected range: %@", NSStringFromRange(self.selectedRange));
    
    
}

@end
