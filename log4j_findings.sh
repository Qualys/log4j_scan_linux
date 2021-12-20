#!/bin/sh

log4j()
{ 
    echo "Scanning started for log4j jar" > /usr/local/qualys/cloud-agent/log4j_findings.stderr ;
    date >> /usr/local/qualys/cloud-agent/log4j_findings.stderr;
    
    id=$(id);
    if ! (echo $id | grep "uid=0")>/dev/null;then 
        echo "Please run the script as root user for complete results";
    fi;
    
    zip -v 2> /dev/null 1> /dev/null;
    isZip=$?;
    unzip -v 2> /dev/null 1> /dev/null;
    isUnZip=$?;
    
    if [ "$isZip" -eq 0 ] && [ "$isUnZip" -eq 0 ];then 
        jars=$(find / -xdev -name "*.jar" -type f ! -fstype nfs ! -fstype nfs4 ! -fstype cifs ! -fstype smbfs ! -fstype gfs ! -fstype gfs2 ! -fstype safenetfs ! -fstype secfs ! -fstype gpfs ! -fstype smb2 ! -fstype vxfs ! -fstype vxodmfs ! -fstype afs -print 2>/dev/null);
        
        IFS=$'\n'
        for i in $jars ;do 
            if zip -sf $i | grep "JndiLookup.class" >/dev/null;then 
                jdi="JNDI Class Found";
            else 
                jdi="JNDI Class Not Found";
            fi;
            if test=$(zip -sf $i | grep "[l]og4j" | grep "pom.xml");then 
                echo "Source: "$test;
                echo "JNDI-Class: "$jdi;echo 'Path= '$i;ve=$(unzip -p $i $test 2> /dev/null | grep -Pzo "<artifactId>log4j</artifactId>\s*<version>.+?</version>"| cut -d ">" -f 2 | cut -d "<" -f 1 | head -2|awk 'ORS=NR%3?FS:RS');
                if [ -z "$ve" ]; then 
                    echo 'log4j Unknown'; 
                else 
                    echo $ve; 
                fi;
                echo "------------------------------------------------------------------------";
            fi;
        done;
    else 
        jars=$( find / -xdev -name "*.jar" -type f ! -fstype nfs ! -fstype nfs4 ! -fstype cifs ! -fstype smbfs ! -fstype gfs ! -fstype gfs2 ! -fstype safenetfs ! -fstype secfs ! -fstype gpfs ! -fstype smb2 ! -fstype vxfs ! -fstype vxodmfs ! -fstype afs -print 2> /dev/null); 
        IFS=$'\n'
        for i in $jars ; do 
            var=$(echo $i | grep -i "log4j.*jar" ) 2> /dev/null; 
            if [ ! -z "$var" ]; then 
                echo 'Path: '$i; ver=$(echo $i | grep -o '[^\/]*$' | grep -oE "([0-9]+\.[0-9]+\.[0-9]+-[a-zA-Z0-9]*[0-9]*|[0-9]+\.[0-9]+-[a-zA-Z0-9]+[0-9]*|[0-9]+\.[0-9]+\.[0-9]+|[0-9]+\.[0-9]+)" | tail -1) 2> /dev/null; 
                if [ -z "$ver" ]; then 
                    echo 'log4j Unknown'; 
                else 
                    echo 'log4j '$ver; 
                fi; 
                echo "------------------------------------------------------------------------"; 
            else 
                injars=$( (jar -tf $i | grep -i "log4j.*jar") 2> /dev/null); 
                for j in $injars ; do 
                    if [ ! -z "$j" ]; then 
                        echo 'Path: '$j; 
                        ver1=$(echo $j | grep -o '[^\/]*$' | grep -oE "([0-9]+\.[0-9]+\.[0-9]+-[a-zA-Z0-9]*[0-9]*|[0-9]+\.[0-9]+-[a-zA-Z0-9]+[0-9]*|[0-9]+\.[0-9]+\.[0-9]+|[0-9]+\.[0-9]+)" | tail -1) 2> /dev/null; 
                        if [ -z "$ver1" ]; then 
                            echo 'log4j Unknown'; 
                        else 
                            echo 'log4j '$ver1; 
                        fi; 
                    fi; 
                    echo "------------------------------------------------------------------------"; 
                done;
            fi;
        done;
    fi;
    echo "Run status : Success" >> /usr/local/qualys/cloud-agent/log4j_findings.stderr;
};

if [ ! -d "/usr/local/qualys/cloud-agent/" ]; then 
    mkdir -p "/usr/local/qualys/cloud-agent/";
    chmod 750 "/usr/local/qualys/cloud-agent/";
fi; 

if [ ! -f "/usr/local/qualys/cloud-agent/log4j_findings_disabled" ]; then 
    log4j > /usr/local/qualys/cloud-agent/log4j_findings.stdout 2>/usr/local/qualys/cloud-agent/log4j_findings.stderr;
else 
    rm -rf /usr/local/qualys/cloud-agent/log4j_findings.stdout; 
    echo "Flag is disabled, skipping command execution" > /usr/local/qualys/cloud-agent/log4j_findings.stderr;
fi;
