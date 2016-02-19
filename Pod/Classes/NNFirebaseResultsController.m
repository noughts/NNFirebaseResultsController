/*
 
 モデルクラスを指定する実装も考えましたが、安全にプロパティを設定していく処理が重くなりそうだったので、使用する側で適宜モデルに変換するのが良さそうです。
 もしくは、objectAtIndexPath 時に変換するのも良さそう
 
 */

#import "NNFirebaseResultsController.h"
#import "Firebase.h"
#import "NBULog.h"

@implementation NNFirebaseResultsController{
    NSUInteger _initialChildrenCount;
    NSMutableArray* _fetchedObjects;
    FQuery* _query;
    NSArray<NSSortDescriptor*>* _sortDescriptors;
    Class _modelClass;
    __weak NNFirebaseResultsController* _self;
    
}



- (instancetype)initWithQuery:(FQuery *)query sortDescriptors:(NSArray<NSSortDescriptor*>*)sortDescriptors{
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


//TODO:カスタムモデル対応
- (FDataSnapshot *)objectAtIndex:(NSUInteger)index {
    return (FDataSnapshot *)[_fetchedObjects objectAtIndex:index];
}
- (FDataSnapshot *)objectAtIndexPath:(NSIndexPath*)indexPath {
	return (FDataSnapshot *)[_fetchedObjects objectAtIndex:indexPath.row];
}


-(NSArray*)fetchedObjects{
    return _fetchedObjects;
}

-(void)performFetch{
    [_query observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        _initialChildrenCount = snapshot.childrenCount;
        [_fetchedObjects addObjectsFromArray:snapshot.children.allObjects];
        [_self sortIfNeeded];
        [_delegate controllerFetchedContent:_self];
        [_self initListeners];
    }];
}

-(id)createInstanceFromSnapshot:(FDataSnapshot*)snapshot{
	NSDictionary* dictionary = snapshot.value;
    id model = [[_modelClass alloc] init];
    for (NSString* key in dictionary.allKeys) {
		bool hasProperty = [model respondsToSelector:NSSelectorFromString(key)];
		if( hasProperty ){
			id value = dictionary[key];
			[model setValue:value forKey:key];
		}
    }
    return model;
}


/// 必要に応じてfetchedObjectsをソート
-(void)sortIfNeeded{
    if( _sortDescriptors ){
		@try {
			[_fetchedObjects sortUsingDescriptors:_sortDescriptors];
		}
		@catch (NSException *exception) {
			NBULogError(@"sortDescriptorで指定したキーが見つからないためソートできませんでした");
			NBULogError(@"%@", exception);
		}
		
    }
}

-(void)initListeners{
    __block NSUInteger counter = 0;
	[_query observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
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
	
	[_query observeEventType:FEventTypeChildChanged withBlock:^(FDataSnapshot *snapshot) {
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
    
    [_query observeEventType:FEventTypeChildRemoved withBlock:^(FDataSnapshot *snapshot) {
        NSUInteger index = [_self indexForKey:snapshot.key];
        [_fetchedObjects removeObjectAtIndex:index];
		NSIndexPath* indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        [_delegate controller:_self didDeleteChild:snapshot atIndexPath:indexPath];
    }];
	
	[_query observeEventType:FEventTypeChildMoved withBlock:^(FDataSnapshot *snapshot) {
		
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
        if ([key isEqualToString:[(FDataSnapshot *)[_fetchedObjects objectAtIndex:index] key]]) {
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



- (Firebase *)refForIndex:(NSUInteger)index {
    return [(FDataSnapshot *)[_fetchedObjects objectAtIndex:index] ref];
}





@end
