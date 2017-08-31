//
//  PSFModels.h
//  FavoritePoints
//
//  Created by Alexander Kozin on 27.08.17.
//  Copyright © 2017 Pragmatic Software. All rights reserved.
//

#import <Foundation/Foundation.h>
@class NSManagedObjectContext;
@class PSFPoint;

@interface PSFModels : NSObject

@property (readonly, nonatomic) NSArray *allPoints;

+ (instancetype)sharedModels;
- (PSFPoint *)makePointWithTitle:(NSString *)aTitle description:(NSString *)aDescription
                        latitude:(double)aLatitude longitude:(double)aLongitude;
- (void)fetchAllPointsWithCompletionHandler:(void(^)(NSArray <PSFPoint *> *points, NSManagedObjectContext *context))callback;

@end
