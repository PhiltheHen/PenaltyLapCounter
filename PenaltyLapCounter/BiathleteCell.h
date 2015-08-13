//
//  BiathleteCell.h
//  PenaltyLapCounter
//
//  Created by Philip Henson on 8/12/15.
//  Copyright (c) 2015 Phil Henson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BiathleteCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *bibNumLabel;
@property (weak, nonatomic) IBOutlet UILabel *lapNumLabel;
@property (weak, nonatomic) IBOutlet UIStepper *lapStepper;

@end
