# Set the prefix to `ctrl + a` instead of `ctrl + b`
unbind C-b
set-option -g prefix C-a
bind-key C-a send-prefix

# Mouse support
set -g mouse on

# Set the default terminal mode to 256color mode
set -g default-terminal "screen-256color"

# enable activity alerts
setw -g monitor-activity on
set -g visual-activity on

# Automatically set window title
set-window-option -g automatic-rename on
set-option -g set-titles on

# Use | and - to split a window vertically and horizontally instead of " and % respoectively
bind | split-window -h -c "#{pane_current_path}"
bind - split-window -v -c "#{pane_current_path}"
unbind '"'
unbind %

# Open ~/.tmux.conf in vim and reload settings on quit
unbind e
bind e new-window -n '~/.tmux.conf' "sh -c 'vim ~/.tmux.conf && tmux source ~/.tmux.conf'"

# Bind D to resize the window to be 8 lines smaller
bind D resize-pane -D 8

# Move around panes with hjkl, as one would in vim after pressing ctrl + w
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R

# Use shift + arrow key to move between windows in a session
bind -n S-Left  previous-window
bind -n S-Right next-window

# Use r to quickly reload tmux settings
unbind r
bind r \
	source-file ~/.tmux.conf \;\
	display 'Reloaded tmux config'

# Use m and M to toggle mouse mode on and off respectively
unbind m
unbind M
bind-key m \
	set -w mouse on \;\
	display 'Mouse mode on'

bind-key M \
	set -w mouse off \;\
	display 'Mouse mode off'


###############################################################################
############# Date/Time values that can be displayed in the status line
###############################################################################

# $(echo $USER) - shows the current username
# %a --> Day of week (Mon)
# %A --> Day of week Expanded (Monday)

# %b --> Month (Jan)
# %d --> Day (31)
# %Y --> Year (2017)

# %D --> Month/Day/Year (12/31/2017)
# %v --> Day-Month-Year (31-Dec-2017)

# %r --> Hour:Min:Sec AM/PM (12:30:27 PM)
# %T --> 24 Hour:Min:Sec (16:30:27)
# %X --> Hour:Min:Sec (12:30:27)
# %R --> 24 Hour:Min (16:30)
# %H --> 24 Hour (16)
# %l --> Hour (12)
# %M --> Mins (30)
# %S --> Seconds (09)
# %p --> AM/PM (AM)

# For a more complete list view: https://linux.die.net/man/3/strftime

###############################################################################
############# Settings
###############################################################################

# Refresh status line every 5 seconds
set -g status-interval 5

# Start window and pane indices at 1.
set -g base-index 1
set -g pane-base-index 1

# length of tmux status line
set -g status-left-length 30
set -g status-right-length 150

# Make active pane border blue
set -g pane-active-border-fg colour2

#Set the left and right status
set -g status-left '#[bg=colour7]#[fg=colour0] ❐ #S #[bg=colour8]#[fg=colour7]#[fg=colour1] ♥ #(~/dotfiles/battery.sh) #{?client_prefix,⌨️ ,} '
set -g status-right '#[fg=colour2]#(~/dotfiles/uptime.sh) #[fg=colour0]⮃ #[fg=colour4]#[bg=colour4]#[fg=colour0] #(~/dotfiles/music.sh) #[bg=colour4]#[fg=colour7]#[bg=colour7]#[fg=colour0] %b %d %H:%M '

# Set the background color
set -g status-bg colour8

#colour0 (black)
#colour1 (red)
#colour2 (green)
#colour3 (yellow)
#colour4 (blue)
#colour7 (white)
#colour5 colour6 colour7 colour8 colour9 colour10 colour11 colour12 colour13 colour14 colour15 colour16 colour17

#D ()
#F ()
#H (hostname)
#I (window index)
#P()
#S (session index)
#T (pane title)
#W (currnet task like vim if editing a file in vim or zsh if running zsh)

# customize how windows are displayed in the status line
set -g window-status-current-format "#[fg=colour8]#[bg=colour4]#[fg=colour117]#[bg=colour4] #I #[fg=colour231] #W #[fg=colour4]#[bg=colour8]"
set -g window-status-format "#[fg=colour244]#[bg=colour8]#I#[fg=colour240]  #W"

# Set the history limit so we get lots of scrollback.
setw -g history-limit 50000
