//
//  UIView+SCHViewTransform.m
//  me
//
//  Created by 沈 晨豪 on 14-8-17.
//  Copyright (c) 2014年 sch. All rights reserved.
//

#import "UIView+SCHViewTransform.h"
#import <objc/runtime.h>

 NSString * const sch_view_transform_key = @"sch_view_transform_key";  //动画group 的名称


/*sch move path block*/
static const void *sch_move_path_shape_layer_key         = (void *)@"sch_move_path_shape_layer_key";
static const void *sch_move_path_animation_end_block_key = (void *)@"sch_move_path_animation_end_block_key";

/*sch scale  transform block*/
static const void *sch_scale_transform_animation_end_block_key = (void *)@"sch_scale_transform_start_animation_end_key";


/*sch turning transform 3D block*/
static const void *sch_turning_transform_animation_end_block_key = (void *)@"sch_turning_transform_animation_end_block_key";

@interface UIView()

/*sch move path*/
@property (nonatomic,strong) CAShapeLayer *move_path_shape_layer;
@property (nonatomic,copy  ) void (^move_path_animation_end_block)(id object);

/*sch scale  transform*/
@property (nonatomic,copy) void (^scale_transform_animation_end_block)(id object);

/*sch turning transform 3D*/
@property (nonatomic,copy) void (^turning_transform_animation_end_block)(id object);


@end

#pragma mark -
#pragma mark - SCHViewScalePathTransform

@implementation SCHScaleTransformModel : NSObject

@end

@implementation UIView (SCHViewScalePathTransform)

- (void)setScale_transform_animation_end_block:(void (^)(id))scale_transform_animation_end_block
{
    [self willChangeValueForKey:@"scale_transform_animation_end_block"];
    objc_setAssociatedObject(self, sch_scale_transform_animation_end_block_key, scale_transform_animation_end_block, OBJC_ASSOCIATION_COPY);
    [self didChangeValueForKey:@"scale_transform_animation_end_block"];
}

- (void (^)(id object))scale_transform_animation_end_block
{
    return objc_getAssociatedObject(self, sch_scale_transform_animation_end_block_key);
}

/**
 *  开始 缩放大小的动画
 *
 *  @param sacle_array            一系列缩放大小的动画
 *  @param scale_animation_start  动画开始的block
 *  @param scale_animation_end    动画结束的block
 */
- (void)startScaleTransformAnimationWithScaleTransformModelArray: (NSArray *) scale_array
                                                  animationStart: (void (^)(id object)) scale_animation_start
                                                    animationEnd: (void (^)(id object)) scale_animation_end
{
    if (scale_array.count <= 0)
    {
   
        return;
    }
    
    if (scale_animation_start)
    {
        scale_animation_start(nil);
    }
    
    self.scale_transform_animation_end_block = scale_animation_end;
    
    
    NSMutableArray *animation_array = [[NSMutableArray alloc] init];
    
    
    CGFloat begin_time = 0.0f;
    
    for (SCHScaleTransformModel *model in scale_array)
    {
        @autoreleasepool
        {
            CABasicAnimation *animation   = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
            animation.fromValue           = model.from_value;
            animation.toValue             = model.to_value;
            animation.fillMode            = kCAFillModeForwards;
            animation.beginTime           = begin_time;
            animation.timingFunction      = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            animation.repeatCount         = 1;
            animation.removedOnCompletion = YES;
            animation.duration            = model.duration;
            
            [animation_array addObject:animation];

        }
        
        begin_time += model.duration;
    }
    
    
    CAAnimationGroup *animation_group   = [CAAnimationGroup animation];
    animation_group.duration            = begin_time;
    animation_group.removedOnCompletion = NO;
    animation_group.fillMode            = kCAFillModeForwards;
    animation_group.delegate            = self;
    animation_group.repeatCount         = 1;
    animation_group.animations          = animation_array;
    
    [animation_group setValue:@"sch_scale_path" forKey:sch_view_transform_key];
    
    [self.layer addAnimation:animation_group forKey:@"sch_scale_animation"];
    
    
    
}


/**
 *  开始 缩放大小的动画
 *
 *  @param is_up                  YES: 先往上  NO: 先往下
 *  @param scale_animation_start  动画开始的block
 *  @param scale_animation_end    动画结束的block
 */
