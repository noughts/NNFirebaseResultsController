# NNFirebaseResultsController

[![CI Status](http://img.shields.io/travis/Koichi Yamamoto/NNFirebaseResultsController.svg?style=flat)](https://travis-ci.org/Koichi Yamamoto/NNFirebaseResultsController)
[![Version](https://img.shields.io/cocoapods/v/NNFirebaseResultsController.svg?style=flat)](http://cocoapods.org/pods/NNFirebaseResultsController)
[![License](https://img.shields.io/cocoapods/l/NNFirebaseResultsController.svg?style=flat)](http://cocoapods.org/pods/NNFirebaseResultsController)
[![Platform](https://img.shields.io/cocoapods/p/NNFirebaseResultsController.svg?style=flat)](http://cocoapods.org/pods/NNFirebaseResultsController)

## Usage

```obj-c
Firebase* firebase = [[Firebase alloc] initWithUrl:@"https://example.firebaseio.com/posts"];
NSSortDescriptor* sortDesc = [NSSortDescriptor sortDescriptorWithKey:@"value.createdAt" ascending:NO];
_frc = [[NNFirebaseResultsController alloc] initWithQuery:firebase sortDescriptors:@[sortDesc] modelClass:[Post class]];
_frc.delegate = self;
[_frc performFetch];
```

## Installation

NNFirebaseResultsController is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
source 'https://github.com/noughts/Specs.git'
pod "NNFirebaseResultsController"
```

## Author

Koichi Yamamoto, noughts@gmail.com

## License

NNFirebaseResultsController is available under the MIT license. See the LICENSE file for more info.
