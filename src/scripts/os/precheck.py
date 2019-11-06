#!/usr/bin/env python
# encoding: utf-8

import  yaml, os

storageList = ['local_volume','ceph_rbd','nfs_client','glusterfs_provisioner','qingcloud_csi','neonsan_csi']
def getVarsFiles():
    varsFiles = []
    varsPath = os.path.join(os.getcwd(), "../conf")
    fileList = os.listdir(varsPath)
    for file in  fileList:
        varsFiles.append(os.path.join(varsPath, file))

    return varsFiles

def getVars(varsFiles):
    vars = {}
    for file in varsFiles:
        filename, type = os.path.splitext(file)
        if type == '.yaml' or type == '.yml':
            with open(file, 'r') as f:
                configs = yaml.load(f.read(), Loader=yaml.FullLoader)
            f.close()
            vars.update(configs)
    return vars

def defaultStorageClassCheck(vars, varsfiles):

    defaultStorageClass=[]
    for sc in storageList:
        if '{}_enabled'.format(sc) in vars.keys() and vars['{}_enabled'.format(sc)] == True:
            if '{}_is_default_class'.format(sc) in vars.keys() and vars['{}_is_default_class'.format(sc)] == True:
                defaultStorageClass.append(sc)

    if len(defaultStorageClass) != 1:
        if len(defaultStorageClass) == 0:
            print("Default storage class must be set !")
        if len(defaultStorageClass) > 1:
            os.system("clear")
            print("Only one default storage class can be set ! Have to choose one: \n")
            for index, sc in enumerate(defaultStorageClass):
                print("{}. {}".format(index + 1, sc))

            print("\n")
            scNum = 0
            while scNum > len(defaultStorageClass) or scNum < 1:
              try:
                  scNum = int(input("please choose: "))
              except:
                  print("Invalid input character !")

            del defaultStorageClass[scNum - 1]

            for sc in defaultStorageClass:
                for file in varsfiles:
                    os.system('sed -i "/{}_is_default_class/s/\:.*/\: false/g" {}'.format(sc, file))

# def externalLoadBlancerCheck(varsFiles):
#     hostsFile = os.path.join(os.getcwd(), "../conf/hosts.ini")
#     print(hostsFile)
#     hostsConfig = ConfigParser.ConfigParser()
#     # with open(hostsFile, 'r') as f:
#     #     hostsConfig.read(f)
#     # f.close()
#     print(hostsConfig.read(hostsFile))
#     # masters = hostsConfig.options("kube-master")
#     # print(masters)

if __name__ == '__main__':
    # externalLoadBlancerCheck(getVarsFiles())
    defaultStorageClassCheck(getVars(getVarsFiles()), getVarsFiles())

