# dotfiles

You can find all configs in the .config folder.

A NixOS config will be added soon.

## Screenshots
<img width="1917" height="1080" alt="image" src="https://github.com/user-attachments/assets/692cf30e-4b87-4729-a453-4111ca94b8e3" />
<img width="729" height="390" alt="image" src="https://github.com/user-attachments/assets/27ad9fbe-c246-42aa-a04f-cb212d72d572" />

## Notes
- For fish shell to work properly you need to install these plugins
```
curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher
  fisher install franciscolourenco/done
  fisher install PatrickF1/fzf.fish
  fisher install jorgebucaran/autopair.fish
  fisher install nickeb96/puffer-fish
  fisher install IlanCosman/tide@v6
  tide configure --auto --style=Rainbow --prompt_colors='True color' --show_time=No --rainbow_prompt_separators=Slanted --powerline_prompt_heads=Slanted --powerline_prompt_tails=Slanted --powerline_prompt_style='Two lines, character' --prompt_connection=Solid --powerline_right_prompt_frame=No --prompt_connection_andor_frame_color=Dark --prompt_spacing=Sparse --icons='Many icons' --transient=No
```
