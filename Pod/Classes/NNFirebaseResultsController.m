#import "NNFirebaseResultsController.h"
#import "Firebase.h"

@implementation NNFirebaseResultsController{
	NSUInteger _initialChildrenCount;
	NSMutableArray<FIRDataSnapshot*>* _fetchedObjects;
	FIRDatabaseQuery* _query;
	NSArray<NSSortDescriptor*>* _sortDescriptors;
	__weak NNFirebaseResultsController* _self;
    
}



- (instancetype)initWithQuery:(FIRDatabaseQuery *)query sortDescriptors:(NSArray<NSSortDescriptor*>*)sortDescriptors{
	self = [super init];
	if (self) {
		_self = self;
		_fetchedObjects = [NSMutableArray array];
		_query = query;
		_sortDescriptors = sortDescriptors;
	}
	return self;
}


#pragma mark - public

-(NSIndexPath*)indexPathForObject:(id)object{
	NSUInteger index = [_fetchedObjects indexOfObject:object];
	return [NSIndexPath indexPathForRow:index inSection:0];
}


- (FIRDataSnapshot*)objectAtIndex:(NSUInteger)index {
	return _fetchedObjects[index];
}
- (FIRDataSnapshot*)objectAtIndexPath:(NSIndexPath*)indexPath {
	return [self objectAtIndex:indexPath.row];
}


-(NSArray<FIRDataSnapshot*>*)fetchedObjects{
	return _fetchedObjects;
}

-(void)performFetch{
	[_query observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot) {
		_initialChildrenCount = snapshot.childrenCount;
		[_fetchedObjects addObjectsFromArray:snapshot.children.allObjects];
		[_self sortIfNeeded];
		[_delegate controllerFetchedContent:_self];
		[_self initListeners];
	}];
}


/// 必要に応じてfetchedObjectsをソート
-(void)sortIfNeeded{
	if( _sortDescriptors ){
		@try {
			[_fetchedObjects sortUsingDescriptors:_sortDescriptors];
		}
		@catch (NSException *exception) {
			NSLog(@"sortDescriptorで指定したキーが見つからないためソートできませんでした");
			NSLog(@"%@", exception);
		}
		
	}
}

-(void)initListeners{
	__block NSUInteger counter = 0;
	[_query observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot *snapshot) {
		/// 初期データ分は無視
		if( counter < _initialChildrenCount ){
			counter++;
			return;
		}
		[_fetchedObjects addObject:snapshot];
		[_self sortIfNeeded];
		NSIndexPath* indexPath = [_self indexPathForObject:snapshot];
		[_delegate controller:_self didInsertChild:snapshot atIndexPath:indexPath];
	}];
	
	[_query observeEventType:FIRDataEventTypeChildChanged withBlock:^(FIRDataSnapshot *snapshot) {
		NSUInteger beforeIndex = [_self indexForKey:snapshot.key];
		NSIndexPath* beforeIndexPath = [NSIndexPath indexPathForRow:beforeIndex inSection:0];
		[_fetchedObjects replaceObjectAtIndex:beforeIndex withObject:snapshot];
		[_delegate controller:_self didUpdateChild:snapshot atIndexPath:beforeIndexPath];
		[_self sortIfNeeded];
		NSUInteger afterIndex = [_self indexForKey:snapshot.key];
		if( beforeIndex != afterIndex ){
			NSIndexPath* afterIndexPath = [NSIndexPath indexPathForRow:afterIndex inSection:0];
			[_delegate controller:_self didMoveChild:snapshot fromIndexPath:beforeIndexPath toIndexPath:afterIndexPath];
		}
	}];
	
	[_query observeEventType:FIRDataEventTypeChildRemoved withBlock:^(FIRDataSnapshot *snapshot) {
		NSUInteger index = [_self indexForKey:snapshot.key];
		[_fetchedObjects removeObjectAtIndex:index];
		NSIndexPath* indexPath = [NSIndexPath indexPathForRow:index inSection:0];
		[_delegate controller:_self didDeleteChild:snapshot atIndexPath:indexPath];
	}];
	
	[_query observeEventType:FIRDataEventTypeChildMoved withBlock:^(FIRDataSnapshot *snapshot) {
		
		/*
		 NSUInteger fromIndex = [_self indexForKey:snapshot.key];
		 [_fetchedObjects removeObjectAtIndex:fromIndex];
		 NSUInteger toIndex = [_self indexForKey:previousChildKey] + 1;
		 [_fetchedObjects insertObject:snapshot atIndex:toIndex];
		 [_delegate controller:_self didMoveChild:snapshot fromIndex:fromIndex toIndex:toIndex];
		 */
	}];
}


- (NSUInteger)indexForKey:(NSString *)key {
	if (!key) return -1;
	
	for (NSUInteger index = 0; index < [_fetchedObjects count]; index++) {
		if ([key isEqualToString:[(FIRDataSnapshot *)[_fetchedObjects objectAtIndex:index] key]]) {
			return index;
		}
	}
	
	NSString *errorReason = [NSString stringWithFormat:@"Key \"%@\" not found in FirebaseArray %@", key, _fetchedObjects];
	@throw [NSException exceptionWithName:@"FirebaseArrayKeyNotFoundException" reason:errorReason userInfo:@{
																											 @"Key" : key,
																											 @"Array" : _fetchedObjects
																											 }];
}


- (NSUInteger)count {
	return [_fetchedObjects count];
}





@end
