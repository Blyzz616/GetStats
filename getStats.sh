#! /bin/bash

monthly_reset () {
        # CHECK FOR THE FILE
        if [ ! -e /usr/local/bin/system/old_month ]; then
                # CREATE IT IF IT DOESN'T EXIST WITH THIS MONTHS DATE
                echo `date` | awk '{print $2,$6}' > /usr/local/bin/system/old_month
        fi

        # CREATE A NEW FILE EVERY TIME THIS IS RUN WITH THIS MONTHS DATE
        echo `date` | awk '{print $2,$6}' > /usr/local/bin/system/this_month

        # CHECK IF OLD_MONTH AND THIS_MONTH ARE THE SAME
        if ! cmp /usr/local/bin/system/this_month /usr/local/bin/system/old_month > /dev/null 2>&1 ;
        then
                echo 0 > /usr/local/bin/system/rx_bytes_old                             # ZERO OUT ALL THE VALUES
                echo 0 > /usr/local/bin/system/rx_bytes
                echo 0 > /usr/local/bin/system/rx_running
                echo 0 > /usr/local/bin/system/tx_bytes_old
                echo 0 > /usr/local/bin/system/tx_bytes
                echo 0 > /usr/local/bin/system/tx_running
                echo 0 > /usr/local/bin/system/wlan_rx_bytes_old
                echo 0 > /usr/local/bin/system/wlan_rx_bytes
                echo 0 > /usr/local/bin/system/wlan_rx_running
                echo 0 > /usr/local/bin/system/wlan_tx_bytes_old
                echo 0 > /usr/local/bin/system/wlan_tx_bytes
                echo 0 > /usr/local/bin/system/wlan_tx_running
                echo `date` | awk '{print $2,$6}' > /usr/local/bin/system/old_month     # UPDATE THE VALUE IN OLD_MONTH SO THAT THEY WILL MATCH NEXT TIME
                reboot now                                                              # REBOOT
                exit 0                                                                  # AND EXIT THIS SCRIPT
        fi                                                                              # AFTER REBOOTING, THE TX_BYTES AND RX_BYTES WILL ALL BE 0
}

# COPY IN NEW VALUES IN ONE SHOT TO MAINTAIN DATA CONSISTENCY
#       ACTUAL FILES
        cp /sys/class/net/eth0/statistics/rx_bytes /usr/local/bin/system/rx_actual
        cp /sys/class/net/eth0/statistics/tx_bytes /usr/local/bin/system/tx_actual
        cp /sys/class/net/wlan0/statistics/rx_bytes /usr/local/bin/system/wlan_rx_actual
        cp /sys/class/net/wlan0/statistics/tx_bytes /usr/local/bin/system/wlan_tx_actual

# CALL THE MONTHLY SCRIPT _ COMMENT THIS OUT IF YOU DON'T WANT TO RESET THE COUNTER EACH MONTH
monthly_reset

# CHECK FOR FILE IN /USR/LOCAL/BIN/SYSTEM
#       BYTES FILES
if [ ! -e /usr/local/bin/system/rx_bytes ]; then                                # IF RX_BYTES DOESN'T EXIST
        cp /usr/local/bin/system/rx_actual /usr/local/bin/system/rx_bytes       # MAKE A NEW COPY FROM THE ACTUALFILE
else
        mv /usr/local/bin/system/rx_bytes /usr/local/bin/system/rx_bytes_old    # IF IT DOES EXIST, RENAME IT
        cp /usr/local/bin/system/rx_actual /usr/local/bin/system/rx_bytes       # AND COPY IN A NEW ONE
fi
if [ ! -e /usr/local/bin/system/tx_bytes ]; then                                # REPEAT THIS FOR TX_BYTES
        cp /usr/local/bin/system/tx_actual /usr/local/bin/system/tx_bytes
else
        mv /usr/local/bin/system/tx_bytes /usr/local/bin/system/tx_bytes_old
        cp /usr/local/bin/system/tx_actual /usr/local/bin/system/tx_bytes
fi

#       BYTES FILES (WLAN0)
if [ ! -e /usr/local/bin/system/wlan_rx_bytes ]; then                                # IF RX_BYTES DOESN'T EXIST
        cp /usr/local/bin/system/wlan_rx_actual /usr/local/bin/system/wlan_rx_bytes       # MAKE A NEW COPY FROM THE ACTUALFILE
else
        mv /usr/local/bin/system/wlan_rx_bytes /usr/local/bin/system/wlan_rx_bytes_old    # IF IT DOES EXIST, RENAME IT
        cp /usr/local/bin/system/wlan_rx_actual /usr/local/bin/system/wlan_rx_bytes       # AND COPY IN A NEW ONE
fi
if [ ! -e /usr/local/bin/system/wlan_tx_bytes ]; then                                # REPEAT THIS FOR TX_BYTES
        cp /usr/local/bin/system/wlan_tx_actual /usr/local/bin/system/wlan_tx_bytes
else
        mv /usr/local/bin/system/wlan_tx_bytes /usr/local/bin/system/wlan_tx_bytes_old
        cp /usr/local/bin/system/wlan_tx_actual /usr/local/bin/system/wlan_tx_bytes
fi

#       RUNNING TOTAL FILES
if [ ! -e /usr/local/bin/system/rx_running ]; then
        cp /usr/local/bin/system/rx_bytes /usr/local/bin/system/rx_running
fi
if [ ! -e /usr/local/bin/system/tx_running ]; then
        cp /usr/local/bin/system/tx_bytes /usr/local/bin/system/tx_running
fi

