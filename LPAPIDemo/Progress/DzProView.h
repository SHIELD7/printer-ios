//
//  DzProView.h
//  DzPrinterParser
//
//  Created by 蔡俊杰 on 16/3/8.
//  Copyright © 2019 Dothantech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DzProView : UIView

+ (void)show:(NSString *)message;

@property (atomic, strong) UIWindow *window;
@property (atomic, strong) UIView   *hud;
@property (atomic, strong) UILabel  *label;

@end
