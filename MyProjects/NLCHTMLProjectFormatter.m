//
//  NLCHTMLProjectFormatter.m
//  MyProjects
//
//  Created by Gaige B. Paulsen on 8/19/14.
//  Copyright (c) 2014 Gaige B. Paulsen. All rights reserved.
//

#import "NLCHTMLProjectFormatter.h"
#import "NLCTask.h"
#import "NLCResource.h"
#import "NLCAppDelegate.h"

@implementation NLCHTMLProjectFormatter
-(NSArray*)arrayFromList:(NSSet*)originalDataSet orderedBy:(NSArray*)sortDescriptors data:(NSString*)dataName filter:(NSPredicate*)filter
{
    // sort by the @"position"
    NSSet *dataSet=originalDataSet;
    if (filter)
        dataSet = [dataSet filteredSetUsingPredicate: filter];
    NSArray *array = [dataSet sortedArrayUsingDescriptors: sortDescriptors ];
    NSMutableArray *outputArray = [NSMutableArray arrayWithCapacity: array.count];
    
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [outputArray addObject: [obj valueForKey: dataName]];
    }];
    return outputArray;

}

-(NSString*)headerString:(NSString*)headerName
{
    return [NSString stringWithFormat: @"<h2>%@</h2>",headerName];
}

-(NSString*)textString:(NSString*)textString
{
     return [NSString stringWithFormat: @"<p>%@</p>", textString];
    
}
-(NSString*)listItemString:(NSString*)textString
{
    if (textString.length<1)
        return @"";
    return [NSString stringWithFormat: @"<li>%@</li>", textString];
}

-(NSString*)listHeaderNumbered:(BOOL)isNumbered
{
    return [NSString stringWithFormat: @"<%@>", isNumbered ? @"ol" : @"ol type='a'"];
}

-(NSString*)listFooterNumbered:(BOOL)isNumbered
{
    return [NSString stringWithFormat: @"</%@>",isNumbered ? @"ol":@"ol"];
}

- (NSString*)textStringWithHeader:(NSString*)header text:(NSString*)text
{
    NSString *string=nil;
    
    string = [self headerString: header];
    
    NSString *str =  @"It is my intention for this project to be a big success";
     NSString *intentionstr = @"It is the objective to be successful in this project";;
    
    
    if (text ==nil ||[text isEqualToString:@"Desired result or outcome"] || [text isEqualToString:@"The intrinsic value of pursuing the Project Objective"] || [text isEqualToString:intentionstr] || [text isEqualToString:str])
         string = [string stringByAppendingString: [self textString: @""]];
    else
        string = [string stringByAppendingString: [self textString: text]];
    return string;
}

- (NSString*)listStringWithHeader:(NSString*)header list:(NSArray*)textArray numbered: (BOOL)isNumbered
{
    NSString *string=nil;
    
    string = [self headerString: header];
    string = [string stringByAppendingString: [self listHeaderNumbered: isNumbered]];
    for (NSString *text in textArray) {
        string = [string stringByAppendingString: [self listItemString: text]];
    }
    string = [string stringByAppendingString: [self listFooterNumbered: isNumbered]];
    return string;
}

- (NSString*)actionListWithHeader:(NSString*)header dataSet:(NSSet*)originalDataSet
{
    __block NSString *string=nil;
    
    string = [self headerString: header];
    string = [string stringByAppendingString: [self listHeaderNumbered: YES]];
    NSSet *dataSet=originalDataSet;
//    if (filter)
//        dataSet = [dataSet filteredSetUsingPredicate: filter];
    NSArray *positionDescriptors=@[ [NSSortDescriptor sortDescriptorWithKey: @"position" ascending:YES]];
    NSArray *array = [dataSet sortedArrayUsingDescriptors: positionDescriptors ];
   // NSPredicate * p = [NSPredicate predicateWithFormat:@"type contains %@",type];
   // NSArray * filtered = [array filteredArrayUsingPredicate:p];
    
    [array enumerateObjectsUsingBlock:^(NLCTask *task, NSUInteger idx, BOOL *stop) {
        
        NSString *text ;
        if ([task.type isEqualToString:@"task"]) {
               text = [NSString stringWithFormat:@"Action: %@",task.name];
        }else{
         text = [NSString stringWithFormat:@"Barrier: %@",task.name];
        
        }
        
        if ([text isEqualToString:@""] || [text isEqualToString:@"(null)"] || text == nil) {
            
        }else{
     
            string = [string stringByAppendingString: [self listItemString: text]];
        }
       
        if (task.resources.count>0) {
            string = [string stringByAppendingString: [self listHeaderNumbered:NO]];
            NSArray *sortedResources = [task.resources sortedArrayUsingDescriptors: positionDescriptors];
            [sortedResources enumerateObjectsUsingBlock:^(NLCResource *resource, NSUInteger resIdx, BOOL *resStop) {
                string = [string stringByAppendingString: [self listItemString:resource.name]];
            }];
            string = [string stringByAppendingString: [self listFooterNumbered:NO]];
        }
    }];
    
    string = [string stringByAppendingString: [self listFooterNumbered: YES]];
    return string;
}

