# [**`Docker Network Configuration and Service`**](https://github.com/mmsaeed509/Labs-DevOps/tree/master/Lab-1)

## Lab Objectives:
-  Custom Bridge Network Creation
-  IP Address Allocation and Management
- Service Discovery and Internal Connectivity
- Multi-Network Container Setup
- Network Isolation and Security Validation

# Task 1

### Requirements:

- Create Custom Bridge Network
- Verify Network Configuration
- Run the Containers:
- Verify IP Addresses
- Test Service Discovery

#### Create Custom Bridge Network

- Create a network ***hr-app-ne***: `docker network create hr-app-net`
 
- Network Type: **Custom Bridge**
  - use this flag: `--driver bridge`

- :Dedicated Subnet `192.168.20.0/24`
  - use this flag`--subnet 192.168.20.0/24`

- Gateway: `192.168.20.1`
  - use this flag`--gateway 192.168.20.1`

Combine all flags into one command:

```bash
docker network create \
  --driver bridge \
  --subnet 192.168.20.0/24 \
  --gateway 192.168.20.1 \
  hr-app-net
```
output: `5e4170bd30ba9a2cefd6d5624bcf7aff30f23c3230b8446bf8783a4bb6604f6a`

#### Verify Network Configuration

run this command to get network info `docker network inspect hr-app-net`

```bash
[
    {
        "Name": "hr-app-net",
        "Id": "5e4170bd30ba9a2cefd6d5624bcf7aff30f23c3230b8446bf8783a4bb6604f6a",
        "Created": "2025-10-24T02:23:48.86498217+03:00",
        "Scope": "local",
        "Driver": "bridge",
        "EnableIPv4": true,
        "EnableIPv6": false,
        "IPAM": {
            "Driver": "default",
            "Options": {},
            "Config": [
                {
                    "Subnet": "192.168.20.0/24",
                    "Gateway": "192.168.20.1"
                }
            ]
        },
        "Internal": false,
        "Attachable": false,
        "Ingress": false,
        "ConfigFrom": {
            "Network": ""
        },
        "ConfigOnly": false,
        "Containers": {},
        "Options": {},
        "Labels": {}
    }
]
```

 or `docker network inspect hr-app-net | egrep "Subnet|Gateway"` to get only `Subnet` and `Gateway` info

```bash
docker network inspect hr-app-net | egrep "Subnet|Gateway"
                    "Subnet": "192.168.20.0/24",
                    "Gateway": "192.168.20.1"
```

#### Run the Containers:
 
run **nginx**: `docker run -d --name nginx-server --network hr-app-net nginx`

```bash
Unable to find image 'nginx:latest' locally
latest: Pulling from library/nginx
38513bd72563: Pull complete
10d18f46ee87: Pull complete
a8d825a0683a: Pull complete
a131bc1d4bd5: Pull complete
3818929ac19f: Pull complete
1498b1cfda15: Pull complete
c50c84d0ed4d: Pull complete
Digest: sha256:029d4461bd98f124e531380505ceea2072418fdf28752aa73b7b273ba3048903
Status: Downloaded newer image for nginx:latest
5e5a8183b33d8c720e3fbe8fadaada9aa34e15c7d6a377dc1d91b469845e550a
```
 
run **alpine**: `docker run -it --name alpine-tester --network hr-app-net alpine sh`

```bash
Unable to find image 'alpine:latest' locally
latest: Pulling from library/alpine
2d35ebdb57d9: Pull complete
Digest: sha256:4b7ce07002c69e8f3d704a9c5d6fd3053be500b7f1c69fc0d80990c2ad8dd412
Status: Downloaded newer image for alpine:latest
/ #
```
> don't close the terminal, and open a new one to make the `alpine-tester` run


#### Verify IP Addresses

to  Verify IP use `docker inspect nginx-server | egrep "Gateway|IPAddress"`
> use `grep` or `egrep` to get only **Gateway|IPAddress** info

```bash
            "SecondaryIPAddresses": null,
            "Gateway": "",
            "IPAddress": "",
            "IPv6Gateway": "",
                    "Gateway": "192.168.20.1",
                    "IPAddress": "192.168.20.2",
                    "IPv6Gateway": "",
```

as same as for `alpine-tester`, run `docker inspect alpine-tester | egrep "Gateway|IPAddress"`

```bash
            "SecondaryIPAddresses": null,
            "Gateway": "",
            "IPAddress": "",
            "IPv6Gateway": "",
                    "Gateway": "192.168.20.1",
                    "IPAddress": "192.168.20.3",
                    "IPv6Gateway": "",

```

#### Test Service Discovery

to Verify Discovery  **ping** from `alpine-tester` to  `nginx-server`
run `ping -c 4 nginx-server` 
> `-c` flag is to set No. send requests

```bash
PING nginx-server (192.168.20.2): 56 data bytes
64 bytes from 192.168.20.2: seq=0 ttl=64 time=0.081 ms
64 bytes from 192.168.20.2: seq=1 ttl=64 time=0.053 ms
64 bytes from 192.168.20.2: seq=2 ttl=64 time=0.073 ms
64 bytes from 192.168.20.2: seq=3 ttl=64 time=0.071 ms

--- nginx-server ping statistics ---
4 packets transmitted, 4 packets received, 0% packet loss
round-trip min/avg/max = 0.053/0.069/0.081 ms
```

