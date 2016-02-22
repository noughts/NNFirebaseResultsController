//
//  NNFirebaseModel.h
//  Pods
//
//  Created by noughts on 2016/02/21.
//
//

#import <Foundation/Foundation.h>
#import "Firebase.h"

@interface NNFirebaseModel : NSObject{
    #pragma mark - protected
    FDataSnapshot* _snapshot;
}

-(instancetype)initWithSnapshot:(FDataSnapshot*)snapshot;
-(Firebase*)ref;
-(NSString*)key;

@end
