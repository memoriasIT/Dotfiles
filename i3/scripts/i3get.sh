#!/bin/sh

NAME="i3get"
VERSION="0.299"
AUTHOR="budRich"
CONTACT='robstenklippa@gmail.com'
CREATED="2017-03-08"
UPDATED="2018-06-30"

getwindow(){
  i3-msg -t get_tree \
  | awk -v RS=',' -F':' -v crit="${crit}" -v srch="${srch}" -v sret="${sret}" \
    'BEGIN{hit="0"}
      $1~"{\"id\"" || $2~"\"id\"" {
        cid=$NF
        for(k in r){if(k!="w"){r[k]=""}}
        if(sret ~ n)
          r["n"]=cid
        if(hit==1){exit}
      }
      $1 ~ crit && $2 ~ srch  {hit=1;fid=cid}
      $2 ~ crit && $3 ~ srch {hit=1;fid=cid}
      sret ~ t && $1=="\"title\"" {r["t"]=$2}
      sret ~ c && $2 ~ "\"class\"" {r["c"]=$3}
      sret ~ i && $1=="\"instance\"" {r["i"]=$2}
      sret ~ d && $1=="\"window\"" {r["d"]=$2}
      sret ~ m && $1=="\"marks\"" {r["m"]=$2}
      sret ~ a && $1=="\"focused\"" {r["a"]=$2}
      sret ~ o && $1=="\"title_format\"" {r["o"]=$2}
      sret ~ w && $1=="\"num\"" {r["w"]=$2}
      sret ~ f && $1=="\"floating\"" {r["f"]=$2;if(hit == "1")exit}
      
    END{
      if(hit == "0") exit
      split(sret, aret, "")
      for (i=1; i <= length(sret); i++) {
        op=r[aret[i]]
        if(aret[i]!~/t|o/){gsub("[\"]","",op)}
        if(op!="")
        printf("%s\n", op)
      }
    }
    '
}

main(){
  synk=0
  sret=n
  crit="\"focused\""
  srch=true

  while getopts :c:i:t:n:d:r:m:o:ayvh option
  do
    case "${option}" in
      v) printf '%s\n' \
           "$NAME - version: $VERSION" \
           "updated: $UPDATED by $AUTHOR"
         exit ;;
      i) crit="\"instance\"" srch="${OPTARG}";;
      c) crit="\"class\"" srch="${OPTARG}";;
      t) crit="\"title\"" srch="${OPTARG}";;
      n) crit="\"id\"" srch="${OPTARG}";;
      d) crit="\"window\"" srch="${OPTARG}";;
      m) crit="\"marks\"" srch="${OPTARG}";;
      o) crit="\"title_format\"" srch="${OPTARG}";;
      a) crit="\"focused\"" && srch="true";;
      r) sret="${OPTARG}" ;;
      y) synk=1;;
      h|*) printinfo && exit ;;
    esac
  done

  result=$(getwindow)

  [ $synk = 1 ] && {
    # timeout after 10 seconds
    for ((i=0;i<100;i++)); do 
      sleep 0.1
      result=$(getwindow)
      [ -n "$result" ] && break
    done
  }

  [ -n "$result" ] \
    && printf '%s\n' "${result}" \
    || exit 1
}

printinfo(){
  case "$1" in
    m ) printf '%s' "${about}" ;;
    
    f ) 
      printf '%s' "${bouthead}"
      printf '%s' "${about}"
      printf '%s' "${boutfoot}"
    ;;

    ''|* ) 
      printf '%s' "${about}" | awk '
         BEGIN{ind=0}
         $0~/^```/{
           if(ind!="1"){ind="1"}
           else{ind="0"}
           print ""
         }
         $0!~/^```/{
           gsub("[`*]","",$0)
           if(ind=="1"){$0="   " $0}
           print $0
         }
       '
    ;;
  esac
}

bouthead="
${NAME^^} 1 ${UPDATED} Linux \"User Manuals\"
=======================================

NAME
----
"

boutfoot="
AUTHOR
------

${AUTHOR} <${CONTACT}>
<https://budrich.github.io>

SEE ALSO
--------

i3(1)
"

about='
`i3get` - Return information about i3wm.

SYNOPSIS
--------

`i3get` [`-h`|`-v`]  
`i3get` [`OPTION` [*CRITERIA*]] [`-r` [tcidnmwafov]] [`-y`]  

DESCRIPTION
-----------

Search for `CRITERIA` in the output of `i3-msg -t get_tree`, 
return desired information. If no arguments are passed. 
`con_id` of acitve window is returned.

OPTIONS
-------

`-v`  
Show version and exit

`-h`  
Show this help

`-a`  
Currently active window (default)

`-c` *CLASS*  
Search for windows with the given class

`-i` *INSTANCE*  
Search for windows with the given instance

`-t` *TITLE*  
Search for windows with title.

`-n` *CON_ID*  
Search for windows with the given con_id

`-d` *CON_ID*  
Search for windows with the given window id

`-m` *CON_MARK*  
Search for windows with the given mark

`-o` *TTL_FRMT*  
Search for windows with the given titleformat

`-y`  
Synch on. If this option is included,  
script will wait till target window exist.

`-r` [*OUTPUT*]  
*OUTPUT* can be one or more of the following 
characters:   

`t`: title  
`c`: class  
`i`: instance  
`d`: Window ID  
`n`: Con_Id (default)  
`m`: mark  
`w`: workspace  
`a`: is active  
`f`: floating state  
`o`: title format  
`v`: visible state  

EXAMPLES
--------
search for window with instance name sublime_text. Request
workspace, title and floating state.  

``` shell
$ i3get -i sublime_text -r wtf 
1
"~/src/bash/i3ass/i3get (i3ass) - Sublime Text"
user_off
```

Title and tile_format output is always surrounded
with doublequotes.

DEPENDENCIES
------------

i3wm
'

if [ "$1" = "md" ]; then
  printinfo m
  exit
elif [ "$1" = "man" ]; then
  printinfo f
  exit
else
  main "${@}"
fi





