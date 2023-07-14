import subprocess
import os

# Function to print colored text to the console
def print_color(text, color):
    print(f"\033[1;{color}m{text}\033[0m")

def build_venv_and_convert_snmpwalk():
    # Create a new virtual environment
    subprocess.run(['python3', '-m', 'venv', 'snmpenv'], check=True)

    # Activate the virtual environment and run subsequent commands within it
    activate_cmd = '. snmpenv/bin/activate && '
    commands = [
        'pip install --upgrade pip',
        'pip install -r requirements.txt',
        'cd ./conversion && python convert.py'
    ]
    for cmd in commands:
        subprocess.run(['bash', '-c', activate_cmd + cmd], check=True)
    print_color("\nVenv and snmpwalk converted successfully!", "32")


def start_containers():
    subprocess.run(['bash', '-c', 'source snmpenv/bin/activate && python start_sandbox.py'], check=True)
    print_color("Containers started successfully!", "32")


def destroy_venv_and_containers():
    # Stop and remove containers using docker-compose
    subprocess.run(['bash', '-c', 'source snmpenv/bin/activate && python destroy_sandbox.py'], check=True)

    # Deactivate and delete virtual environment
    subprocess.run('deactivate', shell=True)
    subprocess.run('rm -rf snmpenv', shell=True, check=True)

    print_color("Venv and containers destroyed successfully!", "31")

def compare_oid():
    subprocess.run(['bash', '-c', 'source snmpenv/bin/activate && python extract_oid.py'], check=True)

# Main loop
while True:
    print_color("##########################################################################################", "31")
    print_color("\nWelcome to SNMP sandbox!", "32")
    print("\nPlease select an option:\n")
    print_color("1) Build venv and convert snmpwalk", "32")
    print_color("2) Build mocksnmp containers + datadog agent and start containers", "32")
    print_color("3) Destroy venv and containers", "31")
    print_color("4) Compare manually configed OID in custom profile to snmpwalk", "33")
    print_color("5) Exit menu", "32")

    choice = input("\nEnter an option number (1-5): ")

    if choice == "1":
        build_venv_and_convert_snmpwalk()
    elif choice == "2":
        start_containers()
    elif choice == "3":
        destroy_venv_and_containers()
        break
    elif choice == "4":
        compare_oid()
        break
    elif choice == "5":
        print_color("Exited menu", "31")
        break
    else:
        print_color("Invalid choice. Please enter a valid option number.", "31")
