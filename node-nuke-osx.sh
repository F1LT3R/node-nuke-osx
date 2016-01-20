#!/bin/sh

SPLASH=(
"## NODE NUKE OSX                                                            "
"               .           .   ________________    .        .               "
"                     .    ____/ (  (    )   )  \___                         "
"               .         /( (  (  )   _    ))  )   )\        .   .          "
"                       ((     (   )(    )  )   (   )  )   .                 "
"            .    .   ((/  ( _(   )   (   _) ) (  () )  )        .   .       "
"                    ( (  ( (_)   ((    (   )  .((_ ) .  )_                  "
"         _  _  ___  ___  ___     _  _ _   _ _  _____      ___  _____  __    "
"        | \| |/ _ \|   \| __|   | \| | | | | |/ / __|    / _ \/ __\ \/ /    "
"        | .\` | (_) | |) | _|    | .\` | |_| | ' <| _|    | (_) \__ \>  <   "
"        |_|\_|\___/|___/|___|   |_|\_|\___/|_|\_\___|    \___/|___/_/\_\    "
"                     _        _  _ _     _       .   .   .                  "
"     .       .     (_((__(_(__(( ( ( |  ) ) ) )_))__))_)___)   .            "
"         .         ((__)        \\\\||lll|l||///          \\_))       .     "
"                  .       . / (  |(||(|)|||//  \\     .    .      .      .  "
"    .       .           .   (   /(/ (  )  ) )\\          .     .            "
"        .      .    .     (  . ( ( ( | | ) ) )\\   )               .        "
"                           (   /(| / ( )) ) ) )) )    .   .  .       .  .  ."
"    .     .       .  .   (  .  ( ((((_(|)_)))))     )            .          "
"            .  .          (    . ||\\(|(|)|/|| . . )        .        .      "
"        .           .   (   .    |(||(||)||||   .    ) .      .         .  ."
"    .      .      .       (     //|/l|||)|\\\\ \\     )      .      .   .   "
"                        (/ / //  /|//||||\\\\  \ \\  \\ _)                  "
"----------------------------------------------------------------------------"
)

BomPath="/var/db/receipts/"

NodeDirectories=(

  # Default Installations
  /usr/local/lib/node
  /usr/local/lib/node_modules
  /usr/local/include/node
  /usr/local/include/node_modules

  # Should by removed by "brew uninstall"
  /usr/local/lib/node_modules

  # Package Installers (brew, .pkg)
  /var/db/receipts/org.nodejs.*

  # $HOME Installations
  ~/.npm
  ~/.npm-packages
  ~/.node-gyp
  ~/.npm_modules

  # Erroneous Installations
  ~/node_modules

  # Node Version Manager
  ~/.nvm

  # Opt
  /opt/local/lib/node_modules
)

NodeFiles=(

  # Symbolic links
  /usr/local/bin/npm
  /usr/local/bin/node

  # Should be removed by "brew uninstall"
  /usr/local/lib/dtrace/node.d
  /usr/local/share/systemtap/tapset/node.stp
  /usr/local/share/man/man1/node.1
  
  # Opt
  /opt/local/bin/node
  /opt/local/include/node
)


for line in "${SPLASH[@]}"
do
  echo "$line"
done


MODE="DRYRUN"
LIST=false
ARGS_FILE="-f"
ARGS_DIR="-rf"
ARGS_VERBOSE="v"


while getopts "Dlhv" arg; do
  case $arg in
    D)
      # Delete each file/directory (overrides dry-run)
      MODE="NUKE"
      ;;
    l)
      # List each file/directory that would be deleted
      LIST=true
      ;;
    v)
     # Verbose deletion (output file/dir as it is being deleted)
      ARGS_FILE=$ARGS_FILE$ARGS_VERBOSE
      ARGS_DIR=$ARGS_DIR$ARGS_VERBOSE 
      ;;
    h)
      # Display help and exit
      echo 'Help: Node Nuke OSX'
      echo '  l - List each file/directory that would be deleted'
      echo '  h - Show help (you are reading help now)'
      echo '  v - Verbose deletion messages'
      echo '  D - [DANGER] Delete each node.js file and directory'
      exit
      ;;
    esac
done


