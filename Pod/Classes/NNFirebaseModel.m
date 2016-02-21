//
//  NNFirebaseModel.m
//  Pods
//
//  Created by noughts on 2016/02/21.
//
//

#import "NNFirebaseModel.h"
#import "Firebase.h"


@implementation NNFirebaseModel{
}



-(instancetype)initWithSnapshot:(FDataSnapshot*)snapshot{
    if( self = [super init] ){
        _snapshot = snapshot;
    }
    return self;
}

-(Firebase*)ref{
    return _snapshot.ref;
}

-(NSString*)key{
    return _snapshot.key;
}


@end
