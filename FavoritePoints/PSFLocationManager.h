//
//  PSFLocationManager.h
//  FavoritePoints
//
//  Created by Alexander Kozin on 28.08.17.
//  Copyright © 2017 Pragmatic Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

typedef void(^LocationHandler)(CLLocation *location);

@interface PSFLocationManager : NSObject <CLLocationManagerDelegate>

+ (instancetype)sharedManager;
- (void)getCurrentLocationWithCompletionHandler:(LocationHandler)aHandler;

@end
