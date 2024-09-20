#import <dlfcn.h>
#import <stdio.h>
#import <sys/mount.h>
#import <sys/param.h>
#import <unistd.h>
#import <rootless.h>

#define LIBJAILBREAK_PATH ROOT_PATH("/usr/lib/libjailbreak.dylib")

char *sandbox_extension_issue_file_to_self(const char *extension_class, const char *path, uint32_t flags);

int (*jbclient_root_steal_ucred)(uint64_t ucredToSteal, uint64_t *orgUcred);

void execute_unsandboxed(void (^block)(void))
{
	uint64_t credBackup = 0;
	jbclient_root_steal_ucred(0, &credBackup);
	block();
	jbclient_root_steal_ucred(credBackup, NULL);
}

int mount_unsandboxed(const char *type, const char *dir, int flags, void *data)
{
	__block int r = 0;
	execute_unsandboxed(^{
		r = mount(type, dir, flags, data);
	});
	return r;
}

int main(int argc, char *argv[]) {
    @autoreleasepool {
        if (argc != 3) {
            fprintf(stderr, "usage: %s <source> <target>\n", argv[0]);
            return 1;
        }

        if (access(LIBJAILBREAK_PATH, F_OK) != 0) {
            fprintf(stderr, "error: libjailbreak not found\n");
            return 1;
        }

        void *libjailbreak = dlopen(LIBJAILBREAK_PATH, RTLD_NOW);
        jbclient_root_steal_ucred = dlsym(libjailbreak, "jbclient_root_steal_ucred");

        return mount_unsandboxed("bindfs", argv[2], MNT_RDONLY, argv[1]);
    }
}
