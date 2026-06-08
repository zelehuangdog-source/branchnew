# branchnew

在**当前终端**里劈一个新窗格(或开新标签 / 新窗口),并在那里**继续当前的 Claude Code 会话**——于是你立刻得到一个上下文相同的「第二视图」,就贴在你正在工作的地方。你原来的窗格不动。

一句话:`branchnew` = 「把这个 Claude 会话再开一个分身,放旁边」。

```
┌───────────────┬───────────────┐
│  你正在工作的   │  branchnew 开的 │
│  Claude 会话    │  分身(同上下文) │
│  (原样不动)     │  fork / 共享    │
└───────────────┴───────────────┘
```

## 它能做什么

- **同上下文**:新视图用 `claude --continue` 接上 `$PWD` 里最近的那个会话。
- **两种会话模式**:
  - `fork`(默认)—— 独立分叉(`--continue --fork-session`),两边各走各的,互不影响。
  - `share` —— 重新接入**同一个**会话(`--continue`),共享同一份 transcript。
- **多种布局**:左右劈 / 上下劈 / 新标签 / 新窗口。
- **不改动任何文件或配置**:它只是开一个新的终端视图去跑 `claude`,纯粹的「开窗器」。

## 支持的终端(自动识别)

启动时按下面的优先级自动选择后端,**无需手动指定**:

| 终端环境 | 左右劈 `right` | 上下劈 `down` | 新标签 `tab` | 新窗口 `window` |
|---|:---:|:---:|:---:|:---:|
| **tmux**(在任意终端里) | ✅ 真分屏 | ✅ 真分屏 | ✅ 新 window | ✅ 新 window |
| **iTerm2** | ✅ 原生分屏 | ✅ 原生分屏 | ✅ | ✅ |
| **Apple Terminal**(系统自带) | ⚠️ 回退到新窗口 | ⚠️ 回退到新窗口 | ✅ 需辅助功能权限 | ✅ |
| 其它终端(Ghostty/Kitty/Warp/VS Code…) | ➡️ 新开一个 Terminal 窗口,并给出提示 | | | |

说明:
- **Apple Terminal 没有「分屏」功能**,所以 `right` / `down` 会自动回退成**新窗口**(你可以把两个窗口并排摆),并打印一行提示。想在一个窗口里真正分屏,请在 **tmux** 里运行,或改用 **iTerm2**。
- Apple Terminal 的**新标签** `tab` 通过模拟 `Cmd-T` 实现,需要「系统设置 › 隐私与安全性 › 辅助功能」授权;没授权会自动回退成新窗口。
- 不在 iTerm2 / Terminal / tmux 里(比如 Ghostty、Kitty、Warp、VS Code 内置终端)时,无法直接脚本控制,会回退到**新开一个 Apple Terminal 窗口**,并提示你用 tmux / iTerm2 获得原地分屏。

## 安装

### 方式一:一键安装脚本

```bash
git clone https://github.com/limin112/branchnew.git
cd branchnew
./install.sh
```

`install.sh` 会把 `branchnew` 装到 `~/.local/bin/`、设好可执行权限,并在需要时把 `~/.local/bin` 加进你的 `PATH`。

### 方式二:手动

```bash
mkdir -p ~/.local/bin
curl -fsSL https://raw.githubusercontent.com/limin112/branchnew/main/branchnew -o ~/.local/bin/branchnew
chmod +x ~/.local/bin/branchnew
# 确保 ~/.local/bin 在 PATH 里(zsh):
grep -q '.local/bin' ~/.zshrc || echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
```

开一个新终端后即可使用。

## 用法

```bash
branchnew                # 右劈一个窗格,fork 当前会话(默认)
branchnew down           # 下方劈一个窗格
branchnew tab            # 新标签
branchnew window         # 新窗口
branchnew tab share      # 新标签,接入同一个会话(共享 transcript)
branchnew down share     # 下方分屏,共享会话
branchnew --help         # 查看帮助
```

参数顺序随意,布局词和会话模式词可以任意组合。

| 布局 | 别名 |
|---|---|
| `right` | `r` `v` `vertical` |
| `down` | `d` `below` `horizontal` |
| `tab` | `t` |
| `window` | `win` `w` |

| 会话模式 | 别名 |
|---|---|
| `fork`(默认) | —— |
| `share` | `cont` `continue` |

> 在你的 Claude 会话所在目录运行它:它会 fork / 继续 `$PWD` 里**最近的**那个会话。

## 环境要求

- **macOS**(脚本基于 AppleScript / tmux,iTerm2 与 Apple Terminal 均为 macOS 应用)。
- 已安装 **Claude Code** CLI,且 `claude` 在 `PATH` 中。
- 终端被允许运行 AppleScript:首次使用会弹「自动化(Automation)」授权 → 允许即可
  (系统设置 › 隐私与安全性 › 自动化)。
- 仅 Apple Terminal 的**新标签**额外需要「辅助功能(Accessibility)」授权。

## 工作原理

`branchnew` 检测 `$TMUX` 和 `$TERM_PROGRAM` 来决定后端:

- **tmux**:用 `tmux split-window` / `tmux new-window` 建好新 pane/window,再 `send-keys` 把 `claude` 命令送进去。
- **iTerm2**:用 iTerm 原生 AppleScript(`split vertically/horizontally`、`create tab`、`create window`)。
- **Apple Terminal**:用 `do script`(新窗口)或模拟 `Cmd-T`(新标签)。

新视图里实际运行的命令是:

```bash
cd <你当前的目录> && claude --continue [--fork-session]
```

脚本本身**不写死任何个人路径**(只用 `$PWD`、`$@`),可以原样分享。

## 排错

| 现象 | 原因 / 解决 |
|---|---|
| 报错 `could not open the new view` + AppleScript 错误 | 没给终端「自动化」授权。去 系统设置 › 隐私与安全性 › 自动化 勾选你的终端控制 iTerm/Terminal。 |
| Apple Terminal 里 `tab` 变成了新窗口 | 没给「辅助功能」授权(模拟 Cmd-T 需要)。授权后再试,或直接用 `window`。 |
| `right`/`down` 在 Apple Terminal 里开成了新窗口 | 正常行为——Terminal 不支持分屏。想真分屏请用 tmux 或 iTerm2。 |
| 新视图里 `claude: command not found` | 新开的 shell 里 `claude` 不在 PATH。先确保 Claude Code 已正确安装。 |

## License

MIT — 见 [LICENSE](LICENSE)。
