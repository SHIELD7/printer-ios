//
//  DzProgress.h
//  DzPrinterParser
//
//  Created by 蔡俊杰 on 16/2/23.
//  Copyright © 2019 Dothantech. All rights reserved.
//

#import <Foundation/Foundation.h>

#define ShowState(string)       [DzProgress showState:string];
#define ShowLoad                [DzProgress showLoad];
#define DismissLoad             [DzProgress dismiss];

#define ShowDismissMark(string) [DzProgress showMarkWithDismiss:string];

/**
 * @brief   定义了进度条操作的接口
 */
@interface DzProgress : NSObject

+ (void)enableProgress:(BOOL)enable;

+ (void)showState:(NSString *)message;
+ (void)showLoad;
+ (void)dismiss;

+ (void)showMarkWithDismiss:(NSString *)message;

@end
