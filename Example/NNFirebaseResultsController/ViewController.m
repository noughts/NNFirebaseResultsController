//
//  ViewController.m
//  NNFirebaseResultsController
//
//  Created by noughts on 2016/02/14.
//  Copyright © 2016年 Koichi Yamamoto. All rights reserved.
//

#import "ViewController.h"
#import "NNFirebaseResultsController.h"
#import <Firebase.h>
#import <NBULog.h>

@implementation ViewController{
    NNFirebaseResultsController* _frc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    Firebase* firebase = [[Firebase alloc] initWithUrl:@"https://hole.firebaseio.com/threads"];
    _frc = [[NNFirebaseResultsController alloc] initWithQuery:firebase sortDescriptors:nil];
    _frc.delegate = self;
    [_frc performFetch];
}



-(IBAction)onAddButtonTap:(id)sender{
    Firebase* firebase = [[Firebase alloc] initWithUrl:@"https://hole.firebaseio.com/threads"];
    NSDictionary* object = @{
                             @"title":@"タイトル",
                             @"createdAt": kFirebaseServerValueTimestamp,
                             @"updatedAt": kFirebaseServerValueTimestamp,
                             @"order": @(arc4random()%100)
                             };
    [[firebase childByAutoId] setValue:object withCompletionBlock:^(NSError *error, Firebase *ref) {
        NBULogError(error.description);
    }];
}



#pragma mark - Table view data source

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _frc.fetchedObjects.count;

}


-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    id object = [_frc objectAtIndex:indexPath.row];
    NBULogInfo(@"%@", object);
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    return cell;
}



#pragma mark - NNFirebaseResultsControllerDelegate


-(void)controllerFetchedContent:(NNFirebaseResultsController *)controller{
    [self.tableView reloadData];
}

-(void)controller:(NNFirebaseResultsController *)controller didInsertChild:(id)child atIndexPath:(NSIndexPath *)indexPath{
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}
-(void)controller:(NNFirebaseResultsController *)controller didUpdateChild:(id)child atIndex:(NSUInteger)index{
    
}
-(void)controller:(NNFirebaseResultsController *)controller didDeleteChild:(id)child atIndex:(NSUInteger)index{
    
}
-(void)controller:(NNFirebaseResultsController *)controller didMoveChild:(id)child fromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex{
    
}



@end
