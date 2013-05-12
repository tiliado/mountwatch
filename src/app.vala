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

public extern const string APPNAME;
public extern const string APPPATH;
public extern const string APPVERSION;

namespace MountWatch
{
public const string EVENT_MOUNT = "M";
public const string EVENT_UNMOUNT = "U";
const string TASKS_DIRECTORY = "tasks";

public class App
{
	private VolumeMonitor monitor;
	private File library;
	private MainLoop loop;
	
	public App()
	{
		library = File.new_for_path(Environment.get_user_config_dir()).get_child(APPPATH).get_child(TASKS_DIRECTORY);
		monitor = VolumeMonitor.get();
	}
	
	public void run()
	{
		loop = new MainLoop();
		monitor.mount_added.connect(on_mount_added);
		monitor.mount_pre_unmount.connect(on_mount_pre_unmount);
		message("%s %s is running...", APPNAME, APPVERSION);
		if (library.query_exists())
			message("Library of tasks: %s", library.get_path());
		else
			warning("Library of tasks not found: %s", library.get_path());
		loop.run();
	}
	
	public void quit()
	{
		monitor.mount_added.disconnect(on_mount_added);
		monitor.mount_pre_unmount.disconnect(on_mount_pre_unmount);
		loop.quit();
	}
	
	private void on_mount_added(Mount mount)
	{
		message("Mount: %s (%s) at %s", mount.get_name(), mount.get_uuid() ?? "null", mount.get_root().get_path());
		var tasks = get_tasks(EVENT_MOUNT, mount.get_uuid() ?? mount.get_name());
		run_tasks(tasks, mount.get_root().get_path());
	}
	
	private void on_mount_pre_unmount(Mount mount)
	{
		message("Unmount: %s (%s) at %s", mount.get_name(), mount.get_uuid() ?? "null", mount.get_root().get_path());
		var tasks = get_tasks(EVENT_UNMOUNT, mount.get_uuid() ?? mount.get_name());
		run_tasks(tasks, mount.get_root().get_path());
	}
	
	private SList<string> get_tasks(string event, string id)
	{
		SList<string> tasks = new SList<string>();
		var prefix = id + "--" + event;
		try
		{
			var enumerator = library.enumerate_children(FileAttribute.STANDARD_NAME, 0);
			FileInfo file_info;
			while ((file_info = enumerator.next_file()) != null)
			{
				var name = file_info.get_name();
				if (name.has_prefix(prefix))
					tasks.prepend(library.get_child(name).get_path());
			}
		}
		catch (GLib.Error e)
		{
			stderr.printf ("Error: %s\n", e.message);
		}
		
		tasks.sort(GLib.strcmp);
		return tasks;
	}
	
	private void run_tasks(SList<string> tasks, string root)
	{
		
		foreach(var task in tasks)
			try
			{
				run_task(task, root);
			}
			catch (Error e)
			{
				warning("%s", e.message);
			}
	}
	
	private void run_task(string task, string root) throws Error
	{
		stdout.printf("Run> %s %s\n", task, root);
		int result = 0;
		string cmd_out;
		string cmd_err;
		try
		{
			string[] args = {task, root};
			Process.spawn_sync(null, args, null,  SpawnFlags.SEARCH_PATH, null, out cmd_out, out cmd_err, out result);
		}
		catch(SpawnError e)
		{
			throw new Error.EXECUTION_FAILED("Execution of '%s' failed: %s", task, e.message);
		}
		
		if (result != 0)
			throw new Error.TASK_FAILED("Task '%s' returned nonzero status: %d\nstdout: %s\nstderr: %s", task, result, cmd_out, cmd_err);
		message("Finished> %s %s\nstdout: %s\nstderr: %s", task, root, cmd_out, cmd_err);
	}
}

public errordomain Error
{
	EXECUTION_FAILED,
	TASK_FAILED
}

}
