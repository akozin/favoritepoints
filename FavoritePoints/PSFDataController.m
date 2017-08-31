//
//  PSFDataController.m
//  FavoritePoints
//
//  Created by Alexander Kozin on 27.08.17.
//  Copyright © 2017 Pragmatic Software. All rights reserved.
//

#import "PSFDataController.h"

@interface PSFDataController()

- (void)displayAlertWithTitle:(NSString *)title message:(NSString *)message andActionCallback:(void(^)())callback;

@end


@implementation PSFDataController

- (instancetype)init {
    if ( self = [super init] ) {
        NSString *storageName = @"FavoritePoints";
        _persistentContainer = [[NSPersistentContainer alloc] initWithName:storageName];
        [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription,
                                                                          NSError *error) {
            if ( error != nil ) {
                [self displayAlertWithTitle:@"Unexpected error has occured"
                                    message:error.localizedDescription
                          andActionCallback:^{
                              abort();
                          }];
            }
        }];
    }
    return self;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    NSError *error = nil;
    if ([context hasChanges] && ![context save:&error]) {
        // отображение ошибки в главном потоке
        [self displayAlertWithTitle:@"Error occurs while saving data"
                            message:error.localizedDescription andActionCallback:nil];
    }
}

#pragma mark - Auxiliary methods

- (void)displayAlertWithTitle:(NSString *)title message:(NSString *)message andActionCallback:(void(^)())callback {
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:title
                                message:message
                                preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action) {
                                                              if ( callback != nil ) {
                                                                  callback();
                                                              }
                                                          }];
    [alert addAction:defaultAction];
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    // отображение предупреждения в главном потоке
    dispatch_async(dispatch_get_main_queue(), ^{
        [window.rootViewController presentViewController:alert animated:YES completion:nil];
    });
}

@end
