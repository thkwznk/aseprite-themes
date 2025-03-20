local InputDirectoryPath = app.params["input"]

function ColorToHex(color)
    return string.format("#%02x%02x%02x", color.red, color.green, color.blue)
end

function CopyColor(originalColor)
    return Color {
        red = originalColor.red,
        green = originalColor.green,
        blue = originalColor.blue,
        alpha = originalColor.alpha
    }
end

function RgbaPixelToColor(rgbaPixel)
    return Color {
        red = app.pixelColor.rgbaR(rgbaPixel),
        green = app.pixelColor.rgbaG(rgbaPixel),
        blue = app.pixelColor.rgbaB(rgbaPixel),
        alpha = app.pixelColor.rgbaA(rgbaPixel)
    }
end

function ReadAll(filePath)
    local file = assert(io.open(filePath, "rb"))
    local content = file:read("*all")
    file:close()
    return content
end

function WriteAll(filePath, content)
    local file = io.open(filePath, "w")
    if file then
        file:write(content)
        file:close()
    end
end

function UpdateThemeXml(theme, templatePath, outputPath)
    -- Prepare theme.xml
    local xmlContent = ReadAll(templatePath)

    for id, color in pairs(theme.colors) do
        xmlContent = xmlContent:gsub("\"" .. id .. "\"",
                                     "\"" .. ColorToHex(color) .. "\"")
    end

    WriteAll(outputPath, xmlContent)
end

function CopySheetData(templatePath, outputPath)
    local content = ReadAll(templatePath)
    WriteAll(outputPath, content)
end

function GenerateVariant(template, theme, templateDirectory, outputDirectory)
    if not app.fs.isDirectory(outputDirectory) then
        app.fs.makeDirectory(outputDirectory)
    end

    local templateSheetPath = app.fs.joinPath(templateDirectory, "sheet.png")
    local templateXmlPath = app.fs.joinPath(templateDirectory, "theme.xml")
    local templateSheetDataPath = app.fs.joinPath(templateDirectory,
                                                  "sheet.aseprite-data")

    local outputSheetPath = app.fs.joinPath(outputDirectory, "sheet.png")
    local outputXmlPath = app.fs.joinPath(outputDirectory, "theme.xml")
    local outputSheetDataPath = app.fs.joinPath(outputDirectory,
                                                "sheet.aseprite-data")

    -- Prepare color lookup
    local Map = {}

    for id, templateColor in pairs(template.colors) do
        -- Map the template color to the theme color
        Map[ColorToHex(templateColor)] = theme.colors[id]
    end

    -- Prepare sheet.png
    local image = Image {fromFile = templateSheetPath}
    local pixelValue, newColor, pixelData, pixelColor, pixelValueKey,
          resultColor

    -- Save references to function to improve performance
    local getPixel, drawPixel = image.getPixel, image.drawPixel

    local cache = {}

    for x = 0, image.width - 1 do
        for y = 0, image.height - 1 do
            pixelValue = getPixel(image, x, y)

            if pixelValue > 0 then
                pixelValueKey = tostring(pixelValue)
                pixelData = cache[pixelValueKey]

                if not pixelData then
                    pixelColor = RgbaPixelToColor(pixelValue)

                    cache[pixelValueKey] = {
                        id = ColorToHex(pixelColor),
                        color = pixelColor
                    }

                    pixelData = cache[pixelValueKey]
                end

                resultColor = Map[pixelData.id]

                if resultColor ~= nil then
                    newColor = CopyColor(resultColor)
                    newColor.alpha = pixelData.color.alpha -- Restore the original alpha value

                    drawPixel(image, x, y, newColor)
                end
            end
        end
    end

    image:saveAs(outputSheetPath)

    -- Update the XML theme file
    UpdateThemeXml(theme, templateXmlPath, outputXmlPath)

    -- Copy the sheet Aseprite data
    CopySheetData(templateSheetDataPath, outputSheetDataPath)
end

