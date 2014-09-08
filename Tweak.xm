#import <UIKit/UIKit.h>

@interface SBControlCenterController : NSObject
@property (assign,getter=isPresented,nonatomic) BOOL presented;
@end

@interface SpringBoard
-(int)_frontMostAppOrientation;
@end

static BOOL CCisEnabled = YES;
static BOOL NCisEnabled = YES;
static BOOL iPhone5Plus = NO;
BOOL otherRepo;

%hook SBNotificationCenterController
-(void)beginPresentationWithTouchLocation:(CGPoint)arg1 {
    if(iPhone5Plus){
        SpringBoard *_springBoard = (SpringBoard *)[UIApplication sharedApplication];
        if (UIInterfaceOrientationIsLandscape([_springBoard _frontMostAppOrientation])) {
            if((arg1.x > 280 && arg1.x < 400) || !NCisEnabled) {
                %orig;
        }
    } else {
      if((arg1.x > 100 && arg1.x < 220) || !NCisEnabled) {
        %orig;
      }
    }
} else {
    //3.5" Code (iPhone 4/4s)
    SpringBoard *_springBoard = (SpringBoard *)[UIApplication sharedApplication];
        if (UIInterfaceOrientationIsLandscape([_springBoard _frontMostAppOrientation])) {
      if((arg1.x > 180 && arg1.x < 300) || !NCisEnabled) {
        %orig;
      }
    } else {
      if((arg1.x > 100 && arg1.x < 220) || !NCisEnabled) {
        %orig;
      }
    }
  }
}
%end

%hook SBControlCenterController
-(void)beginPresentationWithTouchLocation:(CGPoint)arg1 {
    if(iPhone5Plus){
        SpringBoard *_springBoard = (SpringBoard *)[UIApplication sharedApplication];
        if (UIInterfaceOrientationIsLandscape([_springBoard _frontMostAppOrientation])) {
            if((arg1.x > 280 && arg1.x < 400) || !CCisEnabled) {
                %orig;
        }
    } else {
      if((arg1.x > 100 && arg1.x < 220) || !CCisEnabled) {
        %orig;
      }
    }
} else {
    //3.5" Code (iPhone 4/4s)
    SpringBoard *_springBoard = (SpringBoard *)[UIApplication sharedApplication];
        if (UIInterfaceOrientationIsLandscape([_springBoard _frontMostAppOrientation])) {
      if((arg1.x > 200 && arg1.x < 400) || !CCisEnabled) {
        %orig;
      }
    } else {
      if((arg1.x > 100 && arg1.x < 220) || !CCisEnabled) {
        %orig;
      }
    }
  }
}
%end

%hook SpringBoard
-(void)applicationDidFinishLaunching:(id)application{
     %orig;
     if (otherRepo) {
          UIAlertView* repoAlert = [[UIAlertView alloc] initWithTitle:@"Hey there!" message:@"I see you've downloaded my tweak from a different repo. Please download this tweak from BigBoss to help support me and you also get faster updates!" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
          [repoAlert show];
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
        iPhone5Plus = [prefs objectForKey:@"iPhone5Plus"] ? [[prefs objectForKey:@"iPhone5Plus"] boolValue] : iPhone5Plus;
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