#       RUNNING TOTAL FILES (WLAN0)
if [ ! -e /usr/local/bin/system/wlan_rx_running ]; then
        cp /usr/local/bin/system/wlan_rx_bytes /usr/local/bin/system/wlan_rx_running
fi
if [ ! -e /usr/local/bin/system/wlan_tx_running ]; then
        cp /usr/local/bin/system/wlan_tx_bytes /usr/local/bin/system/wlan_tx_running
fi

#       OLD FILES
if [ ! -e /usr/local/bin/system/rx_bytes_old ]; then
        cp /usr/local/bin/system/rx_bytes /usr/local/bin/system/rx_bytes_old
fi
if [ ! -e /usr/local/bin/system/tx_bytes_old ]; then
        cp /usr/local/bin/system/tx_bytes /usr/local/bin/system/tx_bytes_old
fi

#       OLD FILES (WLAN0)
if [ ! -e /usr/local/bin/system/wlan_rx_bytes_old ]; then
        cp /usr/local/bin/system/wlan_rx_bytes /usr/local/bin/system/wlan_rx_bytes_old
fi
if [ ! -e /usr/local/bin/system/wlan_tx_bytes_old ]; then
        cp /usr/local/bin/system/wlan_tx_bytes /usr/local/bin/system/wlan_tx_bytes_old
fi


# SET VARIABLES FOR CALCULATION
OLDRX=`cat /usr/local/bin/system/rx_bytes_old`
NEWRX=`cat /usr/local/bin/system/rx_bytes`
RUNRX=`cat /usr/local/bin/system/rx_running`
OLDTX=`cat /usr/local/bin/system/tx_bytes_old`
NEWTX=`cat /usr/local/bin/system/tx_bytes`
RUNTX=`cat /usr/local/bin/system/tx_running`
OLDWRX=`cat /usr/local/bin/system/wlan_rx_bytes_old`
NEWWRX=`cat /usr/local/bin/system/wlan_rx_bytes`
RUNWRX=`cat /usr/local/bin/system/wlan_rx_running`
OLDWTX=`cat /usr/local/bin/system/wlan_tx_bytes_old`
NEWWTX=`cat /usr/local/bin/system/wlan_tx_bytes`
RUNWTX=`cat /usr/local/bin/system/wlan_tx_running`
MAX=4294967296

# COMPARE AND DO MATH
if [ $NEWRX -lt $OLDRX ]; then                         # IF NEW VALUE IS LESS THAN OLD VALUE (max reached and LOOPED AROUND)
        TOPRX=`expr $MAX - $OLDRX`                             # SUBTRACT THE OLD VALUE FROM THE MAX VALUE
        USERX=`expr $TOPRX + $RUNRX`                           # ADD IT TO RUNNING TOTAL
        $USERX=`expr $USERX + $NEWRX`                          # ADD THAT TO THE NEW VALUE
        echo $USERX > /usr/local/bin/system/rx_running         # OUTPUT THAT TO THE NEW RUNNING TOTAL
else                                                   # OTHERWISE (it hasn't looped around)
        TOPRX=`expr $NEWRX - $OLDRX`                           # SUBTRACT THE OLD VALUE FROM THE NEW
        USERX=`expr $RUNRX + $TOPRX`                           # ADD IT TO THE RUNNING VALUE
        echo $USERX > /usr/local/bin/system/rx_running         # OUTPUT THAT TO THE NEW RUNNING TOTAL
fi
if [ $NEWTX -lt $OLDTX ]; then                         # REATE ABOVE FOR UPLOADS
        TOPTX=`expr $MAX - $OLDTX`
        USETX=`expr $TOPTX + $RUNTX`
        $USETX=`expr $USETX + $NEWTX`
        echo $USETX > /usr/local/bin/system/tx_running
else
        TOPTX=`expr $NEWTX - $OLDTX`
        USETX=`expr $RUNTX + $TOPTX`
        echo $USETX > /usr/local/bin/system/tx_running
fi
 #COMPARE AND DO MATH (WLAN0)
if [ $NEWWRX -lt $OLDWRX ]; then                         # IF NEW VALUE IS LESS THAN OLD VALUE (max reached and LOOPED AROUND)
        TOPWRX=`expr $MAX - $OLDWRX`                             # SUBTRACT THE OLD VALUE FROM THE MAX VALUE
        USEWRX=`expr $TOPWRX + $RUNWRX`                           # ADD IT TO RUNNING TOTAL
        $USEWRX=`expr $USEWRX + $NEWWRX`                          # ADD THAT TO THE NEW VALUE
        echo $USEWRX > /usr/local/bin/system/wlan_rx_running         # OUTPUT THAT TO THE NEW RUNNING TOTAL
else                                                   # OTHERWISE (it hasn't looped around)
        TOPWRX=`expr $NEWWRX - $OLDWRX`                           # SUBTRACT THE OLD VALUE FROM THE NEW
        USEWRX=`expr $RUNWRX + $TOPWRX`                           # ADD IT TO THE RUNNING VALUE
        echo $USEWRX > /usr/local/bin/system/wlan_rx_running         # OUTPUT THAT TO THE NEW RUNNING TOTAL
fi
if [ $NEWWTX -lt $OLDWTX ]; then                         # REATE ABOVE FOR UPLOADS
        TOPWTX=`expr $MAX - $OLDWTX`
        USEWTX=`expr $TOPWTX + $RUNWTX`
        $USEWTX=`expr $USEWTX + $NEWWTX`
        echo $USEWTX > /usr/local/bin/system/wlan_tx_running
else
        TOPWTX=`expr $NEWWTX - $OLDWTX`
        USEWTX=`expr $RUNWTX + $TOPWTX`
        echo $USEWTX > /usr/local/bin/system/wlan_tx_running
