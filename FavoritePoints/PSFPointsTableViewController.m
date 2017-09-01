//
//  PSFPointsTableViewController.m
//  FavoritePoints
//
//  Created by Alexander Kozin on 31.08.17.
//  Copyright © 2017 Pragmatic Software. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "PSFPointsTableViewController.h"
#import "PSFModels.h"
#import "PSFPoint+CoreDataProperties.h"
#import "PSFPointAnnotation.h"
#import "PSFLocationManager.h"
#import "PSFAddPointViewController.h"

@interface PSFPointsTableViewController () {
    NSArray <PSFPoint *> *points;
    PSFLocationManager *locationManager;
    CLLocation *currentLocation;
}

@end

@implementation PSFPointsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    locationManager = [PSFLocationManager sharedManager];
    PSFModels *models = [PSFModels sharedModels];
    PSFPointsTableViewController __weak *weakSelf = self;
    [models fetchAllPointsWithCompletionHandler:^(NSArray <PSFPoint *> *aPoints, NSManagedObjectContext *context) {
        [locationManager getCurrentLocationWithCompletionHandler:^(CLLocation *location) {
            currentLocation = location;
            points = aPoints;
            [weakSelf.tableView reloadData];
        }];
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [points count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    PSFPoint *point = points[indexPath.row];
    [point.managedObjectContext performBlockAndWait:^{
        cell.textLabel.text = point.title;
        // получение дистанции от текущего местоположения до сохранённой точки
        MKMapPoint currentLocationMapPoint = MKMapPointForCoordinate(currentLocation.coordinate);
        CLLocationCoordinate2D anotherPointLocation = CLLocationCoordinate2DMake(point.latitude, point.longitude);
        MKMapPoint anotherMapPoint = MKMapPointForCoordinate(anotherPointLocation);
        double distanceToPoint = MKMetersBetweenMapPoints(currentLocationMapPoint, anotherMapPoint);
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%.0fm", distanceToPoint];
    }];
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    PSFAddPointViewController *vc = (PSFAddPointViewController *)segue.destinationViewController;
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    PSFPoint *point = points[indexPath.row];
    PSFPointAnnotation __block *pointAnnotation;
    [point.managedObjectContext performBlockAndWait:^{
        pointAnnotation = [[PSFPointAnnotation alloc] initWithTitle:point.title
                                                    fullDescription:point.fullDescription];
    }];
    vc.pointAnnotation = pointAnnotation;
    vc.isEditable = NO;
    vc.title = @"My point";
}

@end
