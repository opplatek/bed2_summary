#!/bin/bash

PATH_PRO=`pwd`
echo -e "# added by piPipes_summary installer\nexport PATH=${PATH_PRO}:\$PATH" >> ~/.bashrc
echo -e "export PYTHONPATH=${PATH_PRO}/lib_python:\t$PYTHONPATH" >> ~/.bashrc
source ~/.bashrc