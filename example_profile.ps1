$emojis = @('️❤️', '👽', '💩', '🍄', '👻', '🐷', '🥓', '🌮', '💣', '🚒', '🚓', '🚢', '🚕', '🚌', '🚂', '🚛', '🍇', '🍈', '🍉', '🍊', '🍋', '🍌', '🍍', '🥭', '🍎', '🍏', '🍐', '🍑', '🍒', '🍓', '🥝', '🍅', '🥥', '🥑', '🥒', '🥦', '🫑', '🌵', '🐫', '🦖', '🐳', '🐓', '🐵')
$randomEmoji = $emojis[(Get-Random -Minimum 0 -Maximum $emojis.Length)]

$path = 'C:\Users\username\AppData\Local\Programs\oh-my-posh\themes\mytheme.omp.json'

$theme = Get-Content -Path $path -Raw | ConvertFrom-Json -AsHashtable
$theme.blocks.segments[7].template = $randomEmoji
$theme | ConvertTo-Json -Depth 100 | Set-Content -Path $path

oh-my-posh init pwsh --config $path | Invoke-Expression