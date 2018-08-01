#!/usr/bin/env python
# -*- coding: utf-8 -*-
# Author  : chinatree <chinatree2012#gmail.com>
# Date    : 2015-10-16
# Version : 1.0

# [import]
import os
import sys
import hashlib

# [global]
SCRIPT_PATH = os.path.dirname(os.path.abspath(__file__))
SCRIPT_NAME = os.path.basename(__file__)
PROJECT_ROOT = os.path.dirname(SCRIPT_PATH)

class GenerateMd5List():
    def __init__(self):
        self.file_fd = None
    
    def do_generate(self, scan_dir, md5_list_file):
        self.file_fd = open(md5_list_file, "w")
        if not self.file_fd:
            print("Cannot open the file %s for writing." % md5_list_file)
        self.list_dir(scan_dir)
        self.file_fd.close()
    
    def list_dir(self, dir):
        files = os.listdir(dir)
        files.sort()
        for file in files:
            full_path_name = os.path.join(dir, file)
            if(os.path.isdir(full_path_name)):
                self.list_dir(full_path_name)
            else:
                hash = self.calc_md5(full_path_name)
                self.file_fd.write(hash + "    " + full_path_name + "\n")
        pass

    def calc_md5(self, file):
        hlm = hashlib.md5()
        fp = open(file, 'rb')
        hlm.update(fp.read())
        return hlm.hexdigest()
        fp.close()
    
    def calc_big_md5(self, file):
        hlm = hashlib.md5()        
        fp = open(file, 'rb')
        while True:
            buff = fp.read(8096)
            if not buff:
                break
            hlm.update(b)
        fp.close()
        return hlm.hexdigest()

if __name__ == '__main__':
    if len(sys.argv) != 3:
        print "Usage: \
        \n    %s <scan_dir> <md5_list_file>" % sys.argv[0]
        sys.exit(2)
    else:
        scan_dir = sys.argv[1].strip()
        md5_list_file = sys.argv[2].strip()
        md5_list_file = "%s/tmp/%s" % (PROJECT_ROOT, md5_list_file)

    if(not os.path.isdir(scan_dir)):
        print("%s is not a valid directory." % scan_dir)
        sys.exit(2)

    try:
        GenerateMd5List().do_generate(scan_dir, md5_list_file)
    except Exception, e:
        print e
