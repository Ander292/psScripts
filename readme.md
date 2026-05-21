# All sorts of powershell scripts I wrote to do random stuff

## compile:

compile.ps1 [string:mode]
- A single script I use to compile my c projects. It expects the mingw gcc compiler added to path. 
- It will compile the c files into obj files and then link them. It will also compile the rc script (if present) inside the resources folder into an obj file so the linker can link it properly
- build will compile the project, run will run it and full will do both

## tasm:

Three scripts for assembling and launching tasm files using the dosbox-x emulator
The output is routed to a file and from there read into stdout

To use these scripts you need to:

1) Have dosbox-x emulator installed and its exe added to PATH (important)
- You can get dosbox-x [here](https://dosbox-x.com).

2) Have TASM installed in a folder nammed diskc inside the dosbox-x directory
- You can get TASM for dosbox-x [here](https://github.com/zajo/TASM/tree/master)
- The folder will be mounted as C drive inside dosbox

compile.ps1 [string:in] [string:out] [int:keepLog] [int:timeout]

- produces an exe file from <in> file using tasm assembler and linker inside the <out> directory.
- The obj file and the log file are temporarily put inside the out folder
- If out is invalid it will use the in parameter
- <keepLog> will make the script not delete the log file after it has been printed to stdout
- <timeout> is used to determine how long the script will wait for the dosbox-x before terminating log file reading

run.ps1 [string:file] [int:keepLog] [int:timeout]

- runs the <file> exe file and redirects its output to a file and later stdout
- <keepLog> will make the script not delete the log file after it has been printed to stdout
- <timeout> is used to determine how long the script will wait for the dosbox-x before terminating log file reading

debug.ps1 [string:file]

- runs the dosbox-x and starts the debugger for the <file>
- it expects the .exe file to be in the same dir as .asm file for the source code to display inside the debuger itself

watchFile.ps1 [string:Path] [string:StopToken] [int:IdleTimeoutSeconds]
    - contains a single function used internally by the scripts to display log file to stdout in real time

settings.json
    - For the action buttons plugin buttons (useless but cool)