fi

# GET VALUES AND ASSIGN THEM TO VARIABLES
LOAD=`cat /proc/loadavg | awk '{print $1}'`             # LOAD AVERAGES
RXBYTES=`cat /usr/local/bin/system/rx_running`          # DOWNLOAD DATA
TXBYTES=`cat /usr/local/bin/system/tx_running`          # UPLOAD DATA
WRXBYTES=`cat /usr/local/bin/system/wlan_rx_running`    # DOWNLOAD DATA (WLAN0)
WTXBYTES=`cat /usr/local/bin/system/wlan_tx_running`    # UPLOAD DATA (WLAN0)
TEMP=`/opt/vc/bin/vcgencmd measure_temp|cut -c6-9`      # SoC TEMPERATURE
MEM=`free -b | grep Mem | awk '{print $4/$2 * 100.0}'`  # MEMORY USAGE (%)
RRDTOOL=/usr/bin/rrdtool

# WRITE TEMPREATURE TO FILE TO BE INCLUDED IN NON-RRD FASHION
/opt/vc/bin/vcgencmd measure_temp|cut -c6-9 > /var/www/html/include/temp.php

# UPDATE THE RRDs WITH THOSE VALUES
$RRDTOOL update /usr/local/bin/system/load.rrd N:$LOAD
$RRDTOOL update /usr/local/bin/system/data.rrd -t rx:tx:rxc:txc:wrx:wtx:wrxc:wtxc N:$RXBYTES:$TXBYTES:$RXBYTES:$TXBYTES:$WRXBYTES:$WTXBYTES:$WRXBYTES:$WTXBYTES
$RRDTOOL update /usr/local/bin/system/pitemp.rrd N:$TEMP
$RRDTOOL update /usr/local/bin/system/mem.rrd N:$MEM


# DATA
    # ETH0
        # 36H
$RRDTOOL graph /var/www/html/images/graphs/data36h.png                  \
--title 'Odin Absolute Traffic (eth0)'                                  \
--watermark "Graph Drawn `date`"                                        \
--vertical-label 'Bytes'                                                \
--lower-limit '0'                                                       \
--rigid                                                                 \
--alt-autoscale                                                         \
--units=si                                                              \
--width '640'                                                           \
--height '300'                                                          \
--full-size-mode                                                        \
--start end-36h                                                         \
'DEF:rx=/usr/local/bin/system/data.rrd:rx:AVERAGE'			\
'DEF:tx=/usr/local/bin/system/data.rrd:tx:AVERAGE'			\
'AREA:tx#00CC00FF:Upload\:'						\
'GPRINT:tx:LAST:\:%8.2lf %s]'						\
'STACK:rx#0000FFFF:Download\:'						\
'GPRINT:rx:LAST:\:%8.2lf %s]\n'						\

# DATA
    # ETH0
        # 10D
$RRDTOOL graph /var/www/html/images/graphs/data10d.png                  \
--title 'Odin Absolute Traffic (eth0) 10 days'                          \
--watermark "Graph Drawn `date`"                                        \
--vertical-label 'Bytes'                                                \
--lower-limit '0'                                                       \
--rigid                                                                 \
--alt-autoscale                                                         \
--units=si                                                              \
--width '640'                                                           \
--height '300'                                                          \
--full-size-mode                                                        \
--start end-10d                                                         \
'DEF:rx=/usr/local/bin/system/data.rrd:rx:AVERAGE'			\
'DEF:tx=/usr/local/bin/system/data.rrd:tx:AVERAGE'			\
'AREA:tx#00CC00FF:Upload\:'						\
'GPRINT:tx:LAST:\:%8.2lf %s]'						\
'STACK:rx#0000FFFF:Download\:'						\
'GPRINT:rx:LAST:\:%8.2lf %s]\n'

# DATA
    # ETH0
        # 45D
$RRDTOOL graph /var/www/html/images/graphs/data45d.png                  \
--title 'Odin Absolute Traffic (eth0) 45 days'                          \
--watermark "Graph Drawn `date`"                                        \
--vertical-label 'Bytes'                                                \
--lower-limit '0'                                                       \
--rigid                                                                 \
--alt-autoscale                                                         \
--units=si                                                              \
--width '640'                                                           \
--height '300'                                                          \
--full-size-mode                                                        \
--start end-45d                                                         \
'DEF:rx=/usr/local/bin/system/data.rrd:rx:AVERAGE'			\
'DEF:tx=/usr/local/bin/system/data.rrd:tx:AVERAGE'			\
'AREA:tx#00CC00FF:Upload\:'						\
'GPRINT:tx:LAST:\:%8.2lf %s]'						\
'STACK:rx#0000FFFF:Download\:'						\
'GPRINT:rx:LAST:\:%8.2lf %s]\n'

# DATA
    # ETH0
        # 18M
$RRDTOOL graph /var/www/html/images/graphs/data18m.png                  \
--title 'Odin Absolute Traffic (eth0) 18 month'                         \
--watermark "Graph Drawn `date`"                                        \
--vertical-label 'Bytes'                                                \
--lower-limit '0'                                                       \
--rigid                                                                 \
--alt-autoscale                                                         \
--units=si                                                              \
--width '640'                                                           \
--height '300'                                                          \
--full-size-mode                                                        \
--start end-1y6m                                                        \
'DEF:rx=/usr/local/bin/system/data.rrd:rx:AVERAGE'			\
'DEF:tx=/usr/local/bin/system/data.rrd:tx:AVERAGE'			\
'AREA:tx#00CC00FF:Upload\:'						\
'GPRINT:tx:LAST:\:%8.2lf %s]'						\
'STACK:rx#0000FFFF:Download\:'						\
'GPRINT:rx:LAST:\:%8.2lf %s]\n'

