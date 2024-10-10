# 设置 FFmpeg 的路径
$ffmpegPath = "G:\softwareDir\ffnpeg\ffmpeg-7.1-full_build\bin\ffmpeg.exe"

# 设置输入和输出文件路径
$inputFile = $args[0]

# 构建 FFmpeg 命令
$baseName = [System.IO.Path]::GetFileNameWithoutExtension($inputFile)
# 执行命令
# 构建输出文件名称
$outputFileName = "$baseName.gif"
# $command = "$ffmpegPath -i `"$inputFile`" -filter_complex `"[0:v]split[x][z];[x]palettegen=stats_mode=full[y];[z][y]paletteuse`" -loop 0 `"$outputFileName`""
$fps = 3
$width = 720

# 构建命令
$command = "$ffmpegPath -i `"$inputFile`" -vf `"[0:v]fps=$fps,scale=$width :-1:flags=lanczos[x];[x]split[y][z];[y]palettegen=stats_mode=full[p];[z][p]paletteuse`" -loop 0 `"$outputFileName`""
Invoke-Expression $command