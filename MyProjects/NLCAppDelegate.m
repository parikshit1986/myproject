//
//  NLCAppDelegate.m
//  MyProjects
//
//  Created by Gaige B. Paulsen on 5/21/14.
//  Copyright (c) 2014 Gaige B. Paulsen. All rights reserved.
//

@import CoreData;

#import "NLCAppDelegate.h"
#import "NLCImplication.h"
#import "NLCExperience.h"
#import "NLCBarrier.h"
#import "NLCTask.h"
#import "NLCStakeholder.h"
#import "NLCProject.h"
#import "NLCResource.h"
#import "NLCRootViewController.h"
#import "NLCProjectOverviewViewController.h"

typedef enum {
    kNLCAppDelegateAlerts_sendDatabase=1,
    kNLCAppDelegateAlerts_unexpectedError=2,
} NLCAppDelegateAlerts;

@implementation NLCAppDelegate
@synthesize checkShareCondStr,prodOrCountProduct;
@synthesize flagRank , resourceParentObject , resourceSourceObject,resourceTargetObject , isDuplicate;
@synthesize pageControl;
@synthesize isReload,selectedProject , isCellMoving , isSampleData , currentEditedIndexPath,currentEditedTextView, isPanStarted;
@synthesize elementType,tableBarrier;
@synthesize barrierController ;
@synthesize blurView, viewAddElementPopup;
@synthesize  parentIndexPath , profileImageName;
@synthesize scrollOffset , shareBarrierName , shareIsBarrierorResource;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    checkShareCondStr=@"0";
    profileImageName = @"";
    shareBarrierName = @"";
    //madhvi
    flagRank = 0;
    isReload = NO;
    isDuplicate = NO;
    isCellMoving = NO;
    isSampleData = NO;
    elementType = @"";
    tableBarrier = @"barriers";
    isPanStarted =NO;
    
    parentIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    currentEditedIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    barrierController = [storyboard instantiateViewControllerWithIdentifier:@"Barriers"];
    //listTableController = [[NLCListTableViewController alloc]init];
    previousData = [NSUserDefaults standardUserDefaults];
   // [previousData setBool:NO forKey:@"previousVersionIsInstalled"];
    /** Data Preservance **/
    
//#ifndef RELEASE
//    [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:@""];
//    [[BITHockeyManager sharedHockeyManager] startManager];
//    [[BITHockeyManager sharedHockeyManager].authenticator authenticateInstallation];
//#else
//    [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:@""];
//    [[BITHockeyManager sharedHockeyManager] startManager];
//#endif
    
    //[self myCustomFontName];
    
    blurView=[[UIView alloc] initWithFrame:CGRectMake(0, 0,self.window.frame.size.width, self.window.frame.size.height)];
    //[self.window addSubview:blurView];
    blurView.backgroundColor = [UIColor colorWithRed:0/255.0f green:0/255.0f blue:0/255.0f alpha:0.35];
    // blurView.backgroundColor = [UIColor  redColor];
    blurView.hidden=YES;
    
    if(![[NSUserDefaults standardUserDefaults] objectForKey:@"nc"])
        [[NSUserDefaults standardUserDefaults] setObject:@"00000001" forKey:@"nc"];
    
    if(![[NSUserDefaults standardUserDefaults] objectForKey:@"cnonce"])
        [[NSUserDefaults standardUserDefaults] setObject:@"20000000" forKey:@"cnonce"];
    
    return YES;
}


-(NSString *)currentProjectID
{
    NSString *currentProjectID = [[NSUserDefaults standardUserDefaults] stringForKey: @"CurrentProjectID"];
    
    return  currentProjectID;
}

-(void)setCurrentProject:(NLCProject *)currentProject
{
    if (!currentProject) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"CurrentProjectID"];
        return;
    }
    NSString *projectIDString = currentProject.objectID.URIRepresentation.absoluteString;
    [[NSUserDefaults standardUserDefaults] setObject: projectIDString forKey: @"CurrentProjectID"];
}

