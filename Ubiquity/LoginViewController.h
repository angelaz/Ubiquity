//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController

@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityIndicator;

- (void)loginButtonTouchHandler:(id)sender;
@end
