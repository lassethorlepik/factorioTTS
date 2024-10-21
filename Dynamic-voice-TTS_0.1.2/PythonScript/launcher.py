import subprocess
import sys
import os

def main():
    # Change the current working directory to the script's directory
    script_dir = os.path.dirname(os.path.abspath(__file__))
    os.chdir(script_dir)

    # Now the current working directory is set to the script's directory
    # Construct the path to setup.py
    setup_script = os.path.join(script_dir, 'setup.py')

    # Run setup.py script
    try:
        subprocess.check_call([sys.executable, setup_script])
    except subprocess.CalledProcessError as e:
        print(f"An error occurred while running setup.py: {e}")

    # Mimic the "pause" command from batch files
    input("Press Enter to continue...")

if __name__ == "__main__":
    main()