local template = {
    colors = {
        ["BUTTON_SHADOW"] = Color {
            red = 255,
            green = 0,
            blue = 255,
            alpha = 255
        },
        ["BUTTON_REGULAR"] = Color {red = 255, green = 0, blue = 0, alpha = 255},
        ["BUTTON_HIGHLIGHT"] = Color {
            red = 255,
            green = 255,
            blue = 0,
            alpha = 255
        },
        ["WINDOW_TITLEBAR"] = Color {
            red = 0,
            green = 0,
            blue = 255,
            alpha = 255
        },
        ["LINK"] = Color {red = 0, green = 0, blue = 168, alpha = 255},
        ["TEXT_REGULAR"] = Color {red = 0, green = 255, blue = 255, alpha = 255},
        ["BACKGROUND"] = Color {red = 120, green = 96, blue = 80, alpha = 255},
        ["WHITE"] = Color {red = 255, green = 255, blue = 255, alpha = 255},
        ["BLACK"] = Color {red = 0, green = 0, blue = 0, alpha = 255},
        ["EYE"] = Color {red = 255, green = 0, blue = 129, alpha = 255},

        -- TODO: Add a template color for the input background + mask it in the sheet.png

        -- Dark Variants Only
        ["LIGHT_ICONS"] = Color {red = 0, green = 128, blue = 128, alpha = 255},

        -- Dark Variants Only
        ["DARK_ACCENT_HIGHLIGHT"] = Color {
            red = 128,
            green = 255,
            blue = 0,
            alpha = 255
        },
        ["DARK_ACCENT_REGULAR"] = Color {
            red = 128,
            green = 192,
            blue = 0,
            alpha = 255
        },
        ["DARK_ACCENT_SHADOW"] = Color {
            red = 128,
            green = 128,
            blue = 0,
            alpha = 255
        }
    }
}

