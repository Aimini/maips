import pathlib
import os
import subprocess
import threading

script_folder = pathlib.Path('.') / "generate"




successed_count = 0
failed_list = []

count_lock = threading.Lock()
sem = threading.Semaphore(8)

def new_target(i,x):
    sem.acquire()
    print(f"[begin:{i}] ", end='')
    print(x)
    r = os.system(str(x)) 
    with count_lock:
        global successed_count
        global failed_list
        if r != 0:
            failed_list.append(x)
        else:
            successed_count += 1
    sem.release()

tlist = []
for i, x in enumerate(script_folder.iterdir()):
    if x.is_file() and not x.name.startswith("__"):
        t = threading.Thread(target=new_target,args=(i,x))
        tlist.append(t)

for onerun in tlist:
    onerun.start()
for onerun in tlist:
    onerun.join()

print(f"successed {successed_count}")
print(f"failed {len(failed_list)}")
map(print,failed_list)
