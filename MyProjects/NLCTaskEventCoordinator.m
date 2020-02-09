//
//  NLCTaskEventCoordinator.m
//  MyProjects
//
//  Created by Gaige B. Paulsen on 10/7/14.
//  Copyright (c) 2014 Gaige B. Paulsen. All rights reserved.
//

#import "NLCTaskEventCoordinator.h"

static BOOL sNLCTaskEventCoordinatorAlreadyShownWarning=NO;

@implementation NLCTaskEventCoordinator

- (instancetype)initWithTask:(NLCTask*)task
{
    self = [super init];
    if (self) {
        _task=task;
        _eventStore = [[EKEventStore alloc] init];
    }
    return self;
}

-(void)eventInfoWithCompletion:(void (^)(EKEvent *event, NSError *error))completion
{
    NSAssert( completion, @"Need completion");
    if (!self.task.calendarReference) {
        (completion)(nil,[NSError errorWithDomain: NSCocoaErrorDomain code:NSNotFound userInfo:nil]);
        return;
    }
    
    [self.eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        if (!granted) {
            [[self class] showCalendarWarning];
            (completion)(nil,error);
            return;
        }
        
        EKEvent *event = [self.eventStore eventWithIdentifier: self.task.calendarReference];
        if (!event) {
            // note: modified, but not saved
            self.task.calendarReference = nil;
            (completion)(nil,[NSError errorWithDomain: NSCocoaErrorDomain code:NSNotFound userInfo:nil]);
            return;
        }
        completion(event,nil);
    }];
}

-(NSString*)notesStringForResources
{
    if (self.task.resources.count<1)
        return @"";
    NSString *resourceString = @"Resources:\n- ";
    NSArray *resourceArray = [self.task.resources sortedArrayUsingDescriptors: @[ [NSSortDescriptor sortDescriptorWithKey: @"position" ascending:YES]]];
    resourceString = [resourceString stringByAppendingString: [[resourceArray valueForKey: @"name"] componentsJoinedByString:@"\n- "]];
    
    resourceString = [resourceString stringByAppendingString: @"\n"];
    return resourceString;
}

-(NSString*)replaceOrAppendNotes:(NSString*)priorNotes
{
    __block NSRange priorRange = NSMakeRange( NSNotFound,0);
    if (priorNotes) {
        NSError *error;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern: @"^Resources:\n(- [^\n]*\n)*" options:NSRegularExpressionCaseInsensitive|NSRegularExpressionAnchorsMatchLines error:&error];
        NSAssert( regex, @"Need regex");
        [regex enumerateMatchesInString: priorNotes options:NSRegularExpressionCaseInsensitive|NSRegularExpressionAnchorsMatchLines range: NSMakeRange(0, priorNotes.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
            if (result.range.length>0) {
                priorRange= result.range;
                *stop = YES;
            }
        }];
    }
    
    NSString *finalString=priorNotes?:@"";
    NSString *notesString = [self notesStringForResources];

    if (priorRange.location!=NSNotFound) {
        finalString = [finalString stringByReplacingCharactersInRange: priorRange withString:notesString];
    } else if (notesString.length>0) {
        if (![finalString hasSuffix: @"\n"])
            finalString=[finalString stringByAppendingString: @"\n"];
        finalString = [finalString stringByAppendingString: notesString];
    }
    return finalString;
}

-(void)saveEventInfo:(BOOL (^)(EKEvent *event, NSError *error))update completion:(void (^)(BOOL success))completion
{
    NSAssert( update, @"Need update");

    [self.eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        if (!granted) {
            [[self class] showCalendarWarning];
            if (completion)
                (completion)(NO);
            return;
        }
        EKEvent *event;
        
        NSTimeInterval duration = 60*60;
        if (!self.task.calendarReference) {
            event = [EKEvent eventWithEventStore:self.eventStore];
            [event setCalendar:[self.eventStore defaultCalendarForNewEvents]];
            
        } else {
            event = [self.eventStore eventWithIdentifier: self.task.calendarReference];
           if([event.endDate timeIntervalSinceDate:event.startDate] > 0 ) {
                duration = [event.endDate timeIntervalSinceDate: event.startDate];
           }
         }
        
        BOOL shouldUpdate = update( event, nil);
        if (!shouldUpdate) {
            if (completion)
                (completion)(YES);
            return;
        }
        
        event.notes = [self replaceOrAppendNotes: event.notes];
        event.endDate = [event.startDate dateByAddingTimeInterval:duration]; //set 1 hour meeting

        NSError *writeError = nil;
        
        if (![self.eventStore saveEvent:event span:EKSpanThisEvent commit:YES error:&writeError]) {
//            NSLog(@"%@ - %@" , event.endDate , event.startDate);
            [[self class] showCalendarError: writeError];
        }
        
        self.task.calendarReference = event.eventIdentifier;  //this is so you can access this event later
        if (completion)
            (completion)(YES);
    }];
}

-(void)removeEventWithCompletion:(void (^)(BOOL success))completion
{
    if (!self.task.calendarReference) {
        if (completion)
            completion(YES);
        return;
    }
    [self.eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        if (!granted) {
            [[self class] showCalendarWarning];
            if (completion)
                (completion)(NO);
            return;
        }
        EKEvent *event = [self.eventStore eventWithIdentifier: self.task.calendarReference];
        if (![self.eventStore removeEvent: event span: EKSpanFutureEvents error: &error]) {
//            NSLog(@"%@ - %@" , event.endDate , event.startDate);
            [[self class] showCalendarError: error];
        }
        
        self.task.calendarReference = nil;  //this is so you can access this event later
        if (completion)
            completion(YES);
    }];
    
}

+(void)showCalendarWarning
{
    if (sNLCTaskEventCoordinatorAlreadyShownWarning)
        return;

    dispatch_sync( dispatch_get_main_queue(), ^{
        sNLCTaskEventCoordinatorAlreadyShownWarning=YES;
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: NSLocalizedString(@"No Calendar Access",@"Calendar")
                              message: NSLocalizedString( @"Permission to access the calendar is not available, please re-enable through the Privacy Settings and Save again", @"Calendar")
                              delegate: nil
                              cancelButtonTitle: NSLocalizedString(@"OK",@"OK")
                              otherButtonTitles: nil];
        [alert show];
        
    });
    
}

+(void) showCalendarError:(NSError*)error
{
    dispatch_sync( dispatch_get_main_queue(), ^{

        
        NSString *message = [NSString stringWithFormat: NSLocalizedString( @"Canvas did not successfully update the calendar item. (%@,%lu)", @"Calendar"), error.domain, (unsigned long)error.code];
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: NSLocalizedString(@"Calendar Update Failed",@"Calendar")
                              message: message
                              delegate: nil
                              cancelButtonTitle: NSLocalizedString(@"OK",@"OK")
                              otherButtonTitles: nil];
        [alert show];
    });
}
@end
