# 获取当前脚本路径
$currentScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path

$inputZipFile = $args[0]
# 获取不带后缀的文件名
$fileNameWithoutExtension = [System.IO.Path]::GetFileNameWithoutExtension($inputZipFile)

# 输出不带后缀的文件名
# Write-Log "不带后缀的文件名: $fileNameWithoutExtension"

$filePath = Join-Path $currentScriptPath $fileNameWithoutExtension
$logFolderPath = Join-Path $currentScriptPath 'log'
$logFilePath = Join-Path $logFolderPath "sync_log_$(Get-Date -Format 'yyyy-MM-dd_HH-mm-ss').log"
# 创建$logFilePath文件
New-Item -ItemType File -Path $logFilePath | Out-Null
function Write-Log {
    param (
        [string]$message
    )
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    "$timestamp - $message" | Tee-Object -FilePath $logFilePath -Append
}
# 如果utools进程在运行，关闭进程

$utoolsProcess = Get-Process -Name "utools" -ErrorAction SilentlyContinue
if ($utoolsProcess) {
    Stop-Process -Name "utools" -Force
    Write-Log "uTools process stopped."
}


# 检查 $filePath 文件夹是否存在，如果不存在则创建，存在就删除其全部内容
if (Test-Path -Path $filePath) {
    Remove-Item -Path $filePath\* -Recurse -Force
    Write-Log "文件夹已存在，内容已删除: $filePath"
} else {
    New-Item -Path $filePath -ItemType Directory | Out-Null
    Write-Log "文件夹已创建: $filePath"
}


# 检查输入的 ZIP 文件是否存在
if (Test-Path $inputZipFile) {
    # 解压 ZIP 文件到当前脚本路径
    Expand-Archive -Path $inputZipFile -DestinationPath $filePath
    Write-Log "文件已成功解压到 $currentScriptPath"
} else {
    Write-Error "输入的 ZIP 文件不存在: $inputZipFile"
}

# 获取当前用户的主目录路径
$userHomePath = [System.Environment]::GetFolderPath('UserProfile')

# 定义目标路径并替换用户目录
$targetPaths = @(
    (Join-Path $userHomePath "AppData\Local\Temp\utools-icons"),
    (Join-Path $userHomePath "AppData\Roaming\uTools"),
    (Join-Path $userHomePath "AppData\Roaming\uTools\Partitions\%3Cutools%3E")
)


# Ensure log file path is defined
$logFilePath = Join-Path -Path $currentScriptPath -ChildPath "sync.log"

foreach ($targetPath in $targetPaths) {
    $leafPath = Split-Path $targetPath -Leaf
    $folderPath = Join-Path -Path $filePath -ChildPath $leafPath

    if (Test-Path -Path $folderPath) {
        Write-Log $folderPath
        # 移动文件夹内容到目标路径
        Remove-Item -Path $targetPath\* -Recurse -Force

        Move-Item -Path $folderPath\* -Destination $targetPath -Force
        Write-Log "Moved contents of $folderPath to $targetPath"
        # Copy-Item -Path $folderPath -Destination $targetPath -Recurse -Force
        # Write-Log "Copied $folderPath to $targetPath"
    }
}
#删除$filePath文件夹
Write-Log $filePath

Remove-Item -Path $filePath -Recurse -Force
Write-Log "Temporary sync folder and its contents have been deleted."
