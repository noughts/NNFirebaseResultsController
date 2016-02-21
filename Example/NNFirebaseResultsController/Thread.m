//
//  Thread.m
//  NNFirebaseResultsController
//
//  Created by noughts on 2016/02/14.
//  Copyright © 2016年 Koichi Yamamoto. All rights reserved.
//

#import "Thread.h"


@implementation Thread

-(NSString*)title{
    return _snapshot.value[@"title"];
}

@end
