//Lets the tweak know what device we're dealing with
#define IS_IPHONE_5 [[UIScreen mainScreen] bounds].size.height == 568.0
#define IS_IPHONE_6 [[UIScreen mainScreen] bounds].size.height == 667.0
#define IS_IPHONE_6PLUS [[UIScreen mainScreen] bounds].size.height == 736.0
#define IS_IPAD UIUserInterfaceIdiom() == UIUserInterfaceIdiomPad

//not entirely sure, as Phillip Tennen if you really want to know but I presume it's a modification to the calcHeight method so that it returns in percent
NS_INLINE CGFloat calcHeight(CGFloat percent) { return percent * [[UIScreen mainScreen] bounds].size.height; }
//NS_INLINE CGFloat calcWidth(CGFloat percent) { return percent * [[UIScreen mainScreen] bounds].size.width; }

//no idea ;p
@interface SBControlCenterController : NSObject
@property (assign,getter=isPresented,nonatomic) BOOL presented;
@end

//So that it works on SpringBoard and as you can see below, all apps as well
@interface SpringBoard
-(int)_frontMostAppOrientation;
@end

//make sure it works in the front most app (i.e. the app that you are currently using)
@interface UIApplication (CenterStage)
-(int)_frontMostAppOrientation;
@end

//declared some variables
BOOL CCisEnabled = YES;
BOOL NCisEnabled = YES;
int leftGrabberX;
int rightGrabberX;

//self defined (C) method that detects if the device is landscape
BOOL isLandscape() {

  //landscape
  if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] _frontMostAppOrientation])) return YES;
  //portrait
  else return NO;

}

//self defined (C) method that detects the locations of where the NC/CC is allowed to be presented from
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

//Hook into class and hijack method - add in our checkLocations method, use leftGrabberX and rightGrabberX to determine where to present the NC from
%hook SBNotificationCenterController
-(void)beginPresentationWithTouchLocation:(CGPoint)arg1 {
  
  checkLocations();
  
  if((arg1.x > leftGrabberX && arg1.x < rightGrabberX) || !NCisEnabled) {
    %orig;
  }
}
%end

//Sane as the NC
%hook SBControlCenterController
-(void)beginTransitionWithTouchLocation:(CGPoint)arg1 {

  checkLocations();
  
  if((arg1.x > leftGrabberX && arg1.x < rightGrabberX) || !CCisEnabled) {
    %orig;
  }
}
%end

//Preferences (the old way though - need to update it)
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
