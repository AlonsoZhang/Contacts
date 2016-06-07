#import "RZViewController.h"
#import "AppDelegate.h"
#import "AllListsViewController.h"
#import "DataModel.h"
#import "PXAlertView.h"

static NSString* const kRZTouchIDLoginSuccessSegueIdentifier   = @"loginSuccess";
//static NSString* const kRZTouchIDDefaultPassword               = @"123";
NSString* const kRZTouchIdLoggedInUser                         = @"loggedInUser";

@interface RZViewController ()

// Outlets
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (weak, nonatomic) IBOutlet UIButton *touchIDButton;
@property (weak, nonatomic) IBOutlet UILabel *errorMessage;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *submitButtonRightEdgeConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *touchIdWidthConstraint; 
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *passwordRightEdgeConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *passwordLeftEdgeConstraint;

// State
@property (assign, nonatomic) BOOL touchIDPasswordExists;
@property (assign, nonatomic) BOOL touchIDHasBeenAutoPresented;

// Animation
@property (assign, nonatomic) CGFloat submitButtonRightEdgeConstraintInitialConstant;
@property (assign, nonatomic) CGFloat touchIdWidthConstraintInitialConstant;
@property (assign, nonatomic) BOOL isAnimating;

@end

@implementation RZViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.isAnimating = NO;
    self.errorMessage.alpha = 0.0f;
    self.touchIDPasswordExists = NO;
    self.touchIDHasBeenAutoPresented = NO;
    self.submitButtonRightEdgeConstraintInitialConstant = self.submitButtonRightEdgeConstraint.constant;
    self.touchIdWidthConstraintInitialConstant = self.touchIdWidthConstraint.constant;
    [self showTouchIdReferences:[RZTouchID touchIDAvailable]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSArray *doc = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [doc objectAtIndex:0 ];
    NSDictionary *dic = [ NSDictionary dictionaryWithContentsOfFile:[docPath stringByAppendingPathComponent:@"setting.plist"]];
    NSString *psw = [dic objectForKey:@"admin"];
    if ([psw isEqualToString:@"123"]||[psw isEqualToString:@""]|| psw == nil) {
        self.passwordTextField.placeholder = @"初始密碼123";
    }else{
        self.passwordTextField.placeholder = @"請輸入設定的密碼";
    }
}

- (void)viewDidAppear:(BOOL)animated{
    //[self.passwordTextField becomeFirstResponder];
    //NSLog(@"RZTouchID touchIDAvailable: %@" ,[RZTouchID touchIDAvailable]?@"YES":@"NO");
    //NSLog(@"touchIDHasBeenAutoPresented: %@" ,self.touchIDHasBeenAutoPresented?@"YES":@"NO");
    if ( [RZTouchID touchIDAvailable] && !self.touchIDHasBeenAutoPresented ) {
        [self presentTouchID];
    }
    else if ( ![RZTouchID touchIDAvailable] ) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            
            // 初始化一个一个UIAlertController
            // 参数preferredStyle:是IAlertController的样式
            // UIAlertControllerStyleAlert 创建出来相当于UIAlertView
            // UIAlertControllerStyleActionSheet 创建出来相当于 UIActionSheet
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Touch ID" message:@"該設備不支持 Touch ID" preferredStyle:(UIAlertControllerStyleAlert)];
            
            // 创建按钮
//            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction *action) {
//                NSLog(@"没有 touch ID");
//            }];
            // 创建按钮
            // 注意取消按钮只能添加一个
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"OK" style:(UIAlertActionStyleCancel) handler:^(UIAlertAction *action) {
                // 点击按钮后的方法直接在这里面写
                NSLog(@"没有 touch ID");
            }];
            
            //    // 创建警告按钮
            //    UIAlertAction *structlAction = [UIAlertAction actionWithTitle:@"警告" style:(UIAlertActionStyleDestructive) handler:^(UIAlertAction *action) {
            //        NSLog(@"注意学习");
            //    }];
            //
            // 添加按钮 将按钮添加到UIAlertController对象上
            //[alertController addAction:okAction];
            [alertController addAction:cancelAction];
            //[alertController addAction:structlAction];
            
            // 只有在alert情况下才可以添加文本框
