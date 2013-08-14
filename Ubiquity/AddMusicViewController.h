//
//  AddMusicViewController.h
//  Ubiquity
//
//  Created by Angela Zhang on 8/14/13.
//
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "Rdio/Rdio.h"

@class AddMusicViewController;

@protocol AddMusicViewControllerDelegate <NSObject>

- (void)addMusicViewController:(AddMusicViewController *)controller didFinishSelectingSong:(NSString *)trackKey;

@end


@interface AddMusicViewController : UIViewController <RdioDelegate, RDAPIRequestDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, weak) id <AddMusicViewControllerDelegate> delegate;

@end
