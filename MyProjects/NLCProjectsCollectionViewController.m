//
//  NLCProjectsCollectionViewController.m
//  MyProjects
//
//  Created by Gaige B. Paulsen on 5/29/14.
//  Copyright (c) 2014 Gaige B. Paulsen. All rights reserved.
//

#import "NLCProjectsCollectionViewController.h"
#import "NLCProjectOverviewCell.h"
#import "NLCRootViewController.h"
#import "NLCAppDelegate.h"
#import "NLCProject.h"

@interface NLCProjectsCollectionViewController ()
@property(strong) NSArray *allProjects;
@property(strong) UIPopoverController *myPopoverController;
@end

@implementation NLCProjectsCollectionViewController
@dynamic collectionView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _projectUpdateQueue = [[NSOperationQueue alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self retrieveProjects];
    [self.collectionView reloadData];
}

- (void)retrieveProjects
{
    NSManagedObjectContext *moc;
    NLCAppDelegate *appDelegate = GetAppDelegate();
    moc = [appDelegate managedObjectContext];
    
    NSError *error;
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName: @"Project"];
    [request setSortDescriptors: @[ [NSSortDescriptor sortDescriptorWithKey: @"name" ascending:YES]]];
    
    [request setResultType: NSManagedObjectResultType];
    _allProjects = [moc executeFetchRequest: request error:&error];
    
    if (!_allProjects) {
        [appDelegate promptForUnexpectedError: error];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.projectUpdateObserver=[[NSNotificationCenter defaultCenter] addObserverForName: NSManagedObjectContextDidSaveNotification object:nil queue: self.projectUpdateQueue usingBlock:^(NSNotification *note) {
        BOOL needUpdate=NO;
        
        NSMutableArray *removals=[NSMutableArray array];
        NSMutableArray *insertions=[NSMutableArray array];
        
        for ( NLCProject *project in [note.userInfo objectForKey: NSDeletedObjectsKey]) {
            // handle updates
//            NSLog( @"Deleted %@",project);
            if ([project isKindOfClass: [NLCProject class]]) {
                NSUInteger projectIndex = [_allProjects indexOfObject: project];
                [removals addObject: [NSIndexPath indexPathForItem: projectIndex inSection:0]];
                needUpdate = YES;
            }
        }

        [self retrieveProjects];
        
        for ( NLCProject *project in [note.userInfo objectForKey: NSInsertedObjectsKey]) {
            // handle updates
//            NSLog( @"Added %@",project);
            if ([project isKindOfClass: [NLCProject class]]) {
                NSUInteger projectIndex = [_allProjects indexOfObject: project];
                [insertions addObject: [NSIndexPath indexPathForItem: projectIndex inSection:0]];
                needUpdate = YES;
            }
        }

        if (needUpdate) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (insertions.count>0 && removals.count>0) {
                    [self.collectionView reloadData];
                } else {
                    if (removals.count>0)
                        [self.collectionView deleteItemsAtIndexPaths: removals];
                    if (insertions.count>0)
                        [self.collectionView insertItemsAtIndexPaths: insertions];
                }
            });
        }
        }];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver: self.projectUpdateObserver];
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return (NSInteger)_allProjects.count+1;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NLCProject *project=nil;
    if (indexPath.row <_allProjects.count) {
        project= _allProjects[(NSUInteger)indexPath.row];

    }
    
    UICollectionViewCell *cell;
    
    if (project==nil) {
        // plus cell
        cell = [collectionView dequeueReusableCellWithReuseIdentifier: @"newProjectCell" forIndexPath:indexPath];
    } else {
        // project cell
        NLCProjectOverviewCell *newCell = [collectionView dequeueReusableCellWithReuseIdentifier: @"projectCell" forIndexPath:indexPath];
        
        newCell.project = project;
        cell=newCell;
    }

    return cell;
    
}

-(void)showProject:(NLCProject*)project
{
    NSAssert(project, @"Need the project");
    if (!project)
        return;
    NLCRootViewController *projectController = [self.storyboard instantiateViewControllerWithIdentifier:@"ProjectRoot"];
    projectController.project = project;
    [self.parentViewController presentViewController:projectController animated:YES completion:^{
        // done;
    }];
    
    // set as the current project
    
    [GetAppDelegate() setCurrentProject: project];
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row <_allProjects.count) {
        // start with the selected project
        [self showProject: _allProjects[(NSUInteger) indexPath.row]];
    } else {
        NLCNewProjectViewController *viewControllerForPopover = [self.storyboard instantiateViewControllerWithIdentifier:@"NewProject"];
        
        UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:viewControllerForPopover];
        
        viewControllerForPopover.popover = popover;
        UICollectionViewCell* cell = [collectionView cellForItemAtIndexPath: indexPath];
        [popover presentPopoverFromRect: cell.bounds inView:cell permittedArrowDirections:UIPopoverArrowDirectionRight|UIPopoverArrowDirectionLeft animated:YES];
        
    }
}
@end