local variants = {
    default = {
        colors = {
            ["BUTTON_SHADOW"] = Color {
                red = 128,
                green = 128,
                blue = 128,
                alpha = 255
            },
            ["BUTTON_REGULAR"] = Color {
                red = 192,
                green = 192,
                blue = 192,
                alpha = 255
            },
            ["BUTTON_HIGHLIGHT"] = Color {
                red = 255,
                green = 255,
                blue = 255,
                alpha = 255
            },
            ["WINDOW_TITLEBAR"] = Color {
                red = 0,
                green = 0,
                blue = 168,
                alpha = 255
            },
            ["LINK"] = Color {red = 0, green = 0, blue = 168, alpha = 255},
            ["LINK_HOVER"] = Color {
                red = 255,
                green = 0,
                blue = 128,
                alpha = 255
            },
            ["BACKGROUND"] = Color {
                red = 128,
                green = 128,
                blue = 128,
                alpha = 255
            }
        }
    },
    teal = {
        colors = {
            ["BUTTON_SHADOW"] = Color {
                red = 128,
                green = 128,
                blue = 128,
                alpha = 255
            },
            ["BUTTON_REGULAR"] = Color {
                red = 192,
                green = 192,
                blue = 192,
                alpha = 255
            },
            ["BUTTON_HIGHLIGHT"] = Color {
                red = 255,
                green = 255,
                blue = 255,
                alpha = 255
            },
            ["WINDOW_TITLEBAR"] = Color {
                red = 0,
                green = 128,
                blue = 128,
                alpha = 255
            },
            ["LINK"] = Color {red = 0, green = 128, blue = 128, alpha = 255},
            ["LINK_HOVER"] = Color {
                red = 255,
                green = 0,
                blue = 128,
                alpha = 255
            },
            ["BACKGROUND"] = Color {
                red = 128,
                green = 128,
                blue = 128,
                alpha = 255
            },
            ["LIGHT_ICONS"] = Color {
                red = 0,
                green = 128,
                blue = 208,
                alpha = 255
            }
        }
    },
    desert = {
        colors = {
            ["BUTTON_SHADOW"] = Color {
                red = 160,
                green = 143,
                blue = 104,
                alpha = 255
            },
            ["BUTTON_REGULAR"] = Color {
                red = 215,
                green = 207,
                blue = 184,
                alpha = 255
            },
            ["BUTTON_HIGHLIGHT"] = Color {
                red = 232,
                green = 231,
                blue = 223,
                alpha = 255
            },
            ["WINDOW_TITLEBAR"] = Color {
                red = 0,
                green = 128,
                blue = 128,
                alpha = 255
            },
            ["LINK"] = Color {red = 0, green = 128, blue = 128, alpha = 255},
            ["LINK_HOVER"] = Color {
                red = 255,
                green = 255,
                blue = 255,
                alpha = 255
            },
            ["BACKGROUND"] = Color {
                red = 160,
                green = 143,
                blue = 104,
                alpha = 255
            },
            ["EYE"] = Color {red = 0, green = 192, blue = 255, alpha = 255},
            ["LIGHT_ICONS"] = Color {
                red = 0,
                green = 192,
                blue = 255,
                alpha = 255
            }
        }
    },
    spruce = {
        colors = {
            ["BUTTON_SHADOW"] = Color {
                red = 88,
                green = 151,
                blue = 103,
                alpha = 255
            },
            ["BUTTON_REGULAR"] = Color {
                red = 160,
                green = 200,
                blue = 168,
                alpha = 255
            },
            ["BUTTON_HIGHLIGHT"] = Color {
                red = 208,
                green = 224,
                blue = 208,
                alpha = 255
            },
            ["WINDOW_TITLEBAR"] = Color {
                red = 88,
                green = 151,
                blue = 103,
                alpha = 255
            },
            ["LINK"] = Color {red = 168, green = 0, blue = 255, alpha = 255},
            ["LINK_HOVER"] = Color {
                red = 255,
                green = 255,
                blue = 255,
                alpha = 255
            },
            ["BACKGROUND"] = Color {red = 64, green = 0, blue = 64, alpha = 255},
            ["EYE"] = Color {red = 255, green = 96, blue = 192, alpha = 255},
            ["LIGHT_ICONS"] = Color {
                red = 255,
                green = 96,
                blue = 192,
                alpha = 255
            }
        }
    },
    eggplant = {
        colors = {
            ["BUTTON_SHADOW"] = Color {
                red = 88,
                green = 128,
                blue = 120,
                alpha = 255
            },
            ["BUTTON_REGULAR"] = Color {
                red = 144,
                green = 176,
                blue = 168,
                alpha = 255
            },
            ["BUTTON_HIGHLIGHT"] = Color {
                red = 200,
                green = 216,
                blue = 216,
                alpha = 255
            },
            ["WINDOW_TITLEBAR"] = Color {
                red = 168,
                green = 0,
                blue = 168,
                alpha = 255
            },
            ["LINK"] = Color {red = 168, green = 0, blue = 168, alpha = 255},
            ["LINK_HOVER"] = Color {
                red = 255,
                green = 255,
                blue = 255,
                alpha = 255
            },
            ["BACKGROUND"] = Color {red = 64, green = 0, blue = 64, alpha = 255},
            ["EYE"] = Color {red = 255, green = 96, blue = 192, alpha = 255},
            ["LIGHT_ICONS"] = Color {
                red = 255,
                green = 96,
                blue = 192,
                alpha = 255
            }
        }
    },
    slate = {
        colors = {
            ["BUTTON_SHADOW"] = Color {
                red = 87,
                green = 128,
                blue = 151,
                alpha = 255
            },
            ["BUTTON_REGULAR"] = Color {
                red = 159,
                green = 184,
                blue = 200,
                alpha = 255
            },
            ["BUTTON_HIGHLIGHT"] = Color {
                red = 207,
                green = 223,
                blue = 224,
                alpha = 255
            },
            ["WINDOW_TITLEBAR"] = Color {
                red = 87,
                green = 128,
                blue = 151,
                alpha = 255
            },
            ["LINK"] = Color {red = 255, green = 224, blue = 0, alpha = 255},
            ["LINK_HOVER"] = Color {
                red = 255,
                green = 255,
                blue = 255,
                alpha = 255
            },
            ["BACKGROUND"] = Color {red = 0, green = 0, blue = 0, alpha = 255},
            ["EYE"] = Color {red = 255, green = 128, blue = 0, alpha = 255},
            ["LIGHT_ICONS"] = Color {
                red = 255,
                green = 128,
                blue = 0,
                alpha = 255
            }
        }
    },
    ["rainy-day"] = {
        colors = {
            ["BUTTON_SHADOW"] = Color {
                red = 79,
                green = 103,
                blue = 127,
                alpha = 255
            },
            ["BUTTON_REGULAR"] = Color {
                red = 128,
                green = 152,
                blue = 176,
                alpha = 255
            },
            ["BUTTON_HIGHLIGHT"] = Color {
                red = 192,
                green = 207,
                blue = 216,
                alpha = 255
            },
            ["WINDOW_TITLEBAR"] = Color {
                red = 0,
                green = 0,
                blue = 0,
                alpha = 255
            },
            ["LINK"] = Color {red = 255, green = 192, blue = 0, alpha = 255},
            ["LINK_HOVER"] = Color {
                red = 255,
                green = 255,
                blue = 255,
                alpha = 255
            },
            ["BACKGROUND"] = Color {red = 0, green = 0, blue = 0, alpha = 255},
            ["EYE"] = Color {red = 255, green = 128, blue = 0, alpha = 255},
            ["LIGHT_ICONS"] = Color {
                red = 255,
                green = 128,
                blue = 0,
                alpha = 255
            }
        }
    },
    lilac = {
        colors = {
            ["BUTTON_SHADOW"] = Color {
                red = 88,
                green = 79,
                blue = 176,
                alpha = 255
            },
            ["BUTTON_REGULAR"] = Color {
                red = 175,
                green = 168,
                blue = 216,
                alpha = 255
            },
            ["BUTTON_HIGHLIGHT"] = Color {
                red = 216,
                green = 215,
                blue = 239,
                alpha = 255
            },
            ["WINDOW_TITLEBAR"] = Color {
                red = 88,
                green = 79,
                blue = 176,
                alpha = 255
            },
            ["LINK"] = Color {red = 168, green = 255, blue = 0, alpha = 255},
            ["LINK_HOVER"] = Color {
                red = 255,
                green = 255,
                blue = 255,
                alpha = 255
            },
            ["BACKGROUND"] = Color {
                red = 128,
                green = 128,
                blue = 128,
                alpha = 255
            },
            ["EYE"] = Color {red = 80, green = 224, blue = 0, alpha = 255},
            ["LIGHT_ICONS"] = Color {
                red = 80,
                green = 224,
                blue = 0,
                alpha = 255
            }
        }
    },
    rose = {
        colors = {
            ["BUTTON_SHADOW"] = Color {
                red = 159,
                green = 96,
                blue = 112,
                alpha = 255
            },
            ["BUTTON_REGULAR"] = Color {
                red = 207,
                green = 175,
                blue = 183,
                alpha = 255
            },
            ["BUTTON_HIGHLIGHT"] = Color {
                red = 231,
                green = 216,
                blue = 223,
                alpha = 255
            },
            ["WINDOW_TITLEBAR"] = Color {
                red = 159,
                green = 96,
                blue = 112,
                alpha = 255
            },
            ["LINK"] = Color {red = 160, green = 240, blue = 224, alpha = 255},
            ["LINK_HOVER"] = Color {
                red = 255,
                green = 255,
                blue = 255,
                alpha = 255
            },
            ["BACKGROUND"] = Color {
                red = 128,
                green = 128,
                blue = 128,
                alpha = 255
            },
            ["EYE"] = Color {red = 48, green = 224, blue = 255, alpha = 255},
            ["LIGHT_ICONS"] = Color {
                red = 48,
                green = 224,
                blue = 255,
                alpha = 255
            }
        }
    }
}

