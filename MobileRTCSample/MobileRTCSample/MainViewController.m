//
//  ViewController.m
//  MobileRTCSample
//
//  Created by Robust Hu on 16/5/18.
//  Copyright © 2016年 Zoom Video Communications, Inc. All rights reserved.
//

#import "MainViewController.h"
#import "IntroViewController.h"
#import "InviteViewController.h"
#import "SplashViewController.h"
#import "SettingsViewController.h"
#import <MobileRTC/MobileRTC.h>
//#import "MBProgressHUD.h"

#define RGBCOLOR(r, g, b)   [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0]

#define BUTTON_FONT [UIFont fontWithName:@"HelveticaNeue-Bold" size:18.0]

#define kSDKUserID      @""
#define kSDKUserName    @""
#define kSDKUserToken @""
#define kSDKMeetNumber  @""
#define kZAK @""
//the following parameters are optional, just for login user
#define kParticipantID  @""
#define kWebinarToken   @""

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@interface MainViewController ()<UIAlertViewDelegate, UIActionSheetDelegate, MobileRTCMeetingServiceDelegate,MobileRTCMeetingShareActionItemDelegate>

@property (retain, nonatomic) UIButton *meetButton;
@property (retain, nonatomic) UIButton *joinButton;

@property (retain, nonatomic) IntroViewController  *introVC;
@property (retain, nonatomic) SplashViewController *splashVC;

@property (retain, nonatomic) UIButton *shareButton;
@property (retain, nonatomic) UIButton *expandButton;
@property (retain, nonatomic) UIButton *settingButton;

@property (assign, nonatomic) BOOL isSharing;
@property (assign, nonatomic) NSTimer  *clockTimer;

@property (copy, nonatomic) RTCJoinMeetingActionBlock  joinMeetingBlock;

@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    self.meetButton = nil;
    self.joinButton = nil;
    
    [[MobileRTC sharedRTC] getMeetingService].customizedUImeetingDelegate = nil;
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self.view addSubview:self.meetButton];
    [self.view addSubview:self.joinButton];
    
    [self showIntroView];
    [self showSplashView];
    
    [self.view addSubview:self.expandButton];
    self.expandButton.hidden = YES;
	
    [self.view addSubview:self.shareButton];
    self.shareButton.hidden = YES;
    
    [self.view addSubview:self.settingButton];
//    self.settingButton.hidden = YES;
    
//    //For Enable/Disable Copy URL
//    [MobileRTCInviteHelper sharedInstance].disableCopyURL = YES;
    
//    //For Enable/Disable Invite by Message
//    [MobileRTCInviteHelper sharedInstance].disableInviteSMS = YES;
    
//    MBProgressHUD* hud = [[MBProgressHUD alloc] initWithView:self.view];
//    [self.view addSubview:hud];
//    hud.labelText =@"Initializing...";
//    hud.square = YES;
//    [hud showAnimated:YES whileExecutingBlock:^{
//        sleep(2);
//    } completionBlock:^{
//        [hud removeFromSuperview];
//    }];

}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //for bug that there exist 20 pixels in the bottom while leaving meeting quickly
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
}

- (void)viewDidLayoutSubviews
{
    CGRect bounds = self.view.bounds;
    
#define padding 20
#define button1 50
#define button2 30

    CGFloat btnWidth = MIN(floorf((bounds.size.width - 3 * padding)/2), 160);
    CGFloat btnHeight = 46;
    
    CGFloat safeAreaTop = 0.0f;
    CGFloat safeAreaBottom = 0.0f;
    if(fabs(bounds.size.height - 812.0f) < 0.01f) {
        safeAreaTop = 44.0f;
        safeAreaBottom = 34.0f;
    }

    _meetButton.frame = CGRectMake(bounds.size.width/2-btnWidth-padding/2, bounds.size.height-1.5*padding -btnHeight - safeAreaBottom, btnWidth, btnHeight);
    _joinButton.frame = CGRectMake(bounds.size.width/2+padding/2, bounds.size.height-1.5*padding-btnHeight - safeAreaBottom, btnWidth, btnHeight);
    
    _expandButton.frame = CGRectMake(bounds.size.width-button1-padding, bounds.size.height-button1 -padding - safeAreaBottom, button1, button1);
    
    _settingButton.frame = CGRectMake(bounds.size.width-button2-padding, 1.5*padding + safeAreaTop, button2, button2);
}

