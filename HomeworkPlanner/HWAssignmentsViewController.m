//
//  HWViewController.m
//  HomeworkPlanner
//
//  Created by Andrew Hyatt on 8/24/14.
//
//

#import "HWAssignmentsViewController.h"

@interface HWAssignmentsViewController ()

@property HWPreferencesManager *preferencesManager;
@property HWNotificationManager *notificationManager;
@property HWUtilities *utils;
@property (nonatomic)  NSMutableArray *assignments;
@property NSMutableArray *assignmentsToRetain;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addButton;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property BOOL isNotInitialLaunch;

@end

@implementation HWAssignmentsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    // Initializing our utility objects
    self.preferencesManager = [[HWPreferencesManager alloc] init];
    if (self.preferencesManager.settingsExist == NO) {
        [self.preferencesManager resetSettings];
    }
    // Loading of data
    [self loadData];
    // Notifications are done after loading data on purpose!
    HWNotificationManager *notificationManager = [[HWNotificationManager alloc] initWithMutableArray:self.assignments];
    self.notificationManager = notificationManager;
    self.utils = [[HWUtilities alloc] init];
    self.assignments = [NSMutableArray arrayWithArray:[self.utils testAssignments:100]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self saveData];
    self.assignmentsToRetain = [NSMutableArray array];
    if (self.tableView.contentOffset.y == 0) {
        [self.tableView setContentOffset:CGPointMake(0, 44)];
    } else if (self.tableView.contentOffset.y == -64) {
        self.tableView.contentOffset = CGPointMake(0, -20);
    }
    if (self.isNotInitialLaunch) {
        [self.tableView reloadData];
        [self.notificationManager scheduleNotificationsForNextWeek];
    }
    self.isNotInitialLaunch = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    [self saveData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // The "Assignment" segue brings up the Add Assignment modal view
    if ([segue.identifier isEqualToString:@"Assignment"]) {
        HWAddAssignmentNavigationController *assignmentNavigationController = [segue destinationViewController];
        [assignmentNavigationController setAssignments:_assignments];
        // Sender is the uuid, it is ok if sender is nil
        [assignmentNavigationController setUuidOfTargetAssignment:sender];
    } else if ([segue.identifier isEqualToString:@"Notes"]) {
        HWNotesNavigationController *notesNavigationController = [segue destinationViewController];
        notesNavigationController.assignment = sender;
    }
}

//Loading and saving of data

- (NSMutableArray *)assignments {
    if (!self.preferencesManager.showCompletedAssignments) {
        // Excluding some completed assignments
        // Predicate is for excluding the completed assignments. Completed assignments that should be retained are added in manually.
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isCompleted == NO"];
        NSMutableArray *assignments = [NSMutableArray arrayWithArray:[_assignments filteredArrayUsingPredicate:predicate]];
        // Add back the completedButRetainedAssignments, ignoring location in array. This is ok because the array is sorted by the assignments UUID after this!
        for (NSInteger x = 0; x < self.assignmentsToRetain.count; x ++) {
            HWAssignment *completedButRetainedAssignment = [self.assignmentsToRetain objectAtIndex:x];
            // Proceding with adding the assignment as long as it is not already in the array
            if (![assignments containsObject:completedButRetainedAssignment]) {
                [assignments addObject:completedButRetainedAssignment];
            }
        }
        // Now comes the sorting. Sorting by UUID then having self.utils sort the array.
        NSSortDescriptor *uuidSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"uuid" ascending:YES selector:@selector(compare:)];
        [assignments sortUsingDescriptors:@[uuidSortDescriptor]];
        [self.utils sortAssignmentsInArray:assignments];
        // Returning our array :)
        return assignments;
    } else {
        NSSortDescriptor *uuidSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"uuid" ascending:YES selector:@selector(compare:)];
        [_assignments sortUsingDescriptors:@[uuidSortDescriptor]];
        [self.utils sortAssignmentsInArray:_assignments];
    } return _assignments; // If showing completed assignments is enabled, then the regular assignments array will be returned
}

- (NSString *)applicationDocumentsDirectory {
    // Used for accessing the Documents directory
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

- (void)loadData {
    // Initiate self.assignments
    self.assignments = [NSMutableArray array];
    // Determining the path of assignments.plist
    NSString *assignmentsPath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"assignments.plist"];
    // Loading the dictionaries of assignments.plist into an array
    NSArray *loadedAssignmentDictionaries = [[NSArray alloc] initWithContentsOfFile:assignmentsPath];
    if (loadedAssignmentDictionaries != nil) {
        // Recursively adding assignments for every dictionary in loadedAssignmentDictionaries
        for (int x = 0; x < [loadedAssignmentDictionaries count]; x ++) {
            // Using the special init method for dictionaries of HWAssignment
            HWAssignment *assignment = [[HWAssignment alloc] initWithContentsOfDictionary:[loadedAssignmentDictionaries objectAtIndex:x]];
            [_assignments addObject:assignment];
        }
    }
}

- (void)saveData {
    // Assignments will be saved by creating a dictionary for every assignment, then writing those dictionaries to assignments.plist
    // It would be better to use NSCoder, but I did not know about that class when I came up with this method for retaining assignments between app launches
    NSMutableArray *dictionariesFromAssignments = [[NSMutableArray alloc] init];
    for (int x = 0; x < [_assignments count]; x ++) {
        // Populating the array with a dictionary
        HWAssignment *assignment = [_assignments objectAtIndex:x];
        NSDictionary *dictionaryFromAssignment = [assignment createDictionaryFromAssignment];
        [dictionariesFromAssignments addObject:dictionaryFromAssignment];
    }
    // Determing the path to write the plist to
    NSString *assignmentsPath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"assignments.plist"];
    NSError *error;
    NSData *plist = [NSPropertyListSerialization dataWithPropertyList:dictionariesFromAssignments format:NSPropertyListXMLFormat_v1_0 options:0 error:&error];
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSError *fileManagerError;
    // Deleting the file before we write a new one
    [fileManager removeItemAtPath:assignmentsPath error:&fileManagerError];
    [plist writeToFile:assignmentsPath atomically:YES];
}

