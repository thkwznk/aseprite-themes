$Path = Join-Path -Path (Get-Location) -ChildPath 'Aseprite 95'

# Generate all theme variants
aseprite -b -script-param $('input="' + $Path + '"') -script .\GenerateVariants.lua

# Pack the theme
.\PackTheme.ps1 -Path '.\Aseprite 95'