(( ${#} > 0 )) || {
  echo 'DISCLAIMER: USE THIS SCRIPT AT YOUR OWN RISK!'
  echo
  echo 'THE AUTHOR TAKES NO RESPONSIBILITY FOR THE RESULTS OF THIS SCRIPT.'
  echo
  echo 'Node Nuke OSX will attempt to remove all traces of Node.JS from,'
  echo 'your system, including Node Version Manager. Node Nuke OSX is'
  echo 'designed to be used with systems that use brew to install'
  echo 'Node.JS. Before running this script, please use brew to'
  echo 'uninstall and prune, Eg:'
  echo
  echo '    "brew uninstall nodeversion"'
  echo '    "brew prune"'
  echo
  echo '[CTRL-C] Cancel, [ENTER] Continue'
  read
  echo 'This script requires admin priviledges.'
  echo
  echo 'You may be prompted for a password.'
  echo
  sudo ${0} sudo
  exit $?
}


if [ $MODE = "DRYRUN" ]; then
  echo
fi


### Collect Bom Files

BomFiles=()
BomFileCount=0

for bom in org.nodejs.node.pkg.bom org.nodejs.pkg.bom; do
  receipt=$BomPath${bom}

  # Check receipts
  if [ -e ${receipt} ]; then
    BomList=($(lsbom -f -l -s -pf ${receipt}))

    for file in "${BomList[@]}"
    do
      BomFile="/usr/local/$file"

      # Only add to list if exists
      if [ -f "$BomFile" ] || [ -L "$BomFile" ]; then
        BomFiles+=($BomFile)
        ((BomFileCount+=1))
      fi

    done
  fi
done

echo "Found: $BomFileCount BOM files."


### Collect Other Node.js Files/Symbolic Links

NodeFiles=()
NodeFileCount=0

for file in "${NodeFiles[@]}"
do
  if [ -f "$file" ] || [ -L "$file" ]; then
    NodeFiles+=($file)
    ((NodeFileCount+=1))
  fi
done

echo "Found: $NodeFileCount Node.js files/symbolic links."


### Collect Node.js Directories

NodeDirs=()
NodeDirsCount=0

NodeDirsSubFiles=()
NodeDirsSubFileCount=0

for dir in "${NodeDirectories[@]}"
do
  if [ -d "$dir" ]; then
    NodeDirs+=($dir)
    ((NodeDirsCount+=1))

    SubFiles=($(find $dir -type f -o -type l;))
    for subfile in "${SubFiles[@]}"
    do
      NodeDirsSubFiles+=($subfile)
      ((NodeDirsSubFileCount+=1))
    done  
  fi
done

echo "Found: $NodeDirsCount Node.js directories,"
echo "       with $NodeDirsSubFileCount files contained therein."




    #if [ $MODE = "NUKE" ]; then
      #sudo rm $ARGS_DIR $dir
    #fi


### List every file/directory/link marked for deletion

if [ $LIST = true ]; then
  echo
  echo "Listing every file/directory/link marked for deletion..."

  echo
  echo "  BOM Files:" 
  echo
  for file in "${BomFiles[@]}"; do
    echo "    $file"
  done

  echo
  echo "  Node Files/Symlinks:" 
  echo
  for file in "${NodeFiles[@]}"; do
    echo "    $file"
  done

  echo
  echo "  Node Dirs:" 
  echo
  for dir in "${NodeDirs[@]}"; do
    echo "    $dir"
  done

  echo
  echo "  Files within Node Dirs:"
  echo
  for subfile in "${NodeDirsSubFiles[@]}"; do
    echo "    $subfile"
  done
fi


if [ $MODE == "DRYRUN" ]; then
  echo
  echo 'This was a dry run.'
  echo 'No files or directories were deleted.'
  echo 'Read the help for execution instructions.'
  echo
fi


if [ $MODE == "NUKE" ]; then
  echo
  echo "Nuking Node.js..."

  for file in "${BomFiles[@]}"; do
    sudo rm $ARGS_FILE $file
  done

  for file in "${NodeFiles[@]}"; do
    sudo rm $ARGS_FILE $file
  done
  
  #for file in "${NodeDirsSubFiles[@]}"; do
  #  sudo rm $ARGS_FILE $file
  #done

  for dir in "${NodeDirs[@]}"; do
    sudo rm $ARGS_DIR $dir
  done

  echo
  echo "... Node.js has been nuked!"
  echo
fi


exit 0


# Credits:
#   @nicerobot - https://gist.github.com/ddo/668630454ea0d74fdc21
#   StackOverflow - http://stackoverflow.com/questions/9044788/how-do-i-uninstall-nodejs-installed-from-pkg-mac-os-x
#   @benznext - http://benznext.com/completely-uninstall-node-js-from-mac-os-x/

