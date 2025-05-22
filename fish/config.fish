if status is-interactive
    # Commands to run in interactive sessions can go here
end

# yazi helper
function y
	set tmp (mktemp -t "yazi-cwd.XXXXXX")
	yazi $argv --cwd-file="$tmp"
	if set cwd (command cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
		builtin cd -- "$cwd"
	end
	rm -f -- "$tmp"
end

# default conf

set -g theme_color_scheme jellybeans
set -g fish_key_bindings fish_vi_key_bindings
set -g theme_newline_cursor yes
set -g theme_nerd_fonts yes
set -g fish_prompt_pwd_dir_length 0

# Remove the gretting message.
set -U fish_greeting

# Vi mode.
set -g fish_key_bindings fish_vi_key_bindings
set fish_vi_force_cursor 1
set fish_cursor_default block
set fish_cursor_insert line
set fish_cursor_replace_one underscore

fzf_configure_bindings --directory=\cp

#path

fish_add_path /opt/bin
fish_add_path $HOME/.binlinks/
fish_add_path $HOME/.local/bin/
fish_add_path $HOME/.juliaup/bin
fish_add_path $HOME/.venvs/nvim/bin/
fish_add_path /snap/bin/

alias open=xdg-open
alias jl=jupyter-lab


set -gx MOZ_ENABLE_WAYLAND 1
set -gx AWS_PROFILE default
set -gx JULIA_NUM_THREADS 8

# pyenv
#set -Ux PYENV_ROOT $HOME/.pyenv
#set -U fish_user_paths $PYENV_ROOT/bin $fish_user_paths
#pyenv init - | source


# Add completions from stuff installed with Homebrew.
if test "$os" = Darwin
    eval "$(/opt/homebrew/bin/brew shellenv)"
    if test -d (brew --prefix)"/share/fish/completions"
        set -p fish_complete_path (brew --prefix)/share/fish/completions
    end
    if test -d (brew --prefix)"/share/fish/vendor_completions.d"
        set -p fish_complete_path (brew --prefix)/share/fish/vendor_completions.d
    end
end

# theme

function bobthefish_colors -S -d 'Define a custom bobthefish color scheme'

    #___bobthefish_colors default
set -l orange bf8b56 
set -l light_green 56bf8b
set -l olive 8bbf56
set -l blue 568bbf 
set -l pink bf568b
set -l light_grey cbd6e2 
set -l dark_grey 627e99 
set -l violet 8b56bf 
set -l white f7f9fb 
set -l yellow bfbf56
set -l red bf5656
set -l darker_grey 223b54
set -l grey 405c79
set -l grey2 e5ebf1

  # then override everything you want! note that these must be defined with `set -x`
  set -x color_initial_segment_exit    $red $white  --bold
  set -x color_initial_segment_private $light_grey $dark_grey --bold
  set -x color_initial_segment_su      $orange $darker_grey --bold
  set -x color_initial_segment_jobs    $pink $darker_grey --bold
  set -x color_path  $darker_grey $light_grey
  set -x color_path_nowrite  $darker_grey $pink
  set -x color_path_basename  $darker_grey $light_grey
  set -x color_path_basename_nowrite  $darker_grey $pink
  set -x color_repo  $orange $white 
  set -x color_repo_work_tree  $pink $white 
  set -x color_repo_work_dirty  $red $white 
  set -x color_repo_work_staged  $violet $white 
  set -x color_vi_mode_default $violet $light_grey
  set -x color_vi_mode_insert $light_green $light_grey
  set -x color_vi_mode_visual $red $light_grey
  #  set -x color_vagrant                  48b4fb ffffff --bold
  #  set -x color_aws_vault
  #  set -x color_aws_vault_expired
  #  set -x color_username                 cccccc 255e87 --bold
  #  set -x color_hostname                 cccccc 255e87
  #  set -x color_rvm                      af0000 cccccc --bold
  #  set -x color_virtualfish              005faf cccccc --bold
  #  set -x color_virtualgo                005faf cccccc --bold
  #  set -x color_desk                     005faf cccccc --bold
  #  set -x color_nix                      005faf cccccc --bold
end










