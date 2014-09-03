#import <UIKit/UIKit.h>

@interface SBControlCenterController : NSObject
@property (assign,getter=isPresented,nonatomic) BOOL presented;
@end

static BOOL CCisEnabled = YES;
static BOOL NCisEnabled = YES;
BOOL otherRepo;

%hook SBNotificationCenterController
-(void)beginPresentationWithTouchLocation:(CGPoint)arg1 {
	if((arg1.x > 100 && arg1.x < 220) || !NCisEnabled) {
            %orig;
	   }
   }
%end

%hook SBControlCenterController
-(void)beginTransitionWithTouchLocation:(CGPoint)arg1 {
	if ((arg1.x > 100 && arg1.x < 220) || self.presented || !CCisEnabled) {
		%orig;
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
