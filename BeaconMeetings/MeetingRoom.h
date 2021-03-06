//
//  MeetingRoom.h
//  BeaconMeetings
//
//  Created by Kunnemeyer, Hubert on 10/31/14.
//  Copyright (c) 2014 WebMD. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MeetingRoom : NSObject
@property (nonatomic, strong) NSNumber *major;
@property (strong, nonatomic) NSString *roomName;
@property (nonatomic) NSInteger availableSeating;
@property (nonatomic, assign) BOOL available;

//
//- (instancetype)initWithIdentifier:(NSInteger)identifier;
//
//- (instancetype)initWithMajor:(NSNumber *)major;
//+ (instancetype)roomWithMajor:(NSNumber *)major;
+ (instancetype)meetingRoomWithDictionary:(NSDictionary *)roomDictionary;
- (instancetype)initWithDictionary:(NSDictionary *)roomDictionary;
@end
