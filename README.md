# NNFirebaseResultsController

[![Version](https://img.shields.io/cocoapods/v/NNFirebaseResultsController.svg?style=flat)](http://cocoapods.org/pods/NNFirebaseResultsController)
[![License](https://img.shields.io/cocoapods/l/NNFirebaseResultsController.svg?style=flat)](http://cocoapods.org/pods/NNFirebaseResultsController)
[![Platform](https://img.shields.io/cocoapods/p/NNFirebaseResultsController.svg?style=flat)](http://cocoapods.org/pods/NNFirebaseResultsController)

## Usage

```obj-c
_threads_ref = [[FIRDatabase database] referenceWithPath:@"threads"];
FIRDatabaseQuery* query = [[_threads_ref queryOrderedByChild:@"order"] queryLimitedToLast:3];
NSSortDescriptor* sortDesc = [NSSortDescriptor sortDescriptorWithKey:@"value.order" ascending:NO];// FDataSnapshotはvalueの下に実際のプロパティがあるので、それを指定する。
_frc = [[NNFirebaseResultsController alloc] initWithQuery:query sortDescriptors:@[sortDesc]];
_frc.delegate = self;
[_frc performFetch];
```

## Installation

Firebase を dependency に含むと pod repo push できなかったので、リポジトリを直接指定する方法で利用してください。

```ruby
pod "NNFirebaseResultsController", :git => 'https://github.com/noughts/NNFirebaseResultsController'
```

## Author

Koichi Yamamoto, noughts@gmail.com

## License

NNFirebaseResultsController is available under the MIT license. See the LICENSE file for more info.
