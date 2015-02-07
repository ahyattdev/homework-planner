//
//  HWAboutViewController.m
//  HomeworkPlanner
//
//  Created by Andy Hyatt on 9/19/14.
//
//

#import "HWAboutViewController.h"

@interface HWAboutViewController ()

@end

@implementation HWAboutViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)done:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 3;
    } else return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Standard initialization
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    if (indexPath.section == 0 && indexPath.row == 0) {
        cell.textLabel.text = @"Programmer";
        cell.detailTextLabel.text = @"Andrew Hyatt";
    } if (indexPath.section == 0 && indexPath.row == 1) {
        cell.textLabel.text = @"Beta Tester";
        cell.detailTextLabel.text = @"Evan Mickas";
    } if (indexPath.section == 0 && indexPath.row == 2) {
        cell.textLabel.text = @"Graphics Designer";
        cell.detailTextLabel.text = @"Jonah Kallen";
    }
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"Credits";
    } else return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([MFMailComposeViewController canSendMail] && indexPath.section == 0) {
        MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
        controller.mailComposeDelegate = self;
        [controller setSubject:@"HW Planner"];
        [controller setMessageBody:@"I have some feedback about HW Planner for you. " isHTML:NO];
        if (indexPath.row == 0) {
            [controller setToRecipients:@[@"andys-email@domain.com"]];
        } else if (indexPath.row == 1) {
            [controller setToRecipients:@[@"evans-email@domain.com"]];
        } else if (indexPath.row == 2) {
            [controller setToRecipients:@[@"jonahs-email@domain.com"]];
        }
        [self presentViewController:controller animated:YES completion:nil];
    } else {
        // Handle the error
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
