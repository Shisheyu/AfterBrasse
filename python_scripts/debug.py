#!/usr/bin/python3
import tkinter as tk
import sys
import time
from os.path import expanduser

def get_log_path():
	p = ""
	if sys.platform == "linux" or sys.platform == "linux2":
		p = expanduser("~/.local/share/binding of isaac afterbirth+/log.txt")
	elif sys.platform == "darwin":
		p = expanduser("~/Library/Application Support/Binding of Isaac Afterbirth+/log.txt")
	elif sys.platform == "win32":
		p = expanduser("~/Documents/My Games/binding of isaac afterbirth+/log.txt")
	return p
	pass

class GUI(tk.Frame):
	def __init__(self, master=None):
		super(GUI, self).__init__()
		self.master = master
		self.log_path = get_log_path()
		self.output = tk.Text(master)
		self.frame=tk.Frame()
		self.scrollbar=tk.Scrollbar()
		self.reloadButton = tk.Button(self.frame, text="Reload", command=self.reload)
		self.startButton = tk.Button(self.frame, text="Start", command=self.start)
		self.stopButton = tk.Button(self.frame, text="Stop", command=self.stop)
		self.init_layout()

		self.oldline = "  "


		self.i=0 #DB

		pass

	def init_layout(self):
		#self.output.pack(side=tk.LEFT, fill=tk.BOTH, expand=1)
		self.scrollbar.pack(side=tk.RIGHT, fill=tk.Y)
		self.output.config(font="sans 12", wrap=tk.WORD, yscrollcommand=self.scrollbar.set)
		self.output.tag_config("error", foreground="#FF0000")
		self.output.tag_config("info", foreground="#0000FF")
		self.scrollbar.config(command= self.output.yview)
		self.frame.pack(side=tk.RIGHT)
		self.reloadButton.pack(in_=self.frame)
		self.startButton.pack(in_=self.frame)
		self.stopButton.pack(in_=self.frame)
		pass

	def readfile(self):
		with open(self.log_path, "r") as f:
			tmp = f.readline().lower()
			#DB
			self.output.insert(tk.END, str(self.i) + " " + tmp)
			self.output.pack()
			self.i+=1
			#END DB
			if self.oldline != tmp: #display spam only once@FileLoad
				if "err" in tmp or "error" in tmp or "assert" in tmp or "warn" in tmp and not "overlayeffect" in tmp and not "animation" in tmp: #Filtre d'error a afficher / ne pas afficher
					#print(tmp, end='', file=sys.stderr)
					self.output.insert(tk.END, tmp)
					index = "end - 1 lines"
					self.output.tag_add("error", index)
				elif "lua" in tmp:
					#print(tmp)
					self.output.insert(tk.END, tmp)
					index = "end - 1 lines"
					self.output.tag_add("info", index)
				self.oldline = tmp
				self.output.pack()
			pass
		self.after(5, self.readfile)
		pass
	def reload(self):
		pass
	def start(self):

		self.readfile()
		pass
	def stop(self):
		pass
	pass

if __name__ == "__main__":
	root = tk.Tk()
	root.title("Isaac Debug Helper")
	#root.geometry("650x500")
	gui = GUI(root)
	gui.mainloop()