-(NSString *)bodyFromProject:(NLCProject*)project
{
    NSArray *sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey: @"position" ascending:YES]];
    NSPredicate *leftFilter = [NSPredicate predicateWithFormat: @"onLeft = true"];
    NSPredicate *rightFilter = [NSPredicate predicateWithFormat: @"onLeft = false"];
    NSPredicate *playerFilter = [NSPredicate predicateWithFormat: @"rank = 1"];
    NSPredicate *stakeholderFilter = [NSPredicate predicateWithFormat: @"rank = 2"];
//     NSPredicate *barrierFilter = [NSPredicate predicateWithFormat: @"type = barrier"];
//     NSPredicate *actionFilter = [NSPredicate predicateWithFormat: @"type = task"];
    NSDictionary* infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString* version = [infoDict objectForKey:@"CFBundleShortVersionString"];
    
    NSMutableString *body = [[NSMutableString alloc] initWithCapacity: 1000];
    [body appendString:[NSString stringWithFormat:@"<h2 style='padding:0;margin:0;line-height:40px;'>MyProjects</h2>Version %@", version]];
    [body appendString: [self textStringWithHeader: @"Project" text:project.name]];
    
    
    [body appendString: [self textStringWithHeader: @"Objective" text:project.objective]];
    [body appendString: [self textStringWithHeader: @"Intentions" text:project.intentions]];
    
    [body appendString: [self listStringWithHeader: @"Stakeholders" list: [self arrayFromList: project.stakeholders orderedBy: sortDescriptors data: @"shortName" filter:stakeholderFilter] numbered: YES]];

    [body appendString: [self listStringWithHeader: @"Players" list: [self arrayFromList: project.stakeholders orderedBy: sortDescriptors data: @"shortName" filter:playerFilter] numbered: YES]];
    

    [body appendString: [self listStringWithHeader: @"Implications (Success)" list: [self arrayFromList: project.implications orderedBy: sortDescriptors data: @"name" filter: leftFilter] numbered: YES]];
    [body appendString: [self listStringWithHeader: @"Implications (Failure)" list: [self arrayFromList: project.implications orderedBy: sortDescriptors data: @"name" filter: rightFilter] numbered: YES]];

    [body appendString: [self listStringWithHeader: @"Experiences (Success)" list: [self arrayFromList: project.experiences orderedBy: sortDescriptors data: @"name" filter: leftFilter] numbered: YES]];
    [body appendString: [self listStringWithHeader: @"Experiences (Failure)" list: [self arrayFromList: project.experiences orderedBy: sortDescriptors data: @"name" filter: rightFilter] numbered: YES]];
    
    [body appendString: [self actionListWithHeader: @"Barriers, Actions, and Resources List" dataSet:project.tasks]];
    
//    [self createJsonForServer:project];
    return body;
}
-(NSString *)createJsonForServer:(NLCProject*)project apiKey:(NSString *)apikey userName:(NSString*)username{
    
    NSURL *instanceURL = project.objectID.URIRepresentation;
    NSString *projectId = [instanceURL absoluteString];
    
    NSMutableArray *projectData = [[NSMutableArray alloc] init];
    NSMutableDictionary *dictProject = [[NSMutableDictionary alloc] init];
    
    [projectData addObjectsFromArray:[self getStakeholders:[self getEntityRecord:project forEntity:@"stakeholders"] project:projectId projectIds:dictProject]];
    
    [projectData addObjectsFromArray:[self getImplications:[self getEntityRecord:project forEntity:@"implications"] project:projectId projectIds:dictProject]];
    
    [projectData addObjectsFromArray:[self getExperiences:[self getEntityRecord:project forEntity:@"experiences"] project:projectId projectIds:dictProject]];
    
    [projectData addObjectsFromArray:[self getTasks:[self getEntityRecord:project forEntity:@"tasks"] project:projectId projectIds:dictProject]];
    
    [dictProject setObject:projectId forKey:@"objectId"];
    [dictProject setObject:@"NLCProject" forKey:@"class"];
    [dictProject setObject:project.name  forKey:@"name"];
    NSString *strDate =@"";
    if(project.date)
        strDate = [NSString stringWithFormat:@"%@", project.date];
    [dictProject setObject:strDate forKey:@"date"];
    [dictProject setObject:(project.objective)?project.objective:@"" forKey:@"objective"];
    [dictProject setObject:(project.intentions)?project.intentions:@"" forKey:@"intentions"];
    
    [projectData addObject:dictProject];
    
    NSError* error = nil;
    
    NSDictionary* infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString* version = [infoDict objectForKey:@"CFBundleShortVersionString"];
    NSString* appBundleId = [infoDict objectForKey:@"CFBundleIdentifier"];
    
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    dateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"];
    NSString* created = [NSString stringWithFormat: @"%@",[dateFormatter stringFromDate:[NSDate date]]];
    
    
    NSDictionary *dictDebrif = @{@"username":username,
                                 @"apikey": apikey,
                                 @"created": created,
                                 @"appBundleId": appBundleId,
                                 @"appBundleVersion": version,
                                 @"debrief":projectData
                                 };
//     NSLog(@"%@", dictDebrif);
    NSData * JSONData = [NSJSONSerialization dataWithJSONObject:dictDebrif
                                                        options:kNilOptions
                                                          error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:JSONData encoding:NSUTF8StringEncoding];
    return jsonString;
//       NSLog(@"%@", jsonString);
    
}


