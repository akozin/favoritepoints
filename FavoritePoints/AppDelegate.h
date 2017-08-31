//
//  AppDelegate.h
//  FavoritePoints
//
//  Created by Alexander Kozin on 26.08.17.
//  Copyright © 2017 Pragmatic Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class PSFDataController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (readonly, strong, nonatomic) PSFDataController *dataController;

@end