- (void)startScaleTransformAnimationWithUpOrDown: (BOOL) is_up
                                  animationStart: (void (^)(id object)) scale_animation_start
                                    animationEnd: (void (^)(id object)) scale_animation_end
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    NSArray *scale_array;
    NSArray *time = @[@0.2f,@0.2f,@0.2f,@0.2f,@0.2f];;
    if (is_up)
    {
        scale_array = @[@1,@1.1,@0.8,@1.02,@0.9,@1.0];
    }
    else
    {
        scale_array = @[@1,@0.8,@1.1,@0.9,@1.02,@1.0];
    }
    
    for (int i = 0; i <time.count; ++i)
    {
        SCHScaleTransformModel *model = [[SCHScaleTransformModel alloc] init];
        model.from_value = scale_array[i];
        model.to_value   = scale_array[i + 1];
        model.duration   = [time[i] floatValue];
        
        [array addObject:model];
    }
    
    
    [self startScaleTransformAnimationWithScaleTransformModelArray:array
                                                    animationStart:scale_animation_start
                                                      animationEnd:scale_animation_end];
    
}

@end


#pragma mark -
#pragma mark - SCHMovePath

@implementation UIView (SCHMovePath)



- (void)setMove_path_shape_layer:(CAShapeLayer *)move_path_shape_layer
{
    [self willChangeValueForKey:@"move_path_shape_layer"];
    objc_setAssociatedObject(self, sch_move_path_shape_layer_key, move_path_shape_layer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:@"move_path_shape_layer"];
}

- (CAShapeLayer *)move_path_shape_layer
{
    return objc_getAssociatedObject(self, sch_move_path_shape_layer_key);
}

- (void)setMove_path_animation_end_block:(void (^)(id))move_path_animation_end_block
{
    [self willChangeValueForKey:@"move_path_animation_end_block"];
    objc_setAssociatedObject(self, sch_move_path_animation_end_block_key, move_path_animation_end_block, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self didChangeValueForKey:@"move_path_animation_end_block"];
}

- (void (^)(id))move_path_animation_end_block
{
    return objc_getAssociatedObject(self, sch_move_path_animation_end_block_key);
}

/**
 *  返回对应的点
 *
 *  @param rect_type 这个点的位置
 *  @param rect      view的frame
 *  @param is_above  YES: 在view 上面  NO:在view的父view 上面
 *  @param offset    相对自身体的偏移
 *  @return 返回点的位置
 */
- (CGPoint)returnPathPoint:(SCHRectPathType) rect_type rect:(CGRect) rect isAboveView: (BOOL) is_above offset: (CGFloat)offset;
{
    CGPoint point;
    
    CGRect temp_rect;
    
    temp_rect = (CGRect){offset,offset,rect.size.width - 2 * offset,rect.size.height - 2* offset};
    
    
    
    switch (rect_type)
    {
        case SCHRectLeftTopPoint:
        {
            point.x = temp_rect.origin.x ;
            point.y = temp_rect.origin.y ;
        }
            break;
        case SCHRectRightTopPoint:
        {
            point.x = temp_rect.origin.x + temp_rect.size.width ;
            point.y = temp_rect.origin.y;
        }
            break;
        case SCHRectLeftBottomPoint:
        {
            point.x = temp_rect.origin.x;
            point.y = temp_rect.origin.y + temp_rect.size.height;
        }
            break;
        case SCHRectRightBottomPoint:
        {
            point.x = temp_rect.origin.x + temp_rect.size.width;
            point.y = temp_rect.origin.y + temp_rect.size.height;
        }
            break;
            
        default:
            break;
    }
    
    return point;
}


/**
 *  开始以rect为路径的动画
 *
 *  @param point_array            经过的点
 *  @param delay                  延后的时间
 *  @param color                  线条颜色
 *  @param is_above               YES: 在view 上面  NO:在view的父view 上面
 *  @param animation_start_block  动画开始 block
 *  @param animation_end_block    动画结束 end
 */
- (void)startRectMovePathAnimationWithPassPoint: (NSArray *) point_array
                                          delay: (CGFloat)delay
                                          color: (UIColor *) color
                                    isAboveView: (BOOL) is_above
                                 animationStart: (void (^)()) animation_start_block
                                   animationEnd: (void (^)()) animation_end_block;