#### To Cleanup 

```bash
docker rm -f nginx-server alpine-tester
docker network rm hr-app-net
```

---

# Task 2

### Requirements:

- Create Network 1 (For Frontend)
- Create Network 2 (For Backend)
- Containers Configuration:

#### Create Network 1 (For Frontend)

  - Name: `frontend-net`
  - Dedicated Subnet: `10.1.1.0/24`

```bash
docker network create \
  --driver bridge \
  --subnet 10.1.1.0/24 \
  frontend-net
```
output `532acdb88a63bae52b1194713b28af5ccdd948b2e55426e1cdf4b3cc5b0e09f4`

#### Create Network 2 (For Backend)

  - Name: `backend-net`
  - Dedicated Subnet: `10.1.2.0/24`

```bash
docker network create \
  --driver bridge \
  --subnet 10.1.2.0/24 \
  backend-net
```
output `a8a40832faa273a2004d80ee83acca0bedc150c4624cc181c9cb945ff0421ad4`


#### Containers Configuration and Running:
  - `nginx-lb` (Load Balancer): Must be connected to both `frontend-net` and `backend-net` (Multi-Homed).
  - `client-tester` (Client): Must be connected only to `frontend-net`.
  - `backend-db` (Service): Must be connected only to `backend-net`.


run the `backend-db` Container:

```bash
docker run -it --name backend-db --network backend-net alpine sh
```
> don't close the terminal, and open a new one to make the `backend-db` run


run the `client-tester` Container:

```bash
docker run -it --name client-tester --network frontend-net alpine sh
```
> don't close the terminal, and open a new one to make the `frontend-db` run

run the `nginx-lb` Container:

```bash
docker run -d --name nginx-lb --network frontend-net --network backen-net nginx

# or
docker run -d --name nginx-lb \
  --network frontend-net nginx

docker network connect backend-net nginx-lb

# or 
docker run -d --name nginx-lb \
  --network backend-net nginx

docker network connect frontend-net nginx-lb
```

I'm gonna use 

```bash
docker run -d --name nginx-lb --network frontend-net --network backend-net nginx
```
output `3633d39c62ef573fa92d2c52d1b789e07cc088e120bec99d83471a0c6a0ef93b`

#### Verify IP Allocation

run: `docker inspect nginx-lb | egrep  "Gateway|IPAddress"`

```bash
            "SecondaryIPAddresses": null,
            "Gateway": "",
            "IPAddress": "",
            "IPv6Gateway": "",
                    "Gateway": "10.1.2.1",
                    "IPAddress": "10.1.2.3",
                    "IPv6Gateway": "",
                    "Gateway": "10.1.1.1",
                    "IPAddress": "10.1.1.3",
                    "IPv6Gateway": "",

```

#### Test Network Isolation and Routing

From inside `client-tester`, try to ping `backend-db` (or opposite):

```bash
$ docker run -it --name backend-db --network backend-net alpine sh

# backend-net terminal
/ # ping -c 4 frontend-net
ping: bad address 'frontend-net'
/ #
```
Now from `nginx-lb`, ping both sides: `docker exec -it nginx-lb sh`

```bash
$ ping -c 4 backend-db
sh: 7: ping: not found

# install ping
$ apt update
$ apt upgrade
$ apt install iputils-ping

$ ping -c 4 backend-db

PING backend-db (10.1.2.2) 56(84) bytes of data.
64 bytes from backend-db.backend-net (10.1.2.2): icmp_seq=1 ttl=64 time=0.071 ms
64 bytes from backend-db.backend-net (10.1.2.2): icmp_seq=2 ttl=64 time=0.040 ms
64 bytes from backend-db.backend-net (10.1.2.2): icmp_seq=3 ttl=64 time=0.040 ms
64 bytes from backend-db.backend-net (10.1.2.2): icmp_seq=4 ttl=64 time=0.043 ms

--- backend-db ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 3048ms
rtt min/avg/max/mdev = 0.040/0.048/0.071/0.013 ms

$ ping -c 4 client-tester

PING client-tester (10.1.1.2) 56(84) bytes of data.
64 bytes from client-tester.frontend-net (10.1.1.2): icmp_seq=1 ttl=64 time=0.098 ms
64 bytes from client-tester.frontend-net (10.1.1.2): icmp_seq=2 ttl=64 time=0.038 ms
64 bytes from client-tester.frontend-net (10.1.1.2): icmp_seq=3 ttl=64 time=0.043 ms
64 bytes from client-tester.frontend-net (10.1.1.2): icmp_seq=4 ttl=64 time=0.039 ms

--- client-tester ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 3106ms
rtt min/avg/max/mdev = 0.038/0.054/0.098/0.025 ms
```


#### To Cleanup

```bash
docker rm -f nginx-lb backend-db client-tester
docker network rm frontend-net backend-net
```

