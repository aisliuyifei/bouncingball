//
//  HelloWorldLayer.mm
//  bouncingball
//
//  Created by wupeng on 12-11-12.
//  Copyright __MyCompanyName__ 2012年. All rights reserved.
//
// Import the interfaces
#define LEADERBOARDCATEGORY @"toplist"
#import "GameLayer.h"


// Needed to obtain the Navigation Controller
#import "AppDelegate.h"

#import "PhysicsSprite.h"

enum {
	kTagParentNode = 1,
};


#pragma mark - HelloWorldLayer

@interface GameLayer()
-(void) initPhysics;
-(void) createMenu;
@end

@implementation GameLayer

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	GameLayer *layer = [GameLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	// return the scene
	return scene;
}

-(void)loadLevel{
    _loader = [[LevelHelperLoader alloc] initWithContentOfFile:@"level1"];
    [_loader addObjectsToWorld:world cocos2dLayer:self];
    if ([_loader hasPhysicBoundaries]) {
        [_loader createPhysicBoundaries:world];
    }
    _ball = [_loader spriteWithUniqueName:@"ball"];
    _ballBody = [_ball body];
    [self setUpCollisionHandling];
    [self setUpAudio];
    [_ball registerTouchBeganObserver:self selector:@selector(touchBegin:)];
    [_ball registerTouchMovedObserver:self selector:@selector(touchMoved:)];
    [_ball registerTouchEndedObserver:self selector:@selector(touchEnded:)];
    _shadow = [_loader spriteWithUniqueName:@"shadow"];
}
-(void)touchBegin:(LHTouchInfo*)info{
    if (gameOver) {
        return;
    }
    [self changeColor];
    CCLOG(@"Begin");
    [_ball setScale:0.8];
//    [[_ball sprite] setColor:ccc3(0, 0, 0)];
    
}

-(void)touchMoved:(LHTouchInfo*)info{
    CCLOG(@"Move");

}
-(void)touchEnded:(LHTouchInfo*)info{
    [_ball setScale:1.0];
    if (gameOver) {
        return;
    }
    score+=1;
    labelSCore.string = [NSString stringWithFormat:@"%d",score];
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    CCLOG(@"End");
    AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];

    CGPoint pointTouch = [info.touch locationInView:app.navController.view];
    CGPoint pointBallCenter = ccp(_ball.position.x,winSize.height - _ball.position.y);

    
     _ballBody->ApplyLinearImpulse(b2Vec2((pointBallCenter.x-pointTouch.x)/2,info.relativePoint.y),_ballBody->GetWorldCenter());
    
}

-(void)setUpCollisionHandling{
    [_loader useLevelHelperCollisionHandling];
    [_loader registerBeginOrEndCollisionCallbackBetweenTagA:BALL andTagB:WALL idListener:self selListener:@selector(ballWallCollision:)];
    [_loader registerBeginOrEndCollisionCallbackBetweenTagA:BALL andTagB:CEIL idListener:self selListener:@selector(ballWallCollision:)];
    [_loader registerBeginOrEndCollisionCallbackBetweenTagA:BALL andTagB:BOTTOM idListener:self selListener:@selector(ballBottomCollision:)];
}

-(void)ballWallCollision:(LHContactInfo*)contact{
    if (gameOver) {
        return;
    }
    NSLog(@"撞墙啦,砰~砰~,音效准备");
}

-(void)ballBottomCollision:(LHContactInfo*)contact{
    if (gameOver) {
        return;
    }

    [self gameOver];
}

-(void)gameOver
{
    NSLog(@"撞地球，死啦~死啦");
    gameOver = YES;
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    NSString *str;
    if (score<=0) {
        str = @"点击小球，别然它着地！";
    }else if(score<10){
        str = @"你三岁吗，就这点实力？";
    }else if(score<20){
        str = @"行不行啊，不行就认输。";
    }else if(score<30){
        str = @"好像有点感觉了嘛";
    }else if(score<40){
        str = @"再接再励。";
    }else if(score <50){
        str = @"嗯，就快及格了。";
    }else if (score<60){
        str = @"还不够，还不够。";
    }else if (score <70){
        str = @"哟，我开始佩服你了。";
    }else if(score<80){
        str = @"我觉得你真够无聊的。";
    }else if (score<90){
        str = @"加油，哥看好你";
    }else if (score<100)
    {
        str = @"行百里者半九十";
    }
    else{
        str = @"24k纯爷们啊";
    }
     CCLabelTTF *label = [CCLabelTTF labelWithString:str fontName:@"Marker Felt" fontSize:20];

    label.color = ccRED;
    label.position = ccp(winSize.width*0.5, winSize.height*0.75);
    [self addChild:label];
    
    CCMenuItemFont *item = [CCMenuItemFont itemWithString:@"再来一次" target:self selector:@selector(restartGame)];
    
    CCMenuItemFont *item2 = [CCMenuItemFont itemWithString:@"排行榜" target:self selector:@selector(showLeaderboardButtonAction:)];
    
    CCMenu *menu = [CCMenu menuWithItems:item,item2,nil];
    [menu alignItemsVertically];
    [menu setPosition:ccp(winSize.width/2, winSize.height*0.6)];
    [self addChild:menu];
    [self insertCurrentScroeIntoLeaderboard:LEADERBOARDCATEGORY];
}