#pragma mark - Sub Views

- (UIButton*)meetButton
{
    if (!_meetButton)
    {
        _meetButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_meetButton setTitle:NSLocalizedString(@"Meet Now", @"") forState:UIControlStateNormal];
        [_meetButton setTitleColor:RGBCOLOR(45, 140, 255) forState:UIControlStateNormal];
        _meetButton.titleLabel.font = BUTTON_FONT;
        [_meetButton addTarget:self action:@selector(onMeetNow:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _meetButton;
}

- (UIButton*)joinButton
{
    if (!_joinButton)
    {
        _joinButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_joinButton setTitle:NSLocalizedString(@"Join a Meeting", @"") forState:UIControlStateNormal];
        [_joinButton setTitleColor:RGBCOLOR(45, 140, 255) forState:UIControlStateNormal];
        _joinButton.titleLabel.font = BUTTON_FONT;
        [_joinButton addTarget:self action:@selector(onJoinaMeeting:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _joinButton;
}

- (void)showIntroView
{
    IntroViewController *vc = [IntroViewController new];
    self.introVC = vc;
    
    [self addChildViewController:self.introVC];
    [self.view insertSubview:self.introVC.view atIndex:0];
    [self.introVC didMoveToParentViewController:self];
    
    self.introVC.view.frame = self.view.bounds;
}

- (void)showSplashView
{
    SplashViewController *vc = [SplashViewController new];
    self.splashVC = vc;
    
    [self addChildViewController:self.splashVC];
    [self.view insertSubview:self.splashVC.view atIndex:0];
    [self.splashVC didMoveToParentViewController:self];
    
    self.splashVC.view.frame = self.view.bounds;
}

- (UIButton*)shareButton
{
    if (!_shareButton)
    {
        _shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _shareButton.frame = CGRectMake(20, 30, button2, button2);
        [_shareButton setImage:[UIImage imageNamed:@"icon_resume"] forState:UIControlStateNormal];
        [_shareButton addTarget:self action:@selector(onShareBtn:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _shareButton;
}

- (UIButton*)expandButton
{
    if (!_expandButton)
    {
        _expandButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _expandButton.frame = CGRectMake(0, 0, button1, button1);
        [_expandButton setImage:[UIImage imageNamed:@"icon_share_app"] forState:UIControlStateNormal];
        [_expandButton addTarget:self action:@selector(onExpand:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _expandButton;
}


- (UIButton*)settingButton
{
    if (!_settingButton)
    {
        _settingButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _settingButton.frame = CGRectMake(0, 0, button2, button2);
        [_settingButton setImage:[UIImage imageNamed:@"icon_setting"] forState:UIControlStateNormal];
        [_settingButton addTarget:self action:@selector(onSettings:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _settingButton;
}

- (void)onMeetNow:(id)sender
{
    MobileRTCMeetingService *ms = [[MobileRTC sharedRTC] getMeetingService];
    if (!ms)
    {
        return;
    }

    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Select Meeting Type", @"")
                                                                                 message:nil
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        
        if ([[[MobileRTC sharedRTC] getMeetingSettings] enableCustomMeeting])
        {
            [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Custom Meeting", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                MobileRTCMeetingService *ms = [[MobileRTC sharedRTC] getMeetingService];
                if (ms)
                {
                    ms.customizedUImeetingDelegate = self;
                }
                [self startMeeting:NO];
            }]];
        }
        else
        {
            [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"App Share Meeting", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [self startMeeting:YES];
            }]];
            [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Zoom Meeting", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [self startMeeting:NO];
            }]];
        }
        
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        }]];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
    else
    {
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Select Meeting Type", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"") destructiveButtonTitle:nil otherButtonTitles:nil];
        if ([[[MobileRTC sharedRTC] getMeetingSettings] enableCustomMeeting])
        {
            [sheet addButtonWithTitle:NSLocalizedString(@"Custom Meeting", @"")];
        }
        else
        {
            [sheet addButtonWithTitle:NSLocalizedString(@"App Share Meeting", @"")];
            [sheet addButtonWithTitle:NSLocalizedString(@"Zoom Meeting", @"")];
        }
        
        [sheet showInView:self.view];
    }
}

- (void)onJoinaMeeting:(id)sender
{
    MobileRTCMeetingService *ms = [[MobileRTC sharedRTC] getMeetingService];
    if (!ms)
    {
        return;
    }
    //optional for custom-ui meeting
    ms.customizedUImeetingDelegate = self;
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"Please input the meeting number", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"") otherButtonTitles:NSLocalizedString(@"OK", @""), nil];
    
    alert.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
    [alert textFieldAtIndex:0].placeholder = @"#########";
    [alert textFieldAtIndex:0].keyboardType = UIKeyboardTypeNumberPad;
    
    [alert show];
    [alert release];
}

- (void)onLeave:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^(void){
        
        MobileRTCMeetingService *ms = [[MobileRTC sharedRTC] getMeetingService];
        if (ms)
        {
            [ms leaveMeetingWithCmd:LeaveMeetingCmd_Leave];
        }
    }];
}

