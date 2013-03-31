//
//  AppDelegate.m
//  Morpheme
//
//  Created by Robert Jones on 3/30/13.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//

#import "cocos2d.h"

#import "AppDelegate.h"
#import "GameBoardScene.h"
#import "MorphemeCommon.h"

@implementation AppController

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    PRINT_RECT("_window.bounds", _window.bounds);
    CCGLView *glView = [CCGLView viewWithFrame:[_window bounds]
				 pixelFormat:kEAGLColorFormatRGB565
				 depthFormat:0
				 preserveBackbuffer:NO
				 sharegroup:nil
				 multiSampling:NO
				 numberOfSamples:0];

    _director = (CCDirectorIOS*) [CCDirector sharedDirector];
    _director.wantsFullScreenLayout = YES;
    [_director setDisplayStats:YES];
    [_director setAnimationInterval:1.0/60];
    [_director setView:glView];
    [_director setDelegate:self];
    [_director setProjection:kCCDirectorProjection2D];

    if (![_director enableRetinaDisplay:YES]) {
	CCLOG(@"Retina Display Not supported");
    }

    [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];

    CCFileUtils *sharedFileUtils = [CCFileUtils sharedFileUtils];
    [sharedFileUtils setEnableFallbackSuffixes:NO];				// Default: NO. No fallback suffixes are going to be used
    [sharedFileUtils setiPhoneRetinaDisplaySuffix:@"-hd"];		// Default on iPhone RetinaDisplay is "-hd"
    [sharedFileUtils setiPadSuffix:@"-ipad"];					// Default on iPad is "ipad"
    [sharedFileUtils setiPadRetinaDisplaySuffix:@"-ipadhd"];	// Default on iPad RetinaDisplay is "-ipadhd"

    [CCTexture2D PVRImagesHavePremultipliedAlpha:YES];

    [_director pushScene:[[[GameBoardScene alloc] init] autorelease]];

    _navController = [[UINavigationController alloc] initWithRootViewController:_director];
    _navController.navigationBarHidden = YES;
    [_window setRootViewController:_navController];
    [_window makeKeyAndVisible];
	
    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

-(void)applicationWillResignActive:(UIApplication *)application {
    if ([_navController visibleViewController] == _director) [_director pause];
}

-(void)applicationDidBecomeActive:(UIApplication *)application {
    if ([_navController visibleViewController] == _director) [_director resume];
}

-(void)applicationDidEnterBackground:(UIApplication*)application {
    if ([_navController visibleViewController] == _director) [_director stopAnimation];
}

-(void)applicationWillEnterForeground:(UIApplication*)application {
    if ([_navController visibleViewController] == _director) [_director startAnimation];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    CC_DIRECTOR_END();
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    [[CCDirector sharedDirector] purgeCachedData];
}

-(void) applicationSignificantTimeChange:(UIApplication *)application {
    [[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

- (void) dealloc {
    [_window release];
    [_navController release];
    [super dealloc];
}
@end

