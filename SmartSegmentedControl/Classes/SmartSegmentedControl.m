//
//  SmartSegmentedControl.m
//  SmartSegmentedControl
//
//  Created by Eugene Shevtsov on 07/06/2017.
//  Copyright (c) 2017 Eugene Shevtsov. All rights reserved.
//

#import "SmartSegmentedControl.h"

@interface SmartSegmentedControl ()

@property (nonatomic, strong) NSMutableSet *segmentsIndexesWithExplicitWidthSet;

@end


@implementation SmartSegmentedControl

- (instancetype)init {
    if ((self = [super init])) {
        [self commonInit];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        [self commonInit];
    }
    
    return self;
}


- (void)commonInit {
    self.segmentsIndexesWithExplicitWidthSet = [NSMutableSet set];
    for (int i = 0; i<self.numberOfSegments; i++) {
        if ([self widthForSegmentAtIndex:i]>0.) {
            [_segmentsIndexesWithExplicitWidthSet addObject:@(i)];
        }
    }
}


#pragma mark - overrides to inject new logic

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (_fixNativeProportionalSizing || _smartAdjustment) {
        NSMutableArray *titles = [self widthsForSegmentsTitles].mutableCopy;
        CGFloat width = self.frame.size.width;
        UIImage *dividerImage = nil;
        CGFloat dividerWidth = 1.;
        if ((dividerImage = [self dividerImageForLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault])) {
            dividerWidth = dividerImage.size.width;
        }
        width -= dividerWidth*(self.numberOfSegments-1);
        
        NSArray *segmentIndexes = [_segmentsIndexesWithExplicitWidthSet.allObjects sortedArrayUsingComparator:^NSComparisonResult(NSNumber * _Nonnull obj1, NSNumber * _Nonnull obj2) {
            return [obj2 compare:obj1];
        }];
        for (NSNumber *i in segmentIndexes) {
            if (i.intValue<titles.count) {
                width -= [self widthForSegmentAtIndex:i.intValue];
                [titles removeObjectAtIndex:i.intValue];
            }
        }
        
        if (titles.count > 0) {
            NSMutableArray *widths = [NSMutableArray array];
            if (_smartAdjustment) {
                widths = [self smartWidthWithTitlesWidths:titles inTotalWidthAvailable:width].mutableCopy;
            }
            else {
                widths = [self proportionalWidthsWithTitleWidth:titles inTotalWidthAvailable:width].mutableCopy;
            }
            
            NSArray *segmentIndexes = [_segmentsIndexesWithExplicitWidthSet.allObjects sortedArrayUsingComparator:^NSComparisonResult(NSNumber * _Nonnull obj1, NSNumber * _Nonnull obj2) {
                return [obj1 compare:obj2];
            }];
            for (NSNumber *i in segmentIndexes) {
                [widths insertObject:@([self widthForSegmentAtIndex:i.intValue]) atIndex:i.intValue];
            }
            
            for (int i = 0; i<widths.count; i++) {
                [super setWidth:[widths[i] floatValue] forSegmentAtIndex:i];
            }
        }
    }
    else {
        for (int i = 0; i<self.numberOfSegments; i++) {
            if (![_segmentsIndexesWithExplicitWidthSet containsObject:@(i)]) {
                [super setWidth:0. forSegmentAtIndex:i];
            }
        }
    }
}

- (void)removeAllSegments {
    [_segmentsIndexesWithExplicitWidthSet removeAllObjects];
    
    [super removeAllSegments];
}

- (void)removeSegmentAtIndex:(NSUInteger)segment animated:(BOOL)animated {
    [_segmentsIndexesWithExplicitWidthSet removeObject:@(segment)];
    NSMutableSet *newSet = [NSMutableSet set];
    for (NSNumber *i in _segmentsIndexesWithExplicitWidthSet) {
        if (i.intValue>segment) {
            [newSet addObject:@(i.intValue-1)];
        }
        else {
            [newSet addObject:i];
        }
    }
    self.segmentsIndexesWithExplicitWidthSet = newSet;
    
    [super removeSegmentAtIndex:segment animated:animated];
}

- (void)insertSegmentWithTitle:(NSString *)title atIndex:(NSUInteger)segment animated:(BOOL)animated {
    NSMutableSet *newSet = [NSMutableSet set];
    for (NSNumber *i in _segmentsIndexesWithExplicitWidthSet) {
        if (i.intValue>=segment) {
            [newSet addObject:@(i.intValue+1)];
        }
        else {
            [newSet addObject:i];
        }
    }
    self.segmentsIndexesWithExplicitWidthSet = newSet;
    
    [super insertSegmentWithTitle:title atIndex:segment animated:animated];
}

