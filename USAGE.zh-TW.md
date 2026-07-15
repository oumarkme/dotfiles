# 終端開發環境使用說明書

一套跨 **macOS / Ubuntu / WSL-Ubuntu** 的純終端開發環境。核心是 **bash + tmux +
Neovim(LazyVim) + Claude Code**，搭配 `yazi`、`lazygit`、`delta` 等現代 CLI 工具，
全套採 **GitHub Dark** 配色。本文件為日常操作與速查手冊。

---

## 目錄

1. 這套環境的組成與心智模型
2. 安裝
3. 安裝後的首次設定
4. 日常工作流程
5. tmux 操作速查
6. Neovim / LazyVim 操作速查
7. R / Python REPL 工作流（vim-slime）
8. lazygit 操作速查
9. yazi 操作速查
10. CLI 工具速查
11. 滑鼠使用
12. 三台機器的差異與 `gs4`
13. 客製化與多機同步
14. 疑難排解
15. 移除與還原

---

## 1. 這套環境的組成與心智模型

| 層 | 工具 | 負責 |
|---|---|---|
| 終端機 | Terminal.app（mac）／Windows Terminal（WSL） | 視窗（配色由設定檔自己畫） |
| 多工 | tmux | session / window / pane、斷線續存 |
| 編輯 | Neovim + LazyVim | 編輯、語法高亮、LSP、檔案樹 |
| AI | Claude Code | 主要開發代理，寫程式與重構 |
| 檔案 | yazi | 檔案瀏覽與預覽 |
| 版本 | lazygit + delta | git 操作與 diff 檢視 |
| 導航 | fzf / ripgrep / fd / zoxide / eza / bat / btop | 搜尋、跳轉、列表、預覽、監控 |

**心智模型：一個專案一個 tmux session，一個功能一個 window。** Claude Code 負責大量
產出，你在旁邊用 lazygit 逐檔 review、用 Neovim 小修、用 yazi 找檔。鍵盤導航為主，
滑鼠隨時可用。

---

## 2. 安裝

```bash
git clone https://github.com/oumarkme/dotfiles ~/dotfiles
cd ~/dotfiles
./install.sh              # 只連結設定 + 初始化 TPM/LazyVim（工具已裝時用）
./install.sh --packages   # 新機器：先用 Homebrew 裝好整套 CLI 工具再連結
```

`install.sh` 為**非破壞性**：連結前會把既有檔案備份到 `~/.dotfiles_backup_<時間戳>/`，
你原本的 `~/.bashrc`、`~/.gitconfig` 保留不動（只加一行 `source` 與一條 `include.path`）。

---

## 3. 安裝後的首次設定

安裝腳本結尾會列出這幾步，務必手動完成：

1. **Nerd Font**
   - macOS：`--packages` 已裝好（cask）。
   - 原生 Ubuntu：字型放到 `~/.local/share/fonts/` 後 `fc-cache -f`。
   - **WSL：字型要裝在 Windows 端**（在 WSL 裡裝沒用），再到 Windows Terminal 選它。
2. **不需要設定終端機**：兩個終端的 GitHub Dark 主題你已自行設好，這裡不用再動。
   工具一律用 ANSI 顏色，因此 tmux／lazygit／yazi／fzf 會**精確跟隨**你設好的
   調色盤（兩台都一致）；Neovim 在 Windows Terminal 走 truecolor 主題、在
   Terminal.app 走終端 ANSI 盤（256 色）。圖示採 ASCII（免 Nerd Font）；想要圖示就
   安裝 Nerd Font、在終端選它，再開啟 `have_nerd_font`／`nerdFontsVersion`。

3. **tmux 外掛**：進 tmux 後按 `prefix + I`（大寫 i）安裝 TPM 外掛。
4. **Neovim**：開一次 `nvim`，等 lazy.nvim 同步完，再執行 `:checkhealth` 確認無誤。
5.（選用）想要 Windows Terminal 呈現**精確** GitHub Dark ANSI 盤，可把
   `windows-terminal/github-dark.json` 貼進設定的 `schemes` 並套用；不做也沒關係，
   預設深色盤已夠接近。

> 本文所有 `prefix` 皆指 tmux 預設的 **`Ctrl-b`**。Neovim 的 `<leader>` 為 **空白鍵**。

---

## 4. 日常工作流程

```bash
# 開一個專案（不存在就建立，存在就接回）
t fshd

# 或直接開「上編輯、下雙 shell」的版面
dev fshd
```