{
    if (point_array.count <= 1)
    {
        return;
    }
    
    if (animation_start_block)
    {
        animation_start_block();
    }
    
    if (animation_end_block)
    {
        self.move_path_animation_end_block = animation_end_block;
    }
    
    CGMutablePathRef path        = CGPathCreateMutable();
    CGPoint          move_point  =  [self returnPathPoint:[point_array[0] intValue] rect:self.frame isAboveView:is_above offset:1.0f];
    CGPathMoveToPoint(path, nil, move_point.x, move_point.y);
    
    
    for (int i = 1; i < point_array.count; ++i)
    {
        CGPoint point = [self returnPathPoint:[point_array[i] intValue] rect:self.frame isAboveView:is_above offset:1.0f];
        
        CGPathAddLineToPoint(path, nil, point.x, point.y);
    }
    
    CGRect rect = is_above?self.bounds:self.frame;
    
    /**
     *  CAShapeLayer
     */
    {
        self.move_path_shape_layer             = [CAShapeLayer layer];
        self.move_path_shape_layer.bounds      = self.bounds;
        self.move_path_shape_layer.frame       = rect;
        //        self.move_path_shape_layer.bounds      = CGRectMake(0.0f, 0.0f, self.bounds.size.width - 4, self.bounds.size.height - 4);
        //        self.move_path_shape_layer.position    = CGPointMake(rect.origin.x + rect.size.width / 2.0f , rect.origin.y + rect.size.height / 2.0f);
        self.move_path_shape_layer.lineWidth   = 2.0f;
        self.move_path_shape_layer.strokeColor = color.CGColor;
        self.move_path_shape_layer.strokeStart = 1.0f;
        self.move_path_shape_layer.strokeEnd   = 1.0f;
        self.move_path_shape_layer.fillColor   = [UIColor clearColor].CGColor;
        self.move_path_shape_layer.miterLimit  = 2;
        self.move_path_shape_layer.lineCap     = kCALineCapRound;
        self.move_path_shape_layer.lineJoin    = @"bevel";
        self.move_path_shape_layer.path        = path;
        //self.move_path_shape_layer.anchorPoint = CGPointMake(0.5f, 0.5f);
        
        // self.move_path_shape_layer.position        = self.center;
        
        if (is_above)
        {
            [self.layer addSublayer:self.move_path_shape_layer];
            
        }
        else
        {
            [self.superview.layer addSublayer:self.move_path_shape_layer];
        }
        
        CGPathRelease(path);
        
        
    }
    
    /**
     * move path animation
     */
    {
        CABasicAnimation *animation_stroke_start = [CABasicAnimation animationWithKeyPath:@"strokeStart"];
        animation_stroke_start.duration          = 1.0f;
        animation_stroke_start.fillMode          = kCAFillModeForwards;
        animation_stroke_start.repeatCount       = 0;
        animation_stroke_start.fromValue         = @(0.0f);
        animation_stroke_start.toValue           = @(.2f);
        
        //1,.17,.97,.91
        // animation_stroke_start.timingFunction    = [CAMediaTimingFunction functionWithControlPoints:1.0f :0.17f :0.97f :0.91f];
        animation_stroke_start.timingFunction    = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        
        CABasicAnimation *animation_stroke_end   = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        animation_stroke_end.duration            = 1.0f;
        animation_stroke_end.fillMode            = kCAFillModeForwards;
        animation_stroke_end.repeatCount         = 0;
        animation_stroke_end.fromValue           = @(0.0f);
        animation_stroke_end.toValue             = @(1.0f);
        
        //.06,1.16,.97,.91
        //animation_stroke_end.timingFunction      = [CAMediaTimingFunction functionWithControlPoints:0.06f :1.16f :0.97f :0.91f];
        animation_stroke_end.timingFunction      = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        
        CAAnimationGroup *animation_group   = [CAAnimationGroup animation];
        animation_group.duration            = 1.0f ;
        animation_group.repeatCount         = 1;
        animation_group.delegate            = self;
        animation_group.removedOnCompletion = NO;
        [animation_group setAnimations:@[animation_stroke_start,animation_stroke_end]];
        
        [animation_group setValue:@"sch_rect_move_path" forKey:sch_view_transform_key];
        [self.move_path_shape_layer addAnimation:animation_group forKey:@"move_path"];

    }
    
}

@end

#pragma mark -
#pragma mark - SCHViewTurningTransform

@implementation SCHTransform3DModel


@end

@implementation UIView (SCHViewTurningTransform)

