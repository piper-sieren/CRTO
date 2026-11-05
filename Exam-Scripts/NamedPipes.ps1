try {
    $pipeName = "bad_pipe"
    $pipe = New-Object system.IO.Pipes.NamedPipeServerStream($pipeName)
    Write-Host "Listening on \\.\pipe\$pipeName"
    $pipe.WaitForConnection();
    $sr = new-object System.IO.StreamReader($pipe);
    $msg= $sr.ReadLine()
    Write-Host "I received a message: ", $msg  
   }
   catch {
    Write-Host "Pipe Creation Failed..."
    $_
    return 0
   }
   
   # echo "Sending data to pipe" >\\.\pipe\bad_pipe