# DATA
    # ETH0
        # 10Y
$RRDTOOL graph /var/www/html/images/graphs/data10y.png                  \
--title 'Odin Absolute Traffic (eth0) 10 year'                          \
--watermark "Graph Drawn `date`"                                        \
--vertical-label 'Bytes'                                                \
--lower-limit '0'                                                       \
--rigid                                                                 \
--alt-autoscale                                                         \
--units=si                                                              \
--width '640'                                                           \
--height '300'                                                          \
--full-size-mode                                                        \
--start end-10y                                                         \
'DEF:rx=/usr/local/bin/system/data.rrd:rx:AVERAGE'			\
'DEF:tx=/usr/local/bin/system/data.rrd:tx:AVERAGE'			\
'AREA:tx#00CC00FF:Upload\:'						\
'GPRINT:tx:LAST:\:%8.2lf %s]'						\
'STACK:rx#0000FFFF:Download\:'						\
'GPRINT:rx:LAST:\:%8.2lf %s]\n'

# DATA COUNT
    # ETH0
        # 36H
$RRDTOOL graph /var/www/html/images/graphs/datac36h.png                 \
--title 'Odin Traffic (eth0)'                                           \
--watermark "Graph Drawn `date`"                                        \
--vertical-label 'Bytes / Second'                                       \
--lower-limit '1'                                                       \
--logarithmic                                                           \
--rigid                                                                 \
--alt-autoscale                                                         \
--units=si                                                              \
--width '640'                                                           \
--height '300'                                                          \
--full-size-mode                                                        \
--start end-36h                                                         \
'DEF:rx=/usr/local/bin/system/data.rrd:rxc:AVERAGE'                     \
'DEF:tx=/usr/local/bin/system/data.rrd:txc:AVERAGE'                     \
'AREA:tx#00CC00FF:Upload\:'                                             \
'GPRINT:tx:LAST:\:%8.2lf %s]'						\
'STACK:rx#0000FFFF:Download\:'                                          \
'GPRINT:rx:LAST:\:%8.2lf %s]\n'

# DATA COUNT
    # ETH0
        # 10D
$RRDTOOL graph /var/www/html/images/graphs/datac10d.png                 \
--title 'Odin Traffic (eth0) 10 days'                                   \
--watermark "Graph Drawn `date`"                                        \
--vertical-label 'Bytes / Second'                                       \
--lower-limit '1'                                                       \
--logarithmic                                                           \
--rigid                                                                 \
--alt-autoscale                                                         \
--units=si                                                              \
--width '640'                                                           \
--height '300'                                                          \
--full-size-mode                                                        \
--start end-10d                                                         \
'DEF:rx=/usr/local/bin/system/data.rrd:rxc:AVERAGE'                     \
'DEF:tx=/usr/local/bin/system/data.rrd:txc:AVERAGE'                     \
'AREA:tx#00CC00FF:Upload\:'                                             \
'GPRINT:tx:LAST:\:%8.2lf %s]'						\
'STACK:rx#0000FFFF:Download\:'                                          \
'GPRINT:rx:LAST:\:%8.2lf %s]\n'

# DATA COUNT
    # ETH0
        # 45D
$RRDTOOL graph /var/www/html/images/graphs/datac45d.png                 \
--title 'Odin Traffic (eth0) 45 days'                                   \
--watermark "Graph Drawn `date`"                                        \
--vertical-label 'Bytes / Second'                                       \
--lower-limit '1'                                                       \
--logarithmic                                                           \
--rigid                                                                 \
--alt-autoscale                                                         \
--units=si                                                              \
--width '640'                                                           \
--height '300'                                                          \
--full-size-mode                                                        \
--start end-45d                                                         \
'DEF:rx=/usr/local/bin/system/data.rrd:rxc:AVERAGE'                     \
'DEF:tx=/usr/local/bin/system/data.rrd:txc:AVERAGE'                     \
'AREA:tx#00CC00FF:Upload\:'                                             \
'GPRINT:tx:LAST:\:%8.2lf %s]'						\
'STACK:rx#0000FFFF:Download\:'                                          \
'GPRINT:rx:LAST:\:%8.2lf %s]\n'

# DATA COUNT
    # ETH0
        # 18M
$RRDTOOL graph /var/www/html/images/graphs/datac18m.png                 \
--title 'Odin Traffic (eth0) 18 month'                                  \
--watermark "Graph Drawn `date`"                                        \
--vertical-label 'Bytes / Second'                                       \
--lower-limit '1'                                                       \
--logarithmic                                                           \
--rigid                                                                 \
--alt-autoscale                                                         \
--units=si                                                              \
--width '640'                                                           \
--height '300'                                                          \
--full-size-mode                                                        \
--start end-1y6m                                                        \
'DEF:rx=/usr/local/bin/system/data.rrd:rxc:AVERAGE'                     \
'DEF:tx=/usr/local/bin/system/data.rrd:txc:AVERAGE'                     \
'AREA:tx#00CC00FF:Upload\:'                                             \
'GPRINT:tx:LAST:\:%8.2lf %s]'						\
'STACK:rx#0000FFFF:Download\:'                                          \
'GPRINT:rx:LAST:\:%8.2lf %s]\n'

# DATA COUNT
    # ETH0
        # 10Y
