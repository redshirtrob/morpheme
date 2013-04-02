//
//  AppDelegate.m
//  Morpheme
//
//  Created by Robert Jones on 3/30/13.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//

#import "cocos2d.h"
#import "SimpleAudioEngine.h"

#import "AppDelegate.h"
#import "IntroScene.h"
#import "MorphemeCommon.h"

@implementation AppController

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    CCGLView *glView = [CCGLView viewWithFrame:[_window bounds]
				 pixelFormat:kEAGLColorFormatRGBA8
				 depthFormat:0
				 preserveBackbuffer:NO
				 sharegroup:nil
				 multiSampling:NO
				 numberOfSamples:0];

    _director = (CCDirectorIOS*) [CCDirector sharedDirector];
    _director.wantsFullScreenLayout = YES;
    [_director setDisplayStats:NO];
    [_director setAnimationInterval:1.0/60];
    [_director setView:glView];
    [_director setDelegate:self];
    [_director setProjection:kCCDirectorProjection2D];

    if (![_director enableRetinaDisplay:YES]) {
	CCLOG(@"Retina Display Not supported");
    }

    [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];

    CCFileUtils *sharedFileUtils = [CCFileUtils sharedFileUtils];
    [sharedFileUtils setEnableFallbackSuffixes:NO];
    [sharedFileUtils setiPhoneRetinaDisplaySuffix:@"-hd"];
    [sharedFileUtils setiPadSuffix:@"-ipad"];
    [sharedFileUtils setiPadRetinaDisplaySuffix:@"-ipadhd"];

    [CCTexture2D PVRImagesHavePremultipliedAlpha:NO];

    [SimpleAudioEngine sharedEngine];

    IntroScene *scene = [[[IntroScene alloc] init] autorelease];
    [_director pushScene:scene];

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

