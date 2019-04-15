#!/usr/bin/env bash
# Purpose: Example of select builtin
# Date: 20190415
# Kevin Burg - kevin.burg@state.co.us

# Misc variable definitions {{{

# }}}

# Begin main tasks {{{
select file in *
do
  stat "$file"
  break
done
# }}}

exit 0