$RRDTOOL graph /var/www/html/images/graphs/datac10y.png                 \
--title 'Odin Traffic (eth0) 10 year'                                   \
--watermark "Graph Drawn `date`"                                        \
--vertical-label 'Bytes / Second'                                       \
--lower-limit '0'                                                       \
--rigid                                                                 \
--alt-autoscale                                                         \
--units=si                                                              \
--width '640'                                                           \
--height '300'                                                          \
--full-size-mode                                                        \
--start end-10y                                                         \
'DEF:rx=/usr/local/bin/system/data.rrd:rxc:AVERAGE'                     \
'DEF:tx=/usr/local/bin/system/data.rrd:txc:AVERAGE'                     \
'AREA:tx#00CC00FF:Upload\:'                                             \
'GPRINT:tx:LAST:\:%8.2lf %s]'						\
'STACK:rx#0000FFFF:Download\:'                                          \
'GPRINT:rx:LAST:\:%8.2lf %s]\n'

# DATA
    # WLAN0
        # 36H
$RRDTOOL graph /var/www/html/images/graphs/wdata36h.png                 \
--title 'Odin Absolute Traffic (wlan0)'                                 \
--watermark "Graph Drawn `date`"                                        \
--vertical-label 'Bytes'                                                \
--lower-limit '0'                                                       \
--rigid                                                                 \
--alt-autoscale                                                         \
--units=si                                                              \
--width '640'                                                           \
--height '300'                                                          \
--full-size-mode                                                        \
--start end-36h                                                         \
'DEF:wrx=/usr/local/bin/system/data.rrd:wrx:AVERAGE'                    \
'DEF:wtx=/usr/local/bin/system/data.rrd:wtx:AVERAGE'                    \
'AREA:wtx#00CC00FF:Upload\:'                                            \
'GPRINT:wtx:LAST:\:%8.2lf %s]'						\
'STACK:wrx#0000FFFF:Download\:'                                         \
'GPRINT:wrx:LAST:\:%8.2lf %s]\n'

# DATA
    # WLAN0
        # 10D
$RRDTOOL graph /var/www/html/images/graphs/wdata10d.png                 \
--title 'Odin Absolute Traffic (wlan0) 10 days'                         \
--watermark "Graph Drawn `date`"                                        \
--vertical-label 'Bytes'                                                \
--lower-limit '0'                                                       \
--rigid                                                                 \
--alt-autoscale                                                         \
--units=si                                                              \
--width '640'                                                           \
--height '300'                                                          \
--full-size-mode                                                        \
--start end-10d                                                         \
'DEF:wrx=/usr/local/bin/system/data.rrd:wrx:AVERAGE'                    \
'DEF:wtx=/usr/local/bin/system/data.rrd:wtx:AVERAGE'                    \
'AREA:wtx#00CC00FF:Upload\:'                                            \
'GPRINT:wtx:LAST:\:%8.2lf %s]'						\
'STACK:wrx#0000FFFF:Download\:'                                         \
'GPRINT:wrx:LAST:\:%8.2lf %s]\n'

# DATA
    # WLAN0
        # 45D
$RRDTOOL graph /var/www/html/images/graphs/wdata45d.png                 \
--title 'Odin Absolute Traffic (wlan0) 45 days'                         \
--watermark "Graph Drawn `date`"                                        \
--vertical-label 'Bytes'                                                \
--lower-limit '0'                                                       \
--rigid                                                                 \
--alt-autoscale                                                         \
--units=si                                                              \
--width '640'                                                           \
--height '300'                                                          \
--full-size-mode                                                        \
--start end-45d                                                         \
'DEF:wrx=/usr/local/bin/system/data.rrd:wrx:AVERAGE'                    \
'DEF:wtx=/usr/local/bin/system/data.rrd:wtx:AVERAGE'                    \
'AREA:wtx#00CC00FF:Upload\:'                                            \
'GPRINT:wtx:LAST:\:%8.2lf %s]'						\
'STACK:wrx#0000FFFF:Download\:'                                         \
'GPRINT:wrx:LAST:\:%8.2lf %s]\n'

# DATA
    # WLAN0
        # 18M
$RRDTOOL graph /var/www/html/images/graphs/wdata18m.png                 \
--title 'Odin Absolute Traffic (wlan0) 18 month'                        \
--watermark "Graph Drawn `date`"                                        \
--vertical-label 'Bytes'                                                \
--lower-limit '0'                                                       \
--rigid                                                                 \
--alt-autoscale                                                         \
--units=si                                                              \
--width '640'                                                           \
--height '300'                                                          \
--full-size-mode                                                        \
--start end-1y6m                                                        \
'DEF:wrx=/usr/local/bin/system/data.rrd:wrx:AVERAGE'                    \
'DEF:wtx=/usr/local/bin/system/data.rrd:wtx:AVERAGE'                    \
'AREA:wtx#00CC00FF:Upload\:'                                            \
'GPRINT:wtx:LAST:\:%8.2lf %s]'						\
'STACK:wrx#0000FFFF:Download\:'                                         \
'GPRINT:wrx:LAST:\:%8.2lf %s]\n'

# DATA
    # WLAN0
        # 10Y
$RRDTOOL graph /var/www/html/images/graphs/wdata10y.png                 \
--title 'Odin Absolute Traffic (wlan0) 10 year'                         \
--watermark "Graph Drawn `date`"                                        \
--vertical-label 'Bytes'                                                \
--lower-limit '0'                                                       \
--rigid                                                                 \
--alt-autoscale                                                         \
--units=si                                                              \
--width '640'                                                           \
--height '300'                                                          \
--full-size-mode                                                        \
--start end-10y                                                         \
'DEF:wrx=/usr/local/bin/system/data.rrd:wrx:AVERAGE'                    \
'DEF:wtx=/usr/local/bin/system/data.rrd:wtx:AVERAGE'                    \
'AREA:wtx#00CC00FF:Upload\:'                                            \
'GPRINT:wtx:LAST:\:%8.2lf %s]'						\
'STACK:wrx#0000FFFF:Download\:'                                         \
'GPRINT:wrx:LAST:\:%8.2lf %s]\n'

