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
    NSUInteger _initialChildrenCount;
    NSMutableArray* _fetchedObjects;
    FQuery* _query;
    NSArray<NSSortDescriptor*>* _sortDescriptors;
    Class _modelClass;
    __weak NNFirebaseResultsController* _self;
    
}



- (instancetype)initWithQuery:(FQuery *)query sortDescriptors:(NSArray<NSSortDescriptor*>*)sortDescriptors modelClass:(Class)modelClass{
    self = [super init];
    if (self) {
        _self = self;
        _fetchedObjects = [NSMutableArray array];
        _query = query;
        _sortDescriptors = sortDescriptors;
        _modelClass = modelClass;
    }
    return self;
}


#pragma mark - public

-(NSIndexPath*)indexPathForObject:(id)object{
    NSUInteger index = [_fetchedObjects indexOfObject:object];
    return [NSIndexPath indexPathForRow:index inSection:0];
}

- (FDataSnapshot *)objectAtIndex:(NSUInteger)index {
    return (FDataSnapshot *)[_fetchedObjects objectAtIndex:index];
}


-(NSArray*)fetchedObjects{
    return _fetchedObjects;
}

-(void)performFetch{
    [_query observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        _initialChildrenCount = snapshot.childrenCount;
        
        NSMutableArray* ary = [NSMutableArray new];
        for (FDataSnapshot* obj in snapshot.children) {
            id model = [_self createInstanceFromDictionary:obj.value];
//            [model setValue:obj.key forKey:@"key"];
//            [model setValuesForKeysWithDictionary:obj.value];
            [ary addObject:model];
        }
        
        [_fetchedObjects addObjectsFromArray:ary];
//        [_self sortIfNeeded];
        [_delegate controllerFetchedContent:_self];
        [_self initListeners];
    }];
}

-(id)createInstanceFromDictionary:(NSDictionary*)dictionary{
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
        [_fetchedObjects sortUsingDescriptors:_sortDescriptors];
    }
}

-(void)initListeners{
    __block NSUInteger counter = 0;
    [_query observeEventType:FEventTypeChildAdded andPreviousSiblingKeyWithBlock:^(FDataSnapshot *snapshot, NSString *previousChildKey) {
        /// 初期データ分は無視
        if( counter < _initialChildrenCount ){
            counter++;
            return;
        }
        [_fetchedObjects addObject:snapshot];
        [_self sortIfNeeded];
        NSIndexPath* indexPath = [_self indexPathForObject:snapshot];
        [_delegate controller:_self didInsertChild:snapshot atIndexPath:indexPath];
    } withCancelBlock:^(NSError *error) {
        [_delegate controller:_self didCancelWithError:error];
    }];
    
    [_query observeEventType:FEventTypeChildChanged andPreviousSiblingKeyWithBlock:^(FDataSnapshot *snapshot, NSString *previousChildKey) {
        NSUInteger index = [_self indexForKey:snapshot.key];
        [_fetchedObjects replaceObjectAtIndex:index withObject:snapshot];
        [_delegate controller:_self didUpdateChild:snapshot atIndex:index];
    } withCancelBlock:^(NSError *error) {
        [_delegate controller:_self didCancelWithError:error];
    }];
    
    [_query observeEventType:FEventTypeChildRemoved withBlock:^(FDataSnapshot *snapshot) {
        NSUInteger index = [_self indexForKey:snapshot.key];
        
        [_fetchedObjects removeObjectAtIndex:index];
        
        [_delegate controller:_self didDeleteChild:snapshot atIndex:index];
    } withCancelBlock:^(NSError *error) {
        [_delegate controller:_self didCancelWithError:error];
    }];
    
    [_query observeEventType:FEventTypeChildMoved andPreviousSiblingKeyWithBlock:^(FDataSnapshot *snapshot, NSString *previousChildKey) {
        NSUInteger fromIndex = [_self indexForKey:snapshot.key];
        [_fetchedObjects removeObjectAtIndex:fromIndex];
        NSUInteger toIndex = [_self indexForKey:previousChildKey] + 1;
        [_fetchedObjects insertObject:snapshot atIndex:toIndex];
        [_delegate controller:_self didMoveChild:snapshot fromIndex:fromIndex toIndex:toIndex];
    } withCancelBlock:^(NSError *error) {
        [_delegate controller:_self didCancelWithError:error];
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
