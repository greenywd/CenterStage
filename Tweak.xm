#define IS_IPHONE_5 [[UIScreen mainScreen] bounds].size.height == 568.0
#define IS_IPAD UIUserInterfaceIdiom() == UIUserInterfaceIdiomPad

NS_INLINE CGFloat calcHeight(CGFloat percent) { return percent * [[UIScreen mainScreen] bounds].size.height; }
NS_INLINE CGFloat calcWidth(CGFloat percent) { return percent * [[UIScreen mainScreen] bounds].size.width; }

@interface SBControlCenterController : NSObject
@property (assign,getter=isPresented,nonatomic) BOOL presented;
@end

@interface SpringBoard
-(int)_frontMostAppOrientation;
@end

@interface UIApplication (CenterStage)
-(int)_frontMostAppOrientation;
@end

static BOOL CCisEnabled = YES;
static BOOL NCisEnabled = YES;
static BOOL iPad = IS_IPAD;
static BOOL otherRepo;
static int leftGrabberX = 0;
static int rightGrabberX = 0;

BOOL isLandscape() {

  //landscape
  if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] _frontMostAppOrientation])) return YES;
  //portrait
  else return NO;

}

void checkLocations {
  
  if (isLandscape) {
    leftGrabberX = calcHeight(.492957746);
    rightGrabberX = calcHeight(.704225352);
  }
  
  else {
    leftGrabberX = calcHeight(.3125);
    rightGrabberX = calcHeight(.6875);
  }

}

%hook SBNotificationCenterController
-(void)beginPresentationWithTouchLocation:(CGPoint)arg1 {
  
  checkLocations();
  
  if((arg1.x > leftGrabberX && arg1.x < rightGrabberX) || !NCisEnabled) {
    %orig;
  }
}
%end

%hook SBControlCenterController
-(void)beginTransitionWithTouchLocation:(CGPoint)arg1 {

  checkLocations();
  
  if((arg1.x > leftGrabberX && arg1.x < rightGrabberX) || !CCisEnabled) {
    %orig;
  }
}
%end

%hook SpringBoard
-(void)applicationDidFinishLaunching:(id)application{
  %orig;
    BOOL ranBefore = [[NSUserDefaults standardUserDefaults] boolForKey:@"CenterStageRanBefore"];

    if (!ranBefore) {
        UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"CenterStage"
                          message:@"Hey there! Thank you for downloading CenterStage, iPad users please go straight to settings to configure the tweak. \n If you appreciate my work, please donate by using the button in the settings app."
                          delegate:self
                          cancelButtonTitle:@"Thanks!"
                          otherButtonTitles:nil];
        [alert show];
        [alert release];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"CenterStageRanBefore"];
        [[NSUserDefaults standardUserDefaults] synchronize];
}
  if (otherRepo) {
    UIAlertView* repoAlert = [[UIAlertView alloc] initWithTitle:@"Hey there!" message:@"I see you've downloaded my tweak from a different repo. Please download this tweak from BigBoss to help support me and you also get faster updates!" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
    [repoAlert show];
    [repoAlert release];
  }
}
%end

static void loadPrefs()
{
  NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.greeny.centerstageprefs.plist"];
  if(prefs)
    {
      CCisEnabled = [prefs objectForKey:@"CCisEnabled"] ? [[prefs objectForKey:@"CCisEnabled"] boolValue] : CCisEnabled;
      NCisEnabled = [prefs objectForKey:@"NCisEnabled"] ? [[prefs objectForKey:@"NCisEnabled"] boolValue] : NCisEnabled;
      iPad = [prefs objectForKey:@"iPad"] ? [[prefs objectForKey:@"iPad"] boolValue] : iPad;
    }
    [prefs release];
  }

  %ctor
  //Thanks to Phillip Tennen (/u/Codyd51) for this!
  {
    if (![[NSFileManager defaultManager] fileExistsAtPath:@"/var/lib/dpkg/info/com.greeny.centerstage.list"]){
      otherRepo = YES;
    }

    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPrefs, CFSTR("com.greeny.centerstageprefs/settingschanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);
    loadPrefs();
  }
