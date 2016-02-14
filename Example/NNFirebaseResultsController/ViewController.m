//
//  ViewController.m
//  NNFirebaseResultsController
//
//  Created by noughts on 2016/02/14.
//  Copyright © 2016年 Koichi Yamamoto. All rights reserved.
//

#import "ViewController.h"
#import <NNFirebaseResultsController.h>

@implementation ViewController{
    NNFirebaseResultsController* _frc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _frc = [[NNFirebaseResultsController alloc] initWithPath:@"threads"];
    _frc.delegate = self;
    [_frc performFetch];
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 0;
}



@end
