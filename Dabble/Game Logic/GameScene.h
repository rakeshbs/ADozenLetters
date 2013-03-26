//
//  GameScene.h
//  DictionarySearch
//
//  Created by Rakesh on 17/01/13.
//  Copyright (c) 2013 Rakesh. All rights reserved.
//

#import "Scene.h"
#import "Square.h"
#import "GCHelper.h"

@interface GameScene : Scene <GCHelperDelegate>
{
    GCHelper *gcHelper;
    BOOL isServer;
    int currentRandomNumber;
    TextureShader *testTextureShader;
}
@end
