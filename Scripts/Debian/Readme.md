Step 3: Make the Script Executable

To make the script executable, run the following command:

``` chmod +x update_server.sh ```

Step 4: Schedule the Script to Run Daily

To ensure that the script runs automatically once a day, we’ll use the ‘cron’ scheduler. Open the ‘crontab’ file for the current user with the following command:

``` crontab -e ```

Add the following line at the end of the file:

``` 0 3 * * * /path/to/update_server.sh >> /path/to/update_server.log 2>&1 ```

This line schedules the script to run daily at 3:00 AM. Replace ‘/path/to/update_server.sh’ with the full path to your script and ‘/path/to/update_server.log’ with the desired location of the log file. The ‘2>&1’ part redirects the script’s output and error messages to the specified log file.
