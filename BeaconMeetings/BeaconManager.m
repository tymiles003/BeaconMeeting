//
//  BeaconManager.m
//  BeaconMeetings
//
//  Created by Kunnemeyer, Hubert on 10/26/14.
//  Copyright (c) 2014 WebMD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BeaconManager.h"
#import "ESTBeaconManager.h"



@interface BeaconManager ()
@property (strong, nonatomic) ESTBeaconManager *manager;
@property (strong, nonatomic) NSNumber *major;
@end

@implementation BeaconManager
- (instancetype)initWithMajor:(NSNumber *)major{
    self = [super init];
    if (self) {
        _major = major;

    }
    return self;
}

@end
