#! /bin/bash

case "$1" in
  left  ) varmode="topleft" tilesize="shrink width";;
  right ) varmode="bottomright" tilesize="grow width";;
  up    ) varmode="topright" tilesize="grow height" ;;
  down  ) varmode="bottomleft" tilesize="shrink height" ;;
  * ) exit ;;
esac

if [[ $(i3get -r f) =~ on$ ]]; then
  i3-msg mode "$varmode"
else
  i3-msg resize "$tilesize" 10 px or 10 ppt
fi

# resize shrink width 10 px or 10 ppt
# mode "resize"