- (void)onShareBtn:(id)sender
{
    _isSharing = !_isSharing;
    
    UIView *shareView = _isSharing ? self.introVC.view : self.splashVC.view;
    MobileRTCMeetingService *ms = [[MobileRTC sharedRTC] getMeetingService];
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"11") && _isSharing)
    {
        [ms appShareWithReplayKit];
    }
    else
    {
        [ms appShareWithView:shareView];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIImage *image = [UIImage imageNamed:_isSharing?@"icon_pause":@"icon_resume"];
        [self.shareButton setImage:image forState:UIControlStateNormal];
    });
}

- (void)onExpand:(id)sender
{
    MobileRTCMeetingService *ms = [[MobileRTC sharedRTC] getMeetingService];
    if (ms)
    {
        [ms showMobileRTCMeeting:^(void){
            [ms stopAppShare];
        }];
    }
}

- (void)onSettings:(id)sender
{
    MobileRTCMeetingSettings *settings = [[MobileRTC sharedRTC] getMeetingSettings];
    if (!settings)
        return;
    
    SettingsViewController *vc = [[SettingsViewController alloc] initWithStyle:UITableViewStyleGrouped];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    nav.modalPresentationStyle = UIModalPresentationFormSheet;
    
    [self presentViewController:nav animated:YES completion:NULL];
    
    [nav release];
    [vc release];
}

#pragma mark - Start/Join Meeting

