@import UIKit;
#import "RZTouchID.h"

OBJC_EXTERN NSString* const kRZTouchIdLoggedInUser;
@class DataModel;

@interface RZViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (nonatomic, strong) DataModel *dataModel;

@end