`dev` 會開好：上方一個大 pane 跑 `nvim`，下方兩個小 shell（一個丟 job、一個雜務）。
典型節奏：

1. `t nf-fshd` 進專案，window 1 跑 Claude Code 交付任務。
2. Claude 改完，按 `prefix + g` 彈出 lazygit 逐檔 review、stage、commit。
3. 需要手改就切到 nvim window（或 `dev` 版面的上 pane）微調。
4. 要投 job 到遠端：在某個 shell pane `ssh gs4`，在那邊的 tmux session 裡跑。
5. 收工 `prefix + d` detach，job 與版面都留著，下次 `t nf-fshd` 原樣回來。

---

## 5. tmux 操作速查

### Session / Window
| 按鍵 | 動作 |
|---|---|
| `t <名稱>` | 接回或新建 session（bash 函式） |
| `dev <名稱>` | 開「上編輯下雙 shell」版面（bash 函式） |
| `prefix + d` | detach（離開但保留） |
| `prefix + s` | session 列表 |
| `prefix + c` | 新 window（沿用當前目錄） |
| `prefix + 數字` | 切到第 N 個 window |
| `prefix + w` | window 列表 |
| `prefix + &` | 關閉當前 window |

### Pane
| 按鍵 | 動作 |
|---|---|
| `prefix + \|` | 左右分割（vertical split） |
| `prefix + -` | 上下分割（horizontal split） |
| `Ctrl-h/j/k/l` | 在 pane 間移動（且會無縫進出 Neovim 分割視窗） |
| `prefix + z` | 放大／還原當前 pane（專注） |
| `prefix + x` | 關閉當前 pane |
| 拖曳 pane 邊界 | 用滑鼠調整大小 |

### 彈出視窗與雜項
| 按鍵 | 動作 |
|---|---|
| `prefix + g` | 彈出 lazygit（關掉即回原畫面） |
| `prefix + e` | 彈出 yazi 檔案瀏覽 |
| `prefix + [` | 進 copy-mode（可用 vi 鍵捲動／選取） |
| `prefix + r` | 重新載入 `~/.tmux.conf` |
| `prefix + I` | 安裝 TPM 外掛（首次設定用） |
| `prefix + Ctrl-s` / `prefix + Ctrl-r` | 儲存／還原 session（resurrect） |

---

## 6. Neovim / LazyVim 操作速查

`<leader>` = 空白鍵。按下 `<leader>` 稍等會跳出 which-key 選單，忘記按鍵時很好用。

### 檔案與搜尋
| 按鍵 | 動作 |
|---|---|
| `<leader>e` | 開／關 neo-tree 檔案樹 |
| `<leader>ff` | 找檔案（find files） |
| `<leader>fg` | 全專案內容搜尋（live grep，用 ripgrep） |
| `<leader>fr` | 最近開過的檔案 |
| `<leader>fb` | 切換已開 buffer |

### 檔案樹（neo-tree）內
| 按鍵 | 動作 |
|---|---|
| `Enter` | 開檔 |
| `s` | 在**垂直分割**開檔（左右並排） |
| `S` | 在**水平分割**開檔 |
| `a` / `d` / `r` | 新增／刪除／改名 |

### 分割視窗與 buffer 分頁
| 按鍵 | 動作 |
|---|---|
| `<leader>\|` | 垂直分割當前視窗 |
| `<leader>-` | 水平分割當前視窗 |
| `Ctrl-h/j/k/l` | 在分割間移動（同鍵跨出到 tmux pane） |
| `Shift-h` / `Shift-l` | 上一個／下一個 buffer 分頁 |
| `<leader>bd` | 關閉當前 buffer |

### LSP / 程式碼
| 按鍵 | 動作 |
|---|---|
| `gd` | 跳到定義 |
| `gr` | 找引用 |
| `K` | 懸浮文件說明 |
| `<leader>ca` | code action |
| `<leader>cr` | rename 符號 |

### 其他
| 按鍵 | 動作 |
|---|---|
| `<leader>gg` | 在 Neovim 內開 lazygit |
| `<leader>l` | 開 Lazy 外掛管理器 |
| `:Mason` | 管理 LSP／工具 |
| `:checkhealth` | 健檢 |

> 你要的版面（左檔案樹＋上方分頁＋兩個並排編輯）：`<leader>e` 開樹 → 在樹上對兩個檔各按 `s` → 完成。

