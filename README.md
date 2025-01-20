# Getting Started with COAL (Computer Organization and Assembly Language)

Hey cuties! ☕️✨  
Ready to dive into COAL programming? It’s like programming fundamentals (PF), but the syntax can be tricky. Don’t worry; we’ve got you covered. Follow these steps to set up everything for COAL programming!


## Required Software:
1. **NASM**
2. **AFD**
3. **VS Code**
4. **DOSBox**



## Setup Guide:

### Step 1: Download the Required Files
1. Download the **NASM** zip file from the repository.
2. Extract the zip file to a folder on your computer.

### Step 2: Install VS Code
1. Visit the official [Download VS Code](https://code.visualstudio.com/).
2. Download and install VS Code.

### Step 3: Install DOSBox
1. Download **DOSBox** from its [Download DOSBOX](https://sourceforge.net/projects/dosbox/files/dosbox/0.74-3/DOSBox0.74-3-win32-installer.exe/download).
2. Install DOSBox on your machine.



### Step 4: Configure VS Code
1. Open the folder where you extracted the **NASM** and **AFD** files in VS Code.
2. Inside this folder, create a new folder named `.vscode`.
3. Download the `tasks.json` file from the repository and place it inside the `.vscode` folder.



### Step 5: Edit the `tasks.json` File
1. Open the `tasks.json` file in VS Code.
2. Find this line:
   ```json
   "command": "C:\\Program Files (x86)\\DOSBox-0.74-3\\DOSBox.exe"
   ```
3. Replace the path with the actual location where DOSBox is installed on your computer.


## Writing and Running Your First COAL Program

### Step 1: Create a New File
1. In VS Code, create a new file with the extension `.asm`.  
   Example: `name.asm`.

### Step 2: Write Your Code
Write your COAL program in the `.asm` file.

### Step 3: Build and Run
1. Press `Ctrl + Shift + B` in VS Code.
2. When prompted, enter the name of your program (without the `.asm` extension) and press Enter.
3. DOSBox will open automatically.

### Step 4: Run Your Program in DOSBox
- To debug using **AFD**, type:
  ```bash
  afd name.com
  ```
- To directly run your program, type:
  ```bash
  name.com
  ```

---

🎉 **That’s it!** You’re all set to start programming in COAL. Now go break down some binaries like a pro! 🚀
