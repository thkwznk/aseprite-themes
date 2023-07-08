local InputDirectoryPath =
    "C:\\Users\\kacwo\\Documents\\GitHub\\aseprite-themes\\Aseprite 95" -- TODO: Get this from a parameter

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
        xmlContent = xmlContent:gsub("<" .. id .. ">", ColorToHex(color))
    end

    WriteAll(outputPath, xmlContent)
end

function GenerateVariant(template, theme, templateDirectory, outputDirectory)
    local templateSheetPath = app.fs.joinPath(templateDirectory, "sheet.png")
    local templateXmlPath = app.fs.joinPath(templateDirectory, "theme.xml")
    local outputSheetPath = app.fs.joinPath(outputDirectory, "sheet.png")
    local outputXmlPath = app.fs.joinPath(outputDirectory, "theme.xml")

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

    app.command.Refresh()
end

-- Eggplant:
--     Buttons:
--     #c8d8d8
--     #90b0a8
--     #588078

--     Window Titlebar:
--     #008080

--     Background:
--     #400040

local template = {
    colors = {
        ["button_shadow"] = Color {
            red = 255,
            green = 0,
            blue = 255,
            alpha = 255
        },
        ["button_regular"] = Color {red = 255, green = 0, blue = 0, alpha = 255},
        ["button_highlight"] = Color {
            red = 255,
            green = 255,
            blue = 0,
            alpha = 255
        },
        ["window_titlebar"] = Color {
            red = 0,
            green = 0,
            blue = 255,
            alpha = 255
        },
        ["link"] = Color {red = 0, green = 0, blue = 168, alpha = 255},
        ["text_regular"] = Color {red = 0, green = 255, blue = 255, alpha = 255},
        ["background"] = Color {red = 120, green = 96, blue = 80, alpha = 255},
        -- TODO: Add a template color for the input background + mask it in the sheet.png
        -- Dark Variants Only
        ["dark_accent_highlight"] = Color {
            red = 128,
            green = 255,
            blue = 0,
            alpha = 255
        },
        ["dark_accent_regular"] = Color {
            red = 128,
            green = 192,
            blue = 0,
            alpha = 255
        },
        ["dark_accent_shadow"] = Color {
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
            ["button_shadow"] = Color {
                red = 128,
                green = 128,
                blue = 128,
                alpha = 255
            },
            ["button_regular"] = Color {
                red = 192,
                green = 192,
                blue = 192,
                alpha = 255
            },
            ["button_highlight"] = Color {
                red = 255,
                green = 255,
                blue = 255,
                alpha = 255
            },
            ["window_titlebar"] = Color {
                red = 0,
                green = 0,
                blue = 168,
                alpha = 255
            },
            ["link"] = Color {red = 0, green = 0, blue = 168, alpha = 255},
            ["link_hover"] = Color {
                red = 255,
                green = 0,
                blue = 128,
                alpha = 255
            },
            ["background"] = Color {
                red = 128,
                green = 128,
                blue = 128,
                alpha = 255
            }
        }
    },
    desert = {
        colors = {
            ["button_shadow"] = Color {
                red = 160,
                green = 143,
                blue = 104,
                alpha = 255
            },
            ["button_regular"] = Color {
                red = 215,
                green = 207,
                blue = 184,
                alpha = 255
            },
            ["button_highlight"] = Color {
                red = 232,
                green = 231,
                blue = 223,
                alpha = 255
            },
            ["window_titlebar"] = Color {
                red = 0,
                green = 128,
                blue = 128,
                alpha = 255
            },
            ["link"] = Color {red = 255, green = 0, blue = 255, alpha = 255},
            ["link_hover"] = Color {
                red = 255,
                green = 255,
                blue = 255,
                alpha = 255
            },
            ["background"] = Color {
                red = 160,
                green = 143,
                blue = 104,
                alpha = 255
            }
        }
    },
    eggplant = {
        colors = {
            ["button_shadow"] = Color {
                red = 88,
                green = 128,
                blue = 120,
                alpha = 255
            },
            ["button_regular"] = Color {
                red = 144,
                green = 176,
                blue = 168,
                alpha = 255
            },
            ["button_highlight"] = Color {
                red = 200,
                green = 216,
                blue = 216,
                alpha = 255
            },
            ["window_titlebar"] = Color {
                red = 0,
                green = 128,
                blue = 128,
                alpha = 255
            },
            ["link"] = Color {red = 0, green = 255, blue = 255, alpha = 255},
            ["link_hover"] = Color {
                red = 255,
                green = 255,
                blue = 255,
                alpha = 255
            },
            ["background"] = Color {red = 64, green = 0, blue = 64, alpha = 255}
        }
    },
    ["rainy-day"] = {
        colors = {
            ["button_shadow"] = Color {
                red = 79,
                green = 103,
                blue = 127,
                alpha = 255
            },
            ["button_regular"] = Color {
                red = 128,
                green = 152,
                blue = 176,
                alpha = 255
            },
            ["button_highlight"] = Color {
                red = 192,
                green = 207,
                blue = 216,
                alpha = 255
            },
            ["window_titlebar"] = Color {
                red = 128,
                green = 128,
                blue = 128,
                alpha = 255
            },
            ["link"] = Color {red = 0, green = 255, blue = 0, alpha = 255},
            ["link_hover"] = Color {
                red = 255,
                green = 255,
                blue = 255,
                alpha = 255
            },
            ["background"] = Color {red = 0, green = 0, blue = 0, alpha = 255}
        }
    },
    rose = {
        colors = {
            ["button_shadow"] = Color {
                red = 159,
                green = 96,
                blue = 112,
                alpha = 255
            },
            ["button_regular"] = Color {
                red = 207,
                green = 175,
                blue = 183,
                alpha = 255
            },
            ["button_highlight"] = Color {
                red = 231,
                green = 216,
                blue = 223,
                alpha = 255
            },
            ["window_titlebar"] = Color {
                red = 159,
                green = 96,
                blue = 112,
                alpha = 255
            },
            ["link"] = Color {red = 255, green = 0, blue = 0, alpha = 255},
            ["link_hover"] = Color {
                red = 255,
                green = 255,
                blue = 255,
                alpha = 255
            },
            ["background"] = Color {
                red = 128,
                green = 128,
                blue = 128,
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
    dark = {
        colors = {
            ["button_shadow"] = Color {
                red = 37,
                green = 37,
                blue = 37,
                alpha = 255
            },
            ["button_regular"] = Color {
                red = 59,
                green = 59,
                blue = 59,
                alpha = 255
            },
            ["button_highlight"] = Color {
                red = 88,
                green = 88,
                blue = 88,
                alpha = 255
            },
            ["window_titlebar"] = Color {
                red = 0,
                green = 0,
                blue = 0,
                alpha = 255
            },
            ["link"] = Color {red = 43, green = 123, blue = 244, alpha = 255},
            ["link_hover"] = Color {
                red = 255,
                green = 255,
                blue = 255,
                alpha = 255
            },
            ["text_regular"] = Color {
                red = 128,
                green = 128,
                blue = 128,
                alpha = 255
            },
            ["text_hover"] = Color {
                red = 255,
                green = 255,
                blue = 255,
                alpha = 255
            },
            ["input_background"] = Color {
                red = 0,
                green = 0,
                blue = 0,
                alpha = 255
            },
            ["background"] = Color {red = 37, green = 37, blue = 37, alpha = 37},
            ["dark_accent_highlight"] = Color {
                red = 43,
                green = 123,
                blue = 244,
                alpha = 255
            },
            ["dark_accent_regular"] = Color {
                red = 21,
                green = 61,
                blue = 122,
                alpha = 255
            },
            ["dark_accent_shadow"] = Color {
                red = 37,
                green = 37,
                blue = 37,
                alpha = 255
            }
        }
    }
}

local darkTemplateDirectoryPath = app.fs.joinPath(InputDirectoryPath,
                                                  "template-dark")

for id, data in pairs(darkVariants) do
    GenerateVariant(template, data, darkTemplateDirectoryPath,
                    app.fs.joinPath(InputDirectoryPath, id))
end