-(NLCProject *)currentProject
{
    NLCProject *project=nil;
    NSString *currentProjectID = [self currentProjectID];
    if (currentProjectID) {
        NSURL *urlID = [NSURL URLWithString: currentProjectID];
        if (urlID) {
            NSManagedObjectID *objID = [self.managedObjectContext.persistentStoreCoordinator managedObjectIDForURIRepresentation:urlID];
            if (objID) {
                NSError *error;
                project =(NLCProject*)[self.managedObjectContext existingObjectWithID:objID  error: &error];
                if (!project)
                    currentProjectID =nil;
                NSAssert([project isKindOfClass: [NLCProject class]], @"Wrong type for project");
            }
        }
    }
    
    if (project) {
        //[self createInitialData:project];
//        NSLog( @"Should open project %@ = %@",currentProjectID,project);
    } else {
//        NSLog( @"Starting at beginning");
    }
    return project;
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case kNLCAppDelegateAlerts_sendDatabase:
            // handle our send saved database response
            if (buttonIndex==alertView.cancelButtonIndex) {
                // user doesn't want to send it, so delete it
            } else {
                // user says it's OK to send
                [self sendDatabaseForDiagnostics];
            }
            break;
        case kNLCAppDelegateAlerts_unexpectedError:
        default:
            break;
    }
}

#pragma mark Unexpected error handling
-(void)promptForUnexpectedError:(NSError*)error
{
    NSString *appName = @"Canvas";
    NSString *message = [NSString stringWithFormat: NSLocalizedString( @"An unexpected erorr occurred.  %@ will try and continue.  Please report this to NEXT %@ (%u)", @"Error"), appName, error.domain, error.code, error.localizedDescription];
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:NSLocalizedString( @"Unexpected Error", @"Errors")
                          message: message
                          delegate:self
                          cancelButtonTitle:NSLocalizedString(@"Don't Send", @"Errors")
                          otherButtonTitles:NSLocalizedString(@"Send", @"Errors"), nil];
    alert.tag=kNLCAppDelegateAlerts_unexpectedError;
    [alert show];
    
    // TODO: send to the server for diagnostics
}

#pragma mark Inconsistent database handling
-(void)promptForInconsistentDatabase:(NSError*)error
{
    NSString *message = [NSString stringWithFormat: NSLocalizedString( @"The database on this device is inconsistent. Please report this to NEXT %@ (%u).  A new database will be created. May we send the old database to NEXT for diagnosis?  ", @"Error"), error.domain, error.code];
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:NSLocalizedString( @"Inconsistent Database", @"Errors")
                          message: message
                          delegate:self
                          cancelButtonTitle:NSLocalizedString(@"Don't Send", @"Errors")
                          otherButtonTitles:NSLocalizedString(@"Send", @"Errors"), nil];
    alert.tag=kNLCAppDelegateAlerts_sendDatabase;
    [alert show];
}

- (BOOL)hasSavedDatabase
{
    // TODO: check to see if we've saved the database
    return NO;
}

- (void)prepareDatabaseForDiagnostics
{
    // TODO: save the data store
    // Preprare to ship it off in some secure form
}

- (void)sendDatabaseForDiagnostics
{
    // TODO: send the currently saved database for diagnostics in prepared form
    // After definitive acknowledgement, remove it
}

- (void)deleteDatabaseForDiagnostics
{
    // TODO: remove the queued database for diagnostics
}