# DATA COUNT
    # WLAN0
        # 36H
$RRDTOOL graph /var/www/html/images/graphs/wdatac36h.png                \
--title 'Odin Traffic (wlan0)'                                          \
--watermark "Graph Drawn `date`"                                        \
--vertical-label 'Bytes / Second'                                       \
--lower-limit '1'                                                       \
--logarithmic                                                           \
--rigid                                                                 \
--alt-autoscale                                                         \
--units=si                                                              \
--width '640'                                                           \
--height '300'                                                          \
--full-size-mode                                                        \
--start end-36h                                                         \
'DEF:wrx=/usr/local/bin/system/data.rrd:wrxc:AVERAGE'                   \
'DEF:wtx=/usr/local/bin/system/data.rrd:wtxc:AVERAGE'                   \
'AREA:wtx#00CC00FF:Upload\:'        	                                \
'GPRINT:wtx:LAST:\:%8.2lf %s]'						\
'STACK:wrx#0000FFFF:Download\:'                                         \
'GPRINT:wrx:LAST:\:%8.2lf %s]\n'

# DATA COUNT
    # WLAN0
        # 10D
$RRDTOOL graph /var/www/html/images/graphs/wdatac10d.png                \
--title 'Odin Traffic (wlan0) 10 days'                                  \
--watermark "Graph Drawn `date`"                                        \
--vertical-label 'Bytes / Second'                                       \
--lower-limit '1'                                                       \
--logarithmic                                                           \
--rigid                                                                 \
--alt-autoscale                                                         \
--units=si                                                              \
--width '640'                                                           \
--height '300'                                                          \
--full-size-mode                                                        \
--start end-10d                                                         \
'DEF:wrx=/usr/local/bin/system/data.rrd:wrxc:AVERAGE'                   \
'DEF:wtx=/usr/local/bin/system/data.rrd:wtxc:AVERAGE'                   \
'AREA:wtx#00CC00FF:Upload\:'        	                                \
'GPRINT:wtx:LAST:\:%8.2lf %s]'						\
'STACK:wrx#0000FFFF:Download\:'                                         \
'GPRINT:wrx:LAST:\:%8.2lf %s]\n'

# DATA COUNT
    # WLAN0
        # 45D
$RRDTOOL graph /var/www/html/images/graphs/wdatac45d.png                \
--title 'Odin Traffic (wlan0) 45 days'                                  \
--watermark "Graph Drawn `date`"                                        \
--vertical-label 'Bytes / Second'                                       \
--lower-limit '1'                                                       \
--logarithmic                                                           \
--rigid                                                                 \
--alt-autoscale                                                         \
--units=si                                                              \
--width '640'                                                           \
--height '300'                                                          \
--full-size-mode                                                        \
--start end-45d                                                         \
'DEF:wrx=/usr/local/bin/system/data.rrd:wrxc:AVERAGE'                   \
'DEF:wtx=/usr/local/bin/system/data.rrd:wtxc:AVERAGE'                   \
'AREA:wtx#00CC00FF:Upload\:'        	                                \
'GPRINT:wtx:LAST:\:%8.2lf %s]'						\
'STACK:wrx#0000FFFF:Download\:'                                         \
'GPRINT:wrx:LAST:\:%8.2lf %s]\n'

# DATA COUNT
    # WLAN0
        # 18M
$RRDTOOL graph /var/www/html/images/graphs/wdatac18m.png                \
--title 'Odin Traffic (wlan0) 18 month'                                 \
--watermark "Graph Drawn `date`"                                        \
--vertical-label 'Bytes / Second'                                       \
--lower-limit '1'                                                       \
--logarithmic                                                           \
--rigid                                                                 \
--alt-autoscale                                                         \
--units=si                                                              \
--width '640'                                                           \
--height '300'                                                          \
--full-size-mode                                                        \
--start end-1y6m                                                        \
'DEF:wrx=/usr/local/bin/system/data.rrd:wrxc:AVERAGE'                   \
'DEF:wtx=/usr/local/bin/system/data.rrd:wtxc:AVERAGE'                   \
'AREA:wtx#00CC00FF:Upload\:'        	                                \
'GPRINT:wtx:LAST:\:%8.2lf %s]'						\
'STACK:wrx#0000FFFF:Download\:'                                         \
'GPRINT:wrx:LAST:\:%8.2lf %s]\n'

# DATA COUNT
    # WLAN0
        # 10Y
$RRDTOOL graph /var/www/html/images/graphs/wdatac10y.png                \
--title 'Odin Traffic (wlan0) 10 year'                                  \
--watermark "Graph Drawn `date`"                                        \
--vertical-label 'Bytes / Second'                                       \
--lower-limit '0'                                                       \
--rigid                                                                 \
--alt-autoscale                                                         \
--units=si                                                              \
--width '640'                                                           \
--height '300'                                                          \
--full-size-mode                                                        \
--start end-10y                                                         \
'DEF:wrx=/usr/local/bin/system/data.rrd:wrxc:AVERAGE'                   \
'DEF:wtx=/usr/local/bin/system/data.rrd:wtxc:AVERAGE'                   \
'AREA:wtx#00CC00FF:Upload\:'        	                                \
'GPRINT:wtx:LAST:\:%8.2lf %s]'						\
'STACK:wrx#0000FFFF:Download\:'                                         \
'GPRINT:wrx:LAST:\:%8.2lf %s]\n'

