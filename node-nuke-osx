#!/bin/sh

## NODE NUKE OSX
#               .           .   ________________    .        .
#                     .    ____/ (  (    )   )  \___
#               .         /( (  (  )   _    ))  )   )\        .   .
#                       ((     (   )(    )  )   (   )  )   .
#            .    .   ((/  ( _(   )   (   _) ) (  () )  )        .   .
#                    ( (  ( (_)   ((    (   )  .((_ ) .  )_
#         _  _  ___  ___  ___     _  _ _   _ _  _____      ___  _____  __
#        | \| |/ _ \|   \| __|   | \| | | | | |/ / __|    / _ \/ __\ \/ /
#        | .` | (_) | |) | _|    | .` | |_| | ' <| _|    | (_) \__ \>  < 
#        |_|\_|\___/|___/|___|   |_|\_|\___/|_|\_\___|    \___/|___/_/\_\
#                     _        _  _ _     _       .   .   .
#     .       .     (_((__(_(__(( ( ( |  ) ) ) )_))__))_)___)   .
#         .         ((__)        \\||lll|l||///          \_))       .
#                  .       . / (  |(||(|)|||//  \     .    .      .      .
#    .       .           .   (   /(/ (  )  ) )\          .     .
#        .      .    .     (  . ( ( ( | | ) ) )\   )               .
#                           (   /(| / ( )) ) ) )) )    .   .  .       .  .  .
#    .     .       .  .   (  .  ( ((((_(|)_)))))     )            .
#            .  .          (    . ||\(|(|)|/|| . . )        .        .
#        .           .   (   .    |(||(||)||||   .    ) .      .         .  .
#    .      .      .       (     //|/l|||)|\\ \     )      .      .   .
#                        (/ / //  /|//||||\\  \ \  \ _)
#----------------------------------------------------------------------------

NodeDirectories=(

  # Default Installation
  /usr/local/lib/node
  /usr/local/lib/node_modules

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
)

NodeFiles=(

  # Symbolic links
  /usr/local/bin/npm
  /usr/local/bin/node
  /usr/local/lib/dtrace/node.d  # Should be removed by "brew uninstall"
)



# CMD="echo sudo rm -fr"
# CMD="ls -lRd"
CMD="find"
CMD=""
POSTFIX=""
MODE="DRYRUN"
VERBOSE=false
ARGS_FILE="-f"
ARGS_DIR="-rf"
ARGS_VERBOSE="v"

while getopts "Dvh" arg; do
  case $arg in
    D)
      # Override dry-run with actual remove command
      # CMD="sudo rm -vfr"
      MODE="NUKE"
      ;;
    v)
      # Verbose output, lists all files
      VERBOSE=true
      ARGS_FILE=$ARGS_FILE$ARGS_VERBOSE
      ARGS_DIR=$ARGS_DIR$ARGS_VERBOSE 
      ;;
    h)
      echo 'Help: Node Nuke OSX'
      echo '  v - Verbose list of all files and directories to be removed'
      echo '  h - show help list (you are reading it now)'
      echo '  D - delete all node.js files and directories'
      exit
      ;;
    esac
done


(( ${#} > 0 )) || {
  echo 'DISCLAIMER: USE THIS SCRIPT AT YOUR OWN RISK!'
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
  echo 'You may be prompted for a password.'
  sudo ${0} sudo
  exit $?
}



# This will need to be executed as an Admin (maybe just use sudo).

for bom in org.nodejs.node.pkg.bom org.nodejs.pkg.bom; do

  receipt=/var/db/receipts/${bom}
  [ -e ${receipt} ] && {
    # Loop through all the files in the bom.
    lsbom -f -l -s -pf ${receipt} \
    | while read i; do
      # Remove each file listed in the bom.
      if [ $MODE = "DRYRUN" ]; then
        echo /usr/local/${i} $POSTFIX
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
  if [ -d "$dir" ]; then
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