- (void)createSampleData:(NSManagedObjectContext*)moc
{
    NLCProject *project = (NLCProject*)[NSEntityDescription insertNewObjectForEntityForName:@"Project" inManagedObjectContext:moc];
    NSAssert( project, @"Need project");
    project.name =@"Demo Project";
    project.intentions = @"It is my intention for this project to be a big success";
    project.objective = @"It is the objective to be successful in this project";
    
    // Implications
    NSArray *placeholders = @[ @"First", @"Second", @"Third"];
    for (NSUInteger row=0;row<placeholders.count;row++ ) {
        NSString *name = placeholders[row];
        NLCImplication *implication = (NLCImplication*)[NSEntityDescription insertNewObjectForEntityForName: @"Implication" inManagedObjectContext:moc];
        implication.name = [NSString stringWithFormat: @"%@ implication",name];
        implication.position = @(row);
        implication.onLeft = @(row%2==0);
        [project addImplicationsObject: implication];
        
        // Experiences
        NLCExperience *experience = (NLCExperience*)[NSEntityDescription insertNewObjectForEntityForName:@"Experience" inManagedObjectContext:moc];
        experience.name = [NSString stringWithFormat: @"%@ experience",name];
        experience.position = @(row);
        experience.onLeft = @(row%2==0);
        [project addExperiencesObject: experience];
        
     
        
        // Actions
        NLCTask *task = (NLCTask*)[NSEntityDescription insertNewObjectForEntityForName: @"Task" inManagedObjectContext: moc];
        task.name = [NSString stringWithFormat: @"%@ task",name];
        task.position = @(row);
        task.type = @"task";
        [project addTasksObject: task];
        
        
        // Barriers
        task = (NLCTask*)[NSEntityDescription insertNewObjectForEntityForName: @"Barrier" inManagedObjectContext: moc];
        task.name = [NSString stringWithFormat: @"%@ barrier",name];
        task.type = @"barrier";
        task.position = @(project.tasks.count + 1);
        [project addTasksObject: task];
        
        // Stakeholder
        NLCStakeholder *stakeholder = (NLCStakeholder*)[NSEntityDescription insertNewObjectForEntityForName: @"Stakeholder" inManagedObjectContext: moc];
        stakeholder.shortName = [NSString stringWithFormat: @"%@ stakeholder",name];
        stakeholder.position = @(row);
        stakeholder.rank = @(2);
        [project addStakeholdersObject: stakeholder];
    }
    
    [self saveAllChanges];
}

/* Hockey app auth*/
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if ([[url scheme] isEqualToString:@"myprojects"])
    {
        NSString *text = [[url host] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        text = [text stringByReplacingOccurrencesOfString:@"dot" withString:@":"];
        if (![text isEqualToString:@"textValue"])
        {
            NSError *error;
            NSData *data = [text dataUsingEncoding:NSUTF8StringEncoding];
            prodOrCountProduct=[[NSMutableDictionary alloc]init];
            prodOrCountProduct = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            
            checkShareCondStr=@"1";
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            NLCProjectOverviewViewController *ivc = [storyboard instantiateViewControllerWithIdentifier:@"AllProjects"];
            
            self.window.rootViewController= ivc ;
        }
        return YES;
    }
    else if( [[BITHockeyManager sharedHockeyManager].authenticator handleOpenURL:url
                                                               sourceApplication:sourceApplication
                                                                      annotation:annotation])
    {
        return YES;
    }
    
    return NO;
}
-(void)backToMyPatternApp
{
    NSString *strShare=@"textValue";
    UIApplication *ourApplication = [UIApplication sharedApplication];
    NSString *URLEncodedText = [strShare stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *ourPath = [@"mypatterns://" stringByAppendingString:URLEncodedText];
    NSURL *ourURL = [NSURL URLWithString:ourPath];
    
    if ([ourApplication canOpenURL:ourURL])
    {
        [ourApplication openURL:ourURL];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@" MyPatterns App is not installed. It must be installed to share data." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
}
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)save
{
    NSError *error;
    if (![_managedObjectContext save: &error]) {
        [self promptForUnexpectedError: error];
    }
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    [self save];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Core Data
/*
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *) managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"ProjectModel" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

/*
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"ProjectModel.CDBStore"];
    //NSLog(@"storeURL=%@",storeURL);
    /*
     Set up the store.
     For the sake of illustration, provide a pre-populated default store.
     */
    
    NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption: @YES, NSInferMappingModelAutomaticallyOption: @YES};
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
    
    NSError *error;
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        [self prepareDatabaseForDiagnostics];
        [self promptForInconsistentDatabase: error];
        
        [[NSFileManager defaultManager] removeItemAtURL: storeURL error:nil];
        
        if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
            // BAD error at this point, since we couldn't reinitialize the datbase
            [self promptForUnexpectedError: error];
        }
    }
    
    return _persistentStoreCoordinator;
}

