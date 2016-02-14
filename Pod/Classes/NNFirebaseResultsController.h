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


@interface NNFirebaseResultsController : NSObject

@property(nonatomic,weak) id<NNFirebaseResultsControllerDelegate> delegate;

- (instancetype)initWithQuery:(FQuery *)query;
-(void)performFetch;

@end








@protocol NNFirebaseResultsControllerDelegate<NSObject>

- (void)controllerFetchedContent:(NNFirebaseResultsController*)controller;
- (void)controller:(NNFirebaseResultsController*)controller didInsertChild:(id)child atIndex:(NSUInteger)index;
- (void)controller:(NNFirebaseResultsController*)controller didDeleteChild:(id)child atIndex:(NSUInteger)index;
- (void)controller:(NNFirebaseResultsController*)controller didMoveChild:(id)child fromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex;
- (void)controller:(NNFirebaseResultsController*)controller didUpdateChild:(id)child atIndex:(NSUInteger)index;


@end