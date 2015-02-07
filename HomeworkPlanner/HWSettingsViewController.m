//
//  HWSettingsController.m
//  HomeworkPlanner
//
//  Created by Andrew Hyatt on 8/30/14.
//
//

#import "HWSettingsViewController.h"

@interface HWSettingsViewController ()

@property HWPreferencesManager *preferencesManager;
@property HWUtilities *utils;
@property UISwitch *localNotificationsSwitch;
@property UISwitch *showCompletedAssignmentsSwitch;
@property UIDatePicker *timeToNotifyOfAssignmentsCellDatePicker;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property BOOL debugMode;

@end

@implementation HWSettingsViewController

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
    // Do any additional setup after loading the vi
    self.preferencesManager = [[HWPreferencesManager alloc] init];
    self.utils = [[HWUtilities alloc] init];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)resetSettings {
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }else if (section == 1) {
        if (self.preferencesManager.localNotificationsEnabled == YES) {
            return 3;
        } else return 1;
    } else if (section == 2) {
        return 1;
    } else if (section == 3) {
        return 1;
    } else return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        // Assignment Sort Mode Cell
        if (indexPath.row == 0) {
            static NSString *cellIdentifier = @"AssignmentSortModeCell";
            UITableViewCell *assignmentSortModeCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (assignmentSortModeCell == nil) {
                assignmentSortModeCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
            }
            assignmentSortModeCell.textLabel.text = @"Assignments Sort Mode";
            NSString *sortType;
            if (self.preferencesManager.assignmentsSortMode == 0) {
                sortType =@"Date Due";
            } else if (self.preferencesManager.assignmentsSortMode == 1) {
                sortType = @"Course";
            } else if (self.preferencesManager.assignmentsSortMode == 2) {
                sortType = @"Title";
            }
            assignmentSortModeCell.detailTextLabel.text = sortType;
            return assignmentSortModeCell;
        } else return nil;
    } else if (indexPath.section == 1) {
        // Local Notifications Enabled Switch Cell
        if (indexPath.row == 0) {
            static NSString *cellIdentifier = @"SwitchCell";
            HWSwitchCell *localNotificationsSwitchCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (localNotificationsSwitchCell == nil) {
                localNotificationsSwitchCell = [[HWSwitchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            }
            localNotificationsSwitchCell.textLabel.text = @"Local Notifications";
            self.localNotificationsSwitch = localNotificationsSwitchCell.swatch;
            self.localNotificationsSwitch.on = self.preferencesManager.localNotificationsEnabled;
            return localNotificationsSwitchCell;
        } else if (indexPath.row == 1) {
            // Time to notify of assignments cell
            static NSString *cellIdentifier = @"TimeToNotifyOfAssignmentsCellCustom";
            UITableViewCell *timeToNotifyOfAssignmentsCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (timeToNotifyOfAssignmentsCell == nil) {
                timeToNotifyOfAssignmentsCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                UIDatePicker *datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 0, 320, 216)];
                [timeToNotifyOfAssignmentsCell.contentView addSubview:datePicker];
                [datePicker addTarget:self action:@selector(datePickerChanged) forControlEvents:UIControlEventValueChanged];
                datePicker.datePickerMode = UIDatePickerModeTime;
                datePicker.minuteInterval = 5;
                self.timeToNotifyOfAssignmentsCellDatePicker = datePicker;
            }
            NSDateComponents *components = [[NSDateComponents alloc] init];
            components.calendar = [NSCalendar currentCalendar];
            components.hour = self.preferencesManager.hourOfDayToNotifyAboutAssignments;
            components.minute = self.preferencesManager.minuteOfDayToNotifyAboutAssignments;
            self.timeToNotifyOfAssignmentsCellDatePicker.date = [components date];
            return timeToNotifyOfAssignmentsCell;
        } else if (indexPath.row == 2) {
            // School days that assignments are enabled for cell
            static NSString *cellIdentifier = @"DaysToRemindOfAssignmentsCell";
            UITableViewCell *daysToRemindOfAssignmentsCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (daysToRemindOfAssignmentsCell == nil) {
                daysToRemindOfAssignmentsCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
            }
            daysToRemindOfAssignmentsCell.textLabel.text = @"School Days";
            daysToRemindOfAssignmentsCell.detailTextLabel.text = [NSString stringWithFormat:@"%ld days", (long)[self.utils numberOfDaysEnabled:self.preferencesManager.schoolDays]];
            return daysToRemindOfAssignmentsCell;
        } else return nil;
    } else if (indexPath.section == 2 && indexPath.row == 0) {
        static NSString *cellIdentifier = @"SwitchCell";
        HWSwitchCell *showCompletedAssignmentsCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (showCompletedAssignmentsCell == nil) {
            showCompletedAssignmentsCell = [[HWSwitchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        showCompletedAssignmentsCell.textLabel.text = @"Show Completed Items";
        self.showCompletedAssignmentsSwitch = showCompletedAssignmentsCell.swatch;
        showCompletedAssignmentsCell.swatch.on = self.preferencesManager.showCompletedAssignments;
        return showCompletedAssignmentsCell;
    } else if (indexPath.section == 3) {
        if (indexPath.row == 0) {
            // Reset settings cell
            static NSString *cellIdentifier = @"ResetSettingsCell";
            UITableViewCell *resetSettingsCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (resetSettingsCell == nil) {
                resetSettingsCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            }
            resetSettingsCell.textLabel.text = @"Reset Settings";
            resetSettingsCell.textLabel.textAlignment = NSTextAlignmentCenter;
            return resetSettingsCell;
        } else return nil;
    } else return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0 && indexPath.row == 0) {
        UIActionSheet *chooseSortMode = [[UIActionSheet alloc] initWithTitle:@"Sort by:" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Date Due", @"Course", @"Title", nil];
        chooseSortMode.tag = 1;
        [chooseSortMode showInView:[UIApplication sharedApplication].keyWindow];
    } else if (indexPath.section == 3 && indexPath.row == 0) {
        UIActionSheet *resetSettings = [[UIActionSheet alloc] initWithTitle:@"This will reset the settings for this app. Your assignments will not be lost." delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Reset Settings" otherButtonTitles:nil];
        resetSettings.tag = 2;
        [resetSettings showInView:[UIApplication sharedApplication].keyWindow];
    } else if (indexPath.section == 1 && indexPath.row == 2) {
        [self performSegueWithIdentifier:@"SchoolDays" sender:self];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        //return @"You will be told how much homework you have on schooldays at this time";
        return nil;
    } else return nil;
}

- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (popup.tag) {
        case 1: {
            switch (buttonIndex) {
                case 0:
                    self.preferencesManager.assignmentsSortMode = 0;
                    break;
                case 1:
                    self.preferencesManager.assignmentsSortMode = 1;
                    break;
                case 2:
                    self.preferencesManager.assignmentsSortMode = 2;
                    break;
            }
            break;
        }case 2: {
            switch (buttonIndex) {
                case 0:
                    [self.preferencesManager resetSettings];
                    [self.tableView reloadData];
                    break;
            }
            break;
        }
        default:
            break;
    }
    [self.tableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
if (indexPath.section == 1 && indexPath.row == 1) {
    // The height of the date picker
    return 216;
    } else return 44; // The height of every other cell
}

- (IBAction)switchValueChanged:(id)sender {
    if (sender == self.localNotificationsSwitch) {
        self.preferencesManager.localNotificationsEnabled = self.localNotificationsSwitch.on;
        //[self.tableView reloadData];
        if (self.localNotificationsSwitch.on) {
            [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:1], [NSIndexPath indexPathForRow:2 inSection:1]] withRowAnimation:UITableViewRowAnimationBottom];
            self.timeToNotifyOfAssignmentsCellDatePicker.hidden = NO;
        } else {
            self.timeToNotifyOfAssignmentsCellDatePicker.hidden = YES;
            [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:1], [NSIndexPath indexPathForRow:2 inSection:1]] withRowAnimation:UITableViewRowAnimationTop];
        }
    } else if (sender == self.showCompletedAssignmentsSwitch) {
        self.preferencesManager.showCompletedAssignments = self.showCompletedAssignmentsSwitch.on;
    }
}

- (void)datePickerChanged {
    NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:self.timeToNotifyOfAssignmentsCellDatePicker.date];
    self.preferencesManager.hourOfDayToNotifyAboutAssignments = components.hour;
    self.preferencesManager.minuteOfDayToNotifyAboutAssignments = components.minute;
}

@end