- (void)startMeeting:(BOOL)appShare
{
    MobileRTCMeetingService *ms = [[MobileRTC sharedRTC] getMeetingService];
    if (ms)
    {
#if 0
        //customize meeting title
        [ms customizeMeetingTitle:@"Sample Meeting Title"];
#endif
        
        ms.delegate = self;
        //If App share meeting is expected, please set kMeetingParam_IsAppShare to YES, or just remove this parameter.
        
//        NSDictionary *paramDict = nil;
//        MobileRTCUserType userType = [[[MobileRTC sharedRTC] getAuthService] getUserType];
//        //For API User, the user type should be MobileRTCUserType_APIUser.
//        if (MobileRTCUserType_APIUser == userType)
//        {
//            paramDict = @{kMeetingParam_UserID:kSDKUserID,
//                          kMeetingParam_UserToken:kSDKUserToken,
//                          kMeetingParam_UserType:@(userType),
//                          kMeetingParam_Username:kSDKUserName,
//                          kMeetingParam_MeetingNumber:kSDKMeetNumber,
//                          kMeetingParam_IsAppShare:@(appShare),
//                          //kMeetingParam_ParticipantID:kParticipantID,
//                          //kMeetingParam_NoAudio:@(YES),
//                          //kMeetingParam_NoVideo:@(YES),
//                          };
//        }
//        else
//        {
//            //For Zoom/SSO User, can start instant meeting.
//            paramDict = @{kMeetingParam_UserType:@(userType),
//                          kMeetingParam_IsAppShare:@(appShare),
//                          //kMeetingParam_ParticipantID:kParticipantID,
//                          //kMeetingParam_NoAudio:@(YES),
//                          //kMeetingParam_NoVideo:@(YES),
//                          };
//        }
//
//        MobileRTCMeetError ret = [ms startMeetingWithDictionary:paramDict];
//
//        NSLog(@"onMeetNow ret:%d", ret);
    }
    
#if 1
    //Sample for Start Param interface
    MobileRTCMeetingStartParam * param = nil;
    
    if ([[[MobileRTC sharedRTC] getAuthService] isLoggedIn])
    {
        MobileRTCMeetingStartParam4LoginlUser * user = [[[MobileRTCMeetingStartParam4LoginlUser alloc]init]autorelease];
        param = user;
        param.meetingNumber = kSDKMeetNumber;
    }
    else
    {
        MobileRTCMeetingStartParam4WithoutLoginUser * user = [[[MobileRTCMeetingStartParam4WithoutLoginUser alloc]init] autorelease];
        user.userType = MobileRTCUserType_APIUser;
        user.meetingNumber = kSDKMeetNumber;
        user.userName = kSDKUserName;
        user.userToken = kSDKUserToken;
        user.userID = kSDKUserID;
        user.isAppShare = appShare;
        user.zak = kZAK;
        param = user;
    }
    MobileRTCMeetError ret = [ms startMeetingWithStartParam:param];
    return;
#endif
}

- (void)joinMeeting:(NSString*)meetingNo withPassword:(NSString*)pwd
{
    if (![meetingNo length])
        return;

    MobileRTCMeetingService *ms = [[MobileRTC sharedRTC] getMeetingService];
    if (ms)
    {
#if 0
        //customize meeting title
        [ms customizeMeetingTitle:@"Sample Meeting Title"];
#endif
        ms.delegate = self;
        
        //For Join a meeting with password
        NSDictionary *paramDict = @{
                                    kMeetingParam_Username:kSDKUserName,
                                    kMeetingParam_MeetingNumber:meetingNo,
                                    kMeetingParam_MeetingPassword:pwd,
                                    //kMeetingParam_ParticipantID:kParticipantID,
                                    //kMeetingParam_WebinarToken:kWebinarToken,
                                    //kMeetingParam_NoAudio:@(YES),
                                    //kMeetingParam_NoVideo:@(YES),
                                    };
//            //For Join a meeting
//            NSDictionary *paramDict = @{
//                                        kMeetingParam_Username:kSDKUserName,
//                                        kMeetingParam_MeetingNumber:meetingNo,
//                                        kMeetingParam_MeetingPassword:pwd,
//                                        };
        
        MobileRTCMeetError ret = [ms joinMeetingWithDictionary:paramDict];
        
        NSLog(@"onJoinaMeeting ret:%d", ret);
    }
}

