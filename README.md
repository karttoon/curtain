# curtain
Curtain is a small script to quickly grab PowerShell ScriptBlock log events for fast analysis of heavily obfuscated PowerShell.

Blog post - [09NOV2017 - PowerShell Deobfuscation with Curtain](http://ropgadget.com/posts/intro_curtain.html)

Example output and generated [page](http://ropgadget.com/files/curtain_output.html).

```
$ ./curtain.sh test.ps1
[+] Reverting to snapshot - curtain
[+] Starting headless VM
2017-11-09T10:51:39.463| ServiceImpl_Opener: PID 26072
[+] Copying curtain.ps1 to virtual Guest
[+] Sending target file to detonate
[+] Launching Curtain PS script for - test.ps1
[!] Sleeping for 10 seconds to let malware doing its thang...
[+] Transferring output from script
[+] Grabbing a screenshot of the desktop
[+] Killing virtual Guest
[+] Launching site...
```

The "psorder.py" takes a B64 encoded chunk of PowerShell and will attempt to manually deobfuscate it. It's handy to combine when it comes to token replacement, etc, that Curtain may reveal.

This version of Curtain is no longer maintained. Please see the Curtain module for Cuckoo found [HERE](https://github.com/karttoon/curtaincuckoo/).
