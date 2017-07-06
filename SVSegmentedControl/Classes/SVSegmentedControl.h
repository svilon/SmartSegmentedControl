//
//  SVSegmentedControl.h
//  SVSegmentedControl
//
//  Created by Eugene Shevtsov on 07/06/2017.
//  Copyright (c) 2017 Eugene Shevtsov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SVSegmentedControl : UISegmentedControl

@property (nonatomic, assign) IBInspectable BOOL smartAdjustment;
@property (nonatomic, assign) IBInspectable BOOL fixNativeProportionalSizing;

@end
