#-*- encoding:utf8 -*-
#!/usr/bin/python3
#By Dogeek - Lead Developper of The Binding Of Isaac - Stillbirth
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

class GUI(tk.Frame): #TODO: lua mem usage filter to display in a separate widget to not clutter the text widget, add scroll bar, try to auto reload if the lua file is deleted & add a about/options menu
	def __init__(self, master=None):
		super(GUI, self).__init__()
		self.master = master
		self.start_stop = False
		self.log_path = get_log_path()
		self.output = tk.Text(self)
		self.menubar = tk.Menu(self)
		self.menubar.add_command(label="Start", command=self.start)
		self.menubar.add_command(label="Stop", command=self.stop)
		master.config(menu=self.menubar)
		self.oldline = "  "
		self.init_layout()
		pass
	
	def init_layout(self):
		self.output.config(font="sans 10", width=200, height=60)
		self.output.tag_config("error", foreground="#FF0000")
		self.output.tag_config("warning", foreground="#00FF00")
		self.output.tag_config("info", foreground="#0000FF")
		self.output.tag_config("luadebug", foreground="#000000")
		self.output.pack()
		self.readfile()
		pass
	
	def readfile(self):
		if self.start_stop:
			tmp = self.log_f.readline().lower()
			if self.oldline != tmp: #display spam only once@FileLoad
				self.output.config(state=tk.NORMAL)
				if "err" in tmp or "error" in tmp and not "overlayeffect" in tmp and not "animation" in tmp: #Error filter to display
					self.output.insert(tk.END, tmp, "error")
				elif "lua" in tmp and not "debug" in tmp:
					self.output.insert(tk.END, tmp, "info")
				elif "warn" in tmp:
					self.output.insert(tk.END, tmp, "warning")
				elif "lua debug" in tmp:
					self.output.insert(tk.END, tmp, "luadebug")
				self.oldline = tmp
			self.output.see(tk.END)
			self.update_idletasks()
			self.after(5, self.readfile)
			pass
		pass
	def start(self):
		self.log_f = open(self.log_path, "r")
		self.start_stop = True
		self.readfile()
		pass
	def stop(self):
		self.log_f.close()
		self.start_stop = False
		pass
	pass

if __name__ == "__main__":
	root = tk.Tk()
	root.title("Isaac Debug Helper")
	root.geometry("650x500")
	gui = GUI(root)
	gui.pack()
	gui.mainloop()
