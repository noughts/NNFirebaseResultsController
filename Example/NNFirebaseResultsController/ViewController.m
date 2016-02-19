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
#import "Thread.h"

@implementation ViewController{
    NNFirebaseResultsController* _frc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    Firebase* firebase = [[Firebase alloc] initWithUrl:@"https://hole.firebaseio.com/threads"];
    NSSortDescriptor* sortDesc = [NSSortDescriptor sortDescriptorWithKey:@"value.order" ascending:NO];// FDataSnapshotはvalueの下に実際のプロパティがあるので、それを指定する
    _frc = [[NNFirebaseResultsController alloc] initWithQuery:firebase sortDescriptors:@[sortDesc]];
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

/// スワイプして操作
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
	FDataSnapshot* object = [_frc objectAtIndexPath:indexPath];
	[object.ref removeValueWithCompletionBlock:^(NSError *error, Firebase *ref) {
		NBULogError(@"%@", error);
	}];
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    [self deleteItemAtIndexPath:indexPath];
	[self updateOrderValueAtIndexPath:indexPath];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _frc.fetchedObjects.count;

}


-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    FDataSnapshot* object = [_frc objectAtIndexPath:indexPath];
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
	cell.textLabel.text = object.value[@"title"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", object.value[@"order"]];
    return cell;
}



#pragma mark - NNFirebaseResultsControllerDelegate


-(void)controllerFetchedContent:(NNFirebaseResultsController *)controller{
    [self.tableView reloadData];
}

-(void)controller:(NNFirebaseResultsController *)controller didInsertChild:(id)child atIndexPath:(NSIndexPath *)indexPath{
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}
-(void)controller:(NNFirebaseResultsController *)controller didUpdateChild:(id)child atIndexPath:(NSIndexPath *)indexPath{
	[self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}
-(void)controller:(NNFirebaseResultsController *)controller didDeleteChild:(id)child atIndexPath:(NSIndexPath *)indexPath{
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}
-(void)controller:(NNFirebaseResultsController *)controller didMoveChild:(id)child fromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath{
	[self.tableView moveRowAtIndexPath:fromIndexPath toIndexPath:toIndexPath];
}


#pragma mark - その他

-(void)deleteItemAtIndexPath:(NSIndexPath*)indexPath{
    FDataSnapshot* object = [_frc objectAtIndexPath:indexPath];
    [object.ref removeValue];
}

-(void)updateOrderValueAtIndexPath:(NSIndexPath*)indexPath{
    FDataSnapshot* object = [_frc objectAtIndexPath:indexPath];
    [object.ref updateChildValues:@{@"order":@(arc4random()%100)} withCompletionBlock:^(NSError *error, Firebase *ref) {
        NBULogError(@"%@", error);
    }];
}












@end
