# 获取当前脚本路径
$currentScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$tempBackupPath = Join-Path $currentScriptPath 'Temp'

# 定义目标路径
$targetPaths = @(
    "C:\Users\21945\AppData\Local\Temp\WinGet\cache\V2_PVD\Microsoft.Winget.Source_8wekyb3d8bbwe\packages\Yuanli.uTools",
    "C:\Users\21945\Pictures\uToolsWallpapers",
    "C:\Users\21945\AppData\Local\utools-updater",
    "C:\Users\21945\AppData\Local\Temp\utools-icons",
    "C:\Users\21945\AppData\Roaming\uTools",
    "C:\Users\21945\AppData\Local\Temp\WinGet\cache\V2_M\Microsoft.Winget.Source_8wekyb3d8bbwe\manifests\y\Yuanli\uTools",
    "C:\Users\21945\AppData\Local\Programs\utools",
    "C:\Users\21945\AppData\Roaming\uTools\Partitions\%3Cutools%3E"
)

# 遍历当前路径下的所有文件夹
$foldersToSync = Get-ChildItem -Path $currentScriptPath -Directory

# foreach ($folder in $foldersToSync) {
    # 对于每一个文件夹
    foreach ($targetPath in $targetPaths) {
        $leafPath = Split-Path $targetPath -Leaf
        # Write-Output "Leaf path of $targetPath is $leafPath"
        # 检测$leafPath在当前文件夹下存不存在，存在输出存在
        $folderPath = Join-Path -Path $currentScriptPath -ChildPath $leafPath
        if (Test-Path -Path $folderPath) {
            Write-Output "$leafPath exists in $folderPath"
        }
        Write-Output "开始备份......................."
        $tempPath = Join-Path -Path $currentScriptPath -ChildPath "temp"
        Write-Output $tempPath
        # 如果$tempPath不存在，就创建，存在就删除其所有内容
        if (-Not (Test-Path -Path $tempPath)) {
            New-Item -ItemType Directory -Path $tempPath | Out-Null
            Write-Output "创建备份文件夹"
        } else {
            # Get-ChildItem -Path $tempPath | Remove-Item -Recurse -Force
            Write-Output "备份文件夹已经存在"
        }
        #utools已经关闭现在使用obs进行录制
        #如果$targetPath存在就备份该路径的文件夹的zip到$tempPath下
        if (Test-Path -Path $targetPath) {
            $backupZipPath = Join-Path -Path $tempPath -ChildPath "$($leafPath)_backup_$(Get-Date -Format 'yyyyMMdd_HHmmss').zip"
            Write-Output "Backing up $targetPath to $backupZipPath"
            Compress-Archive -Path "$targetPath\*" -DestinationPath $backupZipPath
        }

        # 将目标路径与文件夹名称结合以创建目标路径。
        #
        # 参数:
        #   $targetPath [string] - 要附加文件夹名称的基本路径。
        #   $folder.Name [string] - 要附加到目标路径的文件夹名称。
        #
        # 返回:
        #   [string] - 目标路径和文件夹名称的组合路径。
        # $destinationPath = Join-Path -Path $targetPath -ChildPath $folder.Name
        
        # if (Test-Path $destinationPath) {
        #     # 如果目标路径存在且不为空，进行备份
        #     if ((Get-ChildItem -Path $destinationPath).Count -gt 0) {
        #         # 创建备份 ZIP 文件
        #         $backupZipPath = Join-Path -Path $tempBackupPath -ChildPath "$($folder.Name)_backup_$(Get-Date -Format 'yyyyMMdd_HHmmss').zip"
        #         Write-Output "Backing up $destinationPath to $backupZipPath"
        #         Compress-Archive -Path $destinationPath\* -DestinationPath $backupZipPath
        #     }
        # }
        
        # 复制文件夹
        # Write-Output "Syncing $folder to $destinationPath"
        # Copy-Item -Path $folder.FullName -Destination $destinationPath -Recurse -Force
    }

# Write-Output "Sync completed."
