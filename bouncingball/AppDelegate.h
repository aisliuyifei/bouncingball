//
//  AppDelegate.h
//  bouncingball
//
//  Created by wupeng on 12-11-12.
//  Copyright __MyCompanyName__ 2012年. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cocos2d.h"
#import <GameKit/GameKit.h>
#import "PlayerModel.h"
#import "SCNavigationViewController.h"
static BOOL isGameCenterAPIAvailable();

@interface AppController : NSObject <UIApplicationDelegate, CCDirectorDelegate>
{
	UIWindow *window_;
	SCNavigationViewController *navController_;
	
	CCDirectorIOS	*director_;							// weak ref
}

@property (nonatomic, retain) UIWindow *window;
@property (readonly) SCNavigationViewController *navController;
@property (readonly) CCDirectorIOS *director;
@property (retain,readwrite) NSString * currentPlayerID;
@property (readwrite, getter=isGameCenterAuthenticationComplete) BOOL gameCenterAuthenticationComplete;
@property (readwrite, retain) PlayerModel * player;

@end
