# Primer Dark for fzf (fish)
# SPDX-License-Identifier: MIT
#
# fish cannot source the POSIX snippet, so this file carries the same color set
# for fish users. Source it from ~/.config/fish/config.fish, or copy it into
# ~/.config/fish/conf.d/. Any color options already present are left untouched.

set -g FZF_DEFAULT_OPTS_PRIMER_DARK '--color=fg:#F0F6FC,bg:#0D1117,hl:#4493F8,fg+:#F0F6FC,bg+:#212830,hl+:#79C0FF,info:#D29922,prompt:#3FB950,pointer:#DB61A2,marker:#AB7DF8,spinner:#3FB950,header:#9198A1,header-bg:#010409,footer:#9198A1,footer-bg:#010409,border:#3D444D,label:#4493F8,list-fg:#F0F6FC,list-bg:#0D1117,selected-fg:#F0F6FC,selected-bg:#262C36,selected-hl:#79C0FF,preview-bg:#0D1117,preview-fg:#F0F6FC,preview-border:#3D444D,preview-label:#4493F8,preview-scrollbar:#656C76,input-bg:#010409,input-border:#3D444D,scrollbar:#656C76,separator:#2F3742,gutter:#0D1117,alt-bg:#151B23,alt-gutter:#151B23,ghost:#656C76,disabled:#656C76,query:#F0F6FC,nomatch:#656C76'

# Only append when no color option is already configured, so an existing fzf
# palette is never overwritten.
if not string match -q -- '*--color*' "$FZF_DEFAULT_OPTS"
    set -gx FZF_DEFAULT_OPTS (string trim -- "$FZF_DEFAULT_OPTS $FZF_DEFAULT_OPTS_PRIMER_DARK")
end