-(BOOL)saveChangesWithError:(NSError *__autoreleasing *)errorPtr
{
    return [[self managedObjectContext] save: errorPtr];
}

- (void)saveAllChanges
{
    NSError *error;
    if (![self saveChangesWithError: &error])
    {
        [self promptForUnexpectedError: error];
    }
}

#pragma mark - Application's documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


////madhvi
//
//- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
//    return UIInterfaceOrientationMaskLandscape;
//}



-(void)gettingOldData
{
    
    NSManagedObjectContext *moc = [self managedObjectContext];
    
    
    NSError *error;
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName: @"Barrier"];
    [request setSortDescriptors: @[ [NSSortDescriptor sortDescriptorWithKey: @"name" ascending:YES]]];
    [request setSortDescriptors: @[ [NSSortDescriptor sortDescriptorWithKey: @"position" ascending:YES]]];
    [request setResultType: NSManagedObjectResultType];
    
    //NSArray *_allProjects = [NSArray new];
    NSArray *projectArr = [[moc executeFetchRequest: request error:&error] mutableCopy];
    
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"position" ascending:YES];
    projectArr=[[(NSArray*)projectArr sortedArrayUsingDescriptors:@[sort]] mutableCopy];
    
    if (!projectArr) {
        [self promptForUnexpectedError: error];
    }
    
    
    
    
    
    
    
    
    
    
    
    
    //    if(success)
    //    {
    //        //*******************************
    //        //Patterns Bank table data
    //        //*******************************
    //
    //        //array to hold patternid in UUID fromat corresponding to the id in sqlite
    //        NSMutableArray *UUIDPatternId = [NSMutableArray new];
    //        //array to hold data
    //        arrOfData  = [NSMutableArray new];
    //        //Select pattern bank data from sqlite database
    //        NSString *strNew = [NSString stringWithFormat:@"SELECT userId, userEmail FROM User"];
    //
    //        // Open the database. The database was prepared outside the application.
    //        NSManagedObjectContext *context =[self managedObjectContext];
    //
    //        //fetch patterns bank data from the sqlite db
    //        if (sqlite3_open([writableDBPath UTF8String], &database) == SQLITE_OK)
    //        {
    //            sqlite3_stmt *statement;
    //
    //            if (sqlite3_prepare_v2(database, [strNew UTF8String], -1, &statement, NULL) == SQLITE_OK)
    //            {
    //                // We "step" through the results - once for each row.
    //                while (sqlite3_step(statement) == SQLITE_ROW)
    //                {
    //                    NSMutableDictionary *value = [[NSMutableDictionary alloc] init];
    //
    //                    //Get patternbankid
    //                    [value setValue:[NSString stringWithUTF8String:(char*)sqlite3_column_text(statement,0)] forKey:@"userId"];
    //                    //Get patternbankname
    //                    [value setValue:[NSString stringWithUTF8String:(char*)sqlite3_column_text(statement,1)] forKey:@"userEmail"];
    //
    //                    //Add patternbank detail to the array
    //                    [arrOfData addObject:value];
    //                    //release the object
    //                    value = nil;
    //                }
    //
    //                // "Finalize" the statement - releases the resources associated with the statement.
    //                sqlite3_finalize(statement);
    //            }
    //
    //            NSError *error;
    //            //Loop through the Pattern bank data and insert into the Core Data pattern bank table
    //            //Here with each insertion of pattern bank record, corresponding patterns and line data will be moved into Core Data
    //            for (int i=0; i<arrOfData.count; i++)
    //            {
    //                NSString *patternBnkId = @"";
    //
    //                NSMutableDictionary *data= [arrOfData objectAtIndex:i];
    //                //As default bank is already created on app launch, no need to sync it again
    //                if(![[NSString stringWithFormat:@"%@",[data valueForKey:@"userEmail"]] isEqualToString:@"Default Bank"] )
    //                {
    //                    NSManagedObject *bubbleDataObj3 = [NSEntityDescription insertNewObjectForEntityForName:@"PatternBanksData" inManagedObjectContext:context];
    //
    //                    NSUUID *uuid = [[NSUUID alloc] init];
    //                    patternBnkId = [uuid UUIDString];
    //                    //Assign PatternBankId
    //                    [bubbleDataObj3 setValue:patternBnkId forKey:@"patternBankId"];
    //                    //Assign PatternBankName
    //                    [bubbleDataObj3 setValue:[NSString stringWithFormat:@"%@",[data valueForKey:@"userEmail"]] forKey:@"patternBankName"];
    //
    //                    //Save data in table
    //                    if (![context save:&error])
    //                    {
    //                        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    //                    }
    //
    //                    bubbleDataObj3 = nil;
    //                }
    //
    //                //*********************
    //                //Bubble table data
    //                //*********************
    //
    //                //Create Core Data object for pattern table
    //                // PatternBanksData *ptrnBanksData ;
    //
    //                //Select data from pattern sqlite table corresponding to the pattern bank inserted into the table
    //                NSString *new = [NSString stringWithFormat:@"SELECT BubbleId, BubbleName, Detail, isRigthBubble, X, Y, Feeling, Thoughts, Tone FROM Bubble where userId = %ld", (long)[[data valueForKey:@"userId"] integerValue]];
    //                sqlite3_stmt *statementBubble;
    //
    //                if (sqlite3_prepare_v2(database, [new UTF8String], -1, &statementBubble, NULL) == SQLITE_OK)
    //                {
    //                    // We "step" through the results - once for each row.
    //                    while (sqlite3_step(statementBubble) == SQLITE_ROW)
    //                    {
    //                        NSManagedObject *bubbleDataObj = [NSEntityDescription insertNewObjectForEntityForName:@"PatternsData" inManagedObjectContext:context];
    //                        //If default bank, then id should be the one which is created  automatically on app launch
    //                        if([[NSString stringWithFormat:@"%@",[data valueForKey:@"userEmail"]] isEqualToString:@"Default Bank"] )
    //                            patternBnkId = defaultBankIdStr;
    //
    //                        //Create new pattern id
    //                        NSUUID *uuid = [[NSUUID alloc] init];
    //                        NSString *patternId = [uuid UUIDString];
    //
    //                        //Assign PatternId
    //                        [bubbleDataObj setValue:patternId forKey:@"patternId"];
    //                        //Assign PatternBankId
    //                        [bubbleDataObj setValue:patternBnkId forKey:@"patternBankId"];
    //                        //Assign PatternName
    //                        [bubbleDataObj setValue:[NSString stringWithUTF8String:(char*)sqlite3_column_text(statementBubble,1)] forKey:@"patternName"];
    //                        //Assign Physical Sensations
    //                        [bubbleDataObj setValue:[NSString stringWithUTF8String:(char*)sqlite3_column_text(statementBubble,2)] forKey:@"phySensations"];
    //                        //Assign isRightBubble
    //                        [bubbleDataObj setValue:[NSNumber numberWithInt:sqlite3_column_int(statementBubble, 3)] forKey:@"isRigthBubble"];
    //                        //Assign X
    //                        [bubbleDataObj setValue:[NSNumber numberWithInt:sqlite3_column_int(statementBubble, 4)] forKey:@"x"];
    //                        //Assign Y
    //                        [bubbleDataObj setValue:[NSNumber numberWithInt:sqlite3_column_int(statementBubble, 5)] forKey:@"y"];
    //                        //Assign Emotions
    //                        [bubbleDataObj setValue:[NSString stringWithUTF8String:(char*)sqlite3_column_text(statementBubble,6)] forKey:@"emotions"];
    //                        //Assign Thoughts
    //                        [bubbleDataObj setValue:[NSString stringWithUTF8String:(char*)sqlite3_column_text(statementBubble,7)] forKey:@"thoughts"];
    //                        //Assign Behaviour
    //                        [bubbleDataObj setValue:[NSString stringWithUTF8String:(char*)sqlite3_column_text(statementBubble,8)] forKey:@"behaviour"];
    //
    //                        //Save data in table
    //                        if (![context save:&error])
    //                        {
    //                            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    //                        }
    //
    //                        bubbleDataObj = nil;
    //
    //                        //**********************************************************
    //                        //Add new patternid in the array to be used to update EndId in Line Table data
    //                        //**********************************************************
    //
    //                        PatternIdData *pValue = [[PatternIdData alloc] init];
    //
    //                        //Get patternbankid
    //                        pValue.UUIDFormat = patternId;
    //                        pValue.actualPatternId = [NSNumber numberWithInt:sqlite3_column_int(statementBubble, 0)];
    //                        //Add patternbank detail to the array
    //                        [UUIDPatternId addObject:pValue];
    //                        pValue = nil;
    //
    //                        //*******
    //                        //END
    //                        //*******
    //
    //                        //*********************
    //                        //Line table data
    //                        //*********************
    //
    //                        //Select data from line sqlite table corresponding to the pattern inserted into the table
    //                        //Here match startid (patternid) and userid(pattenbankid) column
    //                        NSString *strNew2 = [NSString stringWithFormat:@"SELECT lineId,startId,endId,X,Y,startX,startY,isLeft FROM LineTable  where userId = %ld and startId = %d", (long)[[data valueForKey:@"userId"] integerValue],sqlite3_column_int(statementBubble, 0)];
    //
    //                        sqlite3_stmt *statementLine;
    //
    //                        // Open the database. The database was prepared outside the application.
    //                        if (sqlite3_prepare_v2(database, [strNew2 UTF8String], -1, &statementLine, NULL) == SQLITE_OK)
    //                        {
    //                            // We "step" through the results - once for each row.
    //                            while (sqlite3_step(statementLine) == SQLITE_ROW)
    //                            {
    //                                NSManagedObject *bubbleDataObj2 = [NSEntityDescription insertNewObjectForEntityForName:@"LineData" inManagedObjectContext:context];
    //
    //                                //If default bank, then id should be the one which is created  automatically on app launch
    //                                if([[NSString stringWithFormat:@"%@",[data valueForKey:@"userEmail"]] isEqualToString:@"Default Bank"] )
    //                                    patternBnkId = defaultBankIdStr;
    //
    //                                //Assign LineId
    //                                [bubbleDataObj2 setValue:[NSString stringWithUTF8String:(char*)sqlite3_column_text(statementLine,0)] forKey:@"lineId"];
    //                                //Assign StartId. It will be same as pattern id inserted above
    //                                [bubbleDataObj2 setValue:patternId forKey:@"startId"];
    //                                //Assign EndId
    //                                [bubbleDataObj2 setValue:[NSString stringWithUTF8String:(char*)sqlite3_column_text(statementLine,2)]  forKey:@"endId"];
    //                                //Assign X
    //                                [bubbleDataObj2 setValue:[NSNumber numberWithInt:sqlite3_column_int(statementLine, 3)]  forKey:@"x"];
    //                                //Assign Y
    //                                [bubbleDataObj2 setValue:[NSNumber numberWithInt:sqlite3_column_int(statementLine, 4)]  forKey:@"y"];
    //                                //Assign StartX
    //                                [bubbleDataObj2 setValue:[NSNumber numberWithInt:sqlite3_column_int(statementLine, 5)]  forKey:@"startX"];
    //                                //Assign StartY
    //                                [bubbleDataObj2 setValue:[NSNumber numberWithInt:sqlite3_column_int(statementLine, 6)]  forKey:@"startY"];
    //                                //Assign IsLeft
    //                                [bubbleDataObj2 setValue:[NSNumber numberWithInt:sqlite3_column_int(statementLine, 7)]   forKey:@"isLeft"];
    //                                //Assign PatternBankId
    //                                [bubbleDataObj2 setValue:patternBnkId forKey:@"patternBankId"];
    //
    //                                //Save data in table
    //                                if (![context save:&error])
    //                                {
    //                                    NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    //                                }
    //
    //                                bubbleDataObj2 = nil;
    //                            }
    //
    //                            // "Finalize" the statement - releases the resources associated with the statement.
    //                            sqlite3_finalize(statementLine);
    //                        }
    //                    }
    //
    //                    // "Finalize" the statement - releases the resources associated with the statement.
    //                    sqlite3_finalize(statementBubble);
    //                }
    //            }
    //
    //            strSuccess = @"YES";
    //            previousData = [NSUserDefaults standardUserDefaults];
    //            [previousData setObject:strSuccess forKey:@"previousVersionIsInstalled"];
    //            [[NSUserDefaults standardUserDefaults] synchronize];
    //        }
    //        else
    //        {
    //            // Even though the open failed, call close to properly clean up resources.
    //            sqlite3_close(database);
    //            NSLog(@"Failed to open database with message '%s'.", sqlite3_errmsg(database));
    //        }
    //
    //        [self updateEndIdInLineTable:UUIDPatternId];
    //    }
}





