//
//  PSFMapViewController.m
//  FavoritePoints
//
//  Created by Alexander Kozin on 28.08.17.
//  Copyright © 2017 Pragmatic Software. All rights reserved.
//

#import "PSFMapViewController.h"
#import "PSFPoint+CoreDataProperties.h"
#import "PSFModels.h"
#import "PSFPointAnnotation.h"
#import "PSFLocationManager.h"

@interface PSFMapViewController () {
    PSFLocationManager *locationManager;
}

- (void)loadSavedPoints;

@end

@implementation PSFMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mapView.delegate = self;
    [self loadSavedPoints];
    locationManager = [PSFLocationManager sharedManager];
    [locationManager getCurrentLocationWithCompletionHandler:^(CLLocation *location) {
        MKCoordinateSpan span = MKCoordinateSpanMake(0.009, 0.009);
        MKCoordinateRegion region = MKCoordinateRegionMake(location.coordinate, span);
        [_mapView setRegion:region animated:YES];
    }];
}

#pragma mark - Actions

- (IBAction)moveToCurrentLocation:(UIButton *)sender {
    [locationManager getCurrentLocationWithCompletionHandler:^(CLLocation *location) {
        MKCoordinateSpan span = MKCoordinateSpanMake(0.009, 0.009);
        MKCoordinateRegion region = MKCoordinateRegionMake(location.coordinate, span);
        [_mapView setRegion:region animated:YES];
    }];
}

/**
 Добавление новой точки на карту.

 */
- (IBAction)addNewPoint:(UILongPressGestureRecognizer *)sender {
    if ( sender.state == UIGestureRecognizerStateBegan ) {
        CGPoint touchLocation = [sender locationInView:self.mapView];
        CLLocationCoordinate2D coordinate = [self.mapView convertPoint:touchLocation toCoordinateFromView:self.mapView];
        // создание временной точки на карте
        PSFPointAnnotation *tempAnnotation = [PSFPointAnnotation new];
        tempAnnotation.coordinate = coordinate;
        [self.mapView addAnnotation:tempAnnotation];
        // создание окна с выбором действий для сохранения точки
        UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"Add point"
                                                                             message:@"Save point of interest"
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
        PSFMapViewController __weak *weakSelf = self;
        void (^addPointHandler)(UIAlertAction *action) = ^(UIAlertAction *action) {
            // отображение окна для создания новой точки
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            PSFAddPointViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"PSFAddPointVC"];
            vc.pointAnnotation = tempAnnotation;
            vc.delegate = weakSelf;
            [weakSelf.navigationController pushViewController:vc animated:YES];
            // удаление временно добавленной аннотации
            [weakSelf.mapView removeAnnotation:tempAnnotation];
        };
        UIAlertAction *addPointAction = [UIAlertAction actionWithTitle:@"Add point"
                                         style:UIAlertActionStyleDefault handler:addPointHandler];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                               style:UIAlertActionStyleCancel
                                                             handler:^(UIAlertAction *action) {
                                                                 // удаление временно добавленной аннотации
                                                                 [weakSelf.mapView removeAnnotation:tempAnnotation];
                                                             }];
        [actionSheet addAction:addPointAction];
        [actionSheet addAction:cancelAction];
        [self presentViewController:actionSheet animated:YES completion:nil];
    }
}

#pragma mark - Map view delegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    // в качестве метки для текущего местположения возвращается "стандартное" представление
    if ( annotation == mapView.userLocation ) {
        return [mapView viewForAnnotation:annotation];
    }
    
    NSString *viewIdentifier = @"pinAnnotationView";
    MKPinAnnotationView *view = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:viewIdentifier];
    if ( view == nil ) {
        view = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:viewIdentifier];
    }
    view.animatesDrop = YES;
    view.canShowCallout = YES;
    UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
    view.rightCalloutAccessoryView = infoButton;
    return view;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view
calloutAccessoryControlTapped:(UIControl *)control {
    // отображение контроллера с информацией о выбранной точке
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    PSFAddPointViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"PSFAddPointVC"];
    vc.pointAnnotation = view.annotation;
    vc.isEditable = NO;
    vc.title = @"My point";
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Add point view controller delegate

/**
 Добавление созданной точки на карту и
 удаление контроллера для создания точек из стека навигации.

 @param point Добавленная точка.
 */
- (void)pointWasSaved:(PSFPoint *)point {
    PSFPointAnnotation *pointAnnotation = [[PSFPointAnnotation alloc] initWithTitle:point.title
                                                                    fullDescription:point.fullDescription];
    pointAnnotation.coordinate = CLLocationCoordinate2DMake(point.latitude, point.longitude);
    [self.mapView addAnnotation:pointAnnotation];
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Auxiliary methods

/**
 Загрузка сохранённых точек и добавление их на карту.
 */
- (void)loadSavedPoints {
    PSFModels *models = [PSFModels sharedModels];
    PSFMapViewController __weak *weakSelf = self;
    [models fetchAllPointsWithCompletionHandler:^(NSArray <PSFPoint *> *points, NSManagedObjectContext *context) {
        NSMutableArray *annotations = [[NSMutableArray alloc] initWithCapacity:points.count];
        [points enumerateObjectsUsingBlock:^(PSFPoint *point, NSUInteger idx, BOOL *stop) {
            PSFPointAnnotation *pointAnnotation = [[PSFPointAnnotation alloc] initWithTitle:point.title
                                                                            fullDescription:point.fullDescription];
            pointAnnotation.coordinate = CLLocationCoordinate2DMake(point.latitude, point.longitude);
            [annotations addObject:pointAnnotation];
        }];
        [weakSelf.mapView addAnnotations:annotations];
    }];
}

@end
