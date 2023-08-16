# Git Commands

## If git is in an older version follow the commands to upgrade to linux

```
git --version
sudo add-apt-repository -y ppa:git-core/ppa
sudo apt-get update
sudo apt-get install git -y
git --version
```

## Git Repo Commands

```
git init -b main
git add .
git commit -m "initial commit"
git remote add origin https://github.com/USERNAME/REPO_NAME.git
git remote -v
git push origin main
```

### Optional

```
git remote rm origin 
```

## Set the Username and Email in git globally or per project

### Set the username/email for a specific repository
```
git config user.name "Your project specific name"
git config user.email "your@project-specific-email.com"
```
Verify your settings:
```
git config --get user.name
git config --get user.email
```

### Set the username/email globally
```
git config --global user.name "Your global username"
git config --global user.email "your@email.com"
```
Verify your settings:
```
git config --global --get user.name
git config --global --get user.email
```
