## Get more detailed log info
If you cannot get enough log to track down your issues, please follow below steps:

Step1, go into the Pod of ks-installer via kubectl:
`kubectl -n kubesphere-system exec -it $(kubectl -n kubesphere-system get pod -o name | grep ks-installer) bash`

Step2, change directory to `/kubesphere/results`. For example, you can find all details about DevOps:

```shell script
bash-5.0$ ls -ahl
total 32K
drwx------    4 kubesphe kubesphe    4.0K Nov 10 11:15 .
drwxr-xr-x    3 kubesphe kubesphe    4.0K Nov 10 11:15 ..
-rw-------    1 kubesphe kubesphe    3.6K Nov 10 11:15 command
drwxr-xr-x    2 kubesphe kubesphe    4.0K Nov 10 11:15 fact_cache
drwx------    2 kubesphe kubesphe    4.0K Nov 10 11:15 job_events
-rw-------    1 kubesphe kubesphe       1 Nov 10 11:15 rc
-rw-------    1 kubesphe kubesphe       6 Nov 10 11:15 status
-rw-------    1 kubesphe kubesphe     660 Nov 10 11:15 stdout
```
