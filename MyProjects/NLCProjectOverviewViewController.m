//
//  NLCProjectOverviewViewController.m
//  MyProjects
//
//  Created by Gaige B. Paulsen on 5/29/14.
//  Copyright (c) 2014 Gaige B. Paulsen. All rights reserved.
//

#import "NLCProjectOverviewViewController.h"
#import <CoreData/CoreData.h>
#import "NLCAppDelegate.h"
#import "NLCRootViewController.h"
#import "NLCProject.h"
#import "NLCBarrier.h"
#import "NLCTask.h"
#import "NLCHomeViewController.h"

@interface NLCProjectOverviewViewController ()<UIAlertViewDelegate>
{
    NSMutableArray *projectArr;
    IBOutlet UIView *projectView;
    IBOutlet UITableView *tblView;
    NSString *prodOrCountProdStr;
    IBOutlet UILabel *lblTittle;
    NLCAppDelegate *appDelegate;
}
@property(strong) NLCProject *startingProject;
@end

@implementation NLCProjectOverviewViewController

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
    
    appDelegate=(NLCAppDelegate*)[[UIApplication sharedApplication]delegate];
    self.startingProject = [appDelegate currentProject];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [projectView setHidden:YES];
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
   // if(false){
//        if (self.startingProject && [appDelegate.checkShareCondStr isEqualToString:@"0"])
//        {
//            // push to the project view controller immediately
//            NLCRootViewController *projectController = [self.storyboard instantiateViewControllerWithIdentifier:@"ProjectRoot"];
//            projectController.project = self.startingProject;
//            [self presentViewController:projectController animated:YES completion:^{
//                // done;
//            }];
//            self.startingProject=nil;
//        }
//        else
            if([appDelegate.checkShareCondStr isEqualToString:@"1"])
        {
            
            
            if ([appDelegate.prodOrCountProduct isKindOfClass:[NSDictionary class]]) {
                prodOrCountProdStr = [NSString stringWithFormat:@"%@", [appDelegate.prodOrCountProduct objectForKey:@"isRigthBubble"] ];
                
                appDelegate.shareBarrierName = [NSString stringWithFormat:@"%@", [appDelegate.prodOrCountProduct objectForKey:@"patternName"]];
                appDelegate.shareIsBarrierorResource = prodOrCountProdStr;
                
                NLCHomeViewController *projectController = [self.storyboard instantiateViewControllerWithIdentifier:@"NLCHomeViewController"];
                
                [self presentViewController:projectController animated:YES completion:^{
                    
                }];
            }
            
            
           
        }
    
            //contProd=0,prd=1
//            [self fetchProjectData];
//            lblTittle.text=@"Select project";
    
       // }
    //}
}

#pragma mark - tableview method
-(void)fetchProjectData
{
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Project" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSError *error;
    projectArr= [[NSMutableArray alloc]init];
    projectArr= [[context executeFetchRequest:fetchRequest error:&error]mutableCopy];
    
    if(projectArr.count>0)
    {
        [tblView reloadData];
        [self BeginAnimation:projectView];
    }
    else
    {
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"" message:@"There is no project to share the pattern. Please create a project and try again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        alertView.tag=500;
        [alertView show];
    }
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"project"];
    if (!cell)
        cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier:@"project"];
    
    NLCProject *nlcProject= [projectArr objectAtIndex:indexPath.row];
    cell.textLabel.text= nlcProject.name;
    
    return cell;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return projectArr.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([prodOrCountProdStr isEqualToString:@"0"])
    {
        NSString *patternNameStr = [appDelegate.prodOrCountProduct objectForKey:@"patternName"];
        NLCProject *nlcProject= [projectArr objectAtIndex:indexPath.row];
        NSManagedObjectContext *context = [appDelegate managedObjectContext];
        NLCBarrier *barrier = (NLCBarrier*)[NSEntityDescription insertNewObjectForEntityForName: @"Barrier" inManagedObjectContext: context];
        barrier.name = [NSString stringWithFormat: @"%@",patternNameStr];
        barrier.project=nlcProject;
        //barrier.position =[NSNumber numberWithInt:3];
    }
    else
    {
        NSString *patternNameStr = [appDelegate.prodOrCountProduct objectForKey:@"patternName"];
        NLCProject *nlcProject= [projectArr objectAtIndex:indexPath.row];
        NSManagedObjectContext *context = [appDelegate managedObjectContext];
        NLCTask *task = (NLCTask*)[NSEntityDescription insertNewObjectForEntityForName: @"Task" inManagedObjectContext: context];
        task.name = [NSString stringWithFormat: @"%@",patternNameStr];
        task.project=nlcProject;
        //task.position =[NSNumber numberWithInt:3];
    }
    [self cancelBtnClick:self];
}
-(IBAction)cancelBtnClick:(id)sender
{
   [self EndAnimation:projectView];
    [appDelegate backToMyPatternApp];
    
}
#pragma mark  View Animation Effects
-(void)BeginAnimation:(UIView *)viewName
{
    [viewName setAlpha:0.0];
    [UIView beginAnimations:@"theAnimation" context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:1];
    [viewName setAlpha:1.0];
    [viewName setHidden:NO];
    [UIView commitAnimations];
}
-(void)EndAnimation:(UIView *)viewName
{
    [viewName setAlpha:1.0];
    [UIView beginAnimations:@"theAnimation" context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(EndAnimationFinish)];
    [UIView setAnimationDuration:0.5];
    [viewName setAlpha:0.0];
    [viewName setHidden:YES];
    [UIView commitAnimations];
}

-(void)EndAnimationFinish
{
}

#pragma mark - alertView delegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag==500)
    {
        if (buttonIndex==0)
        {
            [self cancelBtnClick:self];
        }
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
