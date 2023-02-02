result=${PWD##*/}
cd ..
rm -r "C:\Program Files (x86)\World of Warcraft\_retail_\Interface\AddOns\BisAlert"
echo "Cleared old addon."
cp -r "./$result" "C:\Program Files (x86)\World of Warcraft\_retail_\Interface\Addons"
echo "Copied addon to Addons folder."
mv "C:\Program Files (x86)\World of Warcraft\_retail_\Interface\Addons\\$result" "C:\Program Files (x86)\World of Warcraft\_retail_\Interface\Addons\BisAlert"
rm -rf "C:\Program Files (x86)\World of Warcraft\_retail_\Interface\Addons\BisAlert\.git"
rm -rf "C:\Program Files (x86)\World of Warcraft\_retail_\Interface\Addons\BisAlert\.gitignore"
rm -rf "C:\Program Files (x86)\World of Warcraft\_retail_\Interface\Addons\BisAlert\build.sh"
rm -rf "C:\Program Files (x86)\World of Warcraft\_retail_\Interface\Addons\BisAlert\.vscode"
echo "Cleaned up git, renamed folder, vscode config and cleared up build steps."
read -p "Do you want to open the folder? y/n " choice
if [[ $choice == "y" ]]
then
    explorer "C:\Program Files (x86)\World of Warcraft\_retail_\Interface\Addons\BisAlert"
fi
 