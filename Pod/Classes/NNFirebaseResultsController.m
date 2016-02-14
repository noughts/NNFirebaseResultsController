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
    Firebase* _firebase;
    NSMutableArray* _fetchedObjects;
    FQuery* _query;
}



- (instancetype)initWithQuery:(FQuery *)query{
    self = [super init];
    if (self) {
        _fetchedObjects = [NSMutableArray array];
        _query = query;
        [_query observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
            _initialChildrenCount = snapshot.childrenCount;
            [_fetchedObjects addObjectsFromArray:snapshot.children.allObjects];
            [self.delegate controllerFetchedContent:self];
            [self initListeners];
        }];
    }
    return self;
}
-(void)performFetch{
    [_firebase observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        [_fetchedObjects addObjectsFromArray:snapshot.children.allObjects];
    }];
}




-(void)initListeners{
    __block NSUInteger counter = 0;
    [_query observeEventType:FEventTypeChildAdded andPreviousSiblingKeyWithBlock:^(FDataSnapshot *snapshot, NSString *previousChildKey) {
        if( counter < _initialChildrenCount ){
            counter++;
            return;
        }
        NSUInteger index = [self indexForKey:previousChildKey] + 1;
        
        [_fetchedObjects insertObject:snapshot atIndex:index];
        
        [self.delegate childAdded:snapshot atIndex:index];
    } withCancelBlock:^(NSError *error) {
        [self.delegate canceledWithError:error];
    }];
    
    [_query observeEventType:FEventTypeChildChanged andPreviousSiblingKeyWithBlock:^(FDataSnapshot *snapshot, NSString *previousChildKey) {
        NSUInteger index = [self indexForKey:snapshot.key];
        
        [_fetchedObjects replaceObjectAtIndex:index withObject:snapshot];
        
        [self.delegate childChanged:snapshot atIndex:index];
    } withCancelBlock:^(NSError *error) {
        [self.delegate canceledWithError:error];
    }];
    
    [_query observeEventType:FEventTypeChildRemoved withBlock:^(FDataSnapshot *snapshot) {
        NSUInteger index = [self indexForKey:snapshot.key];
        
        [_fetchedObjects removeObjectAtIndex:index];
        
        [self.delegate childRemoved:snapshot atIndex:index];
    } withCancelBlock:^(NSError *error) {
        [self.delegate canceledWithError:error];
    }];
    
    [_query observeEventType:FEventTypeChildMoved andPreviousSiblingKeyWithBlock:^(FDataSnapshot *snapshot, NSString *previousChildKey) {
        NSUInteger fromIndex = [self indexForKey:snapshot.key];
        [_fetchedObjects removeObjectAtIndex:fromIndex];
        
        NSUInteger toIndex = [self indexForKey:previousChildKey] + 1;
        [_fetchedObjects insertObject:snapshot atIndex:toIndex];
        
        [self.delegate childMoved:snapshot fromIndex:fromIndex toIndex:toIndex];
    } withCancelBlock:^(NSError *error) {
        [self.delegate canceledWithError:error];
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

- (FDataSnapshot *)objectAtIndex:(NSUInteger)index {
    return (FDataSnapshot *)[_fetchedObjects objectAtIndex:index];
}

- (Firebase *)refForIndex:(NSUInteger)index {
    return [(FDataSnapshot *)[_fetchedObjects objectAtIndex:index] ref];
}





@end
