$Path = Join-Path -Path (Get-Location) -ChildPath 'Aseprite 95'

# Generate all theme variants
$AsepriteOutput = aseprite -b -script-param $('input="' + $Path + '"') -script .\GenerateVariants.lua | Out-String

# Pack the theme
.\PackTheme.ps1 -Path '.\Aseprite 95'