local templateDirectoryPath = app.fs.joinPath(InputDirectoryPath, "template")

for id, data in pairs(variants) do
    GenerateVariant(template, data, templateDirectoryPath,
                    app.fs.joinPath(InputDirectoryPath, id))
end

local darkVariants = {
    midnight = {
        colors = {
            ["BUTTON_SHADOW"] = Color {
                red = 37,
                green = 37,
                blue = 37,
                alpha = 255
            },
            ["BUTTON_REGULAR"] = Color {
                red = 59,
                green = 59,
                blue = 59,
                alpha = 255
            },
            ["BUTTON_HIGHLIGHT"] = Color {
                red = 88,
                green = 88,
                blue = 88,
                alpha = 255
            },
            ["WINDOW_TITLEBAR"] = Color {
                red = 0,
                green = 0,
                blue = 0,
                alpha = 255
            },
            ["LINK"] = Color {red = 43, green = 123, blue = 244, alpha = 255},
            ["LINK_HOVER"] = Color {
                red = 255,
                green = 255,
                blue = 255,
                alpha = 255
            },
            ["TEXT_REGULAR"] = Color {
                red = 128,
                green = 128,
                blue = 128,
                alpha = 255
            },
            ["TEXT_HOVER"] = Color {
                red = 255,
                green = 255,
                blue = 255,
                alpha = 255
            },
            ["INPUT_BACKGROUND"] = Color {
                red = 0,
                green = 0,
                blue = 0,
                alpha = 255
            },
            ["BACKGROUND"] = Color {red = 37, green = 37, blue = 37, alpha = 37},
            ["DARK_ACCENT_HIGHLIGHT"] = Color {
                red = 43,
                green = 123,
                blue = 244,
                alpha = 255
            },
            ["DARK_ACCENT_REGULAR"] = Color {
                red = 21,
                green = 61,
                blue = 122,
                alpha = 255
            },
            ["DARK_ACCENT_SHADOW"] = Color {
                red = 37,
                green = 37,
                blue = 37,
                alpha = 255
            }
        }
    },
    gruvbox = {
        colors = {
            ["BUTTON_SHADOW"] = Color {
                red = 40,
                green = 40,
                blue = 40,
                alpha = 255
            },
            ["BUTTON_REGULAR"] = Color {
                red = 60,
                green = 56,
                blue = 54,
                alpha = 255
            },
            ["BUTTON_HIGHLIGHT"] = Color {
                red = 80,
                green = 73,
                blue = 69,
                alpha = 255
            },
            ["WINDOW_TITLEBAR"] = Color {
                red = 214,
                green = 93,
                blue = 14,
                alpha = 255
            },
            ["LINK"] = Color {red = 69, green = 133, blue = 136, alpha = 255},
            ["LINK_HOVER"] = Color {
                red = 131,
                green = 165,
                blue = 152,
                alpha = 255
            },
            ["TEXT_REGULAR"] = Color {
                red = 168,
                green = 153,
                blue = 132,
                alpha = 255
            },
            ["TEXT_HOVER"] = Color {
                red = 235,
                green = 219,
                blue = 178,
                alpha = 255
            },
            ["INPUT_BACKGROUND"] = Color {
                red = 29,
                green = 32,
                blue = 33,
                alpha = 255
            },
            ["BACKGROUND"] = Color {
                red = 29,
                green = 32,
                blue = 33,
                alpha = 255
            },
            ["DARK_ACCENT_HIGHLIGHT"] = Color {
                red = 69,
                green = 133,
                blue = 136,
                alpha = 255
            },
            ["DARK_ACCENT_REGULAR"] = Color {
                red = 7,
                green = 102,
                blue = 120,
                alpha = 255
            },
            ["DARK_ACCENT_SHADOW"] = Color {
                red = 80,
                green = 73,
                blue = 69,
                alpha = 255
            },
            ["WHITE"] = Color {red = 235, green = 219, blue = 178, alpha = 255},
            ["BLACK"] = Color {red = 29, green = 32, blue = 33, alpha = 255},
            ["EYE"] = Color {red = 69, green = 133, blue = 136, alpha = 255}
        }
    }
}

local darkTemplateDirectoryPath = app.fs.joinPath(InputDirectoryPath,
                                                  "template-dark")

for id, data in pairs(darkVariants) do
    GenerateVariant(template, data, darkTemplateDirectoryPath,
                    app.fs.joinPath(InputDirectoryPath, id))
end
