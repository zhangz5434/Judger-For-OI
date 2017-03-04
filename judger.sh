#!/bin/bash

# clear

__INTERACTIVE=""
if [ -t 1 ] ; then
    __INTERACTIVE="1"
fi

__green(){
    if [ "$__INTERACTIVE" ] ; then
        printf '\033[1;31;32m'
    fi
    printf -- "$1"
    if [ "$__INTERACTIVE" ] ; then
        printf '\033[0m'
    fi
}

__red(){
    if [ "$__INTERACTIVE" ] ; then
        printf '\033[1;31;40m'
    fi
    printf -- "$1"
    if [ "$__INTERACTIVE" ] ; then
        printf '\033[0m'
    fi
}

__yellow(){
    if [ "$__INTERACTIVE" ] ; then
        printf '\033[1;31;33m'
    fi
    printf -- "$1"
    if [ "$__INTERACTIVE" ] ; then
        printf '\033[0m'
    fi
}

echo "$(__yellow "Bash OI Judger VER 1.00 By zhangz")"

read -p "Enter Problem Name: " PROBLEM_NAME
read -p "Enter Begin From: " BEGIN
read -p "Enter End To: " END
read -p "Enter Score Per Test Case: " SCORE_PER_CASE
read -p "Enter Standard Output File Ext Name ." ANSWER_FILE_EXT

SCORE=0

TIME_LIMIT=1
# 1000ms CPU Time

MEMORY_LIMIT=524288
# 524288 KB Memory

echo -n "Compiling Your Problem..."

g++ ${PROBLEM_NAME}.cpp -o ${PROBLEM_NAME}
if [ $? != 0 ]; then
	echo "$(__red "Compile Failed")"
	echo "Your Score: $(__red "0")"
	echo "Result: $(__red "UnAccepted")"
	echo "=====Judge Task Done====="
	echo ""
	exit 0
fi

echo "$(__green "Compile Successful")"
echo "Start Judging Your Program"
echo "=========================="

# Make watcher
echo -e "#!/bin/bash\n\nulimit -t ${TIME_LIMIT}\nulimit -m ${MEMORY_LIMIT}\nulimit -v ${MEMORY_LIMIT}\n./${PROBLEM_NAME} < /dev/null > /dev/null 2> /dev/null\nexit \$?" > watcher.sh
chmod a+x watcher.sh

ALL_CORRECT=1

for i in `seq ${BEGIN} ${END}`; do
	echo -n "Judging Test Case #$(__yellow "$i")... "
	cp ${PROBLEM_NAME}${i}.in ${PROBLEM_NAME}.in
	(./watcher.sh) > /dev/null 2> /dev/null
	RESULT=$?
	if [ $RESULT != 0 ]; then
		echo -n "$(__red "Resource Exceeded Or Runtime Error!   ")"
		echo "Score: $(__red "0")"
		ALL_CORRECT=0
	else
		if [ ! -f "${PROBLEM_NAME}.out" ]; then
			echo -n "$(__red "Output File Not Found!   ")"
			echo "Score: $(__red "0")"
			ALL_CORRECT=0
		else
			diff ${PROBLEM_NAME}.out ${PROBLEM_NAME}${i}.${ANSWER_FILE_EXT} -w -q > /dev/null
			if [ $? != 0 ]; then
				echo -n "$(__red "Wrong Answer!   ")"
				echo "Score: $(__red "0")"
				echo "diff information dumped => ${PROBLEM_NAME}${i}.diff"
				diff ${PROBLEM_NAME}.out ${PROBLEM_NAME}${i}.${ANSWER_FILE_EXT} -w > ${PROBLEM_NAME}${i}.diff
				ALL_CORRECT=0
			else
				echo -n "$(__green "Correct!   ")"
				echo "Score: $(__green "${SCORE_PER_CASE}")"
				SCORE=$[ ${SCORE} + ${SCORE_PER_CASE} ]
			fi
		fi
	fi
done

if [ $ALL_CORRECT != 1 ]; then
	echo "Your Score: $(__red "$SCORE")"
	echo "Result: $(__red "UnAccepted")"
else
	echo "Your Score: $(__green "$SCORE")"
	echo "Result: $(__green "Accepted")"
fi

# echo "=====Cleaning Up====="

rm watcher.sh
rm ${PROBLEM_NAME}
rm ${PROBLEM_NAME}.in
if [ -f "${PROBLEM_NAME}.out" ]; then
	rm ${PROBLEM_NAME}.out
fi

echo "=====Judge Task Done====="

echo ""

exit 0

