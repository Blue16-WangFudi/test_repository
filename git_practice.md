# 🌱 Git 新手实战演练仓库 (Git Practice Camp)

欢迎来到 Git 实践训练营！🎉

本仓库专为 Git 初学者设计。你将通过完成一系列小任务，从零开始掌握版本控制的核心操作，并体验真实的 GitHub 团队协作流程。

> 💡 **核心目标**：学会如何在一个多人协作的项目中安全、规范地提交代码。

---

## 📋 任务清单与考核要求

请按照以下阶段顺序完成任务。**最终以发起 Pull Request (PR) 并被合并视为作业完成。**
在开始之前，请先在电脑上安装Git，示例教程：**https://blog.csdn.net/mukes/article/details/115693833**（也可参考其他教程）
### 🟢 第一阶段：准备工作 (Fork & Config)

在开始写代码之前，你需要将仓库复制到你自己的名下。

1.  **Fork 本仓库**：
    *   点击页面右上角的 **Fork** 按钮。
    *   将本仓库完整复制到你自己的 GitHub 账号下。

2.  **克隆 (Clone) 到本地**：
    *   打开终端（Terminal 或 Git Bash）。
    *   输入以下命令（注意替换为**你自己的**用户名）：
    ```bash
    # ⚠️ 注意：地址里是你的用户名，不是老师的！
    git clone https://github.com/<你的GitHub用户名>/git-practice.git
    
    # 进入项目目录
    ```

3.  **配置身份信息 (Config)**：
    *   这是为了让 Git 知道是谁提交的代码（请使用与 GitHub 一致的邮箱）。
    ```bash
    git config --global user.name "你的姓名拼音"
    git config --global user.email "your_email@example.com"
    ```

---

### 🟡 第二阶段：创建个人工作区 (Branch)

**严禁**直接在 `main` 分支上修改代码！请建立属于你的个人分支。

1.  **创建并切换分支**：
    *   分支名建议格式：`student/姓名拼音`
    ```bash
    # 例如：git checkout -b student/zhangsan
    git checkout -b student/<你的名字>
    ```

---

### 🔵 第三阶段：提交代码 (Commit)

现在，在你的分支上完成作业任务。

1.  **创建专属文件**：
    *   进入 `students` 文件夹（如果没有请新建）。
    *   新建一个 Markdown 文件，命名为：`你的名字.md` (例如 `zhangsan.md`)。

2.  **写入作业内容**：
    *   复制以下模版内容到你的文件中，并修改为真实信息：
    ```markdown
    # 👋 大家好，我是 [你的名字]
    
    - 🏫 学校/班级：[填写班级]
    - 💻 GitHub：[你的GitHub ID]
    - 🎯 学习目标：熟练掌握 Git 协作流程！
    - 🌟 最喜欢的命令：`git commit`
    
    ---
    ### 📝 练习心得
    (在这里写下你的一句话心情或遇到的困难)
    ```

3.  **提交更改**：
    ```bash
    # 1. 查看文件状态（是个好习惯）
    git status
    
    # 2. 将文件添加到暂存区
    git add students/<你的名字>.md
    
    # 3. 提交并写明注释
    git commit -m "docs: 添加 [你的名字] 的个人档案"
    ```

---

### 🟣 第四阶段：推送与协作 (Push & PR)

将你的代码贡献回主仓库。

1.  **推送到远程仓库**：
    ```bash
    # 将你的分支推送到你 Fork 的远程仓库
    # 格式：git push origin <你的分支名>
    git push origin student/<你的名字>
    ```

2.  **发起 Pull Request (PR)**：
    *   回到 **GitHub 网页端**（你自己的仓库页面）。
    *   页面通常会提示 "Compare & pull request"，点击它。
    *   **标题**：`Add student profile: 你的名字`
    *   **描述**：简单说明你完成了练习。
    *   点击 **Create pull request** 按钮。

✅ **等待审核**：一旦你的 PR 被管理员合并，你就成功完成了 Git 协作全流程！

---
