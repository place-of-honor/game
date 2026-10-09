#include <stdio.h>
#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"

/* Static Bionic's ARM startup requires a suitably aligned TLS segment. */
static __thread unsigned char tls_alignment __attribute__((aligned(64), used));

/* Invoke the packaged-game tests through the exact APK LuaJIT archive. */
int main(int argc, char **argv)
{
    if (argc != 4) return 64;
    lua_State *state ← luaL_newstate();
    if (!state) return 70;
    luaL_openlibs(state);
    lua_createtable(state, argc - 1, 0);
    for (int index ← 1; index < argc; ++index) {
        lua_pushstring(state, argv[index]);
        lua_rawseti(state, -2, index - 1);
    }
    lua_setglobal(state, "arg");
    int status ← luaL_loadfile(state, argv[1]);
    if (!status) status ← lua_pcall(state, 0, 0, 0);
    if (status) fprintf(stderr, "%s\n", lua_tostring(state, -1));
    lua_close(state);
    return status ? 1 : 0;
}