# LOAD
    # 36H
$RRDTOOL graph /var/www/html/images/graphs/load36h.png                  \
--title 'Odin Load Average'                                             \
--watermark "Graph Drawn `date`"                                        \
--vertical-label 'Load'                                                 \
--lower-limit '0'                                                       \
--rigid                                                                 \
--units-exponent '0'							\
--alt-autoscale                                                         \
--width '640'                                                           \
--height '300'                                                          \
--full-size-mode                                                        \
--start end-36h                                                         \
'DEF:load=/usr/local/bin/system/load.rrd:load:AVERAGE'                  \
'AREA:load#BA00FFFF:Load Average\:'                                     \
'GPRINT:load:LAST:\:%8.2lf %s]'

# LOAD
    # 10D
$RRDTOOL graph /var/www/html/images/graphs/load10d.png                  \
--title 'Odin Load Average 10 days'                                     \
--watermark "Graph Drawn `date`"                                        \
--vertical-label 'Load'                                                 \
--lower-limit '0'                                                       \
--rigid                                                                 \
--units-exponent '0'							\
--alt-autoscale                                                         \
--width '640'                                                           \
--height '300'                                                          \
--full-size-mode                                                        \
--start end-10d                                                         \
'DEF:load=/usr/local/bin/system/load.rrd:load:AVERAGE'                  \
'AREA:load#BA00FFFF:Load Average\:'                                     \
'GPRINT:load:LAST:\:%8.2lf %s]'

# LOAD
    # 45D
$RRDTOOL graph /var/www/html/images/graphs/load45d.png                  \
--title 'Odin Load Average 45 days'                                     \
--watermark "Graph Drawn `date`"                                        \
--vertical-label 'Load'                                                 \
--lower-limit '0'                                                       \
--rigid                                                                 \
--units-exponent '0'							\
--alt-autoscale                                                         \
--width '640'                                                           \
--height '300'                                                          \
--full-size-mode                                                        \
--start end-45d                                                         \
'DEF:load=/usr/local/bin/system/load.rrd:load:AVERAGE'                  \
'AREA:load#BA00FFFF:Load Average\:'                                     \
'GPRINT:load:LAST:\:%8.2lf %s]'

# LOAD
    # 18M
$RRDTOOL graph /var/www/html/images/graphs/load18m.png                  \
--title 'Odin Load Average 18 month'                                    \
--watermark "Graph Drawn `date`"                                        \
--vertical-label 'Load'                                                 \
--lower-limit '0'                                                       \
--units-exponent '0'							\
--rigid                                                                 \
--alt-autoscale                                                         \
--width '640'                                                           \
--height '300'                                                          \
--full-size-mode                                                        \
--start end-1y6m                                                        \
'DEF:load=/usr/local/bin/system/load.rrd:load:AVERAGE'                  \
'AREA:load#BA00FFFF:Load Average\:'                                     \
'GPRINT:load:LAST:\:%8.2lf %s]'

# LOAD
    # 10Y
$RRDTOOL graph /var/www/html/images/graphs/load10y.png                  \
--title 'Odin Load Average 10 year'                                     \
--watermark "Graph Drawn `date`"                                        \
--vertical-label 'Load'                                                 \
--lower-limit '0'                                                       \
--units-exponent '0'							\
--rigid                                                                 \
--alt-autoscale                                                         \
--width '640'                                                           \
--height '300'                                                          \
--full-size-mode                                                        \
--start end-10y                                                         \
'DEF:load=/usr/local/bin/system/load.rrd:load:AVERAGE'                  \
'AREA:load#BA00FFFF:Load Average\:'                                     \
'GPRINT:load:LAST:\:%8.2lf %s]'

# MEMORY
    # 36H
$RRDTOOL graph /var/www/html/images/graphs/mem36h.png                   \
--title 'Odin Memory Usage'                                             \
--watermark "Graph Drawn `date`"                                        \
--vertical-label 'Percent'                                              \
--lower-limit '0'                                                       \
--width '640'                                                           \
--height '300'                                                          \
--full-size-mode                                                        \
--start end-36h                                                         \
'DEF:mem=/usr/local/bin/system/mem.rrd:mem:AVERAGE'                     \
'AREA:mem#84A7D5FF:Memory\:'                                            \
'GPRINT:mem:LAST:\:%8.2lf %s]'

# MEMORY
    # 10D
$RRDTOOL graph /var/www/html/images/graphs/mem10d.png                   \
--title 'Odin Memory Usage 10 days'                                     \
--watermark "Graph Drawn `date`"                                        \
--vertical-label 'Percent'                                              \
--lower-limit '0'                                                       \
--width '640'                                                           \
--height '300'                                                          \
--full-size-mode                                                        \
--start end-10d                                                         \
'DEF:mem=/usr/local/bin/system/mem.rrd:mem:AVERAGE'                     \
'AREA:mem#84A7D5FF:Memory\:'                                            \
'GPRINT:mem:LAST:\:%8.2lf %s]'

# MEMORY
    # 45D
$RRDTOOL graph /var/www/html/images/graphs/mem45d.png                   \
--title 'Odin Memory Usage 45 days'                                     \
--watermark "Graph Drawn `date`"                                        \
--vertical-label 'Percent'                                              \
--lower-limit '0'                                                       \
--width '640'                                                           \
--height '300'                                                          \
--full-size-mode                                                        \
--start end-45d                                                         \
'DEF:mem=/usr/local/bin/system/mem.rrd:mem:AVERAGE'                     \
'AREA:mem#84A7D5FF:Memory\:'                                            \
'GPRINT:mem:LAST:\:%8.2lf %s]'

