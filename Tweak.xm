//Lets the tweak know what device we're dealing with
#define IS_IPHONE_5 [[UIScreen mainScreen] bounds].size.height == 568.0
#define IS_IPHONE_6 [[UIScreen mainScreen] bounds].size.height == 667.0
#define IS_IPHONE_6PLUS [[UIScreen mainScreen] bounds].size.height == 736.0
#define IS_IPAD UIUserInterfaceIdiom() == UIUserInterfaceIdiomPad
#define SCREEN_BOUNDS [[UIScreen mainScreen] bounds]

//not entirely sure, as Phillip Tennen if you really want to know but I presume it's a modification to the calcHeight method so that it returns in percent
//NS_INLINE CGFloat calcHeight(CGFloat percent) { return percent * [[UIScreen mainScreen] bounds].size.height; }
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
int leftGrabberX = 0;
int rightGrabberX = 0;
int widthOfRegion = 0;

//self defined (C) method that detects if the device is landscape
BOOL isLandscape() {

    //landscape
    if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] _frontMostAppOrientation])) 
        return YES;
    //portrait
    return NO;

}

//self defined (C) method that returns a dynamic width in which the centers can be invoked within
int dynamicWidthOfRegion() {
    int mainScreenWidth = 320;
    int defaultSpace = 100;
    if (isLandscape()) {
        return (SCREEN_BOUNDS.size.height * defaultSpace) / mainScreenWidth;
    }
    return (SCREEN_BOUNDS.size.width * defaultSpace) / mainScreenWidth;
}

//self defined (C) method that detects the locations of where the NC/CC is allowed to be presented from
void checkLocations() {

    widthOfRegion = dynamicWidthOfRegion();

    if (isLandscape()) {
        leftGrabberX = (SCREEN_BOUNDS.size.height/2)-(widthOfRegion/2);
        rightGrabberX = (SCREEN_BOUNDS.size.height/2)+(widthOfRegion/2);
    } else {
        leftGrabberX = (SCREEN_BOUNDS.size.width/2)-(widthOfRegion/2);
        rightGrabberX = (SCREEN_BOUNDS.size.width/2)+(widthOfRegion/2);
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
  
    if ((arg1.x > leftGrabberX && arg1.x < rightGrabberX) || !NCisEnabled) {
        %orig;
    }
}

%end

//Sane as the NC
%hook SBControlCenterController

-(void)beginTransitionWithTouchLocation:(CGPoint)arg1 {

    checkLocations();
  
    if ((arg1.x > leftGrabberX && arg1.x < rightGrabberX) || !CCisEnabled) {
        %orig;
    }

}

- (void)beginPresentationWithTouchLocation:(struct CGPoint)arg1{

    checkLocations();

    if ((arg1.x > leftGrabberX && arg1.x < rightGrabberX) || !CCisEnabled) {
        %orig;
    }

}

-(void)updateTransitionWithTouchLocation:(CGPoint)arg1 velocity:(CGPoint)arg2 {

    checkLocations();

    if ((arg1.x > leftGrabberX && arg1.x < rightGrabberX) || !CCisEnabled) {
        %orig;
    }

}

- (void)endTransitionWithVelocity:(struct CGPoint)arg1{
    checkLocations();

    if ((arg1.x > leftGrabberX && arg1.x < rightGrabberX) || !CCisEnabled) {
        %orig;
    }

}

- (void)endTransitionWithVelocity:(struct CGPoint)arg1 wasCancelled:(_Bool)arg2{
    checkLocations();
    arg2 = FALSE;

    if ((arg1.x > leftGrabberX && arg1.x < rightGrabberX) || !CCisEnabled) {
        %orig;
    }

}

- (void)controlCenterViewControllerWantsDismissal:(CGPoint)arg1{

    checkLocations();

    if ((arg1.x > leftGrabberX && arg1.x < rightGrabberX) || !CCisEnabled) {
        %orig;
    }

}

%end

//Preferences
static void loadPreferences() {
    CFPreferencesAppSynchronize(CFSTR("com.greeny.centerstageprefs"));

    CCisEnabled = [(id)CFPreferencesCopyAppValue(CFSTR("CCisEnabled"), CFSTR("com.greeny.centerstageprefs")) boolValue];
    NCisEnabled = [(id)CFPreferencesCopyAppValue(CFSTR("NCisEnabled"), CFSTR("com.greeny.centerstageprefs")) boolValue];
}

%ctor {
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                NULL,
                                (CFNotificationCallback)loadPreferences,
                                CFSTR("com.greeny.centerstageprefs/settingschanged"),
                                NULL,
                                CFNotificationSuspensionBehaviorDeliverImmediately);
    loadPreferences();
}