-(NSArray *)getEntityRecord:(NLCProject*)project forEntity:(NSString *)entity{
    
    NSArray *sortDescriptor =  @[[NSSortDescriptor sortDescriptorWithKey:@"position" ascending:YES]];
    id dataSet =[project valueForKey: entity];
    NSArray *stakeholdersArr = [dataSet sortedArrayUsingDescriptors: sortDescriptor];
    if (stakeholdersArr) {
        return stakeholdersArr;
    }
    return nil;
}

-(NSArray *)getStakeholders:(NSArray *)stakeholders project:(NSString*)projectId projectIds:(NSMutableDictionary *)dictProject{
    //  convert stakeholder array to object to dctionary array
    NSMutableArray *arrAtakeholders = [[NSMutableArray alloc] init];
    NSMutableArray *arrIds = [[NSMutableArray alloc] init];
    for (NLCStakeholder *stakeholder in stakeholders) {
        NSURL *instanceURL = stakeholder.objectID.URIRepresentation;
        
        NSMutableDictionary *sh = [[NSMutableDictionary alloc] init];
        [sh setObject:@"NLCStakeholder" forKey:@"class"];
        [sh setObject:[instanceURL absoluteString] forKey:@"objectId"];
        [sh setObject:projectId forKey:@"project"];
        //        [sh setObject:stakeholder.addressReference forKey:@"addressReference"];
        //        [sh setObject:stakeholder.picture forKey:@"picture"];
        [sh setObject:stakeholder.position forKey:@"position"];
        [sh setObject:stakeholder.rank forKey:@"rank"];
        [sh setObject:stakeholder.shortName forKey:@"shortName"];
        
        [sh setObject:@[projectId] forKey:@"projects"];
        [arrAtakeholders addObject:sh];
        [arrIds addObject:[instanceURL absoluteString]];
    }
     [dictProject setObject:arrIds forKey:@"stakeholders"];
    return  (NSArray *)arrAtakeholders;
}

-(NSArray *)getImplications:(NSArray *)implications project:(NSString*)projectId projectIds:(NSMutableDictionary *)dictProject{
    //  convert implications array to object to dictionary array
    NSMutableArray *arrIds = [[NSMutableArray alloc] init];
    NSMutableArray *arrImplications = [[NSMutableArray alloc] init];
    for (NLCImplication *impl in implications) {
        NSURL *instanceURL = impl.objectID.URIRepresentation;
        
        NSMutableDictionary *im = [[NSMutableDictionary alloc] init];
        [im setObject:@"NLCImplication" forKey:@"class"];
        [im setObject:[instanceURL absoluteString] forKey:@"objectId"];
        [im setObject:projectId forKey:@"project"];
        
        [im setObject:impl.name forKey:@"name"];
        [im setObject:impl.onLeft forKey:@"onLeft"];
        [im setObject:impl.position forKey:@"position"];
        [arrIds addObject:[instanceURL absoluteString]];
        [arrImplications addObject:im];
    }
    [dictProject setObject:arrIds forKey:@"implications"];
    return  (NSArray *)arrImplications;
}

