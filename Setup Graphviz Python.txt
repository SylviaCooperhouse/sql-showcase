### Setting Up Graphviz for Python Database Diagram Generation

Follow these steps to set up your laptop to run the Python script that generates a database schema diagram using Graphviz and SQLAlchemy.

---

### **1. Install Graphviz**
#### **Option 1: Using Chocolatey (Recommended for Windows)**
1. Open PowerShell as Administrator and run:
   ```powershell
   choco install graphviz -y
   ```
2. Restart your terminal after installation.

#### **Option 2: Manual Download and Setup**
1. Download Graphviz from:
   ```
   https://graphviz.gitlab.io/_pages/Download/Download_windows.html
   ```
2. Extract the ZIP file to a permanent location (e.g., `C:\Program Files\Graphviz`).
3. Locate the `bin` folder inside the extracted directory.

---

### **2. Add Graphviz to System PATH**
1. Press `Win + R`, type `sysdm.cpl`, and hit Enter.
2. Go to the **Advanced** tab → Click **Environment Variables**.
3. Under **System Variables**, find and select `Path`, then click **Edit**.
4. Click **New**, then paste the full path to the `bin` folder:
   ```
   C:\Program Files\Graphviz\bin
   ```
5. Click **OK** → **OK** again to save.
6. Restart your terminal.

---

### **3. Verify Graphviz Installation**
Open a new Command Prompt (cmd) or PowerShell and run:
```powershell
dot -V
```
Expected output:
```
dot - graphviz version X.X.X
```
If the command fails, ensure the correct path was added to the Environment Variables.

---

### **4. Set Up the Python Virtual Environment**
1. Open a terminal inside the project folder.
2. Create and activate a virtual environment:
   ```bash
   python -m venv .venv
   .venv\Scripts\Activate  # Windows
   source .venv/bin/activate  # Mac/Linux
   ```
3. Install required Python dependencies:
   ```bash
   pip install -r requirements.txt
   ```

---

### **5. Run the Python Diagram Script**
With everything set up, run:
```bash
python generate_db_diagram.py
```
If successful, this will generate `db_schema.png` in the project folder.

---

### **Troubleshooting**
- If `dot -V` doesn’t work, double-check the PATH configuration.
- If Python fails with `FileNotFoundError: "dot" not found in path`, restart the terminal and try again.
- If dependencies are missing, rerun:
  ```bash
  pip install -r requirements.txt
  ```

This should fully set up your system for generating database schema diagrams! 🚀
