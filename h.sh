#!/bin/bash

# to run:
# sh h.sh -m 'commit msg'

# rm -r public/assets; git add -u; # don't need to run this often or else the deploys will take a long time... only need to push new assets or assets that have been changed.

MESSAGE="No commit message"
PRECOMP=false
FIGARO=false
SPACER="\n"
BREAKER="\n------------------------------------------------------------------"

# http://linux.about.com/od/Bash_Scripting_Solutions/a/How-To-Pass-Arguments-To-A-Bash-Script.htm
while getopts m:p:f:e:c: option
do
        case "${option}"
        in
                m) MESSAGE=${OPTARG};;
                p) PRECOMP=${OPTARG};;
                f) FIGARO=${OPTARG};;
                e) EXPIRE=${OPTARG};;
                c) COMMITONLY=${OPTARG};;
        esac
done

# don't try doing anything fancy, like setting default of true if we give -p with no
# argument, tried for an hour, bash script is a pain. Just deal with it and move on.

# echo $MESSAGE
if [ $PRECOMP == true ]; then
  echo "$SPACER""PRECOMPILING ASSETS""$BREAKER";
  #rm -r public/assets; # don't need expired assets, as all will be regenerated anyway
  ### however removing all assets makes the git push A LOT SLOWER
  #git add -u;
  rake assets:precompile;
fi


if [ $FIGARO == true ]; then
  echo "$SPACER""SETTING ENVIRONMENT VARIABLES""$BREAKER";
  figaro heroku:set -e production
fi

# ruby '/Users/ck/sites/shared/shared.rb'

echo "$SPACER""COMMITING NEW CHANGES""$BREAKER";
git add .; git commit -m "$MESSAGE";

# USE DOUBLE QUOTES TO FIX UNARY OPERATOR EXCEPTION
# THIS OCCURS BECAUSE $COMMITONLY does not exist if it is not explicitly set
# WHEN IT'S WRAPPED IN QUOTATIONS, IT WILL JUST BE AN EMPTY STRING INSTEAD?
if [ "$COMMITONLY" != true ]; then
  echo "$SPACER""DEPLOYING TO GITHUB THEN HEROKU ""$BREAKER";
  git push origin master
  heroku restart
  #git push bitbucket master

  # echo "$SPACER""DEPLOYING TO GITHUB""$BREAKER";
  # git push origin master

  # somefile="config/application.yml"
  # if ! [ "$(( $(date +"%s") - $(stat -f "%m" $somefile) ))" -gt "7200" ]; then
  #    echo "$SPACER""SETTING ENVIRONMENT VARIABLES""$BREAKER";
  #    figaro heroku:set -e production
  # fi

  # why in "": http://stackoverflow.com/questions/13617843/unary-operator-expected
  if [ "$EXPIRE" = true ] || [ "$PRECOMP" = true ]; then
    echo "$SPACER""CLEARING HEROKU CACHE (FOR CACHED JS, NOT CART SESSIONS)""$BREAKER";
    heroku run rake cache:clear
  fi

  # ping Charitable.org
  echo "$SPACER""PINGING THE SERVER""$BREAKER";
  #ruby ping_projex.rb
fi