-(void)restartGame{
    [[CCDirector sharedDirector] replaceScene: [GameLayer scene]];
}

-(void)setUpAudio{
    //Audio
}

-(void)changeColor{
    [_ball prepareAnimationNamed:[NSString stringWithFormat:@"animation_%d",(score+10)%14] fromSHScene:@"sprites"];
    [_ball playAnimation];
}

-(id) init
{
    
	if( (self=[super init])) {
        context = 0;
	    CGSize screenSize = [[CCDirector sharedDirector] winSize];
	
		// enable events
		gameOver = NO;
        score = 0;
		self.isTouchEnabled = YES;
		self.isAccelerometerEnabled = YES;
		
		// init physics
		[self initPhysics];
        [self loadLevel];
        
        labelSCore = [[CCLabelTTF labelWithString:@"0" fontName:@"Marker Felt" fontSize:40] retain];
		[self addChild:labelSCore z:0];
		[labelSCore setColor:ccc3(0,0,255)];
		labelSCore.position = ccp(screenSize.width/2, screenSize.height-40);
        
        
        CCLabelTTF *labelInfo = [CCLabelTTF labelWithString:@"是男人就点100下" fontName:@"Marker Felt" fontSize:30];
        [self addChild:labelInfo];
        [labelInfo setPosition:ccp(screenSize.width/2,25)];

        
		// create reset button
//		[self createMenu];
		
		//Set up sprite
		
//#if 1
//		// Use batch node. Faster
//		CCSpriteBatchNode *parent = [CCSpriteBatchNode batchNodeWithFile:@"blocks.png" capacity:100];
//		spriteTexture_ = [parent texture];
//#else
//		// doesn't use batch node. Slower
//		spriteTexture_ = [[CCTextureCache sharedTextureCache] addImage:@"blocks.png"];
//		CCNode *parent = [CCNode node];
//#endif
//		[self addChild:parent z:0 tag:kTagParentNode];
//		
//		
//		[self addNewSpriteAtPosition:ccp(s.width/2, s.height/2)];
//		
//		CCLabelTTF *label = [CCLabelTTF labelWithString:@"Tap screen" fontName:@"Marker Felt" fontSize:32];
//		[self addChild:label z:0];
//		[label setColor:ccc3(0,0,255)];
//		label.position = ccp( s.width/2, s.height-50);
		
		[self scheduleUpdate];
	}
	return self;
}

-(void) dealloc
{
	delete world;
	world = NULL;
	
	delete m_debugDraw;
	m_debugDraw = NULL;
	
	[super dealloc];
}	

-(void) createMenu
{
//	// Default font size will be 22 points.
//	[CCMenuItemFont setFontSize:22];
//	
//	// Reset Button
//	CCMenuItemLabel *reset = [CCMenuItemFont itemWithString:@"Reset" block:^(id sender){
//		[[CCDirector sharedDirector] replaceScene: [GameLayer scene]];
//	}];
//	
//	// Achievement Menu Item using blocks
//	CCMenuItem *itemAchievement = [CCMenuItemFont itemWithString:@"Achievements" block:^(id sender) {
//		
//		
//		GKAchievementViewController *achivementViewController = [[GKAchievementViewController alloc] init];
//		achivementViewController.achievementDelegate = self;
//		
//		AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
//		
//		[[app navController] presentModalViewController:achivementViewController animated:YES];
//		
//		[achivementViewController release];
//	}];
//	
//	// Leaderboard Menu Item using blocks
//	CCMenuItem *itemLeaderboard = [CCMenuItemFont itemWithString:@"Leaderboard" block:^(id sender) {
//		
//		
//		GKLeaderboardViewController *leaderboardViewController = [[GKLeaderboardViewController alloc] init];
//		leaderboardViewController.leaderboardDelegate = self;
//		
//		AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
//		
//		[[app navController] presentModalViewController:leaderboardViewController animated:YES];
//		
//		[leaderboardViewController release];
//	}];
//	
//	CCMenu *menu = [CCMenu menuWithItems:itemAchievement, itemLeaderboard, reset, nil];
//	
//	[menu alignItemsVertically];
//	
//	CGSize size = [[CCDirector sharedDirector] winSize];
//	[menu setPosition:ccp( size.width/2, size.height/2)];
//	
//	
//	[self addChild: menu z:-1];	
}

