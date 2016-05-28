#!/bin/sh
# based on script there :
# https://www.chriscowley.me.uk/blog/2014/06/25/super-slick-agile-puppet-for-devops/
# pre-commit git hook to check the validity of  modules manifest/yaml

PUPPETLINT_OPTS=" --no-80chars-check --no-class_inherits_from_params_class-check "

starline="******************************************************"

echo $starline
echo "*** INFO Running pre-commit script..."

for file in `git diff --name-only --cached | grep -E '\.(pp)'`; do
  if [ -f ./$file ]; then
    echo "*** INFO Checking style on $file : "
    puppet-lint $PUPPETLINT_OPTS  ${file}
    ret=$?
    if [ $ret -ne 0 ]; then
      echo "**** ERROR aborting the commit";
      echo $starline      
      exit $ret
    else
      echo "Style looks good"
    fi

    echo "*** INFO Checking syntax of module file : $file"
    puppet parser validate $file
    ret=$?
    if [ $ret -ne 0 ]; then
      echo "**** ERROR aborting the commit";
      exit $ret
      echo $starline
    else
      echo "Syntax looks good"
    fi
  fi 
done


# let also yaml synthax
for file in `git diff --name-only --cached | grep -E '\.(yaml)'`; do
  if [ -f ./$file ]; then
    echo "*** INFO Checking YAML file : $file"
    ruby -e "require 'yaml'; YAML.parse(File.open('$file'))"
    ret=$?
    if [ $ret -ne 0 ]; then
      echo "**** ERROR aborting the commit";
      echo $starline
      exit $ret
    else
      echo "YAML looks good"
    fi
  fi
done

echo $starline
exit 0
