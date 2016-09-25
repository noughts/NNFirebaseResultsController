@import Firebase;
#import "ViewController.h"
#import "NNFirebaseResultsController.h"
#import <NBULog.h>
#import "Thread.h"
#import <MBProgressHUD.h>

@implementation ViewController{
    NNFirebaseResultsController* _frc;
	FIRDatabaseReference* _threads_ref;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
	_threads_ref = [[FIRDatabase database] referenceWithPath:@"threads"];
	FIRDatabaseQuery* query = [[_threads_ref queryOrderedByChild:@"order"] queryLimitedToLast:3];
    NSSortDescriptor* sortDesc = [NSSortDescriptor sortDescriptorWithKey:@"value.order" ascending:NO];// FDataSnapshotはvalueの下に実際のプロパティがあるので、それを指定する
	_frc = [[NNFirebaseResultsController alloc] initWithQuery:query sortDescriptors:@[sortDesc]];
    _frc.delegate = self;
    [_frc performFetch];
	[MBProgressHUD showHUDAddedTo:self.view animated:YES];
	
//	for (int i=0; i<1010; i++) {
//		[self createThreadWithOrderId:i];
//	}
}


-(void)createThreadWithOrderId:(NSUInteger)order{
	NSDictionary* object = @{
							 @"title":@"タイトル",
							 @"createdAt": [FIRServerValue timestamp],
							 @"updatedAt": [FIRServerValue timestamp],
							 @"order": @(order)
							 };
	[[_threads_ref childByAutoId] setValue:object withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
		if( error ){
			NBULogError(@"%@", error);
			return;
		}
		NBULogInfo(@"保存完了!");
	}];
}


-(IBAction)onAddButtonTap:(id)sender{
	NSUInteger order = arc4random() % 100;
	[self createThreadWithOrderId:order];
}



#pragma mark - Table view data source

/// スワイプして操作
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
	FIRDataSnapshot* snapshot = [_frc objectAtIndexPath:indexPath];
	[snapshot.ref removeValueWithCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
		if( error ){
			NBULogError(@"%@", error);
			return;
		}
		NBULogInfo(@"削除完了!");
	}];
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	[self updateOrderValueAtIndexPath:indexPath];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _frc.fetchedObjects.count;

}


-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    FIRDataSnapshot* snapshot = [_frc objectAtIndexPath:indexPath];
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
	cell.textLabel.text = snapshot.value[@"title"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", snapshot.value[@"order"]];
    return cell;
}



#pragma mark - NNFirebaseResultsControllerDelegate


-(void)controllerFetchedContent:(NNFirebaseResultsController *)controller{
    [self.tableView reloadData];
	[MBProgressHUD hideHUDForView:self.view animated:YES];
}

-(void)controller:(NNFirebaseResultsController *)controller didInsertChild:(id)child atIndexPath:(NSIndexPath *)indexPath{
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}
-(void)controller:(NNFirebaseResultsController *)controller didUpdateChild:(id)child atIndexPath:(NSIndexPath *)indexPath{
	// データを保存した直後にinsertが呼ばれ、サーバーに保存が完了するとupdateがよばれるので、セルが点滅アニメしないようにNoneにする
	[self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}
-(void)controller:(NNFirebaseResultsController *)controller didDeleteChild:(id)child atIndexPath:(NSIndexPath *)indexPath{
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}
-(void)controller:(NNFirebaseResultsController *)controller didMoveChild:(id)child fromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath{
	[self.tableView moveRowAtIndexPath:fromIndexPath toIndexPath:toIndexPath];
}


#pragma mark - その他

-(void)updateOrderValueAtIndexPath:(NSIndexPath*)indexPath{
    FIRDataSnapshot* snapshot = [_frc objectAtIndexPath:indexPath];
	[snapshot.ref updateChildValues:@{@"order":@(arc4random()%100)} withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
		if( error ){
			NBULogError(@"%@", error);
			return;
		}
		NBULogInfo(@"更新完了!");
	}];
}












@end
