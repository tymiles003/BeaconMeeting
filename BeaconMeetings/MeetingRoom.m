//
//  MeetingRoom.m
//  BeaconMeetings
//
//  Created by Kunnemeyer, Hubert on 10/31/14.
//  Copyright (c) 2014 WebMD. All rights reserved.
//

#import "MeetingRoom.h"
#import <UIKit/UIKit.h>

@interface MeetingRoom ()
@end

static NSInteger er = 26453;
static NSInteger or = 56021;
static NSInteger neo = 8747;


@implementation MeetingRoom

+ (instancetype)meetingRoomWithDictionary:(NSDictionary *)roomDictionary{
    return [[self alloc]initWithDictionary:roomDictionary];
}
- (instancetype)initWithDictionary:(NSDictionary *)roomDictionary{
    self = [super init];
    if (self) {
        if (roomDictionary) {
            self.major = roomDictionary[@"BeaconMajor"];
            self.roomName = roomDictionary[@"name"];
            self.availableSeating = [roomDictionary[@"occupancy"]integerValue];
            self.available = [roomDictionary[@"available"]boolValue];
        }
    }
    return self;
}

//- (instancetype)initWithIdentifier:(NSInteger)identifier{
//    self = [super init];
//    if (self) {
//        _identifier = identifier;
//        [self setUpRoom];
//    }
//    return self;
//}
//
//+ (instancetype)roomWithMajor:(NSNumber *)major{
//    return [[self alloc]initWithMajor:major];
//}
//
//- (instancetype)initWithMajor:(NSNumber *)major{
//    self = [super init];
//    if (self) {
//        _identifier = [major integerValue];
//        [self setUpRoom];
//    }
//    return self;
//}
//- (void)setUpRoom{
//    if (self.identifier == er) {
//        self.roomName = @"ER";
//        self.availableSeating = 12;
//        _available = NO;
//    } else if (self.identifier == or){
//        self.roomName = @"OR";
//        self.availableSeating = 23;
//        _available = YES;
//    } else if (self.identifier == neo){
//        self.roomName = @"Neonatal";
//        self.availableSeating = 8;
//        _available = YES;
//    }
//
//}

@end
