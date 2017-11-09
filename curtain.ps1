# Output function
function WriteOutput ( $msg ) {
    $msg | Out-File "C:\curtain\output.html" -Append
}

# Grab date - will only get logs past this date
$date = Get-Date 

# Launch process and grab object handle
Get-ChildItem "C:\curtain" | ForEach-Object {
    # Skip curtain.ps1
    If ( -Not $_.FullName.EndsWith("curtain.ps1")) {
	# Try to identify whether it's a script (case insens for "ps1")
        If ( -Not $_.FullName.EndsWith("ps1", 1)) {
            $process = Start-Process -FilePath $_.FullName
	} Else {
            $process = Start-Process PowerShell -ArgumentList "-ep bypass","-file",$_.FullName,"-noexit" -PassThru
        }  
    }
}

# Let the script run for 5 seconds (arbitrary amount of time to do it's stuff)
Start-Sleep -s 5

# Grab all 4104 Script Block Log events 
$events = Get-WinEvent -FilterHashTable @{LogName='Microsoft-Windows-PowerShell/Operational'; Id='4104'}

# Create hashtable for each PID and their related logs
$pids = @{}

# Create new entry for each PID that contains list of 4104 events in order
ForEach ( $element in $events ) {    

    If ( $element.TimeCreated -gt $date ) {
    
        If ( !$pids.ContainsKey($element.ProcessId) ) {
                                
            $pids[$element.ProcessId] = @()            
        }
        
        # This strips out some default information surrounding the actual script
        $message = $element.message.Split([Environment]::NewLine)
        $message = $message[1..($message.Length-7)]
        $message = $message -Join [Environment]::NewLine | Out-String        
        
        $pids[$element.ProcessId] += $message
    }
}

# Write Header part of the HTML file
WriteOutput "<!DOCTYPE html>
<html>
<head>
<style>
button.accordion {
    background-color: #eee;
    color: #444;
    cursor: pointer;
    padding: 18px;
    width: 100%;
    border: none;
    text-align: left;
    outline: none;
    font-size: 15px;
    transition: 0.4s;
}

button.accordion.active, button.accordion:hover {
    background-color: #ccc; 
}

div.panel {
    padding-left: 18px;
    display: none;
    background-color: white;
    border: 1px solid black;
}

pre {
    white-space: pre-wrap;
    word-wrap: break-word;
}

h2 {
    text-align: center;
}
</style>
</head>
<body>
<h2>Curtain</h2>
<br><br>
<a href='desktop.png'><img size=256 width=256 src='desktop.png'></a>"

# This is the original PID from the launched script/executable
ForEach ( $element in $pids.Keys ) {
    
    If ( $element -eq $process.Id ) {
    
        WriteOutput ("<h2>PID: {0} - (Initial)</h2>" -f $element)
    
        For ($counter=0; $counter -le $pids[$element].Length - 1; $counter++) {
        
            WriteOutput ("<button class='accordion'>ID: {2}</button>" -f $element, $counter, $counter)
            WriteOutput ("<div class='panel'>")
            WriteOutput ("<pre>{0}</pre>" -f $pids[$element][$counter])
            WriteOutput "</div>"
        }
    }    
}

# These are subsequent PIDs
ForEach ( $element in $pids.Keys ) {
    
    If ( $element -ne $process.Id ) {
    
        WriteOutput ("<h2>PID: {0}</h2>" -f $element)
    
        For ($counter=0; $counter -le $pids[$element].Length - 1; $counter++) {
        
            WriteOutput ("<button class='accordion'>ID: {2}</button>" -f $element, $counter, $counter)
            WriteOutput ("<div class='panel'>")
            WriteOutput ("<pre>{0}</pre>" -f $pids[$element][$counter])
            WriteOutput "</div>"
        }
    }    
}

# Write Footer
WriteOutput "<script>
var acc = document.getElementsByClassName('accordion');
var i;

for (i = 0; i < acc.length; i++) {
    acc[i].onclick = function(){
        this.classList.toggle('active');
        var panel = this.nextElementSibling;
        if (panel.style.display === 'block') {
            panel.style.display = 'none';
        } else {
            panel.style.display = 'block';
        }
    }
}
</script>

</body>
</html>
"
