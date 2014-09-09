#!/bin/bash
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
set -u

DIR=`dirname "$0"`
DIR=`cd "${DIR}/.."; pwd`

. $DIR/bin/sparkbench-config.sh

if [ -f $SPARKBENCH_REPORT ]; then
    rm $SPARKBENCH_REPORT
fi

function check_and_build {
    local folder=$1
    local module=$2
    echo $folder/*.sbt
    if ls $folder/*.sbt &> /dev/null; then
	echo "====================="
	echo "Build ${module}..."
	echo "====================="
	( cd $folder && sbt package )
	result=$?
	if [ $result -ne 0 ]; then
	    echo "Build ${module} failed!"
	    exit $result
	fi
    fi
}

# build data generator
check_and_build $DIR/data_gen data_gen

for benchmark in `cat $DIR/conf/benchmarks.lst`; do
    if [[ $benchmark == \#* ]]; then continue; fi
    if [ -z $benchmark ]; then continue; fi

    # build prepare, java, scala for each benchmarks
    for target in prepare java scala; do	
	check_and_build $DIR/$benchmark/$target ${benchmark}/${target}
    done
done

echo "Build all done!"