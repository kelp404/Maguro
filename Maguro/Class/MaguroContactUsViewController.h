//
//  MaguroContactUsViewController.h
//  Maguro
//
//  Created by Kelp on 2013/01/18.
//

#import <UIKit/UIKit.h>
#import "MaguroBaseViewController.h"

@class Maguro;
@class MBProgressHUD;

@interface MaguroContactUsViewController : MaguroBaseViewController <UIActionSheetDelegate, UITextFieldDelegate, UITextViewDelegate, UIAlertViewDelegate, UITableViewDataSource, UITableViewDelegate> {
    MBProgressHUD *_hud;
    
    // UI
    UITableView *_tableView;
    UITextView *_textMessage;
    UITextField *_textName;
    UITextField *_textEmail;
    id _editingText;
    
    // data
    NSMutableArray *_answers;
}

@end
