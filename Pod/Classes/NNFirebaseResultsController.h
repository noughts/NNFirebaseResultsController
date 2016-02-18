//
//  NNFirebaseResultsController.h
//  Pods
//
//  Created by noughts on 2016/02/14.
//
//

#import <Foundation/Foundation.h>
@protocol NNFirebaseResultsControllerDelegate;
@class FQuery;
@class FDataSnapshot;


@interface NNFirebaseResultsController : NSObject

@property(nonatomic,weak) id<NNFirebaseResultsControllerDelegate> delegate;

/// FirebaseのクエリはDESCのソートがないので、取得した内容を自由にソートするためにsortDescriptorを渡せます。
- (instancetype)initWithQuery:(FQuery *)query sortDescriptors:(NSArray<NSSortDescriptor*>*)sortDescriptors;
-(void)performFetch;
-(NSArray*)fetchedObjects;
-(NSIndexPath*)indexPathForObject:(id)object;
- (FDataSnapshot *)objectAtIndex:(NSUInteger)index;
- (FDataSnapshot *)objectAtIndexPath:(NSIndexPath*)indexPath;

@end








@protocol NNFirebaseResultsControllerDelegate<NSObject>

- (void)controllerFetchedContent:(NNFirebaseResultsController*)controller;
- (void)controller:(NNFirebaseResultsController*)controller didInsertChild:(id)child atIndexPath:(NSIndexPath*)indexPath;
- (void)controller:(NNFirebaseResultsController*)controller didDeleteChild:(id)child atIndexPath:(NSIndexPath*)indexPath;
- (void)controller:(NNFirebaseResultsController*)controller didMoveChild:(id)child fromIndexPath:(NSIndexPath*)fromIndexPath toIndexPath:(NSIndexPath*)toIndexPath;
- (void)controller:(NNFirebaseResultsController*)controller didUpdateChild:(id)child atIndexPath:(NSIndexPath*)indexPath;
- (void)controller:(NNFirebaseResultsController *)controller didCancelWithError:(NSError*)error;

@end