# MEMORY
    # 18M
$RRDTOOL graph /var/www/html/images/graphs/mem18m.png                   \
--title 'Odin Memory Usage 18 month'                                    \
--watermark "Graph Drawn `date`"                                        \
--vertical-label 'Percent'                                              \
--lower-limit '0'                                                       \
--width '640'                                                           \
--height '300'                                                          \
--full-size-mode                                                        \
--start end-1y6m                                                        \
'DEF:mem=/usr/local/bin/system/mem.rrd:mem:AVERAGE'                     \
'AREA:mem#84A7D5FF:Memory\:'                                            \
'GPRINT:mem:LAST:\:%8.2lf %s]'

# MEMORY
    # 10Y
$RRDTOOL graph /var/www/html/images/graphs/mem10y.png                   \
--title 'Odin Memory Usage 10 year'                                     \
--watermark "Graph Drawn `date`"                                        \
--vertical-label 'Percent'                                              \
--lower-limit '0'                                                       \
--width '640'                                                           \
--height '300'                                                          \
--full-size-mode                                                        \
--start end-10y                                                         \
'DEF:mem=/usr/local/bin/system/mem.rrd:mem:AVERAGE'                     \
'AREA:mem#84A7D5FF:Memory\:'                                            \
'GPRINT:mem:LAST:\:%8.2lf %s]'

# SOC TEMP
    # 36H
$RRDTOOL graph /var/www/html/images/graphs/pitemp36h.png                \
--title 'Odin SoC Temperature'                                          \
--watermark "Graph Drawn `date`"                                        \
--vertical-label '°C'                                                   \
--alt-autoscale								\
--width '640'                                                           \
--height '300'                                                          \
--full-size-mode                                                        \
--start end-36h                                                         \
'DEF:pitemp=/usr/local/bin/system/pitemp.rrd:pitemp:AVERAGE'            \
'AREA:pitemp#FF6B10FF:CPU/GPU Temperature\:'                            \
'GPRINT:pitemp:LAST:\:%8.2lf %s]'

# SOC TEMP
    # 10D
$RRDTOOL graph /var/www/html/images/graphs/pitemp10d.png                \
--title 'Odin SoC Temperature 10 days'                                  \
--watermark "Graph Drawn `date`"                                        \
--vertical-label '°C'                                                   \
--alt-autoscale								\
--width '640'                                                           \
--height '300'                                                          \
--full-size-mode                                                        \
--start end-10d                                                         \
'DEF:pitemp=/usr/local/bin/system/pitemp.rrd:pitemp:AVERAGE'            \
'AREA:pitemp#FF6B10FF:CPU/GPU Temperature\:'                            \
'GPRINT:pitemp:LAST:\:%8.2lf %s]'

# SOC TEMP
    # 45D
$RRDTOOL graph /var/www/html/images/graphs/pitemp45d.png                \
--title 'Odin SoC Temperature 45 days'                                  \
--watermark "Graph Drawn `date`"                                        \
--vertical-label '°C'                                                   \
--alt-autoscale								\
--width '640'                                                           \
--height '300'                                                          \
--full-size-mode                                                        \
--start end-45d                                                         \
'DEF:pitemp=/usr/local/bin/system/pitemp.rrd:pitemp:AVERAGE'            \
'AREA:pitemp#FF6B10FF:CPU/GPU Temperature\:'                            \
'GPRINT:pitemp:LAST:\:%8.2lf %s]'

# SOC TEMP
    # 18M
$RRDTOOL graph /var/www/html/images/graphs/pitemp18m.png                \
--title 'Odin SoC Temperature 18 month'                                 \
--watermark "Graph Drawn `date`"                                        \
--vertical-label '°C'                                                   \
--alt-autoscale								\
--width '640'                                                           \
--height '300'                                                          \
--full-size-mode                                                        \
--start end-1y6m                                                        \
'DEF:pitemp=/usr/local/bin/system/pitemp.rrd:pitemp:AVERAGE'            \
'AREA:pitemp#FF6B10FF:CPU/GPU Temperature\:'                            \
'GPRINT:pitemp:LAST:\:%8.2lf %s]'

# SOC TEMP
    # 10Y
$RRDTOOL graph /var/www/html/images/graphs/pitemp10y.png                \
--title 'Odin SoC Temperature 10 year'                                  \
--watermark "Graph Drawn `date`"                                        \
--alt-autoscale		                                                \
--lower-limit '30'                                                      \
--width '640'                                                           \
--height '300'                                                          \
--full-size-mode                                                        \
--start end-10y                                                         \
'DEF:pitemp=/usr/local/bin/system/pitemp.rrd:pitemp:AVERAGE'            \
'AREA:pitemp#FF6B10FF:CPU/GPU Temperature\:'                            \
'GPRINT:pitemp:LAST:\:%8.2lf %s]'

#FOR THE MENU SCREEN
$RRDTOOL graph /var/www/html/images/graphs.png                          \
--lower-limit '0'                                                       \
--rigid                                                                 \
--units=si                                                              \
--width '288'                                                           \
--height '164'                                                          \
--x-grid 'none'								\
--y-grid 'none'								\
--full-size-mode                                                        \
--start end-45d                                                         \
'DEF:rx=/usr/local/bin/system/data.rrd:rx:AVERAGE'                      \
'DEF:tx=/usr/local/bin/system/data.rrd:tx:AVERAGE'                      \
'AREA:rx#00CC00FF'                                                      \
'STACK:tx#0000FFFF'
