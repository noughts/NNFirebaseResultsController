//
//  NNFirebaseResultsController.h
//  Pods
//
//  Created by noughts on 2016/02/14.
//
//

#import <Foundation/Foundation.h>
@protocol NNFirebaseResultsControllerDelegate;


@interface NNFirebaseResultsController : NSObject

@property(nonatomic,weak) id<NNFirebaseResultsControllerDelegate> delegate;


+(void)initializeWithBaseUrl:(NSString*)baseUrl;
-(instancetype)initWithPath:(NSString*)path;
-(void)performFetch;

@end








@protocol NNFirebaseResultsControllerDelegate<NSObject>



@end