//
//  PSFAddPointViewController.m
//  FavoritePoints
//
//  Created by Alexander Kozin on 29.08.17.
//  Copyright © 2017 Pragmatic Software. All rights reserved.
//

#import "PSFAddPointViewController.h"
#import "PSFModels.h"
#import "PSFPointAnnotation.h"
#import "PSFPoint+CoreDataProperties.h"

@interface PSFAddPointViewController ()

@end

@implementation PSFAddPointViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if ( self = [super initWithCoder:aDecoder] ) {
        // по-умолчанию редактирование разрешено
        _isEditable = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CALayer *layer = self.descriptionTextView.layer;
    layer.borderColor = UIColor.lightGrayColor.CGColor;
    layer.borderWidth = 1.0;
    layer.cornerRadius = 5.0;
    // в режиме просмотра редактирование запрещено
    if ( !self.isEditable ) {
        self.titleTextField.enabled = NO;
        self.descriptionTextView.editable = NO;
        self.saveButton.hidden = YES;
    }
    
    if ( self.pointAnnotation ) {
        self.titleTextField.text = self.pointAnnotation.title;
        self.descriptionTextView.text = self.pointAnnotation.fullDescription;
    }
}

#pragma mark - Actions

/**
 Сохранение новой точки.

 */
- (IBAction)savePoint:(UIButton *)sender {
    NSRegularExpression *regExp = [NSRegularExpression regularExpressionWithPattern:@"^\\w.*$"
                                                                            options:NSRegularExpressionCaseInsensitive|NSRegularExpressionAnchorsMatchLines
                                                                              error:nil];
    NSString *title = self.titleTextField.text;
    NSRange fullTitleRange = NSMakeRange(0, title.length);
    BOOL titleIsCorrect = [regExp numberOfMatchesInString:title options:0 range:fullTitleRange] > 0;
    
    NSString *description = self.descriptionTextView.text;
    NSRange fullDescriptionRange = NSMakeRange(0, description.length);
    BOOL descriptionIsCorrect = [regExp numberOfMatchesInString:description options:0 range:fullDescriptionRange] > 0;
    
    if ( titleIsCorrect && descriptionIsCorrect ) {
        PSFModels *models = [PSFModels sharedModels];
        CLLocationCoordinate2D coordinate = self.pointAnnotation.coordinate;
        PSFPoint *point = [models makePointWithTitle:title description:description
                                            latitude:coordinate.latitude
                                           longitude:coordinate.longitude];
        // вызов метода делегата
        if ( self.delegate ) {
            [self.delegate pointWasSaved:point];
        }
    } else {
        NSString *alertMessage = @"Fields must not be empty and begin with character or digit";
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Incorrect title or description"
                                                                       message:alertMessage
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:nil];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

@end
