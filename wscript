#!/usr/bin/env python
# encoding: utf-8
#
# Copyright 2013-2014 Jiří Janoušek <janousek.jiri@gmail.com>
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met: 
# 
# 1. Redistributions of source code must retain the above copyright notice, this
#    list of conditions and the following disclaimer. 
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution. 
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# Top of source tree
top = '.'
# Build directory
out = 'build'

# Application name and version
DISPLAY_NAME = "Mount Watch"
APPNAME = "mountwatch"
VERSION = "0.01"

import sys
import subprocess
from waflib.Configure import conf
from waflib.Errors import ConfigurationError
from waflib.Context import WAFVERSION

WAF_VERSION = map(int, WAFVERSION.split("."))
REQUIRED_VERSION = [1, 7, 14] 
if WAF_VERSION < REQUIRED_VERSION:
	print("Too old waflib %s < %s. Use waf binary distributed with the source code!" % (WAF_VERSION, REQUIRED_VERSION))
	sys.exit(1)

@conf
def vala_def(ctx, vala_definition):
	"""Appends a Vala definition"""
	if not hasattr(ctx.env, "VALA_DEFINES"):
		ctx.env.VALA_DEFINES = []
	if isinstance(vala_def, tuple) or isinstance(vala_def, list):
		for d in vala_definition:
			ctx.env.VALA_DEFINES.append(d)
	else:
		ctx.env.VALA_DEFINES.append(vala_definition)

@conf
def check_dep(ctx, pkg, uselib, version, mandatory=True, store=None, vala_def=None, define=None):
	"""Wrapper for ctx.check_cfg."""
	result = True
	try:
		res = ctx.check_cfg(package=pkg, uselib_store=uselib, atleast_version=version, mandatory=True, args = '--cflags --libs')
		if vala_def:
			ctx.vala_def(vala_def)
		if define:
			for key, value in define.iteritems():
				ctx.define(key, value)
	except ConfigurationError, e:
		result = False
		if mandatory:
			raise e
	finally:
		if store is not None:
			ctx.env[store] = result
	return res

def revision_info(ctx):
	try:
		try:
			revision = open("revision-info", "r").read()
		except Exception, e:
			revision = subprocess.Popen(["bzr", "revision-info"], stdout=subprocess.PIPE).communicate()[0]
	except Exception, e:
		import sys
		sys.stderr.write("Failed to get revision information from file `revision-info` or command `bzr revision-info`. Install Bazaar (bzr).\n")
		print e
		sys.exit(1)
	
	ctx.define("REVISION", str(revision).strip())

# Add extra options to ./waf command
def options(ctx):
	ctx.load('compiler_c vala')
	ctx.add_option('--noopt', action='store_true', default=False, dest='noopt', help="Turn off compiler optimizations")
	ctx.add_option('--debug', action='store_true', default=True, dest='debug', help="Turn on debugging symbols")
	ctx.add_option('--no-debug', action='store_false', dest='debug', help="Turn off debugging symbols")

# Configure build process
def configure(ctx):
	ctx.msg('Install prefix', ctx.options.prefix, "GREEN")
	ctx.load('compiler_c vala')
	ctx.check_vala(min_version=(0,16,1))
	
	# Don't be quiet
	ctx.env.VALAFLAGS.remove("--quiet")
	ctx.env.append_value("VALAFLAGS", "-v")
	
	# enable threading
	ctx.env.append_value("VALAFLAGS", "--thread")
	
	# Turn compiler optimizations on/off
	if ctx.options.noopt:
		ctx.msg('Compiler optimizations', "OFF?!", "RED")
		ctx.env.append_unique('CFLAGS', '-O0')
	else:
		ctx.env.append_unique('CFLAGS', '-O2')
		ctx.msg('Compiler optimizations', "ON", "GREEN")
	
	# Include debugging symbols
	if ctx.options.debug:
		ctx.env.append_unique('CFLAGS', '-g3')
		ctx.env.append_unique('VALAFLAGS', '-g')
	
	# Anti-underlinking and anti-overlinking linker flags.
	ctx.env.append_unique("LINKFLAGS", ["-Wl,--no-undefined", "-Wl,--as-needed"])
	
	# Check dependencies
	ctx.check_dep('glib-2.0', 'GLIB', '2.32')
	ctx.check_dep('gio-2.0', 'GIO', '2.32')
	ctx.check_dep('gthread-2.0', 'GTHREAD', '2.32')
	ctx.check_dep('dioriteglib', 'DIORITEGLIB', '0.0.1')
	
	ctx.define("APPNAME", DISPLAY_NAME)
	ctx.define("APPPATH", APPNAME)
	ctx.define("G_LOG_DOMAIN", APPNAME)
	ctx.define("APPVERSION", VERSION)

def build(ctx):
	revision_info(ctx)
	#~ print ctx.env
	
	packages = 'glib-2.0 gio-2.0 dioriteglib'
	uselib = 'GLIB GIO GTHREAD DIORITEGLIB'
	vala_defines = ctx.env.VALA_DEFINES
	
	ctx.program(
		target = APPNAME,
		source = ctx.path.ant_glob('src/*.vala'),
		packages = packages,
		uselib = uselib,
		vala_defines = vala_defines,
		vapi_dirs = ['vapi'],
		vala_target_glib = "2.32",
		)

def dist(ctx):
	def my_archive():
		ctx._archive()
		node = ctx.path.find_node("revision-info")
		if node:
			node.delete()
	
	ctx._archive, ctx.archive = ctx.archive, my_archive
	
	ctx.exec_command("bzr revision-info > revision-info")
	ctx.algo      = 'tar.gz'
	ctx.excl      = '.bzrignore .bzr **~ .waf* .*'
