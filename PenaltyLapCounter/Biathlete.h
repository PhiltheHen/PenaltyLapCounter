//
//  Biathlete.h
//  PenaltyLapCounter
//
//  Created by Philip Henson on 8/11/15.
//  Copyright (c) 2015 Phil Henson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Realm/Realm.h>
@import UIKit;

@class Biathlete;

@interface Laps : RLMObject
@property NSString *lapCount;
@end
RLM_ARRAY_TYPE(Laps)


@interface Biathlete : RLMObject
@property NSString *bibNum;
@property RLMArray<Laps> *lapArray;

-(id)initWithBibNumber:(NSString *)bibEntered;
-(NSInteger)isRepeatBib:(NSString *)bibEntered inArray:(NSArray *)biathleteArray;

@end
RLM_ARRAY_TYPE(Biathlete)


