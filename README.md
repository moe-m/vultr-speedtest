# Vultr-Speedtest

Script to benchmark bandwidth and latency to Vultr's 16 globally distributed data centers.


## Disclaimer

This script can use up to `1.6 GB` of bandwidth: `100MB File x 16 Servers = 1600 MB`


## Quick Start

```bash
(curl -s https://raw.githubusercontent.com/moe-m/vultr-speedtest/master/vultr_speedtest.sh | bash) 2>&1 | tee vultr_speedtest_$(date +'%Y-%m-%d %H:%M:%S %Z').log
```

## Usage

```bash
git clone https://github.com/moe-m/vultr-speedtest.git
cd vultr-speedtest
bash vultr_speedtest.sh
```

##  Servers


|    Location     |     Server (Latency)     |                   File (Bandwidth)                   |
|-----------------|--------------------------|------------------------------------------------------|
| Toronto, Canada | tor-ca-ping.vultr.com    | https://tor-ca-ping.vultr.com/vultr.com.100MB.bin     |
| Newark, NJ      | nj-us-ping.vultr.com     | https://nj-us-ping.vultr.com/vultr.com.100MB.bin     |
| Chicago, IL     | il-us-ping.vultr.com     | https://il-us-ping.vultr.com/vultr.com.100MB.bin     |
| Atlanta, GA     | ga-us-ping.vultr.com     | https://ga-us-ping.vultr.com/vultr.com.100MB.bin     |
| Seattle, WA     | wa-us-ping.vultr.com     | https://wa-us-ping.vultr.com/vultr.com.100MB.bin     |
| Miami, FL       | fl-us-ping.vultr.com     | https://fl-us-ping.vultr.com/vultr.com.100MB.bin     |
| Dallas, TX      | tx-us-ping.vultr.com     | https://tx-us-ping.vultr.com/vultr.com.100MB.bin     |
| San Jose, CA    | sjo-ca-us-ping.vultr.com | https://sjo-ca-us-ping.vultr.com/vultr.com.100MB.bin |
| Los Angeles, CA | lax-ca-us-ping.vultr.com | https://lax-ca-us-ping.vultr.com/vultr.com.100MB.bin |
| Frankfurt, DE   | fra-de-ping.vultr.com    | https://fra-de-ping.vultr.com/vultr.com.100MB.bin    |
| Amsterdam, NL   | ams-nl-ping.vultr.com    | https://ams-nl-ping.vultr.com/vultr.com.100MB.bin    |
| Paris, FR       | par-fr-ping.vultr.com    | https://par-fr-ping.vultr.com/vultr.com.100MB.bin    |
| London, UK      | lon-gb-ping.vultr.com    | https://lon-gb-ping.vultr.com/vultr.com.100MB.bin    |
| Singapore       | sgp-ping.vultr.com       | https://sgp-ping.vultr.com/vultr.com.100MB.bin       |
| Tokyo, JP       | hnd-jp-ping.vultr.com    | https://hnd-jp-ping.vultr.com/vultr.com.100MB.bin    |
| Sydney, AU      | syd-au-ping.vultr.com    | https://syd-au-ping.vultr.com/vultr.com.100MB.bin    |


## Example output

Output using a $10/month x1 CPU/2GB RAM Vultr server located in San Jose, California.
```bash

------------------------------------------------
    Vultr Speedtest Benchmark
    2019-06-02 00:36:05 UTC

    IP:    45.63.XX.XX
    Domain:    domain.com
    Location:    San Jose, California 95113 US
    Lat/Long:    37.3387,-121.8910
    Org:    AS20473 Choopa, LLC


    OS:    Ubuntu 18.04.1 LTS (Linux 4.15.0-30-generic x86_64)
    CPU:    Virtual CPU 82d9ed4018dd @ 2600.000 MHz
    CPU Cores:    1 (1 threads)
    Memory:    1.9G
    AES-NI:    True
    Disks:    vda     40G  HDD

-------------------------------------------------
Location	Latency 	Size    	MegaBytes/s	Megabits/s

Toronto, Canada	60 ms   	100MB   	40.0 MB/s	335.5 Mb/s
Newark, NJ	67 ms   	100MB   	36.4 MB/s	305.3 Mb/s
Chicago, IL	54 ms   	100MB   	41.9 MB/s	351.4 Mb/s
Atlanta, GA	59 ms   	100MB   	35.4 MB/s	296.9 Mb/s
Seattle, WA	20 ms   	100MB   	62.2 MB/s	521.7 Mb/s
Miami, FL	66 ms   	100MB   	28.8 MB/s	241.5 Mb/s
Dallas, TX	39 ms   	100MB   	60.6 MB/s	508.3 Mb/s
San Jose, CA	0 ms    	100MB   	143 MB/s	1199.5 Mb/s
Los Angeles, CA	8 ms    	100MB   	178 MB/s	1493.1 Mb/s
Frankfurt, DE	143 ms  	100MB   	16.8 MB/s	140.9 Mb/s
Amsterdam, NL	142 ms  	100MB   	17.2 MB/s	144.2 Mb/s
Paris, FR	144 ms  	100MB   	16.9 MB/s	141.7 Mb/s
London, UK	140 ms  	100MB   	17.3 MB/s	145.1 Mb/s
Singapore	191 ms  	100MB   	12.4 MB/s	104.0 Mb/s
Tokyo, JP	108 ms  	100MB   	21.4 MB/s	179.5 Mb/s
Sydney, AU	189 ms  	100MB   	12.4 MB/s	104.0 Mb/s

```

