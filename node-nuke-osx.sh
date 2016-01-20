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


while getopts "Dlh" arg; do
  case $arg in
    D)
      # Delete each file/directory (overrides dry-run)
      MODE="NUKE"
      ;;
    l)
      # List each file/directory that would be deleted
      LIST=true
      ARGS_FILE=$ARGS_FILE$ARGS_VERBOSE
      ARGS_DIR=$ARGS_DIR$ARGS_VERBOSE 
      ;;
    h)
      # Display help and exit
      echo 'Help: Node Nuke OSX'
      echo '  l - List each file/directory that would be deleted'
      echo '  h - Show help (you are reading help now)'
      echo '  D - Delete each node.js file and directorie'
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
  echo "BOM Packages marked for deletion: \n"
fi


# This will need to be executed as an Admin (maybe just use sudo).
for bom in org.nodejs.node.pkg.bom org.nodejs.pkg.bom; do

  receipt=/var/db/receipts/${bom}
  [ -e ${receipt} ] && {
    # Loop through all the files in the bom.
    lsbom -f -l -s -pf ${receipt} \
    | while read i; do
      # Remove each file listed in the bom.
      if [ $MODE = "DRYRUN" ]; then
        echo /usr/local/${i}
      else
        sudo rm $ARGS_DIR /usr/local/${i}
      fi
    done
  }

done


if [ $MODE = "DRYRUN" ]; then
  echo
  echo "Directories marked for deletion: \n"
fi

for dir in "${NodeDirectories[@]}"
do
  # If the directory exists
  if [ -d "$dir" ]; then
    # 
    if [ $VERBOSE = true ]; then
      find $dir -type d -o -type f -o -type l;
    else
      echo "  $dir"
    fi
    if [ $MODE = "NUKE" ]; then
      sudo rm $ARGS_DIR $dir
    fi
  fi
done


if [ $MODE = "DRYRUN" ]; then
  echo
  echo "Files/Symbolic Links marked for deletion: \n"
fi

for file in "${NodeFiles[@]}"
do
  if [ -f "$file" ] || [ -L "$file" ]; then
     echo "  $file"
  fi
  if [ $MODE = "NUKE" ]; then
    sudo rm $ARGS_FILE $file
  fi  
done


if [ $MODE == "DRYRUN" ]; then
  echo
  echo 'This was a dry run.'
  echo 'No files or directories were deleted.'
  echo 'Read the help for execution instructions.'
fi


exit 0

# Credits:
#   @nicerobot - https://gist.github.com/ddo/668630454ea0d74fdc21
#   StackOverflow - http://stackoverflow.com/questions/9044788/how-do-i-uninstall-nodejs-installed-from-pkg-mac-os-x
#   @benznext - http://benznext.com/completely-uninstall-node-js-from-mac-os-x/

