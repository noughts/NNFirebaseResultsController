//
//  NNFirebaseResultsController.m
//  Pods
//
//  Created by noughts on 2016/02/14.
//
//

#import "NNFirebaseResultsController.h"
#import "Firebase.h"
#import "NBULog.h"

@implementation NNFirebaseResultsController{
    
    Firebase* _firebase;
    NSMutableArray* _fetchedObjects;
}

static Firebase* _rootFirebase;
+(void)initializeWithBaseUrl:(NSString*)baseUrl{
    _rootFirebase = [[Firebase alloc] initWithUrl:baseUrl];
}


-(instancetype)initWithPath:(NSString*)path{
    NSAssert(  _rootFirebase, @"先にinitializeWithBaseUrlを呼んでください" );
    if( self = [super init] ){
        _firebase = [_rootFirebase childByAppendingPath:path];
    }
    return self;
}

-(instancetype)initWithFirebase:(Firebase*)firebase{
    if( self = [super init] ){
        _firebase = firebase;
    }
    return self;
}

-(void)performFetch{
    [_firebase observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        NBULogInfo(@"%@", snapshot);
    }];
}

@end
