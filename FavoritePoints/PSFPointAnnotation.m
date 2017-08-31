//
//  PSFPointAnnotation.m
//  FavoritePoints
//
//  Created by Alexander Kozin on 29.08.17.
//  Copyright © 2017 Pragmatic Software. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "PSFPointAnnotation.h"
#import "PSFPoint+CoreDataProperties.h"

@implementation PSFPointAnnotation

- (instancetype)initWithTitle:(NSString *)aTitle fullDescription:(NSString *)aFullDescription {
    if ( self = [super init] ) {
        self.title = aTitle;
        self.fullDescription = aFullDescription;
    }
    return self;
}

@end
