import subprocess
import sys
import os
# Define the path to the virtual environment
venv_path = 'venv'
main_script = 'TTS.py'

def create_venv(venv_path):
    """Create a virtual environment if it doesn't exist."""
    if not os.path.exists(venv_path):
        print("Creating virtual environment...")
        subprocess.check_call([sys.executable, '-m', 'venv', venv_path])
        print("Virtual environment created.")

def install_requirements(venv_path):
    """Install packages from requirements.txt into the virtual environment."""
    print("Installing dependencies...")
    # Choose the correct pip executable based on the operating system
    pip_executable = 'pip' if os.name == 'posix' else 'Scripts\\pip'
    pip_path = os.path.join(venv_path, pip_executable)
    subprocess.check_call([pip_path, 'install', '-r', 'requirements.txt'])
    print("Dependencies installed.")

def run_script_in_venv(venv_path, script_name):
    """Run a Python script using the virtual environment's interpreter."""
    # Choose the correct Python executable based on the operating system
    python_executable = 'bin/python' if os.name == 'posix' else 'Scripts\\python'
    python_path = os.path.join(venv_path, python_executable)
    # Construct the path to main script and run it
    script_path = os.path.join(os.path.abspath('.'), script_name)
    try:
        subprocess.check_call([python_path, script_path])
    except subprocess.CalledProcessError as e:
        print("↑ There was an error executing main TTS script ↑")

if __name__ == "__main__":
    create_venv(venv_path)
    install_requirements(venv_path)
    run_script_in_venv(venv_path, main_script)   
    
