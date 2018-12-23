
# Learn a command on each new shell open
man $(ls /usr/bin | shuf -n 1)| sed -n "/^NAME/ { n;p;q }"