#pragma mark - AlertView/ActionSheet Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{    
    if (alertView.tag == 10022 && self.joinMeetingBlock)
    {
        NSString *name = [alertView textFieldAtIndex:0].text;
        NSString *pwd = [alertView textFieldAtIndex:1].text;
        BOOL cancel = (buttonIndex == alertView.cancelButtonIndex);
        
        self.joinMeetingBlock(name, pwd, cancel);
        self.joinMeetingBlock = nil;
        return;
    }
    
    if (buttonIndex != alertView.cancelButtonIndex)
    {
        NSString *meetingNo = [alertView textFieldAtIndex:0].text;
        NSString *meetingPwd = [alertView textFieldAtIndex:1].text;
        
        [self joinMeeting:meetingNo withPassword:meetingPwd];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:NSLocalizedString(@"App Share Meeting", @"")])
    {
        [self startMeeting:YES];
    }
    else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:NSLocalizedString(@"Zoom Meeting", @"")])
    {
        [self startMeeting:NO];
    }
    else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:NSLocalizedString(@"Custom Meeting", @"")])
    {
        [self startMeeting:NO];
    }
}

#pragma mark - Meeting Service Delegate

- (void)onMeetingError:(MobileRTCMeetError)error message:(NSString*)message
{
    NSLog(@"onMeetingError:%zd, message:%@", error, message);
}

- (void)onMeetingStateChange:(MobileRTCMeetingState)state
{
    NSLog(@"onMeetingStateChange:%d", state);
    
    MobileRTCMeetingService *ms = [[MobileRTC sharedRTC] getMeetingService];
    BOOL inAppShare = [ms isDirectAppShareMeeting] && (state == MobileRTCMeetingState_InMeeting);
    self.expandButton.hidden = !inAppShare;
    self.shareButton.hidden = !inAppShare;
    self.meetButton.hidden = inAppShare;
    self.joinButton.hidden = inAppShare;
    
    if (state != MobileRTCMeetingState_InMeeting)
    {
        self.isSharing = NO;
    }
    
#if 1
    if (state == MobileRTCMeetingState_InMeeting)
    {
        //For customizing the content of Invite by SMS
        NSString *meetingNumber = [[MobileRTCInviteHelper sharedInstance] ongoingMeetingNumber];
        NSString *smsMessage = [NSString stringWithFormat:NSLocalizedString(@"Please join meeting with ID: %@", @""), meetingNumber];
        [[MobileRTCInviteHelper sharedInstance] setInviteSMS:smsMessage];
        
        //For customizing the content of Copy URL
        NSString *joinURL = [[MobileRTCInviteHelper sharedInstance] joinMeetingURL];
        NSString *copyURLMsg = [NSString stringWithFormat:NSLocalizedString(@"Meeting URL: %@", @""), joinURL];
        [[MobileRTCInviteHelper sharedInstance] setInviteCopyURL:copyURLMsg];
    }
    
    else if(state == MobileRTCMeetingState_WebinarPromote)
    {
        NSLog(@"onMeetingStateChange MobileRTCMeetingState_WebinarPromote");
    }
    
    else if(state == MobileRTCMeetingState_WebinarDePromote)
    {
        NSLog(@"onMeetingStateChange MobileRTCMeetingState_WebinarDePromote");
    }
#endif
    
#if 0
    //For adding customize view above the meeting view
    if (state == MobileRTCMeetingState_InMeeting)
    {
        MobileRTCMeetingService *ms = [[MobileRTC sharedRTC] getMeetingService];
        UIView *v = [ms meetingView];
        
        CGFloat offsetY = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 220 : 180;
        UIView *sv = [[UIView alloc] initWithFrame:CGRectMake(0, offsetY, v.frame.size.width, 50)];
        sv.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
        sv.backgroundColor = [UIColor redColor];
        [v addSubview:sv];
        [sv release];
    }
    
#endif
}

- (void)onMeetingReady
{
    MobileRTCMeetingService *ms = [[MobileRTC sharedRTC] getMeetingService];
    if ([ms isDirectAppShareMeeting])
    {
        if ([ms isStartingShare] || [ms isViewingShare])
        {
            NSLog(@"There exist an ongoing share");
            [ms showMobileRTCMeeting:^(void){
                [ms stopAppShare];
            }];
            return;
        }
        
        BOOL ret = [ms startAppShare];
        NSLog(@"Start App Share... ret:%zd", ret);
    }
    
//    [self startClockTimer];
}

