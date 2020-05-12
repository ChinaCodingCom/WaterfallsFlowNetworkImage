//
//  AppDelegate.h
//  WaterfallsFlowNetworkImage
//
//  Created by CE on 2017/6/6.
//  Copyright © 2017年 CE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

