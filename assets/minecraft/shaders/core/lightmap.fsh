/* NOTICE: most of this is NOT MY CODE!! This is modified Mojang shader code!!! I DO NOT CLAIM I OWN THIS!!!!! */

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

float cbrt(float x) {
    return pow(x, (1.0 / 3.0));
}

/* Credit to https://stackoverflow.com/questions/596216/formula-to-determine-perceived-brightness-of-rgb-color for giving a formula for this impl */

float srgb2lin_1c(float inp) {
    if(inp <= 0.04045) {
        return inp / 12.92;
    }
    return pow((inp + 0.055) / 1.055, 2.4);
}

vec3 srgb2lin(vec3 inp) {
    return vec3(srgb2lin_1c(inp.r), srgb2lin_1c(inp.g), srgb2lin_1c(inp.b));
}

float lum_from_lin(vec3 inp) {
    return (inp.r * 0.2126) + (inp.g * 0.7152) + (inp.b * 0.0722);
}

float true_lum_from_lum(float y) {
    if(y <= 0.008856) {
        return 903.3 * y;
    }
    return (116 * cbrt(y)) - 16;
} 

float luma(vec3 inp) {
    vec3 lin = srgb2lin(inp);
    float y = lum_from_lin(lin);
    float lum = true_lum_from_lum(y);
    return (lum / 100.0);
}


vec3 notGamma(vec3 x) {
    vec3 nx = 1.0 - x;
    return 1.0 - nx * nx * nx * nx;
}

void main() {
    float block_brightness = get_brightness(floor(texCoord.x * 16) / 15) * lightmapInfo.BlockFactor;
    float sky_brightness = get_brightness(floor(texCoord.y * 16) / 15) * lightmapInfo.SkyFactor;

    // cubic nonsense, dips to yellowish in the middle, white when fully saturated
    vec3 color = vec3(
        block_brightness,
        block_brightness * ((block_brightness * 0.6 + 0.4) * 0.6 + 0.4),
        block_brightness * (block_brightness * block_brightness * 0.6 + 0.4)
    );

    if (lightmapInfo.UseBrightLightmap != 0) {
        color = mix(color, vec3(0.99, 1.12, 1.0), 0.25);
        color = clamp(color, 0.0, 1.0);
    } else {
        color += lightmapInfo.SkyLightColor * sky_brightness;
        color = mix(color, vec3(0.75), 0.04);

        vec3 darkened_color = color * vec3(0.7, 0.6, 0.6);
        color = mix(color, darkened_color, lightmapInfo.DarkenWorldFactor);
    }

    if (lightmapInfo.NightVisionFactor > 0.0) {
        // scale up uniformly until 1.0 is hit by one of the colors
        float max_component = max(color.r, max(color.g, color.b));
        if (max_component < 1.0) {
            vec3 bright_color = color / max_component;
            color = mix(color, bright_color, lightmapInfo.NightVisionFactor);
        }
    }

    if (lightmapInfo.UseBrightLightmap == 0) {
        color = clamp(color - vec3(lightmapInfo.DarknessScale), 0.0, 1.0);
    }

    vec3 notGamma = notGamma(color);
    color = mix(color, notGamma, lightmapInfo.BrightnessFactor);
    color = mix(color, vec3(0.75), 0.04);
    color = clamp(color, 0.0, 1.0);
    color = vec3(luma(color));

    fragColor = vec4(color, 1.0);
}
