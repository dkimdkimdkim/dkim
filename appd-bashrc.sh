# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# User specific aliases and functions
function portkill() {
    "kill $(netstat -nptl | awk '/:$@/{gsub("/.*", ""); print $7}')"
}
#alias such=git
alias very=git
alias wow='git status'

export CODEBASE="/home/david.kim/git/codebase"

alias restart_apache="sudo /etc/init.d/httpd restart ; sudo rm -rf /opt/appdynamics-php-agent/logs/*"
alias kill_failed_test="sudo pkill -9 java ; sudo pkill -9 runtest.sh ; pkill -9 httpd"
alias cdcode="cd ${CODEBASE}/"
alias cdphp="cd ${CODEBASE}/agent/php/src/php_extension/src/"
alias cdtests="cd ${CODEBASE}/automation/functional/src/test/java/phpagent/sanity/"
alias cdagent="cd /opt/appdynamics-php-agent/"
alias agentlog="tail -f /opt/appdynamics-php-agent/logs/agent.log"

alias soft_rebuild_extension="make -j4 -C ${CODEBASE}/agent/php/build/extension/5.4/x64-linux-gnu"
alias single_soft_rebuild_extension="make -C ${CODEBASE}/agent/php/build/extension/5.4/x64-linux-gnu"
alias reinstall_extension="sudo make -C ~david.kim/git/codebase/agent/php/build/extension/5.4/x64-linux-gnu install"
alias load_app="while true; do curl -s http://centos5.local/~david.kim/predis/examples/PipelineContext.php > /dev/null ; done"
alias mavendeploy="cd ${CODEBASE}/agent/java/core/ ; ant publish-to-maven-repo ; cd -"

alias controllerinfo="cp ~/controller-info.xml.bak ${CODEBASE}/agent/java/core/build/temp/conf/controller-info.xml"

# Git branch in prompt.
parse_git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}
export PS1="\u@\h \W\[\033[32m\]\$(parse_git_branch)\[\033[00m\] $ "

function spam () {
    while true; do curl -s "$@" > /dev/null ; done
}

CURRENTPHPBUILDVERSION=21
PHPVERSION52="5.2.17-$CURRENTPHPBUILDVERSION"
PHPVERSION53="5.3.27-$CURRENTPHPBUILDVERSION"
PHPVERSION54="5.4.21-$CURRENTPHPBUILDVERSION"
PHPVERSION55="5.5.5-$CURRENTPHPBUILDVERSION"

WORK_BASHRC="${HOME}/git/dkim/appd-bashrc.sh"
alias bashrc="vim $WORK_BASHRC; source $WORK_BASHRC; echo bashrc reloaded"
alias startup="sudo /etc/init.d/smb restart"