- (void)onAppShareSplash
{
    MobileRTCMeetingService *ms = [[MobileRTC sharedRTC] getMeetingService];
    if (ms)
    {
        [ms appShareWithView:self.splashVC.view];
        
        [self.shareButton setImage:[UIImage imageNamed:@"icon_resume"] forState:UIControlStateNormal];
        self.isSharing = NO;
    }
}

- (BOOL)onClickedShareButton:(UIViewController*)parentVC addShareActionItem:(NSMutableArray *)array
{
    MobileRTCMeetingService *ms = [[MobileRTC sharedRTC] getMeetingService];
    if (ms && [ms isDirectAppShareMeeting])
    {
        if ([ms isStartingShare] || [ms isViewingShare])
        {
            NSLog(@"There exist an ongoing share");
            return YES;
        }
        
        [ms hideMobileRTCMeeting:^(void){
            [ms startAppShare];
        }];
        
        return YES;
    }
    
    return NO;
    
#if 0
    //Sample For Add custom share action item
    MobileRTCMeetingShareActionItem * item = [[MobileRTCMeetingShareActionItem itemWithTitle:@"Demo share" Tag:1] autorelease];
    
    item.delegate = self;
    
    [array addObject:item];
    
    return NO;
#endif
}

//Sample for add customized share item
- (void)onShareItemClicked:(NSUInteger)tag completion:(BOOL (^)(UIViewController* shareView))completion
{
    SplashViewController *splashctrl = [[SplashViewController new] autorelease];
    
    if (completion && splashctrl)
    {
        BOOL ret = completion(splashctrl);
        NSLog(@"%zd",ret);
    }
}

- (void)onOngoingShareStopped
{
    NSLog(@"There does not exist ongoing share");
//    MobileRTCMeetingService *ms = [[MobileRTC sharedRTC] getMeetingService];
//    if (ms)
//    {
//        [ms startAppShare];
//    }
}

#if 0
- (void)onJBHWaitingWithCmd:(JBHCmd)cmd
{
    switch (cmd) {
        case JBHCmd_Show:
        {
            UIViewController *vc = [UIViewController new];
            
            NSString *meetingNumber = [MobileRTCInviteHelper sharedInstance].ongoingMeetingNumber;
            vc.title = meetingNumber;
            
            UIBarButtonItem *leaveItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Leave", @"") style:UIBarButtonItemStylePlain target:self action:@selector(onLeave:)];
            [vc.navigationItem setRightBarButtonItem:leaveItem];
            
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
            nav.modalPresentationStyle = UIModalPresentationFormSheet;
            [self presentViewController:nav animated:YES completion:NULL];
        }
            break;
            
        case JBHCmd_Hide:
        default:
        {
            [self dismissViewControllerAnimated:YES completion:NULL];
        }
            break;
    }
}
#endif

#if 0
- (BOOL)onClickedInviteButton:(UIViewController*)parentVC addInviteActionItem:(NSMutableArray *)inListArray
{
    //Sample For Add custom invite action item
    MobileRTCMeetingInviteActionItem * item = [[MobileRTCMeetingInviteActionItem itemWithTitle:@"test" Action:^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"add invite item test", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"Cancel", @"") otherButtonTitles:NSLocalizedString(@"OK", @""), nil];
        [alert show];
        [alert release];
    }] autorelease];
    
    [inListArray addObject:item];
    return NO;
    
    //Sample For show user customized InviteViewController
//    InviteViewController *inviteVC = [[InviteViewController alloc] init];
//    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:inviteVC];
//    nav.modalPresentationStyle = UIModalPresentationFormSheet;
//    
//    [parentVC presentViewController:nav animated:YES completion:NULL];
//    return YES;
}
#endif

