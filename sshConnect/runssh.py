#!/usr/bin/python
##############################
#
##############################

import os
import sys
import re
import pexpect

class runssh:
	def __init__(self, user, path):
		self.user = user
		self.path = path

	def run(self):
		try:
			child = pexpect.spawn('ssh ' + self.user + '@' + self.path )
			child.expect('password')
			child.sendline('123456')
			child.interact()
		except OSError:
			sys.exit(0)
					
if __name__ == '__main__':

	if len(sys.argv) < 1:
		print 'Please give the path!'
		sys.exit()

	if len(sys.argv) == 1:
		rc = runssh('gms-01','192.168.1.110')
	else:
		rc = runssh(sys.argv[1],sys.argv[2])

	rc.run()
