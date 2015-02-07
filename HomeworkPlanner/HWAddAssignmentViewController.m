//
//  HWAssignmentViewController.m
//  HomeworkPlanner
//
//  Created by Andrew Hyatt on 8/24/14.
//
//

#import "HWAddAssignmentViewController.h"

@interface HWAddAssignmentViewController ()

@property HWUtilities *utils;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UITextField *titleCellTextField;
@property (strong, nonatomic) UITextField *courseCellTextField;
@property (strong, nonatomic) UIDatePicker *dateDueCellDatePicker;
@property UIPickerView *coursePicker;
@end

@implementation HWAddAssignmentViewController

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
    if (self.uuidOfTargetAssignment != nil) {
        self.navigationItem.title = @"Edit Assignment";
    } else {
        self.navigationItem.title = @"Add Assignment";
    }
    self.utils = [HWUtilities new];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//UIBarButtonItem actions

- (IBAction)cancelButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)doneButtonPressed:(id)sender {
    if ([[[self titleCellTextField] text] isEqualToString:@""] == YES) {
        UIAlertView *alert =[[UIAlertView alloc ] initWithTitle:@"Title is empty" message:@"You can not leave the title blank" delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
        [alert addButtonWithTitle:@"OK"];
        [alert show];
    } else if ([[[self courseCellTextField] text] isEqualToString:@""] && [self isSetToOther]) {
        UIAlertView *alert =[[UIAlertView alloc ] initWithTitle:@"Course is empty" message:@"You can not leave the course blank" delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
        [alert addButtonWithTitle:@"OK"];
        [alert show];
    } else if ([self.titleCellTextField.text isEqualToString:@"Course"]) {
        UIAlertView *alert =[[UIAlertView alloc ] initWithTitle:@"Bad name" message:@"You can not set course to \"Course\"" delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
        [alert addButtonWithTitle:@"OK"];
        [alert show];
    } else {
        HWAssignment *assignment = [self.utils assignmentForUUID:self.uuidOfTargetAssignment inArray:self.assignments];
        if (!assignment) {
            assignment = [[HWAssignment alloc] init];
        }
        [assignment setTitle:[[self titleCellTextField] text]];
        if ([self isSetToOther] == YES) {
            [assignment setCourse:[[self courseCellTextField] text]];
        } else {
            NSArray *courses = [self.utils coursesOfAssignmentsInArray:self.assignments];
            assignment.course = [courses objectAtIndex:[self.coursePicker selectedRowInComponent:0]];
        }
        assignment.notes = @"";
        [assignment setDateDue:[[self dateDueCellDatePicker] date]];
        if (![self uuidOfTargetAssignment]) {
            [assignment setUuid:[NSUUID UUID]];
            [self.assignments addObject:assignment];
        }
        [[self navigationController] dismissViewControllerAnimated:YES completion:nil];
        }
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

//Begin configuring the UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } if (section == 1) {
        return 2;
    } else if (section == 2) {
        return 2;
    } else return 0;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HWAssignment *assignment = [self.utils assignmentForUUID:self.uuidOfTargetAssignment inArray:self.assignments];
    if (indexPath.section == 0 && indexPath.row == 0) {
        // Title cell
        static NSString *cellIdentifier = @"TextFieldCell";
        HWTextFieldCell *titleCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (titleCell == nil) {
            titleCell = [[HWTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        self.titleCellTextField = titleCell.textField;
        if (assignment) {
            [[titleCell textField] setText:[assignment title]];
        } else {
            self.titleCellTextField.placeholder = @"Title";
        }
        return titleCell;
    } else if (indexPath.section == 1 && indexPath.row == 0) {
        // Course picker
        static NSString *cellIdentifier = @"CoursePickerCell";
        UITableViewCell *coursePickerCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (coursePickerCell == nil) {
            coursePickerCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            UIPickerView *coursePicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, 320, 216)];
            [coursePickerCell.contentView addSubview:coursePicker];
            coursePicker.delegate = self;
            coursePicker.dataSource = self;
            self.coursePicker = coursePicker;
            if (assignment != nil) {
                NSArray *courses = [self.utils coursesOfAssignmentsInArray:self.assignments];
                NSInteger rowForCourseName = 0;
                for (NSInteger x = 0; x < courses.count; x ++) {
                    NSString *string = [courses objectAtIndex:x];
                    if ([[string capitalizedString] isEqualToString:[assignment.course capitalizedString]] == YES) {
                        rowForCourseName = x;
                    }
                }
                [coursePicker reloadAllComponents];
                [coursePicker selectRow:rowForCourseName inComponent:0 animated:YES];
            }
        }
        return coursePickerCell;
    } else if (indexPath.section == 1 && indexPath.row == 1) {
        // Course cell
        static NSString *cellIdentifier = @"TextFieldCell";
        HWTextFieldCell *courseCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (courseCell == nil) {
            courseCell = [[HWTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        self.courseCellTextField = courseCell.textField;
        if (assignment != nil) {
            [[courseCell textField] setPlaceholder:[assignment course]];
        } else {
            NSArray *courses = [self.utils coursesOfAssignmentsInArray:self.assignments];
            if (courses.firstObject) {
                courseCell.textField.placeholder = [courses firstObject];
            } else courseCell.textField.placeholder = @"Course";
        }
        return courseCell;
    } else if (indexPath.section == 2 && indexPath.row == 0) {
        // Date picker cell header
        static NSString *cellIdentifier = @"DatePickerCellHeader";
        UITableViewCell *datePickerCellHeader = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (datePickerCellHeader == nil) {
            datePickerCellHeader = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        }
        datePickerCellHeader.textLabel.text = @"Date Due";
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterShortStyle];
        [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
        if (self.uuidOfTargetAssignment == nil) {
            NSDate *date;
            if (self.dateDueCellDatePicker.date == nil) {
                date = [[NSDate alloc] initWithTimeIntervalSince1970:[[NSDate date] timeIntervalSince1970] + 86400];
            } else {
                date = self.dateDueCellDatePicker.date;
            }
            datePickerCellHeader.detailTextLabel.text = [dateFormatter stringFromDate:date];
        } else {
        datePickerCellHeader.detailTextLabel.text = [dateFormatter stringFromDate:assignment.dateDue];
        }
        return datePickerCellHeader;
    } else if (indexPath.section == 2 && indexPath.row == 1) {
        // Date picker cell
        static NSString *cellIdentifier = @"DatePickerCell";
        HWDatePickerCell *dateDueDatePickerCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (dateDueDatePickerCell == nil) {
            dateDueDatePickerCell = [[HWDatePickerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        HWUtilities *utils = [[HWUtilities alloc] init];
        NSDate *cleanedDate = [NSDate new];
        self.dateDueCellDatePicker = dateDueDatePickerCell.datePicker;
        if (assignment != nil) {
            cleanedDate = [utils removeTimeFromDate:assignment.dateDue];
        } else {
            cleanedDate = [NSDate dateWithTimeIntervalSince1970:[[utils removeTimeFromDate:[NSDate date]] timeIntervalSince1970] + 86400];
        }
        dateDueDatePickerCell.datePicker.date = cleanedDate;
        return dateDueDatePickerCell;
    } else return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [cell setSelected:false animated:true];
}

- (BOOL)isSetToOther {
    NSArray *courses = [self.utils coursesOfAssignmentsInArray:self.assignments];
    if (courses.count == [self.coursePicker selectedRowInComponent:0]) {
        return YES;
    } else return NO;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField isEqual:[self titleCellTextField]] == YES) {
        [self.titleCellTextField resignFirstResponder];
        return YES;
    } else if ([textField isEqual:[self courseCellTextField]]) {
        [[self courseCellTextField] resignFirstResponder];
        return YES;
    } else return NO;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if ([self isSetToOther] == NO && textField == self.courseCellTextField) {
        return NO;
    } else if (textField == self.courseCellTextField) {
        //[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        CGPoint origin = textField.frame.origin;
        CGPoint point = [textField.superview convertPoint:origin toView:self.tableView];
        float navBarHeight = self.navigationController.navigationBar.frame.size.height;
        CGPoint offset = self.tableView.contentOffset;
        // Adjust the below value as you need
        offset.y += (point.y - navBarHeight - 194);
        [self.tableView setContentOffset:offset animated:YES];
        return YES;
    } else return YES;
}

- (IBAction)datePickerValueChanged:(id)sender {
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:2]] withRowAnimation:UITableViewRowAnimationNone];
}


- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    NSArray *courses = [self.utils coursesOfAssignmentsInArray:self.assignments];
    return courses.count + 1;
}

 - (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSArray *courses = [self.utils coursesOfAssignmentsInArray:self.assignments];
    if (row == courses.count) {
        return @"Other";
    } else return [courses objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSArray *courses = [self.utils coursesOfAssignmentsInArray:self.assignments];
    if (row != courses.count) {
        [[self courseCellTextField] resignFirstResponder];
        self.courseCellTextField.text = nil;
        self.courseCellTextField.placeholder = [courses objectAtIndex:row];
    } else {
        self.courseCellTextField.placeholder = @"Course";
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1 && indexPath.row == 0) {
        return 216;
    } else if (indexPath.section == 2 && indexPath.row == 1) {
        return 216;
    } else return 44;
}

@end
