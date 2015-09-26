//
//  ResultsTableViewController.m
//  PenaltyLapCounter
//
//  Created by Philip Henson on 9/24/15.
//  Copyright © 2015 Phil Henson. All rights reserved.
//

#import "ResultsTableViewController.h"
#import "Biathlete.h"

@interface ResultsTableViewController () <UITableViewDataSource, UITableViewDelegate>


@property NSMutableArray *fullResults;

@end

@implementation ResultsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.hidesBackButton = YES;
    UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(back:)];
    self.navigationItem.leftBarButtonItem = newBackButton;

    RLMResults *allBiathletes = [Biathlete allObjects];
    self.fullResults = [NSMutableArray new];

    for (Biathlete *biathlete in allBiathletes) {
        NSMutableArray *lapArray = [NSMutableArray new];
        for (Laps *laps in biathlete.lapArray){
            [lapArray addObject:laps.lapCount];
        }
        NSString *lapString = [lapArray componentsJoinedByString:@", "];
        [self.fullResults addObject:[NSString stringWithFormat:@"%@: %@", biathlete.bibNum, lapString]];
    }

    [self sortBiathleteArray:self.fullResults];
    [self.tableView reloadData];

    
    self.title = @"Penalty Lap Results";

}

-(void)sortBiathleteArray:(NSMutableArray *)unsortedArray
{
    NSArray *sortedArray;

    sortedArray = [unsortedArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSNumber *num1 = [NSNumber numberWithInteger:[obj1 integerValue]];
        NSNumber *num2 = [NSNumber numberWithInteger:[obj2 integerValue]];
        return [num1 compare:num2];
    }];

    [self.fullResults removeAllObjects];
    [self.fullResults addObjectsFromArray:sortedArray];
}

- (void) back:(UIBarButtonItem *)sender {

    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"You are leaving the results page"
                                  message:@"Pressing YES will clear lap data and return to main screen"
                                  preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"YES"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [self.navigationController popViewControllerAnimated:YES];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.fullResults count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ResultsCell" forIndexPath:indexPath];

    cell.textLabel.font = [UIFont systemFontOfSize:16];
    
    if ([self.fullResults count]){
        cell.textLabel.text = [self.fullResults objectAtIndex:indexPath.row];
    }
    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    NSDate *localDate = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm MM/dd/yy "];
    NSString *stringFromDate = [formatter stringFromDate:localDate];
    NSString *sectionName = [NSString stringWithFormat:@"Race Time and Date: %@", stringFromDate];

    return sectionName;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