#if 0
- (BOOL)onClickedParticipantsButton:(UIViewController*)parentVC
{
    InviteViewController *inviteVC = [[InviteViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:inviteVC];
    nav.modalPresentationStyle = UIModalPresentationFormSheet;

    [parentVC presentViewController:nav animated:YES completion:NULL];

    return YES;
}
#endif

#if 0
- (void)onClickedDialOut:(UIViewController*)parentVC isCallMe:(BOOL)me
{
    MobileRTCMeetingService *ms = [[MobileRTC sharedRTC] getMeetingService];
    if (!ms)
        return;
    
    if ([ms isDialOutInProgress])
    {
        NSLog(@"There already exists an ongoing call");
        return;
    }
    
    NSString *callName = me ? nil : @"Dialer";
    BOOL ret = [ms dialOut:@"+866004" isCallMe:me withName:callName];
    NSLog(@"Dial out result: %zd", ret);
}

- (void)onDialOutStatusChanged:(DialOutStatus)status
{
    NSLog(@"onDialOutStatusChanged: %zd", status);
}
#endif

#pragma mark - In meeting users' state updated

#if 0
- (void)onInMeetingUserUpdated
{
    MobileRTCMeetingService *ms = [[MobileRTC sharedRTC] getMeetingService];
    NSArray *users = [ms getInMeetingUserList];
    NSLog(@"In Meeting users:%@", users);
}

- (void)onInMeetingChat:(NSString *)messageID
{
    MobileRTCMeetingService *ms = [[MobileRTC sharedRTC] getMeetingService];
    NSLog(@"In Meeting Chat:%@ content:%@", messageID, [ms meetingChatByID:messageID]);
}
#endif

#pragma mark - Handle Session Key

#if 0
- (void)onWaitExternalSessionKey:(NSData*)key
{
    NSLog(@"session key: %@", key);
    Byte byte[] = {0x90,0xd7,0x19,0x28,0x7c,0xa5,0x4c,0xfd,0xca,0x89,0x5a,0x31,0x3f,0xf1,0xbc,0x8f,0x9b,0x6c,0x6b,0x4b,0x3e,0xcd,0xfc,0xa8,0xdf,0xda,0x0e,0xe7,0x00,0x4f,0x32,0xc5};
    NSData *keyData = [[NSData alloc] initWithBytes:byte length:32];
    NSLog(@"data: %@", keyData);
    
    MobileRTCE2EMeetingKey *mkChat = [[[MobileRTCE2EMeetingKey alloc] init] autorelease];
    mkChat.type = MobileRTCComponentType_Chat;
    mkChat.meetingKey = keyData;
    mkChat.meetingIv = nil;
    MobileRTCE2EMeetingKey *mkAudio = [[[MobileRTCE2EMeetingKey alloc] init] autorelease];
    mkAudio.type = MobileRTCComponentType_AUDIO;
    mkAudio.meetingKey = keyData;
    mkAudio.meetingIv = nil;
    MobileRTCE2EMeetingKey *mkVideo = [[[MobileRTCE2EMeetingKey alloc] init] autorelease];
    mkVideo.type = MobileRTCComponentType_VIDEO;
    mkVideo.meetingKey = keyData;
    mkVideo.meetingIv = nil;
    MobileRTCE2EMeetingKey *mkShare = [[[MobileRTCE2EMeetingKey alloc] init] autorelease];
    mkShare.type = MobileRTCComponentType_AS;
    mkShare.meetingKey = keyData;
    mkShare.meetingIv = nil;
    MobileRTCE2EMeetingKey *mkFile = [[[MobileRTCE2EMeetingKey alloc] init] autorelease];
    mkFile.type = MobileRTCComponentType_FT;
    mkFile.meetingKey = keyData;
    mkFile.meetingIv = nil;
    
    MobileRTCMeetingService *ms = [[MobileRTC sharedRTC] getMeetingService];
    BOOL ret = [ms handleE2EMeetingKey:@[mkChat, mkAudio, mkVideo, mkShare, mkFile] withLeaveMeeting:NO];
    NSLog(@"handleE2EMeetingKey ret:%zd", ret);
}
#endif

#pragma mark - H.323/SIP call state changed

#if 0
- (void)onSendPairingCodeStateChanged:(MobileRTCH323ParingStatus)state MeetingNumber:(unsigned long long)meetingNumber
{
    NSLog(@"onSendPairingCodeStateChanged %zd", state);
}

- (void)onCallRoomDeviceStateChanged:(H323CallOutStatus)state
{
    NSLog(@"onCallRoomDeviceStateChanged %zd", state);
}
#endif

#pragma mark - Timer

- (void)startClockTimer
{
    NSTimeInterval interval = 1.0;
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(handleClockTimer:) userInfo:nil repeats:YES];
    self.clockTimer = timer;
}

