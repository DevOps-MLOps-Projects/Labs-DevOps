### Lab 9

To clone a specific branch `git clone -b <branchname> <remote-repo-url>`

```bash
git clone -b nodejs-docker-task https://github.com/abdelrahmanonline4/EFE-Labs-.git
```

remove git repo

```bash
rm -rf .git
```

initiate a new git repo

```bash
git init
```

create a new repo in github and add remote

```bash
git remote add origin https://github.com/mmsaeed509/Lab-9.git
```

push to github(I'm using an automated [**`git-push.sh`**](git-push.sh) script)

```bash

./git-push.sh -m "Added src code"

# or keep script to generate the commit msg
./git-push.sh
```

#### see `docker-build` branch for Docker Build File

```bash
git checkout docker-build
# or 
git switch docker-build
```