---

## 7. R / Python REPL 工作流（vim-slime）

在 tmux 裡開兩個 pane：一個跑 REPL、一個用 Neovim 編輯，用 vim-slime 把選取行送過去。

```
1. prefix + |            # 分出右邊 pane
2. 右 pane 執行  R   或   python   或   ipython
3. 左 pane 用 nvim 打開你的 .R / .py
4. 選取要跑的行（visual mode），或游標停在段落上
5. 按  Ctrl-c Ctrl-c    # 送到「最後使用的 tmux pane」＝右邊 REPL
```

vim-slime 已設定 `target_pane = {last}`、不再每次詢問，所以直接按 `Ctrl-c Ctrl-c` 即可。
Nextflow 的 `.nf` 與 `nextflow.config` 會以 groovy 語法高亮（Nextflow 無 LSP）。

---

## 8. lazygit 操作速查

用 `prefix + g`（tmux 彈出）或 `<leader>gg`（Neovim 內）開啟。左側五個面板：狀態、
檔案、分支、commit 紀錄、stash。

| 按鍵 | 動作 |
|---|---|
| `Tab` | 切換面板 |
| `↑/↓` 或 `j/k` | 在檔案間移動（右側即時顯示 diff） |
| `Space` | stage／unstage 該檔 |
| `Enter` | 進檔看 diff，可逐行（hunk）stage |
| `c` | commit |
| `P`（大寫） | push |
| `p`（小寫） | pull |
| `b` | 分支操作 |
| `z` | undo |
| `?` | 說明 |
| `q` | 離開 |

review Claude 的批次修改標準流程：逐檔 `↑/↓` 看 diff → 確認無誤 `Space` stage → 全部
好了 `c` 寫 commit message → `P` push。

---

## 9. yazi 操作速查

用 `prefix + e`（tmux 彈出）或終端直接 `yazi` 開啟。

| 按鍵 | 動作 |
|---|---|
| `h/j/k/l` 或方向鍵 | 上層／下／上／進入 |
| `Enter` | 開檔（文字檔會進 Neovim） |
| `Space` | 選取並下移 |
| `y` / `p` / `x` | 複製／貼上／剪下 |
| `d` / `a` / `r` | 刪除／新增／改名 |
| `/` | 搜尋 |
| `.` | 顯示／隱藏隱藏檔 |
| `q` | 離開 |

---

## 10. CLI 工具速查

| 指令 | 用途 |
|---|---|
| `ls` / `ll` / `la` | eza 列表（已別名；含 git 狀態、目錄優先） |
| `bat <檔>` | 有語法高亮的 cat |
| `fd <名>` | 找檔案（比 find 快、預設略過 .git） |
| `rg <關鍵字>` | 全文搜尋（ripgrep） |
| `z <部分目錄名>` | 智慧跳轉常用目錄（zoxide）；`zi` 互動選 |
| `btop` | 系統資源監控 |
| `git diff` / `git show` | 自動走 delta，diff 有語法高亮；`n`/`N` 在 hunk 間跳 |

### fzf 快捷鍵（任何 bash 提示字元下）
| 按鍵 | 動作 |
|---|---|
| `Ctrl-t` | 選檔案路徑插入到命令列 |
| `Ctrl-r` | 搜尋指令歷史 |
| `Alt-c` | 選目錄並 cd 進去 |

---

## 11. 滑鼠使用

鍵盤導航之外，滑鼠全程可用，且 tmux 與 Neovim 兩層分工不衝突：

- **切 pane**：點一下該 pane。**調整大小**：拖曳 pane 邊界。**捲動**：滾輪。
- **在 shell／Claude 輸出的 pane 拖選文字** → 放開即複製到系統剪貼簿（mac/Wayland/X11/WSL 皆支援）。
- **在 Neovim 內**：滑鼠點選定位、拖選進入 visual mode、滾輪捲動皆可。
- **想用終端機原生選取**（一次拖很長、跨 pane）：按住修飾鍵繞過 tmux——
  Linux／Windows Terminal 為 **Shift+拖**，macOS(Ghostty) 為 **Option+拖**。

---

## 12. 三台機器的差異與 `gs4`

