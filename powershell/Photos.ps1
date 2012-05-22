$PhotosDirectory="d:\Photos & Movies"

[System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") >> log.txt
[System.Reflection.Assembly]::LoadWithPartialName("mscorlib") >> log.txt

$encoding = New-Object -TypeName "System.Text.ASCIIEncoding"

Function GetPhotoDate([string] $fullPath, [DateTime] $defaultDate)
{
	Try 
	{
		$img = [System.Drawing.Bitmap]::FromFile( $fullPath )

		foreach ($propItem in $img.PropertyItems)
		{		
			if ($propItem.Type -ne 2)
			{
				continue
			}
			if ($propItem.Id -ne 306)
			{
				continue
			}
			
			$dateAndTime = $encoding.GetString($propItem.Value).Split(' ')
			$date = $dateAndTime[0].Split(':')
			$year = $date[0]
			$month = $date[1]
			$day = $date[2]
			
			$returnValue = [DateTime]::Parse("$month/$day/$year")

			return $returnValue
			
		}
	}
	catch
	{
		return $defaultdate
	}
	finally
	{
		
	}
}

Function CopyFiles([System.IO.FileInfo[]]$Files)
{
	$currentCount = 0
	$percent = 0;
	
	if (!$Files)
	{
		Write-Host "No Files Found"
		return
	}
	
	Write-Host "  0% Complete"
	foreach ($file in $Files) 
	{
	
		if (!($file))
		{
			continue
		}
	
		$currentCount++
		if ($currentCount -gt ($Files.Length / 10))
		{
			$percent += 10
			$percentString = $percent.ToString().PadLeft(3, ' ')
			Write-Host "$percentString% Complete"
			$currentCount = 0
		}
		
		$date = $file.CreationTime
		
		$newDate = GetPhotoDate $file.fullname $date

		$year =$newDate.Year.ToString()
		$month = $newDate.Month.ToString().PadLeft(2, '0')
		$monthName = $newDate.ToString("MMMM") # <-- Month Name
		
		$TargetDirectory = "$year\$month - $monthName"
		$TargetPath = "$PhotosDirectory\$TargetDirectory"
		
		if (!(test-path $targetpath))
		{
			new-item $targetpath -type directory >> log.txt
		}
		xcopy /y $file.fullname "$targetpath" >> log.txt
	}
	Write-Host "100% Complete"
}

Write-Host "Copying JPG's"
$files = Get-ChildItem -recurse -filter *.jpg
CopyFiles($files)
Write-Host "Copying MOV's"
$files = Get-ChildItem -recurse -filter *.mov
CopyFiles($files)
Write-Host "Copying MOD's"
$files = Get-ChildItem -recurse -filter *.mod
CopyFiles($files)