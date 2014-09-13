#import <UIKit/UIKit.h>

#define IS_IPHONE_5 [[UIScreen mainScreen] bounds].size.height == 568.0
#define IS_IPAD UIUserInterfaceIdiom() == UIUserInterfaceIdiomPad

@interface SBControlCenterController : NSObject
@property (assign,getter=isPresented,nonatomic) BOOL presented;
@end

@interface SpringBoard
-(int)_frontMostAppOrientation;
@end

static BOOL CCisEnabled = YES;
static BOOL NCisEnabled = YES;
static BOOL iPad = YES;
BOOL otherRepo;

%hook SBNotificationCenterController
-(void)beginPresentationWithTouchLocation:(CGPoint)arg1 {
  int leftGrabberX = 0;
  int rightGrabberX = 0;
  SpringBoard *_springBoard = (SpringBoard *)[UIApplication sharedApplication];
  BOOL isLandscape = UIInterfaceOrientationIsLandscape([_springBoard _frontMostAppOrientation]);
  BOOL isPortrait = UIInterfaceOrientationIsPortrait([_springBoard _frontMostAppOrientation]);

  if(iPad){
  if (IS_IPAD && isLandscape) {
    leftGrabberX = 950;
    rightGrabberX = 1100;
  } else if (isLandscape) {
    leftGrabberX = 470;
    rightGrabberX = 555;
  } else {
    leftGrabberX = 345;
    rightGrabberX = 435;
  }

  if (IS_IPAD && isPortrait) {
      leftGrabberX = 700;
      rightGrabberX = 830;
    } else if (isPortrait) {
      leftGrabberX = 345;
      rightGrabberX = 435;
    } else {
      leftGrabberX = 470;
      rightGrabberX = 555;
    }
  }
  else{
  if (IS_IPHONE_5 && isLandscape) { // Landscape 4" device
    leftGrabberX = 280;
    rightGrabberX = 400;
  } else if (isLandscape) { // Landscape 3.5" device
    leftGrabberX = 180;
    rightGrabberX = 300;
  } else { // Portrait iPhone
    leftGrabberX = 100;
    rightGrabberX = 220;
  }
}
  if((arg1.x > leftGrabberX && arg1.x < rightGrabberX) || !NCisEnabled) {
    %orig;
  }
}
%end

%hook SBControlCenterController
-(void)beginTransitionWithTouchLocation:(CGPoint)arg1 {
  int leftGrabberX = 0;
  int rightGrabberX = 0;
  SpringBoard *_springBoard = (SpringBoard *)[UIApplication sharedApplication];
  BOOL isLandscape = UIInterfaceOrientationIsLandscape([_springBoard _frontMostAppOrientation]);
  BOOL isPortrait = UIInterfaceOrientationIsPortrait([_springBoard _frontMostAppOrientation]);

  if(iPad){
  if (IS_IPAD && isLandscape) {
    leftGrabberX = 950;
    rightGrabberX = 1100;
  } else if (isLandscape) {
    leftGrabberX = 470;
    rightGrabberX = 555;
  } else {
    leftGrabberX = 345;
    rightGrabberX = 435;
  }

  if (IS_IPAD && isPortrait) {
      leftGrabberX = 700;
      rightGrabberX = 830;
    } else if (isPortrait) {
      leftGrabberX = 345;
      rightGrabberX = 435;
    } else {
      leftGrabberX = 470;
      rightGrabberX = 555;
    }
  }
  else{
  if (IS_IPHONE_5 && isLandscape) { // Landscape 4" device
    leftGrabberX = 280;
    rightGrabberX = 400;
  } else if (isLandscape) { // Landscape 3.5" device
    leftGrabberX = 180;
    rightGrabberX = 300;
  } else { // Portrait iPhone
    leftGrabberX = 100;
    rightGrabberX = 220;
  }
}
  if((arg1.x > leftGrabberX && arg1.x < rightGrabberX) || !NCisEnabled) {
    %orig;
  }
}
%end

%hook SpringBoard
-(void)applicationDidFinishLaunching:(id)application{
  %orig;
    BOOL ranBefore = [[NSUserDefaults standardUserDefaults] boolForKey:@"RanBefore"];

    if (!ranBefore) {
        UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"CenterStage"
                          message:@"Hey there! Thank you for downloading CenterStage, iPad users please go straight to settings to configure the tweak. \n If you appreciate my work, please donate by using the button in the settings app."
                          delegate:self
                          cancelButtonTitle:@"Thanks!"
                          otherButtonTitles:nil];
        [alert show];
        [alert release];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"RanBefore"];
        [[NSUserDefaults standardUserDefaults] synchronize];
}
  if (otherRepo) {
    UIAlertView* repoAlert = [[UIAlertView alloc] initWithTitle:@"Hey there!" message:@"I see you've downloaded my tweak from a different repo. Please download this tweak from BigBoss to help support me and you also get faster updates!" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
    [repoAlert show];
    %orig;
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
