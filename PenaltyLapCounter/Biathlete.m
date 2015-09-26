//
//  Biathlete.m
//  PenaltyLapCounter
//
//  Created by Philip Henson on 8/11/15.
//  Copyright (c) 2015 Phil Henson. All rights reserved.
//

#import "Biathlete.h"

@implementation Laps

@end

@implementation Biathlete

-(id)initWithBibNumber:(NSString *)bibEntered
{
    self = [super init];
    if (self){
        self.bibNum = bibEntered;
        Laps *laps = [Laps new];
        laps.lapCount = @"1";
        [self.lapArray addObject:laps];
    }
    return self;
}

-(NSInteger)isRepeatBib:(NSString *)bibEntered inArray:(NSArray *)biathleteArray
{
    for (Biathlete *biathlete in biathleteArray){
        if ([bibEntered isEqualToString:biathlete.bibNum]){
            return [biathleteArray indexOfObject:biathlete];
        }
    }

    return -1;
}



@end
