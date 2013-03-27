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
    
    int numberOfWordsMade;
    int numberOfTripletsMade;
    int numberOfDoublesMade;
    
    Texture2D *analyticsTexture;
    StringTextureShader *analyticsShader;
    
}
@end
