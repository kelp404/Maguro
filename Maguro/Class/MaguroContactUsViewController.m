//
//  MaguroContactUsViewController.m
//  Maguro
//
//  Created by Kelp on 2013/01/18.
//  Copyright (c) 2013 Accuvally Inc. All rights reserved.
//

#import "MaguroContactUsViewController.h"
#import "Maguro.h"
#import "MBProgressHUD.h"
#import "MaguroArticleViewController.h"


#define MAGURO_USER_DEFAULTS_MESSAGE @"maguro.message"
#define SECTION_MESSAGE 0
#define SECTION_USER 1
#define SECTION_ANSWERS 2
#define TEXT_MESSAGE_HEIGHT 100

@implementation MaguroContactUsViewController

#pragma mark - View Events
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // set up navigation
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(clickClose:)];
    self.navigationItem.leftBarButtonItem = closeButton;
    UIBarButtonItem *continueButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"Continue", @"Maguro", @"continue") style:UIBarButtonItemStylePlain target:self action:@selector(clickContinue:)];
    [continueButton setEnabled:NO];
    self.navigationItem.rightBarButtonItem = continueButton;
    
    // set up tableview
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    UIView *view = [[UIView alloc] initWithFrame:_tableView.frame];
    view.backgroundColor = _delegate.config.backgroundColor;
    [_tableView setBackgroundView:view];
    [self.view addSubview:_tableView];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        // register for keyboard notifications
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardDidShow:)
                                                     name:UIKeyboardDidShowNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillHide)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];
    }
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (_answers == nil) {
        // focus _textMessage
        [_textMessage becomeFirstResponder];
    }
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        // unregister for keyboard notifications while not visible.
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UIKeyboardDidShowNotification
                                                      object:nil];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UIKeyboardDidHideNotification
                                                      object:nil];
    }
}
#pragma mark Keyboard
- (void)keyboardDidShow:(NSNotification *)notification
{
    CGRect keyboardBounds;
    [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardBounds];
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
    CGRect frame = CGRectMake(_tableView.frame.origin.x, _tableView.frame.origin.y, _tableView.frame.size.width, self.view.frame.size.height - keyboardBounds.size.height);
    [UIView animateWithDuration:0.2 animations:^{
        _tableView.frame = frame;
    } completion:^(BOOL finished) {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone && _editingText) {
            [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_editingText == _textName ? 0 : 1 inSection:SECTION_USER] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
    }];
}
- (void)keyboardWillHide
{
    CGRect frame = CGRectMake(_tableView.frame.origin.x, _tableView.frame.origin.y, _tableView.frame.size.width, self.view.frame.size.height);
    [UIView animateWithDuration:0.2 animations:^{
        _tableView.frame = frame;
    }];
}
#pragma mark Orientation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    @try { return [_delegate.rootViewController shouldAutorotateToInterfaceOrientation:orientation]; }
    @catch (NSException *exception) { return NO; }
}


