#version 150

layout(std140) uniform LightmapInfo {
    float AmbientLightFactor;
    float SkyFactor;
    float BlockFactor;
    int UseBrightLightmap;
    float NightVisionFactor;
    float DarknessScale;
    float DarkenWorldFactor;
    float BrightnessFactor;
    vec3 SkyLightColor;
} lightmapInfo;

in vec2 texCoord;

out vec4 fragColor;

float get_brightness(float level) {
    float curved_level = level / (4.0 - 3.0 * level);
    return mix(curved_level, 1.0, lightmapInfo.AmbientLightFactor);
}

float brightness_curve(float x) {
    return 1.0 + pow(x - 1.0, 3.0);
}

#define saturate(x) (clamp((x), 0.0, 1.0))

void main() {
    /* get block and sky brightness, add them both */
    float block_brightness = get_brightness(floor(texCoord.x * 16) / 15) * lightmapInfo.BlockFactor;
    float sky_brightness = get_brightness(floor(texCoord.y * 16) / 15) * lightmapInfo.SkyFactor;
    float brightness = saturate(sky_brightness + block_brightness);

    if(lightmapInfo.UseBrightLightmap == 0) {
        /* darken if needed */
        float dark = brightness * 0.633;
        brightness = mix(brightness, dark, lightmapInfo.DarkenWorldFactor);       
    }

    /* night vision */
    brightness = mix(brightness, 1.0, lightmapInfo.NightVisionFactor);
    /* darken more, apparently... */
    brightness = saturate(brightness - lightmapInfo.DarknessScale);

    /* user brightness scale */
    float user_brightness = lightmapInfo.BrightnessFactor * (8.0 / 9.0);

    
    float alt = brightness_curve(brightness);
    brightness = mix(brightness, alt, user_brightness);
    brightness = saturate(brightness);

    /* return */
    fragColor = vec4(vec3(brightness), 1.0);
}
