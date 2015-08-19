//
//  LapCounterViewController.m
//  PenaltyLapCounter
//
//  Created by Philip Henson on 8/11/15.
//  Copyright (c) 2015 Phil Henson. All rights reserved.
//

#import "LapCounterViewController.h"
#import "Biathlete.h"
#import "BiathleteCell.h"


@interface LapCounterViewController () <UITableViewDataSource, UITableViewDelegate>

@property NSMutableArray *biathleteArray; // Array of ONLY athletes currently displayed in the view
@property NSMutableDictionary *completeLapData; // Complete array of ALL athletes that have been entered throughout the race
@property (weak, nonatomic) IBOutlet UITextField *bibNumToEnter;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property NSTimeInterval timeInterval;

@end

@implementation LapCounterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Time (seconds) until cell will disappear from table. Should be around 1 minute for final build, shorter for testing
    self.timeInterval = 10.0;
    
    self.biathleteArray = [NSMutableArray new];
    self.completeLapData = [NSMutableDictionary new];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.biathleteArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BiathleteCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    // Update labels with data from biathlete array
    if ([self.biathleteArray count]){
        cell.bibNumLabel.text = [[[self.biathleteArray objectAtIndex:indexPath.row] bibNum] stringValue];
        cell.lapNumLabel.text = [[[self.biathleteArray objectAtIndex:indexPath.row] lapNum] stringValue];
        
        // Need to update stepper value if repeat bib number entered to adjust lap count
        cell.lapStepper.value = [[[self.biathleteArray objectAtIndex:indexPath.row] lapNum] doubleValue];
        //NSLog(@"Bib: %@, Laps: %@", cell.bibNumLabel.text, cell.lapNumLabel.text);
        
    }
    return cell;
                             
}
- (IBAction)numberButtonPressed:(UIButton *)sender {
    self.bibNumToEnter.text = [NSString stringWithFormat:@"%@%d", self.bibNumToEnter.text, (int)[sender tag]];
    
}
- (IBAction)clearButtonPressed:(UIButton *)sender {
    self.bibNumToEnter.text = @"";
}

-(void)startTimer:(NSNumber *) bibNumber{

    // Call after 10 second delay
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self removeAndSave:bibNumber];
    });
}

- (IBAction)enterBibNum:(UIButton *)sender {

    Biathlete *biathlete = [[Biathlete alloc] initWithBibNumber:self.bibNumToEnter.text];
    NSInteger repeatBibIndex =[biathlete isRepeatBib:self.bibNumToEnter.text inArray:self.biathleteArray];

        if (repeatBibIndex>=0){
            // Replace bib with correct value

            Biathlete *biathleteRepeat = [self.biathleteArray objectAtIndex:repeatBibIndex];
            NSLog(@"OLD: %@", biathleteRepeat.lapNum);
            biathleteRepeat.lapNum = @([biathleteRepeat.lapNum intValue] + 1);
            [self.biathleteArray replaceObjectAtIndex:repeatBibIndex withObject:biathleteRepeat];
            NSLog(@"NEW: %@", biathleteRepeat.lapNum);

        } else {
            // Add and sort
            [self.biathleteArray addObject:biathlete];
            [self sortBiathleteArray:self.biathleteArray];
        }

    // Start cell timer
    [self startTimer:@([self.bibNumToEnter.text integerValue])];

    // Clear text field and update cells
    self.bibNumToEnter.text = @"";
    [self.tableView reloadData];

}

- (IBAction)stepperValueDidChanged:(UIStepper *)sender {

    // Need to change athlete model data so view can update with correct lap number
    
    // First get UIStepper position in tableView
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    
    // Then use that index to edit biathlete object
    
    if ([self.biathleteArray count]){
        Biathlete *biathleteToEdit = [self.biathleteArray objectAtIndex:indexPath.row];
        biathleteToEdit.lapNum = [NSNumber numberWithDouble:sender.value];
        [self.biathleteArray replaceObjectAtIndex:indexPath.row withObject:biathleteToEdit];
    }
    
    [self.tableView reloadData];
    
}

-(void)removeAndSave:(NSNumber *)bibNumber
{
    NSString *bibNumKey = [bibNumber stringValue];
    
    for (Biathlete *biathlete in self.biathleteArray)
    {
        if ([bibNumber intValue] == [biathlete.bibNum intValue])
        {
            // Add to completeLapData, first checking to see if athlete already exists
            if ([self.completeLapData objectForKey:bibNumKey]){
                NSMutableArray *adjustedLapArray = [self.completeLapData valueForKey:bibNumKey];
                [adjustedLapArray addObject:biathlete.lapNum];
                [self.completeLapData setValue:[NSMutableArray arrayWithArray:adjustedLapArray] forKey:bibNumKey];
            } else{
                // default behavior
                [self.completeLapData setValue:[NSMutableArray arrayWithObject:biathlete.lapNum] forKey:bibNumKey];
            }
            
            // finally need to then remove from self.biathleteArray to update table view
            [self.biathleteArray removeObject:biathlete];
            break;
         
        }
        
    }
    //NSLog(@"%@", self.completeLapData);
    [self.tableView reloadData];
}

-(void)sortBiathleteArray:(NSMutableArray *)unsortedArray
{
    NSArray *sortedArray;
    
    sortedArray = [unsortedArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSNumber *first = [(Biathlete*)obj1 bibNum];
        NSNumber *second = [(Biathlete*)obj2 bibNum];
        return [first compare:second];
    }];
    
    [self.biathleteArray removeAllObjects];
    [self.biathleteArray addObjectsFromArray:sortedArray];
}

- (IBAction)endRace:(UIButton *)sender {
    
    //TODO: add code here to handle the saving of data
    
    NSLog(@"%@", self.completeLapData);
}




@end