//            [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
//                textField.placeholder = @"用户名";
//                textField.secureTextEntry = YES;
//            }];
            
            //    // 取出文本
            //    UITextField *text = alertController.textFields.firstObject;
            //    UIAlertAction *action = alertController.actions.firstObject;
            
            // 将UIAlertController模态出来 相当于UIAlertView show 的方法
            [self presentViewController:alertController animated:YES completion:nil];
            
            //UIAlertView *touchIdDemoAlert = [[UIAlertView alloc] initWithTitle:@"Touch ID" message:@"This device doesn't support touch ID - the demo will be a little... boring." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            //[touchIdDemoAlert rz_showWithCompletionBlock:nil];
        });
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - Private methods

- (void)showTouchIdReferences:(BOOL)show
{
    if ( show ) {
        self.submitButtonRightEdgeConstraint.constant = self.submitButtonRightEdgeConstraintInitialConstant;
        self.touchIdWidthConstraint.constant = self.touchIdWidthConstraintInitialConstant;
        self.touchIDButton.hidden = NO;
    }
    else {
//        self.submitButtonRightEdgeConstraint.constant = 0.0f;
//        self.touchIdWidthConstraint.constant = 0.0f;
        self.touchIDButton.hidden = YES;
    }
}

/**
 *  Create your own authentication mechanism e.g. webservice call with the userID and password
 *
 *  @return return YES if successful, otherwise NO.
 */
- (BOOL)authenticationSuccessful
{
//    NSMutableDictionary *mainplist = [[NSMutableDictionary alloc]init];
//    NSString *mainplistpath = [[NSString alloc]init];
//    mainplistpath = [[NSBundle mainBundle]pathForResource:@"main" ofType:@"plist"];
//    mainplist=[[NSMutableDictionary alloc]initWithContentsOfFile:mainplistpath];
//    NSString * kRZTouchIDDefaultPassword = [mainplist objectForKey:@"admin"];
//    NSLog(@"psw:%@,%@",mainplistpath,kRZTouchIDDefaultPassword);
    
    NSArray *doc = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * kRZTouchIDDefaultPassword;
    NSString *docPath = [ doc objectAtIndex:0 ];
    if( [[NSFileManager defaultManager] fileExistsAtPath:[docPath stringByAppendingPathComponent:@"setting.plist"]]==NO ) {
        NSMutableDictionary *newDic = [[NSMutableDictionary alloc]init];
        NSString *psw = @"123";
        [newDic setValue:psw forKey:@"admin"];
        NSString *ip =@"10.42.53.99";
        [newDic setValue:ip forKey:@"ip"];
        kRZTouchIDDefaultPassword = psw;
        [newDic writeToFile:[docPath stringByAppendingPathComponent:@"setting.plist"] atomically:YES];
        NSLog(@"first write");
    }else{
        NSDictionary *dic = [ NSDictionary dictionaryWithContentsOfFile:[docPath stringByAppendingPathComponent:@"setting.plist"]];
        NSString *psw = [dic objectForKey:@"admin"];
        kRZTouchIDDefaultPassword = psw;
        //NSLog(@"read admin");
    }
    return [self.passwordTextField.text isEqualToString:kRZTouchIDDefaultPassword];
}

- (IBAction)touchIdLaunchTapped:(id)sender
{
    [self.view endEditing:YES];
    [self presentTouchID];
}

