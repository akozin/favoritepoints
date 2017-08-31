//
//  PSFLocationManager.m
//  FavoritePoints
//
//  Created by Alexander Kozin on 28.08.17.
//  Copyright © 2017 Pragmatic Software. All rights reserved.
//

#import "PSFLocationManager.h"

@interface PSFLocationManager () {
    CLLocationManager *locationManager;
    LocationHandler handler;
}

- (void)displayLocationErrorAlert;

@end

@implementation PSFLocationManager


+ (instancetype)sharedManager {
    static PSFLocationManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [PSFLocationManager new];
    });
    return sharedInstance;
}

- (instancetype)init {
    if ( self = [super init] ) {
        locationManager = [CLLocationManager new];
        locationManager.delegate = self;
        CLAuthorizationStatus status = CLLocationManager.authorizationStatus;
        BOOL locationAccessIsForbidden = (status == kCLAuthorizationStatusDenied || status == kCLAuthorizationStatusRestricted);
        
        if ( status == kCLAuthorizationStatusNotDetermined ) {
            [locationManager requestWhenInUseAuthorization];
        } else if ( locationAccessIsForbidden || !CLLocationManager.locationServicesEnabled ) {
            [self displayLocationErrorAlert];
        }

    }
    return self;
}

- (void)getCurrentLocationWithCompletionHandler:(LocationHandler)aHandler {
    CLAuthorizationStatus status = CLLocationManager.authorizationStatus;
    if ( status == kCLAuthorizationStatusRestricted || status == kCLAuthorizationStatusDenied ) {
        [self displayLocationErrorAlert];
        return;
    }
    
    CLLocation *lastFetchedLocation = locationManager.location;
    NSDate *now = [NSDate date];
    NSTimeInterval actualLocationLifeTime = 60 * 10;  // 10 минут
    if ( lastFetchedLocation && [now timeIntervalSinceDate:lastFetchedLocation.timestamp] < actualLocationLifeTime ) {
        handler = aHandler;
        aHandler(lastFetchedLocation);
    } else {
        handler = aHandler;
        [locationManager startUpdatingLocation];
    }
    
}

#pragma mark - Location manager delegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if ( status == kCLAuthorizationStatusAuthorizedWhenInUse ) {
        [locationManager requestLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    CLLocation *loc = [locations firstObject];
    handler(loc);
    // останавливаю обновление местоположения при достижении высокой точности
    if ( loc.horizontalAccuracy < 100 ) {
        [locationManager stopUpdatingLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"Error getting location: %@", error.localizedDescription);
}

#pragma mark - Auxiliary methods

- (void)displayLocationErrorAlert {
    NSString *message = @"Turn on Location Services in Settings->Privacy to allow determination of your current location";
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:@"Location Services Off"
                                message:message
                                preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK"
                                                            style:UIAlertActionStyleDefault
                                                          handler:nil];
    [alert addAction:defaultAction];
    UIApplication *app = [UIApplication sharedApplication];
    [app.keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
}

@end
