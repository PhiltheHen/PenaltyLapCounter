//
//  Biathlete.m
//  PenaltyLapCounter
//
//  Created by Philip Henson on 8/11/15.
//  Copyright (c) 2015 Phil Henson. All rights reserved.
//

#import "Biathlete.h"

@implementation Biathlete

-(id)initWithBibNumber:(NSString *)bibEntered
{
    self = [super init];
    if (self){

        if ([bibEntered isEqualToString:@""]){
            // alert user to enter valid number
        } else {
                self.bibNum = @([bibEntered integerValue]);
                self.lapNum = @(1);
        }
    }
    return self;
}

-(NSInteger)isRepeatBib:(NSString *)bibEntered inArray:(NSArray *)biathleteArray
{
    for (Biathlete *biathlete in biathleteArray){
        if ([bibEntered intValue] == [biathlete.bibNum intValue]){
            NSLog(@"%lu", (unsigned long)[biathleteArray indexOfObject:biathlete]);
            return [biathleteArray indexOfObject:biathlete];

        }
    }

    return -1;
}



@end
