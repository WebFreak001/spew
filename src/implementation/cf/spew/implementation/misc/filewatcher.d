﻿module cf.spew.implementation.misc.filewatcher;
import cf.spew.miscellaneous.filewatcher;
import devisualization.bindings.libuv;
import stdx.allocator : IAllocator, makeArray, dispose;

abstract class FileSystemWatcherImpl : IFileSystemWatcher {
	package(cf.spew.implementation) {
		IAllocator alloc;

		// some weirdo bug for dmd.
		version(DigitalMars) {
			ubyte[4] padding1;
		}
		char[] thePath;

		FileSystemWatcherEventDel onChangeDel, onCreateDel, onDeleteDel;
	}

	~this() {
		alloc.dispose(thePath);
	}

	this(char[] path, IAllocator alloc) {
		this.thePath = path;
		this.alloc = alloc;
	}

	@property {
		scope string path() { return cast(string)thePath; }
	}
	
	void onChange(FileSystemWatcherEventDel del) { onChangeDel = del; }
	void onCreate(FileSystemWatcherEventDel del) { onCreateDel = del; }
	void onDelete(FileSystemWatcherEventDel del) { onDeleteDel = del; }
}

class LibUVFileSystemWatcher : FileSystemWatcherImpl {
	package(cf.spew.implementation) {
		LibUVFileSystemWatcher self;
		uv_fs_event_t ctx;
		bool stopped;
	}

	this(string path, IAllocator alloc) {
		import cf.spew.event_loop.wells.libuv;

		char[] thePathC = alloc.makeArray!char(path.length+1);
		thePathC[0 .. $-1] = path[];
		thePathC[$-1] = 0;

		super(thePathC[0 .. $-1], alloc);
		self = this;

		libuv.uv_fs_event_init(getThreadLoop_UV(), &ctx);
		ctx.data = &self;
		libuv.uv_fs_event_start(&ctx, &libuvFSWatcherCB, thePathC.ptr, uv_fs_event_flags.UV_FS_EVENT_RECURSIVE);
	}

	~this() {
		if (!stopped) stop();
	}

	void stop() {
		if (!stopped) {
			stopped = true;
			libuv.uv_fs_event_stop(&ctx);
			libuv.uv_close(cast(uv_handle_t*)&ctx, null);
		}
	}
}

extern(C) {
	void libuvFSWatcherCB(uv_fs_event_t* handle, const(char)* filename, int events, int status) {
		import std.file : exists;
		import core.stdc.string : strlen;

		LibUVFileSystemWatcher watcher = *cast(LibUVFileSystemWatcher*)handle.data;
		string name = cast(string)filename[0 .. strlen(filename)];

		bool needSeperator = !(watcher.thePath[$-1] == '/' || watcher.thePath[$-1] == '\\');
		char[] fullPath = watcher.alloc.makeArray!char((needSeperator ? 1 : 0) + watcher.thePath.length + name.length);

		fullPath[0 .. watcher.thePath.length] = watcher.thePath[];
		if (needSeperator) fullPath[watcher.thePath.length] = '/';
		fullPath[$-name.length .. $] = name[];

		if (events == uv_fs_event.UV_RENAME) {
			if (exists(fullPath)) {
				if (watcher.onCreateDel !is null)
					watcher.onCreateDel(watcher, cast(string)fullPath);
			} else {
				if (watcher.onDeleteDel !is null)
					watcher.onDeleteDel(watcher, cast(string)fullPath);
			}
		} else if (events == uv_fs_event.UV_CHANGE) {
			if (watcher.onChangeDel !is null)
				watcher.onChangeDel(watcher, cast(string)fullPath);
		}

		watcher.alloc.dispose(fullPath);
	}
}