// UIBarButtonItem actions

- (IBAction)editButtonPressed:(id)sender {
    // The function of the Edit/Done button. Pretty self-explanatory.
    if (self.tableView.isEditing == NO) {
        self.editButton.style = UIBarButtonItemStyleDone;
        self.editButton.title = @"Done";
        [self.tableView setEditing:YES];
    } else {
        self.editButton.style = UIBarButtonItemStylePlain;
        self.editButton.title = @"Edit";
        [self.tableView setEditing:NO];
    }
}

- (IBAction)addButtonPressed:(id)sender {
    [self performSegueWithIdentifier:@"Assignment" sender:nil];
}

// Configuration methods for the table views

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.preferencesManager.assignmentsSortMode == 1) {
        return [self.utils coursesOfAssignmentsInArray:self.assignments].count;
    } else if (self.assignments.count == 0) {
    return 0;
    } else return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Determine which table view called this method
    if ([tableView isEqual:self.tableView] == YES) {
        // Act differently if the assignments are sorted by course
        if (self.preferencesManager.assignmentsSortMode == 1) {
            NSArray *courses = [self.utils coursesOfAssignmentsInArray:self.assignments];
            // Count the assignments and return it
            NSInteger elvis = [self.utils assignmentsForCourse:[courses objectAtIndex:section] inArray:self.assignments].count;
            return elvis;
        } else return self.assignments.count;
    } else {
        // Number of rows depends on what the user searched for
        return [self.utils searchForTitle:self.searchBar.text inArray:self.assignments].count;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    // The title is gotten with self.utils. See there for what it is doing!
    if ([tableView isEqual:self.tableView] == YES) {
        if (self.preferencesManager.assignmentsSortMode == 1) {
            NSArray *courses = [self.utils coursesOfAssignmentsInArray:self.assignments];
            HWAssignment *assignment = [self.utils assignmentsForCourse:[courses objectAtIndex:section] inArray:self.assignments].firstObject;
            return assignment.course.capitalizedString;
        }
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HWAssignment *assignment;
    // Will be set depending on which table view this method is returning the cell for
    if ([tableView isEqual:self.tableView] == YES) {
        if (self.preferencesManager.assignmentsSortMode == 1) {
            assignment = [self.utils assignmentForIndexPath:indexPath inArray:self.assignments];
        } else {
            assignment = [self.assignments objectAtIndex:indexPath.row];
        }
    } else {
        assignment = [[self.utils searchForTitle:self.searchBar.text inArray:self.assignments] objectAtIndex:indexPath.row];
    }
    // Configuring the cell has been outsourced to HWUtilities, for the simplicity of this class
    return [self.utils cellForAssignment:assignment inTableView:tableView];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Get a pointer to the cell so we can access it's assignment
    HWAssignmentCell *cellThatWasSelected = (HWAssignmentCell *)[[self tableView] cellForRowAtIndexPath:indexPath];
    if (cellThatWasSelected.assignment.isCompleted) {
        // If the assignment is already completed, set completed to NO, then remove the assignment from the list of assignments to retain
        cellThatWasSelected.assignment.isCompleted = NO;
        [self.assignmentsToRetain removeObject:cellThatWasSelected.assignment];
    } else {
        // If the assignment is not completed, add the assignment to the list of assignments that are retained, then set completed to YES
        [self.assignmentsToRetain addObject:cellThatWasSelected.assignment];
        cellThatWasSelected.assignment.isCompleted = YES;
    }
    // Reloading is necesary to get the effects on the text of the cell
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES; // Allows editing
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    [self tableView:tableView deleteRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView deleteRowAtIndexPath:(NSIndexPath *)indexPath {
    // Get the cell that is being deleted
    HWAssignmentCell *cell = (HWAssignmentCell *)[tableView cellForRowAtIndexPath:indexPath];
    // Delete the assignment for the cell
    [_assignments removeObject:cell.assignment];
    if ([self.assignmentsToRetain containsObject:cell.assignment]) {
        // Make sure the assignment is not being retained!
        [self.assignmentsToRetain removeObject:cell.assignment];
    }
    [tableView beginUpdates];
    if ([tableView isEqual:self.tableView] == YES) {
        // Deletion method for the main table view
        if ([tableView numberOfRowsInSection:indexPath.section] == 1) {
            [tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationLeft];
        } else {
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        }
    } else {
        // Deletion method for the UISearchDisplayController view
        HWAssignmentCell *cell = (HWAssignmentCell *)[tableView cellForRowAtIndexPath:indexPath];
        [self.assignments removeObject:cell.assignment];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    }
    [tableView endUpdates];
    [self saveData];
}

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    HWAssignmentCell *assignmentCell = (HWAssignmentCell *)[[self tableView] cellForRowAtIndexPath:indexPath];
    HWAssignment *assignment = [assignmentCell assignment];
    [self performSegueWithIdentifier:@"Assignment" sender:[assignment uuid]];
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    HWAssignmentCell *activeCell = (HWAssignmentCell *)[tableView cellForRowAtIndexPath:indexPath];
    UITableViewRowAction *notes = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Notes" handler: ^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        [self performSegueWithIdentifier:@"Notes" sender:activeCell.assignment];
    }];
    UITableViewRowAction *delete = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"Delete" handler: ^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        [self tableView:tableView deleteRowAtIndexPath:indexPath];
    }];
    return @[delete, notes];
}

@end
