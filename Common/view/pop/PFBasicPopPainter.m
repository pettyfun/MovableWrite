//
//  PFBasicPopPainter.m
//  PettyFunPop
//
//  Created by YJ Park on 1/6/11.
//  Copyright 2011 PettyFun.com. All rights reserved.
//

#import "PFBasicPopPainter.h"
#import "PFPopPainterFactory.h"

@implementation PFBasicPopPainter
@synthesize usingCellCache;

-(id) init {
    if ((self = [super init])) {
        baseConfig = [[PFPopConfig alloc] init];
    }
    return self;
}

-(void) dealloc {
    [baseConfig release];
    [super dealloc];
}

-(void) updateBaseConfig:(PFPopConfig *)config {
    [baseConfig updateTo:config];
    baseConfig.factor = 1.0f;
}

-(void) paintPop:(PFPop *)pop
       onContext:(CGContextRef)context 
      withConfig:(PFPopConfig *)config
          inRect:(CGRect)rect
        viewRect:(CGRect)viewRect {
}

-(void) paintEmptyPopOnContext:(CGContextRef)context 
                    withConfig:(PFPopConfig *)config 
                        inRect:(CGRect)rect
                      viewRect:(CGRect)viewRect {
}

-(void) paintCell:(PFPopCell *)cell
        onContext:(CGContextRef)context
           inRect:(CGRect)rect
       withConfig:(PFPopConfig *)config {
    [self updateBaseConfig:config];
    //CGContextClipToRect(context, rect);
    [self _paintCell:cell onContext:context inRect:rect withConfig:config
         usingCache:usingCellCache background:YES];
    [self _paintCell:cell onContext:context inRect:rect withConfig:config
         usingCache:usingCellCache background:NO];
}

-(void) _paintCell:(PFPopCell *)cell
        onContext:(CGContextRef)context
           inRect:(CGRect)rect
       withConfig:(PFPopConfig *)config 
       usingCache:(BOOL)usingCache
       background:(BOOL)background {
        
    DECLARE_PFPOP_PAINTER_FACTORY
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineJoin(context, kCGLineJoinRound);
    
    if (usingCache) {
        PFPopStroke *lastStroke = [cell.strokes lastObject];
        currentStrokeRef = lastStroke;
        UIImage *cellImage = [self _getCellImage:cell withConfig:config
                                        background:background];
        if (cellImage) {
            float scale = config.factor;
            float imageY = cellImage.size.height - (rect.origin.y + rect.size.height) / scale;
            CGRect imageRect = CGRectMake(rect.origin.x / scale,
                                          imageY,
                                          rect.size.width / scale,
                                          rect.size.height / scale);
            /*
            NSLog(@"scale = %f, imageRect = %@ rect = %@",
                  scale,
                  NSStringFromCGRect(imageRect),
                  NSStringFromCGRect(rect));
            */
            CGImageRef drawImage = CGImageCreateWithImageInRect(cellImage.CGImage,
                                                                imageRect); 
            if (drawImage != NULL)
            {
                CGContextDrawImage(context, rect, drawImage);
                // Clean up memory and restore previous state
                CGImageRelease(drawImage);
            }            
        }
        id<PFPopStrokePainter> strokePainter = [painterFactory getStrokePainter:currentStrokeRef];
        [strokePainter paintStroke:currentStrokeRef forCell:cell onContext:context
                        withConfig:config background:background];
    } else {
        for (PFPopStroke *stroke in cell.strokes) {
            if (stroke != currentStrokeRef) {
                id<PFPopStrokePainter> strokePainter = [painterFactory getStrokePainter:stroke];
                [strokePainter paintStroke:stroke forCell:cell onContext:context
                                withConfig:config background:background];
            }
        }        
    }    
}

-(void) updateCellCache:(PFPopCell *)cell
             withConfig:(PFPopConfig *)config
             background:(BOOL)background {
    [self updateBaseConfig:config];
    CGRect cellRect = CGRectMake(0.0f, 0.0f, config.width, config.height);
    UIGraphicsBeginImageContext(cellRect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();      
    float scale = 1.0f;
    CGContextTranslateCTM(context, 0.0f, cellRect.size.height * scale);
    CGContextScaleCTM(context, scale, -scale);
    [self _paintCell:cell onContext:context inRect:cellRect withConfig:baseConfig
          usingCache:YES background:background];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    DECLARE_PFUTILS    
    NSString *cellCacheKey = NSFormat(@"%@%d%d", PFNOTE_CELL_CACHE_PREFIX, [cell hash], background);
    [utils setCache:image forKey:cellCacheKey];
}

-(void) resetCell:(PFPopCell *)cell
       withConfig:(PFPopConfig *)config {
    if (usingCellCache) {
        [self updateCellCache:cell
                   withConfig:config
                   background:YES]; 
        [self updateCellCache:cell
                   withConfig:config
                   background:NO]; 
    }
}

-(UIImage *) _getCellImage:(PFPopCell *)cell
                withConfig:(PFPopConfig *)config 
                background:(BOOL)background {
    DECLARE_PFUTILS
    NSString *cellCacheKey = NSFormat(@"%@%d%d", PFNOTE_CELL_CACHE_PREFIX, [cell hash], background);
    UIImage *image = [utils getCache:cellCacheKey];
    if (!image) {
        CGRect cellRect = CGRectMake(0.0f, 0.0f, config.width, config.height);
        UIGraphicsBeginImageContext(cellRect.size);
        CGContextRef context = UIGraphicsGetCurrentContext();    
        float scale = 1.0f;
        CGContextTranslateCTM(context, 0.0f, cellRect.size.height * scale);
        CGContextScaleCTM(context, scale, -scale);
        [self _paintCell:cell onContext:context inRect:cellRect withConfig:baseConfig
              usingCache:NO background:background];
        
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [utils setCache:image forKey:cellCacheKey];
    }
    return image;
}

@end
