//
//  Biathlete.h
//  PenaltyLapCounter
//
//  Created by Philip Henson on 8/11/15.
//  Copyright (c) 2015 Phil Henson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Biathlete : NSObject
@property NSNumber *bibNum;
@property NSNumber *lapNum;

-(id)initWithBibNumber:(NSString *)bibEntered;
-(NSInteger)isRepeatBib:(NSString *)bibEntered inArray:(NSArray *)biathleteArray;

@end
