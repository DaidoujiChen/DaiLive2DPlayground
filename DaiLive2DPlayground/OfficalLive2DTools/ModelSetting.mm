/*
 *
 *  You can modify and use this source freely
 *  only for the development of application related Live2D.
 *
 *  (c) Live2D Inc. All rights reserved.
 *
 *  Modify By DaidoujiChen https://github.com/DaidoujiChen
 *
 */

#import "ModelSetting.h"

static NSString *NAME                     = @"name";
static NSString *MODEL                    = @"model";
static NSString *ID                       = @"id";
static NSString *TEXTURES                 = @"textures";
static NSString *INIT_PARAM               = @"init_param";
static NSString *INIT_PARTS_VISIBLE       = @"init_parts_visible";
static NSString *HIT_AREAS                = @"hit_areas";
static NSString *EXPRESSIONS              = @"expressions";
static NSString *POSE                     = @"pose";
static NSString *PHYSICS                  = @"physics";
static NSString *MOTION_GROUPS            = @"motions";
static NSString *SOUND                    = @"sound";
static NSString *FADE_IN                  = @"fade_in";
static NSString *FADE_OUT                 = @"fade_out";
static NSString *VAL                      = @"val";
static NSString *LAYOUT                   = @"layout";
static NSString *FILENAME                 = @"file";

@interface ModelSetting ()

@property (nonatomic, strong) NSDictionary *json;

@end

@implementation ModelSetting

#pragma mark - Readonly Property

- (const char *)modelName {
    return [self.json[NAME] UTF8String] ? : "";
}

- (const char *)modelFile {
    return [self.json[MODEL] UTF8String] ? : "";
}

- (int)textureCount {
    NSArray *textures = self.json[TEXTURES];
    return textures ? (int)textures.count : 0;
}

- (int)initParamCount {
    NSArray *parameters = self.json[INIT_PARAM];
    return parameters ? (int)parameters.count : 0;
}

- (int)initPartsVisibleCount {
    NSArray *parts = self.json[INIT_PARTS_VISIBLE];
    return parts ? (int)parts.count : 0;
}

- (int)hitAreasCount {
    NSArray *areas = self.json[HIT_AREAS];
    return areas ? (int)areas.count : 0;
}

- (const char *)physicsFile {
    return [self.json[PHYSICS] UTF8String] ? : "";
}

- (const char *)poseFile {
    return [self.json[POSE] UTF8String] ? : "";
}

- (int)expressionCount {
    NSArray *expressions = self.json[EXPRESSIONS];
    return expressions ? (int)expressions.count : 0;
}

- (int)motionGroupCount {
    NSDictionary *motionGroups = self.json[MOTION_GROUPS];
    return motionGroups ? (int)motionGroups.count : 0;
}

#pragma mark - Instance Method

- (const char *)textureAtIndex:(int)index {
    NSArray *textures = self.json[TEXTURES];
    if (index >= textures.count) {
        return "";
    }
    NSString *texture = textures[index];
    return texture.UTF8String ? : "";
}

- (float)initParamValueAtIndex:(int)index {
    NSNumber *value = self.json[INIT_PARAM][index][VAL];
    return value ? value.floatValue : 0;
}

- (const char *)initParamIDAtIndex:(int)index {
    NSString *parameterID = self.json[INIT_PARAM][index][ID];
    return parameterID.UTF8String ? : "";
}

- (float)initPartsVisibleValueAtIndex:(int)index {
    NSNumber *value = self.json[INIT_PARTS_VISIBLE][index][VAL];
    return value ? value.floatValue : 0;
}

- (const char *)initPartsVisibleIDAtIndex:(int)index {
    NSString *visibleID = self.json[INIT_PARTS_VISIBLE][index][ID];
    return visibleID.UTF8String ? : "";
}

- (const char *)hitAreaIDAtIndex:(int)index {
    NSString *areaID = self.json[HIT_AREAS][index][ID];
    return areaID.UTF8String ? : "";
}

- (const char *)hitAreaNameAtIndex:(int)index {
    NSString *areaName = self.json[HIT_AREAS][index][NAME];
    return areaName.UTF8String ? : "";
}

- (const char *)expressionFileAtIndex:(int)index {
    NSString *file = self.json[EXPRESSIONS][index][FILENAME];
    return file.UTF8String ? : "";
}

- (const char *)expressionNameAtIndex:(int)index {
    NSString *name = self.json[EXPRESSIONS][index][NAME];
    return name.UTF8String ? : "";
}

- (int)motionCountByName:(const char *)name {
    NSArray *motions = self.json[MOTION_GROUPS][[NSString stringWithCString:name encoding:NSUTF8StringEncoding]];
    return motions ? (int)motions.count : 0;
}

- (const char *)motionFileByName:(const char *)name atIndex:(int)index {
    NSArray *motions = self.json[MOTION_GROUPS][[NSString stringWithCString:name encoding:NSUTF8StringEncoding]];
    if (index >= motions.count) {
        return "";
    }
    NSString *file = motions[index][FILENAME];
    return file.UTF8String ? : "";
}

- (const char *)motionSoundByName:(const char*)name atIndex:(int)index {
    NSArray *sounds = self.json[MOTION_GROUPS][[NSString stringWithCString:name encoding:NSUTF8StringEncoding]];
    if (index >= sounds.count) {
        return "";
    }
    NSString *sound = sounds[index][SOUND];
    return sound.UTF8String ? : "";
}

- (int)motionFadeInByName:(const char*)name atIndex:(int)index {
    NSArray *motions = self.json[MOTION_GROUPS][[NSString stringWithCString:name encoding:NSUTF8StringEncoding]];
    if (index >= motions.count) {
        return 1000;
    }
    NSNumber *fadeIn = motions[index][FADE_IN];
    return fadeIn ? (int)fadeIn.integerValue : 1000;
}

- (int)motionFadeOutByName:(const char*)name atIndex:(int)index {
    NSArray *motions = self.json[MOTION_GROUPS][[NSString stringWithCString:name encoding:NSUTF8StringEncoding]];
    if (index >= motions.count) {
        return 1000;
    }
    NSNumber *fadeIn = motions[index][FADE_OUT];
    return fadeIn ? (int)fadeIn.integerValue : 1000;
}

- (const char *)motionGroupNameAtIndex:(int)index {
    NSDictionary *motionGroups = self.json[MOTION_GROUPS];
    if (motionGroups) {
        if (index >= motionGroups.count) {
            return "";
        }
        else {
            return [motionGroups.allKeys[index] UTF8String] ? : "";
        }
    }
    else {
        return "";
    }
}

- (BOOL)layout:(std::map<std::string, float>&)layout {
    NSDictionary *map = self.json[LAYOUT];
    if (map) {
        for (NSString *mapKey in map.allKeys) {
            layout[mapKey.UTF8String] = [map[mapKey] floatValue];
        }
        return YES;
    }
    else {
        return NO;
    }
}

#pragma mark - Life Cycle

- (id)initWithData:(NSData *)jsonData {
    self = [super init];
    if (self) {
        NSError *jsonError;
        self.json = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&jsonError];
        if (jsonError) {
            return nil;
        }
    }
    return self;
}

@end