- (IBAction)submitTapped:(id)sender
{
    if ( [self authenticationSuccessful] ) {
        [[NSUserDefaults standardUserDefaults] setObject:@"admin" forKey:kRZTouchIdLoggedInUser];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        if ( [RZTouchID touchIDAvailable] && !self.touchIDPasswordExists ) {
            __weak __typeof(self)wself = self;
//            UIAlertView *useTouchIDAlertView = [[UIAlertView alloc] initWithTitle:@"Touch ID" message:@"Would you like to enable touch ID to make it easier to login in the future?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
//            [useTouchIDAlertView rz_showWithCompletionBlock:^(NSInteger dismissalButtonIndex) {
//                if ( dismissalButtonIndex != useTouchIDAlertView.cancelButtonIndex ) {
//                    [wself savePasswordToKeychain:wself.passwordTextField.text withCompletion:^(NSString *password, NSError *error){
//                        if ( error == nil ) {
//                            wself.touchIDPasswordExists = YES;
//                        }
//                        else {
//                            wself.touchIDPasswordExists = NO;
//                        }
//                        [wself performSegueWithIdentifier:kRZTouchIDLoginSuccessSegueIdentifier sender:wself];
//                    }];
//                }
//                else {
//                    [wself removePasswordFromKeychain];
//                    wself.touchIDPasswordExists = NO;
//                    [wself performSegueWithIdentifier:kRZTouchIDLoginSuccessSegueIdentifier sender:wself];
//                }
//
//            }];
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Touch ID" message:@"為了更方便更安全登錄\n是否啟用Touch ID?" preferredStyle:(UIAlertControllerStyleAlert)];
            
             //创建按钮
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"是" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction *action) {
                NSLog(@"开启 touch ID");
                [wself savePasswordToKeychain:wself.passwordTextField.text withCompletion:^(NSString *password, NSError *error){
                    if ( error == nil ) {
                        wself.touchIDPasswordExists = YES;
                    }
                    else {
                        wself.touchIDPasswordExists = NO;
                    }
                    [wself performSegueWithIdentifier:kRZTouchIDLoginSuccessSegueIdentifier sender:wself];
                    }];
                }];
            // 创建按钮
            // 注意取消按钮只能添加一个
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"否" style:(UIAlertActionStyleCancel) handler:^(UIAlertAction *action) {
                // 点击按钮后的方法直接在这里面写
                [wself removePasswordFromKeychain];
                wself.touchIDPasswordExists = NO;
                [wself performSegueWithIdentifier:kRZTouchIDLoginSuccessSegueIdentifier sender:wself];
                [[AppDelegate sharedTouchIDInstance]deletePasswordWithIdentifier:@"admin" completion:nil];
                //wself.touchIDHasBeenAutoPresented = NO;
            }];
            
            //    // 创建警告按钮
            //    UIAlertAction *structlAction = [UIAlertAction actionWithTitle:@"警告" style:(UIAlertActionStyleDestructive) handler:^(UIAlertAction *action) {
            //        NSLog(@"注意学习");
            //    }];
            //
            // 添加按钮 将按钮添加到UIAlertController对象上
            [alertController addAction:okAction];
            [alertController addAction:cancelAction];
            //[alertController addAction:structlAction];
            
            // 只有在alert情况下才可以添加文本框
            //            [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            //                textField.placeholder = @"用户名";
            //                textField.secureTextEntry = YES;
            //            }];
            
            //    // 取出文本
            //    UITextField *text = alertController.textFields.firstObject;
            //    UIAlertAction *action = alertController.actions.firstObject;
            
            // 将UIAlertController模态出来 相当于UIAlertView show 的方法
            [self presentViewController:alertController animated:YES completion:nil];
        }
        else {
            [self performSegueWithIdentifier:kRZTouchIDLoginSuccessSegueIdentifier sender:self];
        }
    }
    else {
        [self showErrorAnimated:YES];
    }
}

- (void)showErrorAnimated:(BOOL)animated
{
    if ( animated && !self.isAnimating ) {
        self.isAnimating = YES;
        CGFloat leftEdgeInitial = self.passwordLeftEdgeConstraint.constant;
        CGFloat rightEdgeInitial = self.passwordRightEdgeConstraint.constant;
        CGFloat animationDuration = 0.1f;
        CGFloat damping = 0.65f;
        CGFloat springVelocity = 1.0f;
        self.passwordRightEdgeConstraint.constant = rightEdgeInitial - 10.0f;
        self.passwordLeftEdgeConstraint.constant = leftEdgeInitial + 10.0f;
        
        [UIView animateWithDuration:animationDuration delay:0.0f usingSpringWithDamping:damping initialSpringVelocity:springVelocity options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.errorMessage.alpha = 1.0f;
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            self.passwordRightEdgeConstraint.constant = rightEdgeInitial + 10.0f;
            self.passwordLeftEdgeConstraint.constant = leftEdgeInitial - 10.0f;
            [UIView animateWithDuration:animationDuration delay:0.0f usingSpringWithDamping:damping initialSpringVelocity:springVelocity options:UIViewAnimationOptionCurveEaseInOut animations:^{
                [self.view layoutIfNeeded];
            } completion:^(BOOL finished) {
                self.passwordRightEdgeConstraint.constant = rightEdgeInitial - 10.0f;
                self.passwordLeftEdgeConstraint.constant = leftEdgeInitial + 10.0f;
                [UIView animateWithDuration:animationDuration delay:0.0f usingSpringWithDamping:damping initialSpringVelocity:springVelocity options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    [self.view layoutIfNeeded];
                } completion:^(BOOL finished) {
                    self.passwordRightEdgeConstraint.constant = rightEdgeInitial ;
                    self.passwordLeftEdgeConstraint.constant = leftEdgeInitial ;
                    [UIView animateWithDuration:animationDuration delay:0.0f usingSpringWithDamping:damping initialSpringVelocity:springVelocity options:UIViewAnimationOptionCurveEaseInOut animations:^{
                        [self.view layoutIfNeeded];
                    } completion:^(BOOL finished) {
                        [UIView animateWithDuration:1.4f animations:^{
                            self.errorMessage.alpha = 0.0f;
                            self.isAnimating = NO;
                        }];
                    }];
                }];
            }];
        }];
    }
    else {
        self.errorMessage.alpha = 1.0f;
    }
}

