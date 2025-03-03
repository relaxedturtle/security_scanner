#!/bin/bash
ascii="                              _ __       
   ________  _______  _______(_) /___  __
  / ___/ _ \\/ ___/ / / / ___/ / __/ / / /
 (__  )  __/ /__/ /_/ / /  / / /_/ /_/ / 
/____/\\___/\\___/\\__,_/_/  /_/\\__/\\__, /  
   ______________ _____  ____  _/____/___
  / ___/ ___/ __ \`/ __ \\/ __ \\/ _ \\/ ___/
 (__  ) /__/ /_/ / / / / / / /  __/ /    
/____/\\___/\\__,_/_/ /_/_/ /_/\\___/_/     
"
log_file=/var/log/auth.log
failed_login_pattern="(gdm-password:auth): authentication failure;"
unauthorized_sudo_pattern="(sudo:auth): authentication failure;"
login_attempts_output="login_attempts.log"
sudo_attempts_output="sudo_attempts.log"

failed_login_scan() {
        if grep -q "$failed_login_pattern" "$log_file"; then
                echo -e "One or more failed login attempt(s) found. Saving to 'login_attempts.log'"
                grep "$failed_login_pattern" "$log_file" >> "$login_attempts_output"
        else
                echo "No failed login attempts found."
        fi
}

unauthorized_sudo_scan() {
        if grep -q "$unauthorized_sudo_pattern" "$log_file"; then
                echo -e "One or more unauthorized sudo access attempt(s) found. Saving to 'sudo_attempts.log'"
                grep "$unauthorized_sudo_pattern" "$log_file" >> "$sudo_attempts_output"
        else
                echo "No unauthorized sudo access attempts found."
        fi
}

read_login_attempts() {
	if [ -s "$login_attempts_output" ]; then
		echo -e "\nDetected failed login attempts:"
		cat "$login_attempts_output"
		echo -e "\n"
	else
		echo "Error: Login attempts log is empty."
	fi
}

read_sudo_attempts() {
	if [ -s "$sudo_attempts_output" ]; then
		echo -e "\nDetected failed sudo access attempts: "
		cat "$sudo_attempts_output"
		echo -e "\n"
	else
		echo "Error: Sudo access attempts log is empty."
	fi
}

wipe_log_files() {
	if [ -s "$login_attempts_output" ]; then
		truncate -s 0 "$login_attempts_output"
		echo "Success: Login attempts log empty."
	else
		echo "Error: Login attempts log is empty."
	fi

	if [ -s "$sudo_attempts_output" ]; then
		truncate -s 0 "$sudo_attempts_output"
		echo "Success: Sudo attempts log emptied."
	else
		echo "Error: Sudo attempts log is empty."
	fi
}

main() {
        while true; do
		echo "$ascii"
                echo "Options: "
                echo "1. Scan for failed login attempts"
                echo "2. Scan for unauthorized sudo attempts"
		echo "3. Read failed login attempts log (must run option 1 first)"
		echo "4. Read failed sudo attempts log (must run option 2 first)"
		echo "5. Empty log files (NOT auth.log)"
                echo "6. Exit"
                read -p "Enter your choice: " choice

                case $choice in
                        1) failed_login_scan ;;
                        2) unauthorized_sudo_scan ;;
			3) read_login_attempts ;;
			4) read_sudo_attempts ;;
			5) wipe_log_files ;;
                        6) exit 0 ;;
                esac
        done
}
main
