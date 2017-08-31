//
//  PSFDataController.h
//  FavoritePoints
//
//  Created by Alexander Kozin on 27.08.17.
//  Copyright © 2017 Pragmatic Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface PSFDataController : NSObject

@property (readonly, strong, nonatomic) NSPersistentContainer *persistentContainer;

- (void)saveContext;

@end
