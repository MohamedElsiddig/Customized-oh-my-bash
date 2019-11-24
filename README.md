

**This is a modified version of Oh My Bash framework**
https://github.com/ohmybash/oh-my-bash

I have used some of bash-it framework functions and utilties (https://github.com/Bash-it/bash-it)
the completions directory changed from plural {completions} to {completion} as singular 
I have edited the custom bashrc and disabled the { plugin | completions | aliases } arrays

________________________________________________________________

* Added some of my collected function from bash_function (https://github.com/MohamedElsiddig/MyDotFiles) to **[ functions.sh ]** which are :

1. weather 
2. devhints 
3. man 
4. cheatsheets 
5. convert_to_mp3

* Changed $OSH/lib/base.sh to a plugin and added some of my collected functions which are:

1. mkcd 
2. up 
3. mkexecute 
4. extract 
5. oft 
6. mkarchive 
7. wirelessNetworksInRange

* and added base completion which contains mkarchive function completion

________________________________________________________________

* Added **(helpers | utilties | composure [Which contain helpfull functions])** form bash-it framework to OSH/lib
* Added My **connection** and **system-dignostics** scripts as plugins
* Added plugins or made plugins like from oh-my-zsh [just the idea of the plugin] **( fastfiles | clipboard | copydir | copyfile |copybuffer | sudo | man | web search )**
* Added plugins from bash-it **( dirs | explain |fasd | fzf | alias-completion | less-pretty-cat | gif | git-subrepo | autojump )**
* Added **has script** from github and turn it to a plugin
* Created a completion for **has script**
* Added **bd script** from github and turn it to a plugin with it completion
* Added completion for **bashing** [which is a small tool that let's you create single-file -Bash script- in a multi-file way from github] 
* Added completion for **bpkg** [which is a lightweight bash package manager. and it takes care of fetching the shell scripts, installing them appropriately, setting the execution permission and more.] 
* Edited Fasd plugin to be complete command 
* Replacd Progress plugin with this one [https://github.com/edouard-lopez/progress-bar.sh]
* Added **( Systemd | fzf-marks | sd [wd clone for bash] | bash-insulter | repeat-history | enhanced-cd | q-registers | forgit | prm | fkill-cli | pkgsearch | bash-autopairs | any-bash  | ssh-connect | dirhistory | bash-navigator | zsh-cd-clone | cd-reminder | autoenv )** plugins
* Added **( fuzzy-completion | prm )** completion
* Added **( git-open | git-switch )** functions to git plugin 
* Added autoload and chpwd to lib/
________________________________________________________________

* Added Auto Enabling for completions related to plugins if found and added this line to bashrc **The completion name must be the same of the plugin name**
```bash

#Automatically enable completions related to plugins if found
#change it to [disable] if you want to disable it
export AUTO_ENABLING="enable"

```

* Added the following lines of code to **_enable-thing ()** function which can be found in lib/helpers.sh from line **(381 to 385)**

```bash
   if [[ ${file_type} == "plugin" ]]
      then
            new_to_enable=${to_enable%%.plugin.sh}
            _OSH-auto-enabling-completions $new_to_enable
    fi

```
 
* After adding previous lines I added the **_OSH-auto-enabling-completions ()** function from line **(447 to 517)**

* The Function check if the input has completion if it does and the environmet variable **AUTO_ENABLING** is assigned to enable it's enable the completion

```bash

function _OSH-auto-enabling-completions()
{
  
  enabled_elements=`_OSH-component-help "completion" | awk '{print $1}' | grep "^${new_to_enable}$" | uniq | sort | tr '\n' ' '`
  for is_enabed in ${enabled_elements[@]}
    do
        _OSH-component-item-is-enabled completion ${is_enabed}
        if [[ "$?" != "0" ]] && [[ "${AUTO_ENABLING}" == "enable" ]] 
          then
            source "${OSH}/themes/colours.theme.sh"
            source "${OSH}/themes/base.theme.sh"
            echo ""
            echo -e "$echo_bold_green Enabling ${new_to_enable} plugin completion${echo_normal}"
            sleep 1
            _enable-completion ${is_enabed}


fi
  done
}

``` 
  
* If you want to add the completion with different name <Not the same name of the plugin> add those lines to your plugins to enable the completion you want for it

## You can take an example the commented lines in **( apt | fastfiles | dirs | projects )** plugins which contains the following script lines 

## NOTES ABOUT THE BELLOW SCRIPT LINES

[

	* completion-name - < Is the desired completion name to enable >
	* plugin-name - < The name of plugin that you want to enable it's completion >
	* _OSH-component-item-is-enabled completion completion-name - < This line check if the completion is enabled >

]

```bash

#Automatically enable [plugin-name] completion

_OSH-component-item-is-enabled completion completion-name

if [[ "$?" != "0" ]] && [[ "${AUTO_ENABLING}" == "enable" ]]
	then
		source "${OSH}/themes/colours.theme.sh"
		source "${OSH}/themes/base.theme.sh"
		echo ""
		echo -e "$echo_bold_green Enabling plugin-name plugin completion${echo_normal}"
		sleep 1
		_enable-completion completion-name

fi
```

* Added Auto Disabling to some completions if their main plugins are not enabled Those completion are **( apt | fastfiles | dirs | projects )**

##The code


```bash
if [[ `declare -F Func-name-in-the-main-plugin` ]]
	then
		#completions commands go heres
	else
		echo ""
		sleep 1
		source "${OSH}/themes/colours.theme.sh"
		source "${OSH}/themes/base.theme.sh"
		echo -e "${echo_bold_yellow}[WARRNING]${echo_normal} completion-name completion won't work without plugin-name plugin.. Please make sure that it's enabled ${echo_normal}"
		echo ""
		sleep 1
		echo -e "${echo_bold_cyan}[INFO]${echo_normal} Disabling it to make sure that it dosen't effect the bash startup time${echo_normal}"
		sleep 1
		_disable-completion completion-name
fi


````

## NOTES ABOUT THE PREVIOUS SCRIPT LINES

[

	* Func-name-in-the-main-plugin < Is the function name in the main plugin >
	* completion-name - < Is the name of completion name to disable >
	* plugin-name - < The name of plugin that the completion script referes to >
	* _disable-completion completion-name - < This line disable the completion >

]




________________________________________________________________

* Added those lines from bash-it.sh in oh-my-bash.sh file 
  to load the reloader script
  
# Load enabled aliases, completion, plugins
```bash
 
 source "${OSH}/scripts/reloader.sh"
 
for file_type in "aliases" "plugins" "completion"
do
  # shellcheck source=./scripts/reloader.bash
  source "${OSH}/scripts/reloader.sh" "skip" "$file_type"
done
```
________________________________________________________________

* Added show-enabled option to oh-my-bash [ Which can be found in lib/helpers.sh ] function which print all enabled components **(aliases plugins completion)** 

##function code
```bash

_OSH-show-enabled()
{
printf '%s' 'please wait, Getting enabled features...' && sleep 3
 printf '%s\n'
 
feature=("aliases" "plugins" "completion")
for i in ${feature[@]} 
	do
		sleep 1
		echo -e "\t" -------------${echo_bold_green} Enabled $i ${echo_normal}------------- 
		sleep 1
		echo ""
		_OSH-component-help "$i" | $(_OSH-grep) -E  '\[x\]'
		echo ""
done 
}


```

________________________________________________________________

* If you want to install new plugin make sure to put it without it's directory and put it under plugins dir

eg: 
	from:
*		`$OSH/plugins/plugin-name/some.plugin.sh`
	to:
*		`$OSH/plugins/some.plugin.sh`
		
after you add it remember to add descibition to the plugin or the aliases
eg:
* `cite about-plugin | about-alias`
* `about-plugin 'This plugin change themes'`

* I haved merged the two methods [the old and the new one] so if any plugin could be added as single executable file use the above method if not the add the folder of plugin to the plugins directory and add the plugin name in the plugin array in the bashrc [I did that because there are cli programs has libraries and if i want to apply it as single file it will take alot of time]
________________________________________________________________

Have fun 
