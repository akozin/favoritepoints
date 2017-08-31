//
//  PSFPointAnnotation.h
//  FavoritePoints
//
//  Created by Alexander Kozin on 29.08.17.
//  Copyright © 2017 Pragmatic Software. All rights reserved.
//

@class MKPointAnnotation;

@interface PSFPointAnnotation : MKPointAnnotation

@property (nonatomic, copy) NSString *fullDescription;

- (instancetype)initWithTitle:(NSString *)aTitle fullDescription:(NSString *)aFullDescription;

@end
