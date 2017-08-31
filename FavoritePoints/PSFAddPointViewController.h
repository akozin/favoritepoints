//
//  PSFAddPointViewController.h
//  FavoritePoints
//
//  Created by Alexander Kozin on 29.08.17.
//  Copyright © 2017 Pragmatic Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
@class PSFPoint;
@class PSFPointAnnotation;

@protocol PSFAddPointViewControllerDelegate;

@interface PSFAddPointViewController : UIViewController

@property (nonatomic) PSFPointAnnotation *pointAnnotation;
@property (weak, nonatomic) id<PSFAddPointViewControllerDelegate> delegate;
@property (nonatomic) BOOL isEditable;  // возможно ли редактирование данных
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;

@end

@protocol PSFAddPointViewControllerDelegate

- (void)pointWasSaved:(PSFPoint *)point;

@end