#pragma mark - TableView Delegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    
    if (indexPath.section == SECTION_MESSAGE) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if (_textMessage == nil) {
            _textMessage = [[UITextView alloc] initWithFrame:CGRectMake(_cellBound.width, 0, _tableView.frame.size.width - _cellBound.width * 2, TEXT_MESSAGE_HEIGHT)];
            _textMessage.font = [UIFont systemFontOfSize:17];
            _textMessage.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            _textMessage.backgroundColor = [UIColor clearColor];
            _textMessage.delegate = self;
            
            // load message from user defaults
            NSString *message = [[NSUserDefaults standardUserDefaults] objectForKey:MAGURO_USER_DEFAULTS_MESSAGE];
            if (message && message.length > 0) {
                _textMessage.text = message;
                [self.navigationItem.rightBarButtonItem setEnabled:YES];
            }
        }
        [cell addSubview:_textMessage];
    }
    else if (indexPath.section == SECTION_USER) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if (indexPath.row == 0) {
            if (_textName == nil) {
                _textName = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, _tableView.frame.size.width - _cellBound.width * 2 - 100, 22)];
                _textName.text = _delegate.config.name;
                _textName.placeholder = NSLocalizedStringFromTable(@"Your Name", @"Maguro", @"Your Name");
                _textName.autocapitalizationType = UITextAutocapitalizationTypeNone;
                _textName.clearButtonMode = UITextFieldViewModeWhileEditing;
                _textName.autoresizingMask = UIViewAutoresizingFlexibleWidth;
                _textName.returnKeyType = UIReturnKeyDone;
                _textName.delegate = self;
            }
            cell.accessoryView =_textName;
            cell.textLabel.text = NSLocalizedStringFromTable(@"Name", @"Maguro", @"Name");
        }
        else if (indexPath.row == 1) {
            if (_textEmail == nil) {
                _textEmail = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, _tableView.frame.size.width - _cellBound.width * 2 - 100, 22)];
                _textEmail.text = _delegate.config.email;
                _textEmail.placeholder = NSLocalizedStringFromTable(@"Your Email", @"Maguro", @"Your Email");
                _textEmail.keyboardType = UIKeyboardTypeEmailAddress;
                _textEmail.autocapitalizationType = UITextAutocapitalizationTypeNone;
                _textEmail.clearButtonMode = UITextFieldViewModeWhileEditing;
                _textEmail.autoresizingMask = UIViewAutoresizingFlexibleWidth;
                _textEmail.returnKeyType = UIReturnKeyDone;
                _textEmail.delegate = self;
            }
            cell.accessoryView = _textEmail;
            cell.textLabel.text = NSLocalizedStringFromTable(@"Email", @"Maguro", @"Email");
        }
    }
    else if (indexPath.section == SECTION_ANSWERS && indexPath.row < _answers.count) {
        NSDictionary *document = [_answers objectAtIndex:indexPath.row];
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text = [document objectForKey:@"question"];
    }
    
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case SECTION_MESSAGE:
            return TEXT_MESSAGE_HEIGHT;
        default:
            return -1;
    }
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case SECTION_MESSAGE:
            return NSLocalizedStringFromTable(@"Message", @"Maguro", @"Message");
        case SECTION_USER:
            return NSLocalizedStringFromTable(@"Your Information", @"Maguro", @"your information");
        case SECTION_ANSWERS:
            return _answers.count > 0 ? NSLocalizedStringFromTable(@"Matching articles", @"Maguro", @"Matching articles") : nil;
        default:
            return nil;
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case SECTION_MESSAGE:
            return 1;
        case SECTION_USER:
            return 2;
        case SECTION_ANSWERS:
            return _answers.count;
        default:
            return 0;
    }
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}
#pragma mark Select Row
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == SECTION_USER) {
        if (indexPath.row == 0) { [_textName becomeFirstResponder]; }
        else { [_textEmail becomeFirstResponder]; }
    }
    else if (indexPath.section == SECTION_ANSWERS) {
        NSDictionary *article = [_answers objectAtIndex:indexPath.row];
        
        MaguroArticleViewController *controller = [MaguroArticleViewController new];
        controller.article = article;
        controller.delegate = self.delegate;
        [self.navigationController pushViewController:controller animated:YES];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - TextView Delegate
- (void)textViewDidChange:(UITextView *)textView
{
    [self.navigationItem.rightBarButtonItem setEnabled:(textView.text.length > 0)];
}
#pragma mark - TextField Delegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    _editingText = textField;
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    _editingText = nil;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


#pragma mark - Button Events
// close Maguro
- (void)clickClose:(UIBarButtonItem *)sender
{
    [self.view endEditing:YES];
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:NSLocalizedStringFromTable(@"Cancel", @"Maguro", @"Cancel")
                                               destructiveButtonTitle:NSLocalizedStringFromTable(@"Don't save", @"Maguro", @"Don't save")
                                                    otherButtonTitles:NSLocalizedStringFromTable(@"Save draft", @"Maguro", @"Save draft"), nil];
    [actionSheet showFromBarButtonItem:sender animated:YES];
}
// load instant_answers, than goto next step
- (void)clickContinue:(UIBarButtonItem *)sender
{
    // close keyboard
    [self.view endEditing:YES];
    
    // disable continue button
    [sender setEnabled:NO];
    
    // show loading view
    _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    _hud.removeFromSuperViewOnHide = YES;
    _hud.dimBackground = YES;
    [_hud show:YES];
    
    // load instant_answers
    [_delegate requestForInstantAnswers:_textMessage.text errorHandler:^(NSError *error) {
        // load answers error, try to submit the message
        [self clickSubmit:sender];
    } completionHandler:^(NSDictionary *document) {
        if ([[document objectForKey:@"instant_answers"] count] > 0) {
            // show instant answers
            [_hud hide:YES];
            
            // update right button on navigation bar
            self.navigationItem.rightBarButtonItem = nil;
            UIBarButtonItem *submitButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"Submit", @"Maguro", @"Submit") style:UIBarButtonItemStyleDone target:self action:@selector(clickSubmit:)];
            self.navigationItem.rightBarButtonItem = submitButton;
            
            // parser data >> instant answers
            _answers = [NSMutableArray new];
            for (NSDictionary *item in [document objectForKey:@"instant_answers"]) {
                if ([[item objectForKey:@"type"] isEqualToString:@"article"]) {
                    [_answers addObject:item];
                }
            }
            if (_answers.count > 0) {
                // refresh table view
                [_tableView reloadSections:[NSIndexSet indexSetWithIndex:SECTION_ANSWERS] withRowAnimation:UITableViewRowAnimationFade];
                [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:SECTION_ANSWERS] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
                
                return;
            }
        }
     
        // no instant answers, submit the message
        [self clickSubmit:nil];
    }];
}
// send the message to UserVoice
- (void)clickSubmit:(UIBarButtonItem *)sender
{
    // close keyboard
    [self.view endEditing:YES];
    
    // click submit by user
    if (sender && sender.enabled) {
        // disable submit button
        [sender setEnabled:NO];
        
        // show loading view
        _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        _hud.removeFromSuperViewOnHide = YES;
        _hud.dimBackground = YES;
        [_hud show:YES];
    }
    
    // update name and email when that are not empty.
    if (_textName.text.length > 0) { _delegate.config.name = _textName.text; }
    if (_textEmail.text.length > 0) { _delegate.config.email = _textEmail.text; }
    
    __weak UIBarButtonItem *button = sender;
    [_delegate requestForSubmitTicket:_textMessage.text errorHandler:^(NSError *error) {
        [_hud hide:YES];
        [button setEnabled:YES];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:NSLocalizedStringFromTable(@"problem with your network", @"Maguro", @"problem with your network")
                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    } completionHandler:^(NSDictionary *document) {
        [_hud hide:YES];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"Success!", @"Maguro", @"success!")
                                                        message:NSLocalizedStringFromTable(@"Your message has been sent.", @"Maguro", @"Your message has been sent.")
                                                       delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }];
}


#pragma mark - AlerView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // remove draft and close maguro
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:MAGURO_USER_DEFAULTS_MESSAGE];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.navigationController dismissModalViewControllerAnimated:YES];
    [_delegate closed];
}


#pragma mark - Actionsheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex - 1) {
        // save draft
        [[NSUserDefaults standardUserDefaults] setObject:_textMessage.text forKey:MAGURO_USER_DEFAULTS_MESSAGE];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self.navigationController dismissModalViewControllerAnimated:YES];
        [_delegate closed];
    }
    else if (buttonIndex == 0) {
        // don't save
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:MAGURO_USER_DEFAULTS_MESSAGE];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self.navigationController dismissModalViewControllerAnimated:YES];
        [_delegate closed];
    }
}


@end
