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



@end