- (void)setWidth:(CGFloat)width forSegmentAtIndex:(NSUInteger)segment {
    if (width>0.) {
        [_segmentsIndexesWithExplicitWidthSet addObject:@(segment)];
    }
    else {
        [_segmentsIndexesWithExplicitWidthSet removeObject:@(segment)];
    }
    
    [super setWidth:width forSegmentAtIndex:segment];
}


#pragma mark - calculations

- (NSArray *)widthsForSegmentsTitles {
    NSDictionary *attributes;
    
    if (!(attributes = [self titleTextAttributesForState:UIControlStateNormal])) {
        attributes = @{NSFontAttributeName : [UIFont systemFontOfSize:UIFont.systemFontSize]};
    }
    
    NSMutableArray *widths = [NSMutableArray array];
    
    for (int i = 0; i<self.numberOfSegments; i++) {
        CGFloat width;
        NSString *text = nil;
        if ((text = [self titleForSegmentAtIndex:i])) {
            width = [text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, self.frame.size.height)
                                       options:0
                                    attributes:attributes
                                       context:nil].size.width + 5.;
        }
        else {
            width = 5.;
        }
        
        [widths addObject:@(width)];
    }
    
    return widths;
}

- (NSArray *)proportionalWidthsWithTitleWidth:(NSArray *)titles inTotalWidthAvailable:(CGFloat)widthAvailable {
    CGFloat requiredWidth = 0.;
    
    for (NSNumber *title in titles) {
        requiredWidth += title.floatValue;
    }
    
    CGFloat ratio = widthAvailable/requiredWidth;
    
    NSMutableArray *widths = [NSMutableArray array];
    CGFloat actualLength = 0.;
    for (NSNumber *title in titles) {
        CGFloat width = floor(title.floatValue*ratio);
        [widths addObject:@(width)];
        actualLength += width;
    }
    
    if (widths.count > 0) {
        [widths replaceObjectAtIndex:widths.count-1 withObject:@([widths.lastObject floatValue]+widthAvailable-actualLength)];  //compensate rounding error
    }
    
    return widths;
}

- (NSArray *)smartWidthWithTitlesWidths:(NSArray *)titles inTotalWidthAvailable:(CGFloat)widthAvailable {
    CGFloat equalWidth = floor(widthAvailable / (CGFloat)titles.count);
    CGFloat greatestTitle = 0.;
    for (NSNumber *title in titles) {
        if (title.floatValue > greatestTitle) {
            greatestTitle = title.floatValue;
        }
    }
    if (greatestTitle<equalWidth) {
        //we can fit with simply equal segments
        NSMutableArray *widths = [NSMutableArray array];
        for (int i = 0; i<titles.count-1; i++) {
            [widths addObject:@(equalWidth)];
        }
        [widths addObject:@(widthAvailable - equalWidth*(CGFloat)(titles.count-1))];
        return widths;
    }
    
    
    CGFloat requiredWidth = 0.;
    for (NSNumber *title in titles) {
        requiredWidth += title.floatValue;
    }
    
    if (requiredWidth >= widthAvailable) {
        return [self proportionalWidthsWithTitleWidth:titles inTotalWidthAvailable:widthAvailable];  //there is no way to fit all segments in width, so just adjusting segments proportionaly to content
    }
    
    //assume titles with width > equal width as adjusted on current step, all the others go to next iteration
    NSMutableArray *titlesLeftToAdjust = [NSMutableArray array];
    CGFloat widthAdjusted = 0.;
    NSMutableArray *titlesIndexesAdjusted = [NSMutableArray array];
    
    for (int i = 0; i<titles.count; i++) {
        CGFloat width = [titles[i] floatValue];
        if (width>equalWidth) {
            widthAdjusted += width;
            [titlesIndexesAdjusted addObject:@(i)];
        }
        else {
            [titlesLeftToAdjust addObject:@(width)];
        }
    }
    
    NSMutableArray *adjustedOnNextStep = titlesLeftToAdjust.count>0 ? [self smartWidthWithTitlesWidths:titlesLeftToAdjust inTotalWidthAvailable:widthAvailable-widthAdjusted].mutableCopy : [NSMutableArray array];
    
    for (NSNumber *index in titlesIndexesAdjusted) {
        [adjustedOnNextStep insertObject:titles[index.intValue] atIndex:index.intValue];
    }
    
    return adjustedOnNextStep;
}


@end
