#define IS_IPHONE_5 [[UIScreen mainScreen] bounds].size.height == 568.0
#define IS_IPHONE_6 [[UIScreen mainScreen] bounds].size.height == 667.0
#define IS_IPHONE_6PLUS [[UIScreen mainScreen] bounds].size.height == 736.0
#define IS_IPAD UIUserInterfaceIdiom() == UIUserInterfaceIdiomPad

NS_INLINE CGFloat calcHeight(CGFloat percent) { return percent * [[UIScreen mainScreen] bounds].size.height; }
//NS_INLINE CGFloat calcWidth(CGFloat percent) { return percent * [[UIScreen mainScreen] bounds].size.width; }

@interface SBControlCenterController : NSObject
@property (assign,getter=isPresented,nonatomic) BOOL presented;
@end

@interface SpringBoard
-(int)_frontMostAppOrientation;
@end

@interface UIApplication (CenterStage)
-(int)_frontMostAppOrientation;
@end

BOOL CCisEnabled = YES;
BOOL NCisEnabled = YES;
int leftGrabberX = 0;
int rightGrabberX = 0;

BOOL isLandscape() {

  //landscape
  if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] _frontMostAppOrientation])) return YES;
  //portrait
  else return NO;

}

void checkLocations() {
  
  if (isLandscape()) {
    leftGrabberX = calcHeight(.4029);
    rightGrabberX = calcHeight(.6042);
  } else {
    leftGrabberX = calcHeight(.1725);
    rightGrabberX = calcHeight(.4075);
  }

  //if(IS_IPHONE_6){
    //leftGrabberX = calcHeight(.4029);
    //rightGrabberX = calcHeight(.)
  //}

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

static void loadPrefs()
{
  NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.greeny.centerstageprefs.plist"];
  if(prefs)
    {
      CCisEnabled = [prefs objectForKey:@"CCisEnabled"] ? [[prefs objectForKey:@"CCisEnabled"] boolValue] : CCisEnabled;
      NCisEnabled = [prefs objectForKey:@"NCisEnabled"] ? [[prefs objectForKey:@"NCisEnabled"] boolValue] : NCisEnabled;
    }
    [prefs release];
  }

%ctor
{
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPrefs, CFSTR("com.greeny.centerstageprefs/settingschanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);
    loadPrefs();
  }
