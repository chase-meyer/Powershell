$emojis = @('️❤️', '👽', '💩', '🍄', '👻', '🐷', '🥓', '🌮', '💣', '🚒', '🚓', '🚢', '🚕', '🚌', '🚂', '🚛', '🍇', '🍈', '🍉', '🍊', '🍋', '🍌', '🍍', '🥭', '🍎', '🍏', '🍐', '🍑', '🍒', '🍓', '🥝', '🍅', '🥥', '🥑', '🥒', '🥦', '🫑', '🌵', '🐫', '🦖', '🐳', '🐓', '🐵')
$randomEmoji = $emojis[(Get-Random -Minimum 0 -Maximum $emojis.Length)]

$path = "C:\Users\180580\OneDrive - City of Lubbock\Documents\PowerShell\theme.omp.json"

$theme = Get-Content -Path $path -Raw | ConvertFrom-Json -AsHashtable

$theme.blocks[2].segments[0].template = $randomEmoji

$theme | ConvertTo-Json -Depth 100 | Set-Content -Path $path

oh-my-posh init pwsh --config $path | Invoke-Expression

"C:\scripts\dotnet-completion.ps1"