-(void) initPhysics
{
	b2Vec2 gravity;
	gravity.Set(0.0f, -20.0f);
	world = new b2World(gravity);
	
	
	// Do we want to let bodies sleep?
	world->SetAllowSleeping(true);
	
	world->SetContinuousPhysics(true);
	
	m_debugDraw = new GLESDebugDraw( PTM_RATIO );
	world->SetDebugDraw(m_debugDraw);
	
	uint32 flags = 0;
	flags += b2Draw::e_shapeBit;
	//		flags += b2Draw::e_jointBit;
	//		flags += b2Draw::e_aabbBit;
	//		flags += b2Draw::e_pairBit;
	//		flags += b2Draw::e_centerOfMassBit;
	m_debugDraw->SetFlags(flags);		
}

-(void) draw
{
	//
	// IMPORTANT:
	// This is only for debug purposes
	// It is recommend to disable it
	//
	[super draw];
	
	ccGLEnableVertexAttribs( kCCVertexAttribFlag_Position );
	
	kmGLPushMatrix();
	
	world->DrawDebugData();	
	
	kmGLPopMatrix();
}

-(void) update: (ccTime) dt
{
    if (gameOver) {
        return;
    }
	//It is recommended that a fixed time step is used with Box2D for stability
	//of the simulation, however, we are using a variable time step here.
	//You need to make an informed choice, the following URL is useful
	//http://gafferongames.com/game-physics/fix-your-timestep/
	
	int32 velocityIterations = 8;
	int32 positionIterations = 1;
	
	// Instruct the world to perform a single step of simulation. It is
	// generally best to keep the time step and iterations fixed.
	world->Step(dt, velocityIterations, positionIterations);
    for (b2Body* b = world->GetBodyList(); b; b = b->GetNext())
	{
		if (b->GetUserData() != NULL)
        {
			//Synchronize the AtlasSprites position and rotation with the corresponding body
			CCSprite *myActor = (CCSprite*)b->GetUserData();
            
            if(myActor != 0)
            {
                //THIS IS VERY IMPORTANT - GETTING THE POSITION FROM BOX2D TO COCOS2D
                myActor.position = [LevelHelperLoader metersToPoints:b->GetPosition()];
                myActor.rotation = -1 * CC_RADIANS_TO_DEGREES(b->GetAngle());
            }
            
        }
	}
    [self updateShadow];
}

-(void)updateShadow{
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    [_shadow setPosition:ccp(_ball.position.x, _shadow.position.y)];
    [_shadow setScale:(screenSize.height*1.5-_ball.position.y/2)/screenSize.height];
}

- (void)showLeaderboardButtonAction:(id)event
{
    // The intent here is to show the leaderboard and then submit a score. If we try to submit the score first there is no guarentee
    // the server will have recieved the score when retreiving the current list
    [self showLeaderboard:LEADERBOARDCATEGORY];
//    [self insertCurrentScroeIntoLeaderboard:leaderboardCategory];
}

- (void)showLeaderboard:(NSString *)leaderboard
{
    AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
    GKLeaderboardViewController * leaderboardViewController = [[GKLeaderboardViewController alloc] init];
    [leaderboardViewController setCategory:leaderboard];
    [leaderboardViewController setLeaderboardDelegate:self];
    [[app navController] presentModalViewController:leaderboardViewController  animated:YES];
    [leaderboardViewController release];
}

- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
    AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated: YES];
}

- (void)insertCurrentScroeIntoLeaderboard:(NSString*)leaderboard
{
    GKScore * submitScore = [[GKScore alloc] initWithCategory:leaderboard];
    [submitScore setValue:score];
    
    // New feature in iOS5 tells GameCenter which leaderboard is the default per user.
    // This can be used to show a user's favorite course/track associated leaderboard, or just show the latest score submitted.
    [submitScore setShouldSetDefaultLeaderboard:YES];
    
    // New feature in iOS5 allows you to set the context to which the score was sent. For instance this will set the context to be
    //the count of the button press per run time. Information stored in context isn't accessable in standard GKLeaderboardViewController,
    //instead it's accessable from GKLeaderboard's loadScoresWithCompletionHandler:
    [submitScore setContext:context++];
    AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];

    [app.player submitScore:submitScore];
    [submitScore release];
}

//#pragma mark GameKit delegate
//
//-(void) achievementViewControllerDidFinish:(GKAchievementViewController *)viewController
//{
//	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
//	[[app navController] dismissModalViewControllerAnimated:YES];
//}
//
//-(void) leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
//{
//	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
//	[[app navController] dismissModalViewControllerAnimated:YES];
//}

@end
