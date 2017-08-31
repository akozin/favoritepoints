//
//  PSFModels.m
//  FavoritePoints
//
//  Created by Alexander Kozin on 27.08.17.
//  Copyright © 2017 Pragmatic Software. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "PSFModels.h"
#import "PSFPoint+CoreDataProperties.h"
#import "PSFDataController.h"
#import "AppDelegate.h"

@interface PSFModels () {
    NSPersistentContainer *persistentContainer;
    PSFDataController *dataController;
    NSManagedObjectContext *privateContext;
}

@property (readonly, nonatomic) NSInteger newPointId;

@end

@implementation PSFModels

+ (instancetype)sharedModels {
    static PSFModels *sharedIntance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedIntance = [[PSFModels alloc] init];
    });
    return sharedIntance;
}

- (instancetype)init {
    if ( self = [super init] ) {
        AppDelegate *appDelegate = (AppDelegate *)UIApplication.sharedApplication.delegate;
        dataController = appDelegate.dataController;
        persistentContainer = dataController.persistentContainer;
        // созданию дочерний контекст для главного, который выполняется в главном потоке
        privateContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        privateContext.parentContext = persistentContainer.viewContext;
    }
    return self;
}

/**
 Получение всех созданных точек.

 @param callback Функция обратного вызова, в которую передаются полученные точки.
 */
- (void)fetchAllPointsWithCompletionHandler:(void (^)(NSArray <PSFPoint *> *points, NSManagedObjectContext *context))callback {
    [privateContext performBlock:^{
        NSFetchRequest *request = PSFPoint.fetchRequest;
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"identifier" ascending:NO]];
        request.predicate = [NSPredicate predicateWithFormat:@"identifier != nil"];
        NSError *error;
        NSArray <PSFPoint *> *points = [request execute:&error];
        if ( error || points.count == 0 ) {
            callback(@[], privateContext);
        } else {
            callback(points, privateContext);
        }
    }];
}

- (PSFPoint *)makePointWithTitle:(NSString *)aTitle description:(NSString *)aDescription
                        latitude:(double)aLatitude longitude:(double)aLongitude {
    PSFPoint *point = [NSEntityDescription insertNewObjectForEntityForName:@"PSFPoint"
                                                    inManagedObjectContext:persistentContainer.viewContext];
    point.identifier = self.newPointId;
    point.title = aTitle;
    point.fullDescription = aDescription;
    point.latitude = aLatitude;
    point.longitude = aLongitude;
    [dataController saveContext];
    return point;
}

#pragma mark - Auxiliary properties

/**
 Получение автоинкрементного идентификатора для модели PSFPoint.

 @return Следующий идентификатор, который на единицу больше предыдущего.
 */
- (NSInteger)newPointId {
    NSFetchRequest *request = PSFPoint.fetchRequest;
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"identifier" ascending:NO]];
    request.predicate = [NSPredicate predicateWithFormat:@"identifier != nil"];
    request.propertiesToFetch = @[@"identifier"];
    NSError *error;
    NSArray *points = [request execute:&error];
    if ( error || points.count == 0 ) {
        return 1;
    }
    PSFPoint *lastAddedPoint = [points lastObject];
    return lastAddedPoint.identifier;
}

@end
