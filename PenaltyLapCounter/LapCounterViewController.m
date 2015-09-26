//
//  LapCounterViewController.m
//  PenaltyLapCounter
//
//  Created by Philip Henson on 8/11/15.
//  Copyright (c) 2015 Phil Henson. All rights reserved.
//

#import "LapCounterViewController.h"
#import "ResultsTableViewController.h"
#import "Biathlete.h"
#import "BiathleteCell.h"


@interface LapCounterViewController () <UITableViewDataSource, UITableViewDelegate>

@property NSMutableArray *biathleteArray; // Array of ONLY athletes currently displayed in the view
@property (weak, nonatomic) IBOutlet UITextField *bibNumToEnter;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property NSTimeInterval timeInterval;

@end

@implementation LapCounterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.biathleteArray = [NSMutableArray new];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

    // clear realm data
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    [realm deleteAllObjects];
    [realm commitWriteTransaction];
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
        cell.bibNumLabel.text = [[self.biathleteArray objectAtIndex:indexPath.row] bibNum];
        cell.lapNumLabel.text = [[[[self.biathleteArray objectAtIndex:indexPath.row] lapArray] lastObject] lapCount];

        // Need to update stepper value if repeat bib number entered to adjust lap count
        cell.lapStepper.value = [[[[[self.biathleteArray objectAtIndex:indexPath.row] lapArray] lastObject] lapCount] doubleValue];
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

-(void)startTimer:(Biathlete *) biathlete{

    NSString *laps = [[biathlete.lapArray lastObject] lapCount];

    // Call after 10 second delay
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // restart timer when lap number is changed
        if (![laps isEqualToString:[[biathlete.lapArray lastObject] lapCount]])
            [self startTimer:biathlete];
        else
            [self removeAndSave:biathlete];
    });
}

- (IBAction)enterBibNum:(UIButton *)sender {

    if ([self.bibNumToEnter.text isEqualToString:@""]){
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Invalid bib"
                                                                       message:@"Please enter a valid bib number."
                                                                preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];

        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        Biathlete *biathlete = [[Biathlete alloc] initWithBibNumber:self.bibNumToEnter.text];
        NSInteger repeatBibIndex =[biathlete isRepeatBib:self.bibNumToEnter.text inArray:self.biathleteArray];

        if (repeatBibIndex>=0){
            // Replace biathlete object with one that has correct lap count

            Biathlete *biathleteRepeat = [self.biathleteArray objectAtIndex:repeatBibIndex];
            int lapToEdit = [[[biathleteRepeat.lapArray lastObject] lapCount] intValue] +1;
            [biathleteRepeat.lapArray removeLastObject];
            Laps *addLaps = [Laps new];
            addLaps.lapCount = [NSString stringWithFormat:@"%d", lapToEdit];
            [biathleteRepeat.lapArray addObject:addLaps];
            [self.biathleteArray replaceObjectAtIndex:repeatBibIndex withObject:biathleteRepeat];

        } else {
            // Add and sort
            [self.biathleteArray addObject:biathlete];
            [self sortBiathleteArray:self.biathleteArray];
        }

        // Start cell timer
        [self startTimer:biathlete];

        // Clear text field and update cells
        self.bibNumToEnter.text = @"";
        [self.tableView reloadData];
    }

}

- (IBAction)stepperValueDidChanged:(UIStepper *)sender {

    // Replace athlete object at specific index with new athlete (the same bib number but new lap number)

    // First get UIStepper position in tableView
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];

    // Then use that index to edit biathlete
    if ([self.biathleteArray count]){
        Biathlete *biathleteToEdit = [self.biathleteArray objectAtIndex:indexPath.row];
        [biathleteToEdit.lapArray removeLastObject];
        Laps *addLaps = [Laps new];
        addLaps.lapCount = [NSString stringWithFormat:@"%d", (int)sender.value];
        [biathleteToEdit.lapArray addObject:addLaps];
        [self.biathleteArray replaceObjectAtIndex:indexPath.row withObject:biathleteToEdit];
    }
    [self.tableView reloadData];

}

-(void)removeAndSave:(Biathlete *)biathlete
{

    RLMRealm *realm = [RLMRealm defaultRealm];
    // Add to realm data, first checking to see if athlete already exists
    NSString *biathleteKey = biathlete.bibNum;
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"bibNum = %@", biathleteKey];

    RLMResults *biathleteExists = [Biathlete objectsWithPredicate:pred];


    if ([biathleteExists count] != 0){
        [realm beginWriteTransaction];
        Laps *addLaps = [biathlete.lapArray lastObject];
        [[biathleteExists.lastObject lapArray] addObject:addLaps];
        [realm commitWriteTransaction];
    } else{
        [realm beginWriteTransaction];
        [realm addObject:biathlete];
        [realm commitWriteTransaction];
    }

    // finally need to then remove from self.biathleteArray to update table view
    [self.biathleteArray removeObject:biathlete];

    [self.tableView reloadData];
}

-(void)sortBiathleteArray:(NSMutableArray *)unsortedArray
{
    NSArray *sortedArray;

    sortedArray = [unsortedArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSNumber *num1 = [NSNumber numberWithInteger:[[(Biathlete*)obj1 bibNum] integerValue]];
        NSNumber *num2 = [NSNumber numberWithInteger:[[(Biathlete*)obj2 bibNum] integerValue]];
        return [num1 compare:num2];
    }];

    [self.biathleteArray removeAllObjects];
    [self.biathleteArray addObjectsFromArray:sortedArray];
}

- (IBAction)endRace:(UIButton *)sender {

    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Race Complete?"
                                  message:@"Press YES to continue"
                                  preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"YES"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {

                             // Need to clear table view first
                             while ([self.biathleteArray count]){
                                 [self removeAndSave:[self.biathleteArray lastObject]];
                             }

                             [self performSegueWithIdentifier:@"endRaceSegue" sender:self];

                             [self.biathleteArray removeAllObjects];

                             [alert dismissViewControllerAnimated:YES completion:nil];


                         }];

    UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:@"NO"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {}];

    [alert addAction:ok];
    [alert addAction:cancel];

    [self presentViewController:alert animated:YES completion:nil];

}





@end
