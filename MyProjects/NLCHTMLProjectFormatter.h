//
//  NLCHTMLProjectFormatter.h
//  MyProjects
//
//  Created by Gaige B. Paulsen on 8/19/14.
//  Copyright (c) 2014 Gaige B. Paulsen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NLCProject.h"

@interface NLCHTMLProjectFormatter : NSObject

- (NSString*)bodyFromProject:(NLCProject*)project;
-(NSString *)createJsonForServer:(NLCProject*)project apiKey:(NSString *)apikey userName:(NSString*)username;

@end
