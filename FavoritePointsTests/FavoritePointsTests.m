//
//  FavoritePointsTests.m
//  FavoritePointsTests
//
//  Created by Alexander Kozin on 27.08.17.
//  Copyright © 2017 Pragmatic Software. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <CoreData/CoreData.h>
#import "PSFModels.h"
#import "AppDelegate.h"
#import "PSFDataController.h"
#import "PSFAddPointViewController.h"

@interface FavoritePointsTests : XCTestCase

@end

@implementation FavoritePointsTests

- (void)setUp {
    [super setUp];
    AppDelegate *appDelegate = (AppDelegate *)UIApplication.sharedApplication.delegate;
    PSFDataController *dataController = appDelegate.dataController;
    NSArray *points = [dataController.persistentContainer.viewContext
                       executeFetchRequest:[NSFetchRequest fetchRequestWithEntityName:@"PSFPoint"]
                       error:nil];
    [points enumerateObjectsUsingBlock:^(NSManagedObject *object, NSUInteger idx, BOOL *stop) {
        [dataController.persistentContainer.viewContext deleteObject:object];
    }];
    [dataController saveContext];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testPointCreation {
    PSFModels *models = [PSFModels sharedModels];
    NSString *title = @"Point title";
    NSString *description = @"Point description";
    double latitude = 50.001;
    double longitude = 50.002;
    
    NSManagedObject *point = (NSManagedObject *)[models makePointWithTitle:title description:description
                                                                  latitude:latitude longitude:longitude];
    XCTAssertNotNil(point, @"Point was not created");
    XCTAssertEqualObjects([point valueForKey:@"title"], title);
    XCTAssertEqualObjects([point valueForKey:@"desc"], description);
    XCTAssertEqual([[point valueForKey:@"latitude"] doubleValue], latitude);
    XCTAssertEqual([[point valueForKey:@"longitude"] doubleValue], longitude);
    XCTAssertGreaterThan([[point valueForKey:@"identifier"] integerValue], 0);
}

- (void)testFetchingPoints {
    PSFModels *models = [PSFModels sharedModels];
    NSString *pointTitle = @"Point title";
    [models makePointWithTitle:pointTitle description:@"Point description" latitude:55.123 longitude:37.987];
    XCTestExpectation *expectation = [self expectationWithDescription:@"fetchPointsAsyncRequest"];
    // асинхронный запрос
    [models fetchAllPointsWithCompletionHandler:^(NSArray *points, NSManagedObjectContext *context) {
        XCTAssertEqual(points.count, 1, @"Incorrect points array count");
        id point = points[0];
        XCTAssertEqualObjects([point valueForKey:@"title"], pointTitle);
        
        [expectation fulfill];
    }];
    // ожидание завершения асинхронного запроса
    [self waitForExpectations:@[expectation] timeout:5];
}

//- (void)testAddNewPoint {
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    PSFAddPointViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"PSFAddPointVC"];
//    MKPointAnnotation *pointAnnotation = [MKPointAnnotation new];
//    pointAnnotation.coordinate = CLLocationCoordinate2DMake(50.123, 37.123);
//    vc.pointAnnotation = pointAnnotation;
//    NSString *titleText = @"Title";
//    NSString *descriptionText = @"Description";
//    vc.titleTextField.text = titleText;
//    vc.descriptionTextView.text = descriptionText;
//}

@end
