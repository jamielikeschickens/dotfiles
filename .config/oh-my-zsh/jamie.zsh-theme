function get_smiley() {
	if [ $? != 0 ]; then
		echo "$emoji[dizzy_face]"
	else
		echo "$emoji[smiling_face_with_sunglasses]"
	fi
}

function user_at_host() {
	echo "%{$fg[cyan]%}%n@%{$fg[blue]%}%m%"
}

function print_cwd() {
	echo "%{$fg_bold[yellow]%}%~%{$reset_color%}"
}

function parse_git_branch() {
	ref=$(git symbolic-ref HEAD 2> /dev/null) || return
	GIT_PREFIX="$fg_bold[green]"
	GIT_SUFFIX="$reset_color"
	echo " %{$GIT_PREFIX%}("${ref#refs/heads/}")%{$GIT_SUFFIX%}"
}

ZSH_THEME_VIRTUALENV_PREFIX="%{$fg_bold[blue]%}"
ZSH_THEME_VIRTUALENV_SUFFIX="%{$reset_color%}"

ZSH_THEME_RVM_PREFIX="%{$fg_bold[red]%}"
ZSH_THEME_RVM_SUFFIX="%{$reset_color%}"
ZLE_RPROMPT_INDENT=0

PROMPT='$(get_smiley) $(user_at_host)\:$(print_cwd)$(parse_git_branch)$ '
#RPROMPT='$ZSH_THEME_VIRTUALENV_PREFIX$(virtualenv_prompt_info)$ZSH_THEME_VIRTUALENV_SUFFIX $ZSH_THEME_RVM_PREFIX$(rvm-prompt)$ZSH_THEME_RVM_SUFFIX'
