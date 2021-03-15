#!/bin/bash
COMMAND=""
TIME=0
PERIOD=0
OUTPUT=""
WF=0
OKN=0
if [ -z "$1" ]||[ $1 = "--help" ]
then
OKN=1
echo "

Описание работы скрипта: 
sh ./smartlogger.sh -c [COMMAND] -t [TIME] -p [PERIOD] -o [OUTPUT_FILE] -w [ВРЕМЕННЫЙ ФАЙЛ]
-c [COMMAND] - та комманда, логгирование которой будет происходить, необходимо вписать в кавычках полную команду со всеми ключами, если они есть;
-t [TIME] - время в секундах, минутах или часах, в которое будет происходить логгирование;
-p [PERIOD] - интервал в милисекундах, через который будет производится новая запись;
-o [OUTPUT_FILE] - название файла, в который будут записываться логи, не нужно писать .log;
-w [ВРЕМЕННЫЙ ФАЙЛ] - Раз в это количество периодов данные будут перезаписываться в основной файл, если не нужно, то 0
Пример:
sh ./smartlogger.sh -c \"top -b -n 1\" -t 3600 -p 5000 -o today -w 3
Данная команда бубет записываться раз в 5 секунд на протяжении 3600 секунд, то есть всего будет 720 записей. Запись будет производится в временные файлы, раз в 3 секунды данные будут переноситься в основной файл.
Не рекомендуется использовать время меньше 200 милиcекунд.
"
else
while [ -n "$1" ]
do
case "$1" in
-c) COMMAND="$2"
shift;;
-t) TIME="$2"
shift ;;
-p) PERIOD="$2"
shift;;
-o) OUTPUT="$2"
shift;;
-w) WF="$2"
shift;;
--) shift
break ;;
*) echo "$1 is not an option";;
esac
shift
done
count=1
for param in "$@"
do
echo "Parameter #$count: $param"
count=$(( $count + 1 ))
done

if [ $OKN -eq 0 ]
then
echo "Я получил на вход:"
echo "Команда: " $COMMAND
echo "Время: " $TIME "секунд"
echo "Период: " $PERIOD "милисекунд"
echo "Название файла: " $OUTPUT".log"
if [ -n "$WF" ]
then
if [ $WF -gt 0 ]
then
echo "Перезпись из временных файлов раз в" $WF "периодов"
else
echo "Временные файлы будут отсутствовать"
WF=$((1))
fi
else
echo "ERROR! -w пустое, так нельзя!" 
exit
fi

echo 
echo "Логгирование начнётся через 3 секунды, если что-то неверно, необходимо нажать CTRL+C"
sleep 3
echo "Начинаем логгирование"
TIME=$((TIME*1000))
date +%T
COUNTER=$(($WF*$PERIOD))
touch $OUTPUT.log
TIME_OUTPUT="time_log_dont_open.log"
rm -rf $TIME_OUTPUT
while [ $TIME -ge $PERIOD ]
do
if [ $COUNTER -gt 0 ]
then
date +%T
echo "Происходит запись в временный файл, осталось времени:" $(($TIME/1000)).$(($TIME-($TIME/1000)*1000)).
echo "Запись в основной файл через" $(($COUNTER/1000)).$(($COUNTER-($COUNTER/1000)*1000)).
echo "Число строк в основном файле файле:"
wc -l $OUTPUT.log
echo >> $TIME_OUTPUT
echo >> $TIME_OUTPUT
date +"%T.%N" >> $TIME_OUTPUT
echo >> $TIME_OUTPUT
$COMMAND >> $TIME_OUTPUT
echo "Число строк в временном файле:"
wc -l $TIME_OUTPUT
echo
echo
usleep $(($PERIOD*1000))
TIME=$(($TIME-$PERIOD))
COUNTER=$(($COUNTER-$PERIOD))
else
echo ------------------------
echo "Запись в основной файл"
echo ------------------------
echo
echo
COUNTER=$(($WF*$PERIOD))
cat $TIME_OUTPUT >> $OUTPUT.log
rm $TIME_OUTPUT
fi
done
date +%T
cat $TIME_OUTPUT >> $OUTPUT.log
rm $TIME_OUTPUT

echo ------------------------
echo "Запись в основной файл"
echo ------------------------
echo
echo "Число строк в основном файле файле:"
wc -l $OUTPUT.log
fi
fi
