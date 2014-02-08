/*
 * Copyright 2013 Jiří Janoušek <janousek.jiri@gmail.com>
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met: 
 * 
 * 1. Redistributions of source code must retain the above copyright notice, this
 *    list of conditions and the following disclaimer. 
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution. 
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
 * ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

namespace MountWatch
{
	
	private static bool opt_system = false;
	private static bool opt_verbose = false;
	private static bool opt_debug = false;
	private static bool opt_version = false;
	private static string? opt_log_file = null;
	
	private const OptionEntry[] options =
	{
		{ "system", 0, 0, OptionArg.NONE, ref opt_system, "Run task from system tasks library", null },
		{ "verbose", 'v', 0, OptionArg.NONE, ref opt_verbose, "Print informational messages", null },
		{ "debug", 'd', 0, OptionArg.NONE, ref opt_debug, "Print debugging messages", null },
		{ "version", 'V', 0, OptionArg.NONE, ref opt_version, "Print version and exit", null },
		{ "log-file", 'L', 0, OptionArg.FILENAME, ref opt_log_file, "Log to file", "FILE" },
		{ null }
	};

int main(string[] args)
{
	try
	{
		var opt_context = new OptionContext("- Diorite Test Generator");
		opt_context.set_help_enabled(true);
		opt_context.add_main_entries(options, null);
		opt_context.parse(ref args);
	}
	catch (OptionError e)
	{
		stderr.printf("%s\n", e.message);
		return 1;
	}
	
	if (opt_version)
	{
		stdout.printf("%s %s\n", APPNAME, APPVERSION);
		stdout.printf("Revision: %s\n", REVISION);
		return 0;
	}
	
	FileStream? log = null;
	
	if (opt_log_file != null)
	{
		log = FileStream.open(opt_log_file, "w");
		if (log == null)
		{
			stderr.printf("Cannot open log file '%s' for writting.\n", opt_log_file);
			return 1;
		}
	}

	
	Diorite.Logger.init(log != null ? log : stderr, opt_debug ? GLib.LogLevelFlags.LEVEL_DEBUG : (opt_verbose ? GLib.LogLevelFlags.LEVEL_INFO: GLib.LogLevelFlags.LEVEL_WARNING));
	
	var app = new App(opt_system);
	app.run();
	return 0;
}

}
