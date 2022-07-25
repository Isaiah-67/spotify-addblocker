$shell = new-object -com "Shell.Application"  
$folder = $shell.Namespace('Desktop/iTunes.lnk')    
$item = $folder.Parsename('iTunes.exe')
$verb = $item.Verbs() | ? {$_.Name -eq 'Pin to Taskbar'}
if ($verb) {$verb.DoIt()}
