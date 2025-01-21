#!/bin/bash
echo
echo "Sendmail в списке процессов (если есть..):"
echo 
ps aux | grep sendmail | grep -v check_sendmail | grep -v grep
echo

echo "Последние 12 строк лога sendmail:"
echo
tail -n 12 /var/log/maillog
echo