function enablephp () {
    sudo chmod 700 /opt/php/*
    for arg; do
        case "$arg" in
            "52")
            sudo chmod 755 /opt/php/${PHPVERSION52}
            ;;
            "53")
            sudo chmod 755 /opt/php/${PHPVERSION53}
            ;;
            "54")
            sudo chmod 755 /opt/php/${PHPVERSION54}
            ;;
            "55")
            sudo chmod 755 /opt/php/${PHPVERSION55}
            ;;
            "all")
            sudo chmod 755 /opt/php/*
            ;;
        esac
    done
}
alias cleanbuildagent="rm -rf ${CODEBASE}/../lastagent ; cp -r ${CODEBASE}/agent/php/build ${CODEBASE}/../lastagent ; rm -rf ${CODEBASE}/agent/php/build ; ${CODEBASE}/agent/php/build.sh"
alias buildagent="${CODEBASE}/agent/php/build.sh"
alias untaragent="sudo tar -xjf ~david.kim/git/codebase/agent/php/build/appdynamics-php-agent.tar.bz2 -C /opt/"
alias installagent="sudo /opt/appdynamics-php-agent/install.sh osxltdkim.local 8080 centos5 php centos5.local"
# && sudo tar -xjf ~david.kim/git/codebase/agent/php/build/appdynamics-php-agent.tar.bz2 -C /opt/ && sudo /opt/appdynamics-php-agent/install.sh osxltdkim.local 8080 centos5 php centos5.local"
#alias gtest="gradle -DphpAgentTests.debug \"-Dphp.test.single=phpagent.sanity.MemCacheD\" -Dcontroller.host=osxltdkim.local -Dcontroller.port=8080 -Dphpagent.location=/home/david.kim/git/codebase/agent/php/build/appdynamics-php-agent-x64-linux.tar.bz2 :automation:functional:phpAgentTests -Dtests.temp.dir=/home/david.kim/git/codebase/../foo"


function killproxyleaks () {
for i in `seq 1 4`; do
    sudo pkill -9 java
    sudo pkill -9 mysqld
    sudo pkill -9 erl
    sudo pkill -9 epmd
    sudo pkill -9 httpd
    sleep 1
done
}

function gradlecmd () {
    local TESTREPORTS="${HOME}/Documents/testreports/"
    if [ ! -d ${TESTREPORTS} ]; then
        echo "Creating ${TESTREPORTS}"
    else
        echo "Using existing directory: ${TESTREPORTS}"
    fi
    echo

    if [[ -z ${JAVAAGENTLOCATION} ]]; then
        local JAVAAGENTLOCATION="${CODEBASE}/agent/java/core/build/temp/javaagent.jar"
    fi
    if [[ -z ${CONTROLLERHOST} ]]; then
        local CONTROLLERHOST="osxltdkim.local"
    fi
    if [[ -z ${CONTROLLERPORT} ]]; then
        local CONTROLLERPORT="8080"
    fi
    if [[ -z ${PHPAGENTLOCATION} ]]; then
        local PHPAGENTLOCATION="${CODEBASE}/agent/php/build/appdynamics-php-agent.tar.bz2"
    fi

    local PHPVERSION="${PHPVERSION54}" #default
    local DEBUG="" #default
    local SINGLETEST="-Dphp.test.single=phpagent.sanity."$1""

    for arg; do
    case "$arg" in
        "-P52")
        PHPVERSION="${PHPVERSION52}"
        ;;
        "-P53")
        PHPVERSION="${PHPVERSION53}"
        ;;
        "-P54")
        PHPVERSION="${PHPVERSION54}"
        ;;
        "-P55")
        PHPVERSION="${PHPVERSION55}"
        ;;
        "-Dyes")
        DEBUG="-DphpAgentTests.debug"
        ;;
        "-a")
        SINGLETEST=""
        ;;
        "-M")
        mavendeploy
        ;;
        "-K")
        KEEPTESTS="-Dtests.keep=true"
        ;;
    esac
    done

    local TESTTEMPDIR="${CODEBASE}/../testtemp-${PHPVERSION}"

    killproxyleaks
    echo "git branch:"
    git branch
    echo
    echo "Possible leaked mysqld, java, and httpd killed";
    echo
    echo "AGENT -----"
    echo "Using Java agent at: ${JAVAAGENTLOCATION}"
    echo "Using PHP agent at: ${PHPAGENTLOCATION}"
    echo
    echo "CONTROLLER -----"
    echo "Using controller host: ${CONTROLLERHOST}"
    echo "Using controller port: ${CONTROLLERPORT}"
    echo
    echo "PHP -----"
    echo "Testing PHP version: ${PHPVERSION}"
    echo
    echo "GRADLE -----"
    echo "Storing test reports in temp dir: ${TESTTEMPDIR}"
    echo
    #echo "Rebuilding Java Agent -----"
    #mavendeploy

    rm -rf ${TESTTEMPDIR} && \
    gradle ${DEBUG} ${SINGLETEST} \
    -Dagent.location=${JAVAAGENTLOCATION} \
    -Dcontroller.host=${CONTROLLERHOST} \
    -Dcontroller.port=${CONTROLLERPORT} \
    -Dphpagent.location=${PHPAGENTLOCATION} \
    -Dphp.version=${PHPVERSION} \
    -Dtests.temp.dir=${TESTTEMPDIR} \
    $KEEPTESTS \
    :automation:functional:phpAgentTests;

    local REPORT_NAME=`date | sed "s/[[:space:]]/_/g" | sed "s/:/-/g"`
    local FINAL_TEST_REPORTS="${TESTREPORTS}/${REPORT_NAME}"
    mkdir $FINAL_TEST_REPORTS
    local GRADLE_REPORTS="${CODEBASE}/automation/functional/build/reports/tests/"
    cp -r "${GRADLE_REPORTS}" $FINAL_TEST_REPORTS
    echo "You can find the completed test reports here:"
    echo "    file://localhost/Volumes/david.kim/Documents/testreports/${REPORT_NAME}/tests/index.html"

}

function gradleall {
    gradlecmd -a -P53
    gradlecmd -a -P54
    gradlecmd -a -P55
    gradlecmd -a -P52
}


#function gtestj () {
#    rm -rf /home/david.kim/git/foo && gradle -DjavaAgentTests.debug -Djava.test.single=javaagent.features37.rabbitmq.RabbitMQBackendConfigTest -Dagent.location=/home/david.kim/git/codebase/agent/java/core/build/temp/javaagent.jar -Dcontroller.host=osxltdkim.local -Dcontroller.port=8080 -Dtests.temp.dir=/home/david.kim/git/codebase/../foo :automation:functional:javaAgentTests;
#}

function suchtestswow() {
    rm -rf ~/Documents/testreports/
    mkdir ~/Documents/testreports/

#    rm -rf ~/Documents/testreports/5.2
#    mkdir ~/Documents/testreports/5.2
#    gradlecmd -Dno 52 all
#
#    #gtest_full52
#    cp -r $CODEBASE/automation/functional/build/reports/tests/ ~/Documents/testreports/5.2
#    touch ~/Documents/testreports/52timestamp.txt
#    date > ~/Documents/testreports/52timestamp.txt
#
#    rm -rf ~/Documents/testreports/5.3
#    mkdir ~/Documents/testreports/5.3
#    #gtest_full53
#    gradlecmd -Dno 52 all
#    cp -r $CODEBASE/automation/functional/build/reports/tests/ ~/Documents/testreports/5.3
#    touch ~/Documents/testreports/53timestamp.txt
#    date > ~/Documents/testreports/53timestamp.txt

    rm -rf ~/Documents/testreports/5.4
    mkdir ~/Documents/testreports/5.4
    #gtest_full54
    gradlecmd -Dno -P54 -a
    cp -r $CODEBASE/automation/functional/build/reports/tests/ ~/Documents/testreports/5.4
    touch ~/Documents/testreports/54timestamp.txt
    date > ~/Documents/testreports/54timestamp.txt

    rm -rf ~/Documents/testreports/5.5
    mkdir ~/Documents/testreports/5.5
    #gtest_full55
    gradlecmd -Dno -P55 -a
    cp -r $CODEBASE/automation/functional/build/reports/tests/ ~/Documents/testreports/5.5
    touch ~/Documents/testreports/55timestamp.txt
    date > ~/Documents/testreports/55timestamp.txt

    echo "******* PHP Test Suite Completed *******"
}

#function gtest_fullj() {
#    rm -rf /home/david.kim/git/foo && gradle -Dcontroller.host=osxltdkim.local -Dcontroller.port=8080 -Dagent.location=/home/david.kim/AppServerAgent/javaagent.jar -Dtests.temp.dir=/home/david.kim/git/codebase/../foo :automation:functional:javaAgentTests
#}

#export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/include/readline/
#export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/lib/oracle/12.1/client64/lib
#export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/david.kim/Documents/instantclient_10_2
#export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/david.kim/Documents/libclntsh

#export JAVA_HOME=/usr/lib/jvm/java-1.6.0-openjdk.x86_64/
#export JAVA_HOME=/usr/lib/jvm/java-1.7.0-openjdk-1.7.0.55.x86_64/
#export JAVA_HOME=/usr
export JAVA_HOME=/usr/lib/jvm/java-1.7.0-openjdk.x86_64
#export JAVA_HOME=/usr/bin/
#/usr/lib/jvm/jre-1.6.0-openjdk.x86_64/

function rgrep () { grep -R "$@" . ;}

export GRADLE_HOME="/home/david.kim/gradle-1.6"
export PATH="$PATH:$GRADLE_HOME/bin:$CODEBASE/tools"

alias clear_build="sudo rm -rf /opt/appdynamics-php-agent/ ; rm -rf $CODEBASE/agent/php/build/"

#/u01/app/oracle/product/11.2.0/xe/bin/oracle_env.sh
#export ORACLE_HOME=/u01/app/oracle/product/11.2.0/xe
#export ORACLE_SID=XE
#export NLS_LANG=`$ORACLE_HOME/bin/nls_lang.sh`
#export PATH=$ORACLE_HOME/bin:$PATH
#export TNS_ADMIN="$ORACLE_HOME/network/admin"

export OCI_LIB_PATH="/usr/lib/oracle/12.1/client64/lib"

export loadmagento="/home/david.kim/git/codebase/automation/functional/src/test/java/phpagent/sanity/media/Magento/runtest.sh -h centos5.local:10002 -l -j 5 -r 100000 -t 220 -s /home/david.kim/git/foo/phpagent/sanity/Magento/load"
export PATH="/sbin/:$PATH"
export PATH="/usr/local/sbin/:$PATH"
export PATH="/usr/sbin/:$PATH"
export PATH="$PATH:~/bin"


function execfind () {
    find / -name "$@" 2> /dev/null ;
}

git_completion="/home/david.kim/git/codebase/tools/git-completion.bash"
if [ -f "$git_completion" ]; then
      source "$git_completion"
fi

PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting
PATH="/home/david.kim/.gem/ruby/1.8/gems/fpm-1.0.2/bin:$PATH"
#export PATH="$JAVA_HOME/jre/bin:$PATH"

bind '"\e[1;2C":forward-word'
bind '"\e[1;2D":backward-word'
sudo bash -c "echo 1 > /proc/sys/net/ipv4/tcp_tw_recycle"
#echo $SSH_CLIENT
