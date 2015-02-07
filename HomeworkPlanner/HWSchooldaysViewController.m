//
//  HWSchooldaysViewController.m
//  HomeworkPlanner
//
//  Created by Andy Hyatt on 9/13/14.
//
//

#import "HWSchooldaysViewController.h"

@interface HWSchooldaysViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property HWPreferencesManager *preferencesManager;

@end

@implementation HWSchooldaysViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.preferencesManager = [[HWPreferencesManager alloc] init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doneButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Dynamically get amount of weekdays. Compatible with weird calendars.
    return [[[NSDateFormatter new] weekdaySymbols] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"You will be notified about your homework on the days selected";
    } else return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    NSNumber *number = [self.preferencesManager.schoolDays objectForKey:[[[NSDateFormatter new] weekdaySymbols] objectAtIndex:indexPath.row]];
    if ([number boolValue] == YES) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    cell.textLabel.text = [[[NSDateFormatter new] weekdaySymbols] objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    NSMutableDictionary *temporaryDictionary = [NSMutableDictionary dictionaryWithDictionary:self.preferencesManager.schoolDays];
    if (cell.accessoryType == UITableViewCellAccessoryNone) {
        [temporaryDictionary setValue:[NSNumber numberWithBool:YES] forKey:[[[NSDateFormatter new] weekdaySymbols] objectAtIndex:indexPath.row]];
    } else {
        [temporaryDictionary setValue:[NSNumber numberWithBool:NO] forKey:[[[NSDateFormatter new] weekdaySymbols] objectAtIndex:indexPath.row]];
    }
    self.preferencesManager.schoolDays = [NSDictionary dictionaryWithDictionary:temporaryDictionary];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

@end