#pragma mark - Set dummy data when no record found

- (void)createInitialData:(NLCProject*)project
{
   // NLCProject *project = (NLCProject*)[NSEntityDescription insertNewObjectForEntityForName:@"Project" inManagedObjectContext:moc];
   // NSAssert( project, @"Need project");
    //project.name =@"Demo Project";
    
   // project.intentions = @"It is my intention for this project to be a big success";
   // project.objective = @"It is the objective to be successful in this project";
    
    NSUInteger row=0;
             // Actions
        NLCTask *task = (NLCTask*)[NSEntityDescription insertNewObjectForEntityForName: @"Task" inManagedObjectContext: self.managedObjectContext];
        task.name = @"";
        task.position = @(row);
        task.type = @"task";
        task.resourceCollapsed = @(1);
        [project addTasksObject: task];
    
    
      
        
        // Barriers
        NLCTask *task1 = (NLCTask*)[NSEntityDescription insertNewObjectForEntityForName: @"Task" inManagedObjectContext: self.managedObjectContext];
        task1.name = @"";
        task1.type = @"barrier";
        task1.resourceCollapsed = @(1);
        task1.position = @(row +1);
        [project addTasksObject: task1];
    
    
    NLCResource *resource = (NLCResource*)[NSEntityDescription insertNewObjectForEntityForName: @"Resource" inManagedObjectContext: self.managedObjectContext];
    
    resource.name = @"";
    resource.type = task.type;
    resource.position = @(row);
    [task addResourcesObject:resource];
   // [project addResourcesObject: resource];
    
    NLCResource *resource1 = (NLCResource*)[NSEntityDescription insertNewObjectForEntityForName: @"Resource" inManagedObjectContext: self.managedObjectContext];
    
    resource1.name = @"";
    resource1.type = task1.type;
    resource1.position = @(row+1);
    [task1 addResourcesObject:resource1];
   // [project addResourcesObject: resource];
    
    [self saveAllChanges];
}

-(void)createPlist
{
    NSError *error;
    NSString *path = [DOCUMENT_PATH stringByAppendingPathComponent:@"data.plist"]; //3
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath: path]) //4
    {
        NSString *bundle = [[NSBundle mainBundle] pathForResource:@"data" ofType:@"plist"]; //5
        
        [fileManager copyItemAtPath:bundle toPath: path error:&error]; //6
    }
}


-(void)saveStrToPlist:(NSString*)x forKey:(NSString *)key
{
    [self createPlist];
    NSString *path = [DOCUMENT_PATH stringByAppendingPathComponent:@"data.plist"];
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
    
    //here add elements to data file and write data to file
    [data setObject:x forKey:key];
    
    [data writeToFile: path atomically:YES];
    
}
-(NSString*)loadStrFromPlistForKey:(NSString*)key{
    
    NSString *path = [DOCUMENT_PATH stringByAppendingPathComponent:@"data.plist"];
    NSMutableDictionary *savedStock = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
    
    //load from savedStock example int value
    NSString* value;
    value = [savedStock objectForKey:key];
    
    return value;
    
    
    
    

}


#pragma mark -




@end
