$shell = new-object -com "Shell.Application"  
$folder = $shell.Namespace('C:\Windows')    
$item = $folder.Parsename('notepad.exe')
$verb = $item.Verbs() | ? {$_.Name -eq 'Pin to Tas&kbar'}
if ($verb) {$verb.DoIt()}