#pragma mark - RZTouchID helpers
- (void)presentTouchID
{
    __weak __typeof(self)wself = self;
    [[AppDelegate sharedTouchIDInstance] retrievePasswordWithIdentifier:@"admin" withPrompt:@"Access your account" completion:^(NSString *password, NSError *error) {
        if ( password == nil || error != nil ) {
            if ( error.code != RZTouchIDErrorAuthenticationFailed ) {
                [wself showTouchIdReferences:NO];
                wself.touchIDPasswordExists = NO;
            }
            else {
                wself.touchIDPasswordExists = YES;
            }
        }
        else {
            wself.touchIDHasBeenAutoPresented = YES;
            wself.touchIDPasswordExists = YES;
            wself.passwordTextField.text = password;
            [wself submitTapped:wself];
        }
    }];
}

- (void)savePasswordToKeychain:(NSString *)password withCompletion:(RZTouchIDCompletion)completion
{
    [[AppDelegate sharedTouchIDInstance] addPassword:password withIdentifier:@"admin" completion:completion];
}

- (void)removePasswordFromKeychain
{
    [[AppDelegate sharedTouchIDInstance] deletePasswordWithIdentifier:@"admin" completion:nil];
}

#pragma mark - Segue methods

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ( [identifier isEqualToString:kRZTouchIDLoginSuccessSegueIdentifier] ) {
        return NO;
    }
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UINavigationController *navigationController = segue.destinationViewController;
    AllListsViewController *destinationVC = navigationController.viewControllers[0];
    destinationVC.touchIDLoginDisabled = !self.touchIDPasswordExists;
    //self.dataModel = [[DataModel alloc] init];
    destinationVC.dataModel = self.dataModel;
}

- (IBAction)unwindToThisViewController:(UIStoryboardSegue *)unwindSegue
{
    AllListsViewController *sourceVC = (AllListsViewController *)unwindSegue.sourceViewController;
    [self showTouchIdReferences:!sourceVC.touchIDLoginDisabled];
    self.touchIDPasswordExists = !sourceVC.touchIDLoginDisabled;
    
    self.passwordTextField.text = @"";
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kRZTouchIdLoggedInUser];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ( [textField isEqual:self.passwordTextField] ) {
        BOOL useTouchID = ([[AppDelegate sharedTouchIDInstance] touchIDAvailableForIdentifier:@"admin"] );
        [self showTouchIdReferences:useTouchID];
        if ( useTouchID ) {
            [self presentTouchID];
        }
    }
}

- (IBAction)setdefult:(id)sender {
    NSArray *doc = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [doc objectAtIndex:0];
    NSDictionary *dic = [ NSDictionary dictionaryWithContentsOfFile:[docPath stringByAppendingPathComponent:@"setting.plist"]];
    NSString *ip = [dic objectForKey:@"ip"];
    NSMutableDictionary *newDic = [[NSMutableDictionary alloc]init];
    [newDic setObject:@"123" forKey:@"admin"];
    [newDic setObject:ip forKey:@"ip"];
    [newDic writeToFile:[docPath stringByAppendingPathComponent:@"setting.plist"] atomically:YES];
}

//- (BOOL)textFieldShouldReturn:(UITextField *)textField
//{
//    if ( [textField isEqual:self.usernameTextField] ) {
//        [self.passwordTextField becomeFirstResponder];
//    }
//    else {
//        [self.view endEditing:YES];
//    }
//    return NO;
//}

@end
