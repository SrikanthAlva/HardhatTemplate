//Git Commands
// if git is in older version follow the commands to upgrade in linux
git --version
sudo add-apt-repository -y ppa:git-core/ppa
sudo apt-get update
sudo apt-get install git -y
git --version

// Git Repo Commands
git init -b main
git add .
git commit -m "initial commit"
git remote add origin https://github.com/SrikanthAlva/hardhat-fund-me-ts.git
git remote -v
git push origin main