-(NSArray *)getExperiences:(NSArray *)experiences project:(NSString*)projectId projectIds:(NSMutableDictionary *)dictProject{
    //  convert implications array to object to dictionary array
    NSMutableArray *arrIds = [[NSMutableArray alloc] init];
    NSMutableArray *arrExperiences = [[NSMutableArray alloc] init];
    for (NLCExperience *expr in experiences) {
        NSURL *instanceURL = expr.objectID.URIRepresentation;
        
        NSMutableDictionary *im = [[NSMutableDictionary alloc] init];
        [im setObject:@"NLCExperience" forKey:@"class"];
        [im setObject:[instanceURL absoluteString] forKey:@"objectId"];
        [im setObject:projectId forKey:@"project"];
        
        [im setObject:expr.name forKey:@"name"];
        [im setObject:expr.onLeft forKey:@"onLeft"];
        [im setObject:expr.position forKey:@"position"];
        [arrIds addObject:[instanceURL absoluteString]];
        [arrExperiences addObject:im];
    }
    [dictProject setObject:arrIds forKey:@"implications"];
    return  (NSArray *)arrExperiences;
}

-(NSArray *)getTasks:(NSArray *)arrTask project:(NSString*)projectId projectIds:(NSMutableDictionary *)dictProject{
    //  convert task array to object to dctionary array
    NSArray *sortDescriptor =  @[[NSSortDescriptor sortDescriptorWithKey:@"position" ascending:YES]];
 
    NSMutableArray *arrTasks = [[NSMutableArray alloc] init];
    NSMutableArray *arrIdsTask = [[NSMutableArray alloc] init];
    NSMutableArray *arrIdsResource = [[NSMutableArray alloc] init];
    
    for ( NLCTask *task in  arrTask) {
        NSURL *instanceURL = task.objectID.URIRepresentation;
        
        NSMutableDictionary *tsk = [[NSMutableDictionary alloc] init];
        [tsk setObject:@"NLCTask" forKey:@"class"];
        [tsk setObject:[instanceURL absoluteString] forKey:@"objectId"];
        [tsk setObject:projectId forKey:@"project"];
        
        [tsk setObject:(task.completed)?task.completed:@"" forKey:@"completed"];
        [tsk setObject:(task.completedDate)?task.completedDate:@"" forKey:@"completedDate"];
        [tsk setObject:(task.dueDate)?task.dueDate:@"" forKey:@"dueDate"];
        [tsk setObject:(task.longDescription)?task.longDescription:@"" forKey:@"longDescription"];
        [tsk setObject:(task.name)?task.name:@"" forKey:@"name"];
        [tsk setObject:(task.calendarReference)?task.name:@"" forKey:@"calendarReference"];
        [tsk setObject:(task.position)?task.position:@"" forKey:@"position"];
        [tsk setObject:(task.resourceCollapsed)?task.resourceCollapsed:@"" forKey:@"resourceCollapsed"];
        [tsk setObject:(task.project)?task.project:@"" forKey:@"project"];
        [tsk setObject:(task.type)?task.type:@"" forKey:@"type"];
        [tsk setObject:projectId forKey:@"project"];
       [arrIdsTask addObject:[instanceURL absoluteString]];
        
        NSMutableArray *arrResource = [[NSMutableArray alloc] init];
        id taskDataSet =[task valueForKey: @"resources"];
        NSArray  *resourcesArr =[taskDataSet sortedArrayUsingDescriptors: sortDescriptor];
        if (resourcesArr) {
           
            //copy Resource
            for ( NLCResource *resources in  resourcesArr) {
                NSURL *instanceURLResources = resources.objectID.URIRepresentation;
                NSMutableDictionary *res = [[NSMutableDictionary alloc] init];
                [res setObject:@"NLCResource" forKey:@"class"];
                [res setObject:projectId forKey:@"project"];
                [res setObject:[instanceURLResources absoluteString] forKey:@"objectId"];
                [res setObject:(resources.longDescription)?resources.longDescription:@"" forKey:@"longDescription"];
                [res setObject:resources.name forKey:@"name"];
                [res setObject:resources.position forKey:@"position"];
                [res setObject:[instanceURL absoluteString] forKey:@"task"];
                [res setObject:resources.type forKey:@"type"];
//                [res setObject:(resources.project)?resources.project:@"" forKey:@"project"];
                [res setObject:projectId forKey:@"project"];
                [arrResource addObject:[instanceURLResources absoluteString]];
                [arrTasks addObject:res];
                [arrIdsResource addObject:[instanceURLResources absoluteString]];
            }
        }
        
         [tsk setObject:arrResource forKey:@"resources"];
//         NSLog(@"%@", tsk);
        [arrTasks addObject:tsk];
    }
    
    [dictProject setObject:arrIdsTask forKey:@"tasks"];
    [dictProject setObject:arrIdsResource forKey:@"resources"];
    
//    [arrTasks addObjectsFromArray:arrResource];
    return  (NSArray *)arrTasks;
}



@end