- (void)setTurning_transform_animation_end_block:(void (^)(id))turning_transform_animation_end_block
{
    [self willChangeValueForKey:@"turning_transform_animation_end_block"];
    objc_setAssociatedObject(self,sch_turning_transform_animation_end_block_key, turning_transform_animation_end_block, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self didChangeValueForKey:@"turning_transform_animation_end_block"];
}

- (void(^)(id ))turning_transform_animation_end_block
{
    return objc_getAssociatedObject(self, sch_turning_transform_animation_end_block_key);
}


/**
 *
 *
 *  @param center  相机位置
 *  @param z       距离 z方向的位置
 *
 *  @return 返回变换后的 形态
 */
- (CATransform3D)SCHTransform3DMakePerspective: (CGPoint) center :(CGFloat) z
{
    CATransform3D transToCenter = CATransform3DMakeTranslation(-center.x, -center.y, 0);
    CATransform3D transBack = CATransform3DMakeTranslation(center.x, center.y, 0);
    CATransform3D scale = CATransform3DIdentity;
    scale.m34 = -1.0f/z;
    return CATransform3DConcat(CATransform3DConcat(transToCenter, scale), transBack);
}

- (CATransform3D)SCHTransform3DPerspect: (CATransform3D) transform  : (CGPoint) center :(CGFloat)z
{
    return CATransform3DConcat(transform, [self SCHTransform3DMakePerspective:center :z]);
}



/**
 *  返回改变的锚点
 *
 *  @param direction_type 锚点的方位
 *
 *  @return 返回改变的锚点
 */
- (CGPoint)returnTurningTransformAnchorPoint: (SCHTurningDirectionType) direction_type
{
    NSDictionary *dic_type;
    
    @autoreleasepool
    {
        dic_type = @{@(SCHTurningDirectionTop)   : [NSValue valueWithCGPoint:CGPointMake(0.5f,0.0f)],
                     @(SCHTurningDirectionRight) : [NSValue valueWithCGPoint:CGPointMake(1.0f,0.5f)],
                     @(SCHTurningDirectionBottom): [NSValue valueWithCGPoint:CGPointMake(0.5f,1.0f)],
                     @(SCHTurningDirectionLeft)  : [NSValue valueWithCGPoint:CGPointMake(0.0f,0.5f)]};
    }
    
    return [[dic_type objectForKey:@(direction_type)] CGPointValue];
 
}

- (void)changeViewFrameFromPoint: (CGPoint) from_point toPoint: (CGPoint) to_point
{
    CGRect  rect           = self.frame;
    CGFloat x              = (to_point.x - from_point.x) * rect.size.width  + rect.origin.x;
    CGFloat y              = (to_point.y - from_point.y) * rect.size.height  + rect.origin.y;
    rect.origin.x          = x;
    rect.origin.y          = y;
    
    self.frame             = rect;
}

/**
 *  对指定点摇摆的动画
 *
 *  @param direction_type                    锚点方向
 *  @param is_from_front                     YES: 从前方出现 NO: 从后背出现
 *  @param transform_animation_start_block   动画开始
 *  @param transform_animation_end_block     动画结束
 */
- (void)startTurningTransformAnimationWithAnchorPointDirection: (SCHTurningDirectionType) direction_type
                                                   frontOrBack: (BOOL) is_from_front
                                                animationStart: (void (^)(id object)) transform_animation_start_block
                                                  animationEnd: (void (^)(id object)) transform_animation_end_block
{

    NSMutableArray *path_array = [[NSMutableArray alloc] init];
    @autoreleasepool
    {
        NSArray        *array;
        NSArray        *times;
        if (is_from_front)
        {
            array = @[@(M_PI/2.0f),@(-M_PI/10.0f),@(0.0f)];
        }
        else
        {
            array = @[@(-M_PI/2.0f),@(M_PI/10.0f),@(0.0f)];
        }
        times  = @[@(.1f),@(.05f)];
        
        CGFloat x = (direction_type%3)?0.0f:1.0f;
        CGFloat y = (direction_type%3)?1.0f:0.0f;
    
        for (int i = 0; i < array.count - 1 ; ++i)
        {
            
            SCHTransform3DModel *model = [[SCHTransform3DModel alloc] init];
            model.from_value           = [NSValue valueWithCATransform3D:[self SCHTransform3DPerspect:CATransform3DMakeRotation([array[i] floatValue], x, y, 0) :CGPointMake(0.5, 0.5) :600.0f]];
            model.to_value             = [NSValue valueWithCATransform3D:[self SCHTransform3DPerspect:CATransform3DMakeRotation([array[i +1] floatValue], x, y, 0) :CGPointMake(0.5, 0.5) :600.0f]];
            model.duration             = [times[i] floatValue];
            
            
            [path_array addObject:model];
        }
    }
    
    
    [self startTurningTransformAnimationWithAnchorPointDirection:direction_type transform3DPerspectArray:path_array animationStart:transform_animation_start_block animationEnd:transform_animation_end_block];
    
    
}

