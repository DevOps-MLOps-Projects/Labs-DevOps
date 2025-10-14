# TASK 1

- create the network

```bash
$ docker network create hr-app-net --subnet 192.168.20.0/24

21346aa112480940c4f7a61f86146bc2a2c8cbbb4c28b86ecb11e7dc34fe5e5c
```

- run nginx-server

```bash
$ docker run -d --name nginx-server --network hr-app-net nginx

Unable to find image 'nginx:latest' locally
latest: Pulling from library/nginx
8c7716127147: Pull complete
250b90fb2b9a: Pull complete
5d8ea9f4c626: Pull complete
58d144c4badd: Pull complete
b459da543435: Pull complete
8da8ed3552af: Pull complete
54e822d8ee0c: Pull complete
Digest: sha256:3b7732505933ca591ce4a6d860cb713ad96a3176b82f7979a8dfa9973486a0d6
Status: Downloaded newer image for nginx:latest
3694f5f2fc6dc014ddf57f4a340049751d5afdcd203de5a6b39ba12012f977bf
```


- run alpine-tester

```bash
$ docker run -it --name alpine-tester --network hr-app-net alpine

Unable to find image 'alpine:latest' locally
latest: Pulling from library/alpine
2d35ebdb57d9: Pull complete
Digest: sha256:4b7ce07002c69e8f3d704a9c5d6fd3053be500b7f1c69fc0d80990c2ad8dd412
Status: Downloaded newer image for alpine:latest
44f64fb6684603db6da31fac2378a61ed5e458c538a19556b9bd5a7ab0c0de1a
```



- network inspection (nginx-server)

```bash
$ docker inspect nginx-server | egrep "hr-app-net|Gateway|IPAddress"

            "NetworkMode": "hr-app-net",
            "SecondaryIPAddresses": null,
            "Gateway": "",
            "IPAddress": "",
            "IPv6Gateway": "",
                "hr-app-net": {
                    "Gateway": "192.168.20.1",
                    "IPAddress": "192.168.20.2",
                    "IPv6Gateway": "",
```


- network inspection (alpine-tester)

```bash
$ docker inspect alpine-tester | egrep "hr-app-net|Gateway|IPAddress"

            "NetworkMode": "hr-app-net",
            "SecondaryIPAddresses": null,
            "Gateway": "",
            "IPAddress": "",
            "IPv6Gateway": "",
                "hr-app-net": {
                    "Gateway": "",
                    "IPAddress": "",
                    "IPv6Gateway": "",
```


- Service Discovery Test

```bash
$ ping -c 5 nginx-server

PING nginx-server (192.168.20.2): 56 data bytes
64 bytes from 192.168.20.2: seq=0 ttl=64 time=0.031 ms
64 bytes from 192.168.20.2: seq=1 ttl=64 time=0.039 ms
64 bytes from 192.168.20.2: seq=2 ttl=64 time=0.047 ms
64 bytes from 192.168.20.2: seq=3 ttl=64 time=0.041 ms
64 bytes from 192.168.20.2: seq=4 ttl=64 time=0.041 ms

--- nginx-server ping statistics ---
5 packets transmitted, 5 packets received, 0% packet loss
round-trip min/avg/max = 0.031/0.039/0.047 ms
```

---

# TASK 2

- create networks 

```bash
$ docker network create frontend-net --subnet  10.1.1.0/24
5c453c6204c7b1ea160ed9fbe3b06d45fd3df04c55b79f639ebb756b8d619a65

$ docker network create backen-net --subnet  10.1.2.0/24
5497623b6ec1fd5f872636aa5a5a4a4e8d8d2a8c4851e26344903ae03688b6f1
```


- run nginx-lb

```bash
$ docker run -d --name nginx-lb --network frontend-net --network backen-net nginx
e1ca61852df5320f8eac16c3dfe3300f0d0853b826ec432286429135a69432bf

```


- 

```bash
$ docker run -it --name  backend-db --network backen-net alpine
ping: bad address 'client-tester'

```


- 

```bash
$ docker run -it --name  client-tester --network frontend-net  alpine
ping: bad address 'backend-db'
```


- docker inspect command on nginx-lb to confirm
that it has been assigned two distinct IP addresses (one from 10.1.1.x and one from

```bash
$ docker inspect nginx-lb | egrep "hr-app-net|Gateway|IPAddress"

            "SecondaryIPAddresses": null,
            "Gateway": "",
            "IPAddress": "",
            "IPv6Gateway": "",
                    "Gateway": "10.1.2.1",
                    "IPAddress": "10.1.2.3",
                    "IPv6Gateway": "",
                    "Gateway": "10.1.1.1",
                    "IPAddress": "10.1.1.2",
                    "IPv6Gateway": "",
```
