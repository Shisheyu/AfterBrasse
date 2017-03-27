#Krayz:Beta. Work With IDLE Tested Windows and linux.
#Py 3.4.3
#Lancer le script APRES avoir lancé le jeux: commandes stop(), start() and reload()
import sys
import _thread
import time

#Linux: working
log_path = "/home/simon/.local/share/binding of isaac afterbirth+/log.txt" #modidy by your path
#Window: working
#log_path = "C:\\Users\\****\\Documents\\My Games\\Binding of Isaac Afterbirth+\\log.txt" #modidy by you path
db = 0



class DebugLog:
    def __init__(self):
        self._ThreadRunning = 0
        self.thread0 = 0

    def _readfile(self):
        f = open(log_path, "r")
        oldline = " "
        print()
        while (1):
            tmp = f.readline().lower()
            if oldline != tmp: #display spam only once@FileLoad
                if "err" in tmp or "error" in tmp or "warn" in tmp and not "overlayeffect" in tmp and not "animation" in tmp: #Filtre d'error a afficher / ne pas afficher
                    print(tmp, end='', file=sys.stderr)
                elif "lua" in tmp:
                    print(tmp, end='')
                oldline = tmp
            if self._ThreadRunning == 0:
                f.close()
                print("-Thread Closed-")
                _thread.exit()
                return
            time.sleep(0.005)

    def _startDebug(self):
        self._ThreadRunning = 1
        self.thread0 = _thread.start_new_thread(self._readfile,())
        print("-Thread Started- ." + str(self._ThreadRunning), end='')

    def _end(self):
        self._ThreadRunning = 0
        self.thread0 = 0

def reload():
    db._end()
    time.sleep(0.5)
    db._startDebug()

if __name__ == "__main__":
    db = DebugLog()
    help = "stop(), start() and reload()"
    stop = db._end
    start = db._startDebug
    start()
