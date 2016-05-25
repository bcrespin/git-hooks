#!/bin/sh
#
# pre-commit to check r10k Puppetfile synthax
#
# author maxpayne911@hotmail.com
#
# Prerequistes :
# r10k installed
#
# Install :
# /path/to/the/reop/.git/hooks/pre-commit
#
# based on script seens there : N/A
#
# tested on linux Centos 7, should work on FreeBSD also

#ensure r10k there
#if not , display message and exit depending of want you want 
R10KMISSING_ERROR_MESAGE="*** ERROR : r10k not found, no synthax check done !"
R10KMISSING_ERROR_EXIT=1

ret=`whereis r10k | awk '{print $2}'`
if [ "$ret" == "" ]; then
	echo $R10KMISSING_ERROR_MESAGE
	exit $R10KMISSING_ERROR_EXIT
fi

# assume the puppet file is in root of the repo
# as r10k will run check against Puppet file in current path..which is repo root...


for file in `git diff --name-only --cached |grep -E '^Puppetfile$'`; do
	echo "*** INFO Checking r10k puppetfile synthax :"
	r10k puppetfile check 
	ret=$?
	if [ "$ret" == "1" ]; then
		echo "**** ERROR aborting the commit";
		exit $ret
	fi 
	exit $ret
done

#add other possible check there
# as I put hiera data  with r10k
for file in `git diff --name-only --cached | grep -E '\.(yaml)'`; do
  echo "*** INFO Checking YAML is valid : $file"
  ruby -e "require 'yaml'; YAML.parse(File.open('$file'))"
  ret=$?
  if [ "$ret" == "1" ]; then
  	echo "**** ERROR aborting the commit";
        exit $ret

  else
    echo "YAML looks good"
  fi
done
exit 0
