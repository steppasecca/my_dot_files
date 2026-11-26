# Cyberpunk rice — sway / waybar / foot / rofi / mako / swaylock / yazi / lidm

Palette unica (sfondo `#0a0a12`, ciano `#00f0ff`, magenta `#ff2a6d`, giallo `#fcee0a`) e un solo font
(JetBrainsMono Nerd Font) per tutto. Wallpaper invariato.

## Installazione (a prova di errore)

```sh
cd ~/.dotfiles
git switch -c cyberpunk && git add -A && git commit -m "stato prima del rice" --allow-empty
tar xzf ~/Downloads/cyberpunk-rice.tar.gz -C ~/.dotfiles --strip-components=1
git diff --stat                          # rivedi cosa e' cambiato
./install.sh check                       # nessuna modifica: valida tutto
./install.sh apply --safe=45 foot rofi swaylock   # prima tappa, con rollback automatico
```

Tappe consigliate (una alla volta, `--safe=45` ripristina da solo se non confermi):
1. `foot rofi swaylock` 2. `waybar mako` 3. `yazi fish xdg` 4. `sway` (poi logout/login) 5. `sudo ./install.sh lidm`

## Fallback

| Cosa va storto | Rimedio |
|---|---|
| Una tappa non ti convince | `./install.sh rollback` (ripristina l'ultimo backup, byte per byte) |
| Hai dimenticato `--safe` e lo schermo e' rotto | da un terminale qualsiasi (o Ctrl+Alt+F3): `~/.dotfiles/install.sh rollback` |
| Sway non parte piu' dopo il login | Ctrl+Alt+F3, login, `~/.dotfiles/install.sh rollback`, poi Ctrl+Alt+F1 |
| Vuoi solo provare la config vecchia di sway | `sway -c ~/.local/state/dotfiles-rice/backup-*/orig/<n>/config` |
| Schermata lidm illeggibile | Ctrl+Alt+F2, login, `sudo ~/.dotfiles/install.sh rollback-lidm` (oppure `sudo cp /etc/lidm.ini.pre-rice /etc/lidm.ini`) |
| Cambio brusco, vuoi tornare al passato | `git switch main` nella repo e `./install.sh apply` (se i link puntano alla repo, basta il checkout) |

I backup stanno in `~/.local/state/dotfiles-rice/backup-DATA/` e non vengono mai cancellati.

## Programmi predefiniti via XDG (niente piu' vim/vlc hardcodati)

Un solo file, `bin/xdg-tools`, con quattro comandi (symlink creati da `install.sh apply xdg`):

| Comando | Cosa fa |
|---|---|
| `xdg-pick` | scegli i predefiniti (menu rofi, o fzf da terminale): terminal browser files editor video audio image pdf mail |
| `xdg-pick --show` / `--init [--force]` | mostra gli attuali / imposta quelli preferiti dove non c'e' una scelta esplicita |
| `xdg-launch ROLE [ARG]` | avvia l'app predefinita (usato da sway: `Super+Invio`, `Super+Shift+B`, `Super+Y`) |
| `xdg-run [--here] FILE...` | apre file con l'app predefinita del loro tipo MIME (usato da yazi) |
| `xdg-term [-e] [CMD]` | avvia il terminale scelto (`~/.config/xdg-terminals.list`) |

Per cambiare programma: `xdg-pick browser` (o `xdg-pick` da sola). Nessun file di config da modificare.
Per usare un altro selettore: `XDG_PICK_MENU="fuzzel -d" xdg-pick`.

## Cose da fare a mano dopo

- `wofi/` non e' piu' usato: `git rm -r wofi` quando sei soddisfatto. Idem `~/.config/swaync`.
- In `yazi/` cancella eventuali vecchie copie complete di `yazi.toml`/`keymap.toml` (qui ci sono solo le tue modifiche).
- Aggiungi `kanshi/` e `vim/` all'installazione se vuoi gestirli con lo stesso script (non li ho toccati).