| | mini（macOS） | wsl（Windows 下 Ubuntu） | gs4（遠端） |
|---|---|---|---|
| 角色 | 本機開發 | 本機開發 | 只跑 job |
| 終端機 | Terminal.app（你已設好主題） | Windows Terminal（你已設好主題） | 用 SSH 進入 |
| 套件來源 | Homebrew | Homebrew（Linuxbrew） | 不裝這套 |
| 字型 | cask 安裝 | 裝在 Windows 端 | 不需要 |
| 這套環境 | 完整安裝 | 完整安裝 | **只用 tmux 保命** |

`gs4` 不是本套的安裝對象：那邊只需 `ssh gs4` 後開個 tmux session 讓 job 在斷線後
繼續跑，不要在上面安裝編輯器或工具鏈。要投 job 時，在本機某個 shell pane `ssh gs4`
進遠端 tmux 操作即可。

---

## 13. 客製化與多機同步

所有設定都在 `~/dotfiles` 這個 git repo 裡，透過 symlink 連到定位，所以：

- **改設定**：直接編輯 `~/dotfiles/` 內對應檔案（例如 `tmux/tmux.conf`、
  `nvim/plugins/*.lua`），存檔即生效（tmux 按 `prefix + r` 重載；nvim 重開）。
- **新增 Neovim 外掛**：在 `~/dotfiles/nvim/plugins/` 丟一個回傳 table 的 `.lua`，
  重開 nvim 後 `:Lazy sync`。
- **同步到其他機器**：
  ```bash
  cd ~/dotfiles && git add -A && git commit -m "tweak" && git push
  # 另一台
  cd ~/dotfiles && git pull        # symlink 已存在，改動立即生效
  ```

---

## 14. 疑難排解

| 症狀 | 原因 / 解法 |
|---|---|
| 想要好看的檔案圖示 | 預設關閉 Nerd Font（求零手動）。要圖示：安裝 JetBrainsMono Nerd Font 並在終端選它，再把 `nvim/plugins/local-opts.lua` 的 `have_nerd_font` 設 true、`lazygit/config.yml` 的 `nerdFontsVersion` 設 `"3"`。 |
| `./install.sh --packages` 中途失敗 | 舊版把 `bash`（formula）誤放進 `--cask` 導致中止——已修正；請 `git pull` 更新。現在字型/bash 安裝失敗只會警告、不影響後續連結。 |
| Neovim 圖示或外掛異常、版本不符 | LazyVim 需 Neovim **≥ 0.11.2**；`nvim --version` 若過低，多半是 apt 版本混進 PATH，改用 Homebrew 的 `nvim`。 |
| `Ctrl-c Ctrl-c` 沒送到 REPL | 確認右邊 pane 正在跑 R/python，且它是「最後使用過」的 pane；先點一下 REPL pane 再回編輯選取。 |
| 拖選沒進系統剪貼簿 | 該 pane 若是 Neovim，拖選是 nvim 的 visual；要系統剪貼簿請在 shell pane 拖選，或用 Shift/Option+拖走終端原生選取。 |
| tmux 顏色不對／無真彩 | 確認終端機支援 true color；設定已含 `terminal-overrides ",*:RGB"`，改設定後 `prefix + r` 重載。 |
| `dev`／`t` 指令找不到 | 開新 shell 或 `source ~/.bashrc`；用 `type dev` 確認函式已載入。 |
| macOS 還是用到舊 bash 3.2 | `brew install bash` 後，tmux 靠 PATH 上先出現的 `bash`；確認 brew 的 bin 在 PATH 前段。 |

健檢指令：
```bash
for c in nvim tmux lazygit yazi delta bat eza fd rg zoxide btop fzf; do
  command -v "$c" >/dev/null && echo "ok  $c" || echo "MISSING  $c"
done
```

---

## 15. 移除與還原

`install.sh` 連結前已把舊檔備份到 `~/.dotfiles_backup_<時間戳>/`。要還原：

```bash
BK=~/.dotfiles_backup_<時間戳>          # 挑一個備份目錄
cp -a "$BK"/. "$HOME"/                  # 把舊檔複製回去（覆蓋 symlink）
```

移除 symlink 與加入的行：
- 刪掉 `~/.tmux.conf`、`~/.config/{ghostty,lazygit,yazi}` 內對應 symlink、
  `~/.config/nvim`（如為本套所建）。
- 移除 `~/.bashrc` 內那行 `source ".../dotfiles/bash/init.bash"`。
- 取消 git include：`git config --global --unset include.path`。

---

*對應完整安裝流程與各設定檔內容，見 `term_setup.md` 與 `README.md`。*
