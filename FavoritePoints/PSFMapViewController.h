//
//  PSFMapViewController.h
//  FavoritePoints
//
//  Created by Alexander Kozin on 28.08.17.
//  Copyright © 2017 Pragmatic Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "PSFAddPointViewController.h"

@interface PSFMapViewController : UIViewController <MKMapViewDelegate, PSFAddPointViewControllerDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end