- (void)stopClockTimer
{
    if ([self.clockTimer isValid])
    {
        [self.clockTimer invalidate];
        self.clockTimer = nil;
    }
}

- (void)handleClockTimer:(NSTimer *)theTimer
{
    MobileRTCMeetingService *ms = [[MobileRTC sharedRTC] getMeetingService];
    MobileRTCNetworkQuality sendQuality = [ms queryNetworkQuality:MobileRTCComponentType_VIDEO withDataFlow:YES];
    MobileRTCNetworkQuality receiveQuality = [ms queryNetworkQuality:MobileRTCComponentType_VIDEO withDataFlow:NO];
    NSLog(@"Query Network Data [sending: %zd, receiving: %zd]...", sendQuality, receiveQuality);
}

#pragma mark - ZAK expired
#if 0
- (void)onZoomIdentityExpired
{
    NSLog(@"onZoomIdentityExpired");
}

#pragma mark - Closed Caption
- (void)onClosedCaptionReceived:(NSString *)message
{
    NSLog(@"onClosedCaptionReceived : %@",message);
}
#endif

#if 0
#pragma mark - Webinar Q&A
- (void)onSinkQAConnectStarted
{
    MobileRTCMeetingService *ms = [[MobileRTC sharedRTC] getMeetingService];
    NSLog(@"onSinkQAConnectStarted QA Enable:%d...", [ms isQAEnabled]);
}

- (void)onSinkQAConnected:(BOOL)connected
{
    MobileRTCMeetingService *ms = [[MobileRTC sharedRTC] getMeetingService];
    NSLog(@"onSinkQAConnected %d, QA Enable:%d...", connected, [ms isQAEnabled]);
}

- (void)onSinkQAOpenQuestionChanged:(NSInteger)count
{
    NSLog(@"onSinkQAOpenQuestionChanged %zd...", count);
}
#endif

- (void)onJoinMeetingConfirmed
{
    NSString *meetingNo = [[MobileRTCInviteHelper sharedInstance] ongoingMeetingNumber];
    NSLog(@"onJoinMeetingConfirmed MeetingNo: %@", meetingNo);
}

- (void)onJoinMeetingInfo:(MobileRTCJoinMeetingInfo)info
               completion:(void (^)(NSString *displayName, NSString *password, BOOL cancel))completion
{
    if (completion)
        self.joinMeetingBlock = completion;
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"Please input display name and password", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"") otherButtonTitles:NSLocalizedString(@"OK", @""), nil];
    
    alert.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
    alert.tag = 10022;
    [alert textFieldAtIndex:0].placeholder = @"#########";
    [alert textFieldAtIndex:0].keyboardType = UIKeyboardTypeNumberPad;
    
    [alert show];
    [alert release];
}

#if 0
- (void)onMeetingEndedReason:(MobileRTCMeetingEndReason)reason
{
    NSLog(@"onMeetingEndedReason %d", reason);
}
#endif

- (void)onMicrophoneStatusError:(MobileRTCMicrophoneError)error
{
    NSLog(@"onMicrophoneStatusError %d", error);
}

@end