/**
 * 对指定点摇摆的动画
 *
 *  @param direction_type                    锚点方向
 *  @param array                             摇摆的路径的 array
 *  @param transform_animation_start_block   动画开始
 *  @param transform_animation_end_block     动画结束
 */
- (void)startTurningTransformAnimationWithAnchorPointDirection: (SCHTurningDirectionType) direction_type
                                      transform3DPerspectArray: (NSArray *) array
                                                animationStart: (void (^)(id object)) transform_animation_start_block
                                                  animationEnd: (void (^)(id object)) transform_animation_end_block
{
    
    {
        self.layer.anchorPoint = [self returnTurningTransformAnchorPoint:direction_type];
        [self changeViewFrameFromPoint:CGPointMake(0.5f, 0.5f) toPoint:self.layer.anchorPoint];

    }
  
    if (transform_animation_start_block)
    {
        transform_animation_start_block(self);
    }
    
    self.turning_transform_animation_end_block = transform_animation_end_block;
    
    
    
    NSMutableArray *animation_array = [[NSMutableArray alloc] init];
    
    CGFloat begin_time = 0.0f;
    @autoreleasepool
    {
        for (SCHTransform3DModel *model in array)
        {
            CABasicAnimation *animation   = [CABasicAnimation animationWithKeyPath:@"transform"];
            animation.fillMode            = kCAFillModeForwards;
            animation.fromValue           = model.from_value;
            animation.toValue             = model.to_value;
            animation.beginTime           = begin_time;
            animation.duration            = model.duration;
            animation.repeatCount         = 1;
            animation.removedOnCompletion = NO;
            animation.timingFunction      = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            
            begin_time += model.duration;
           
            [animation_array addObject:animation];
        }
    }
    
    @autoreleasepool
    {
        CAAnimationGroup *animation_group   = [CAAnimationGroup animation];
        animation_group.animations          = animation_array;
        animation_group.duration            = begin_time;
        animation_group.fillMode            = kCAFillModeForwards;
        animation_group.removedOnCompletion = NO;
        animation_group.repeatCount         = 1;
        animation_group.delegate            = self;
     
       
        [animation_group setValue:@"sch_turing_path" forKey:sch_view_transform_key];
        [self.layer addAnimation:animation_group forKey:@"turing_transform"];
    }
  
    
}


@end


#pragma mark -
#pragma mark - SCHViewTransform

@interface UIView(SCHViewTransform)



@end


@implementation UIView (SCHViewTransform)

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{

    NSString *value = [anim valueForKey:sch_view_transform_key];
    
    if ([value isEqualToString:@"sch_rect_move_path"])
    {
        [self.move_path_shape_layer removeFromSuperlayer];
        self.move_path_shape_layer = nil;
        
        if (self.move_path_animation_end_block)
        {
            self.move_path_animation_end_block(anim);
            
            self.move_path_animation_end_block = nil;
        }
    }
    else if([value isEqualToString:@"sch_scale_path"])
    {
        if (self.scale_transform_animation_end_block)
        {
            self.scale_transform_animation_end_block(anim);
            
            self.scale_transform_animation_end_block = nil;
        }
    }
    else if([value isEqualToString:@"sch_turing_path"])
    {
        CGPoint point = self.layer.anchorPoint;
        self.layer.anchorPoint = CGPointMake(0.5f, 0.5f);
        
        [self changeViewFrameFromPoint:point toPoint: CGPointMake(0.5f, 0.5f)];
        
        if (self.turning_transform_animation_end_block)
        {
            self.turning_transform_animation_end_block(anim);
            self.turning_transform_animation_end_block = nil;
            
        }
    }
    

}

- (void)animationDidStart:(CAAnimation *)anim
{
    
}


@end
















