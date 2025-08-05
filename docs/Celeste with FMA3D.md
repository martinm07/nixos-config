Yesterday I was playing Celeste, when I ran into weird lighting issues in Chapter 5 (the Mirror Temple), where in the dark section where you light it up as you go, there was issues with the lights all clipping in strange ways and generally making things way too dark (and if you back out and jump directly to this section the lighting completely breaks).
I naturally wanted to fix this, and the first thing I did was go to Proton DB, and indeed I found others experiencing the same issues:

[https://www.protondb.com/app/504230](https://www.protondb.com/app/504230)# ...\
...[1ywjmHj60t](https://www.protondb.com/app/504230#1ywjmHj60t), [TPfJAWZjz1](https://www.protondb.com/app/504230#TPfJAWZjz1), [DSplU_siay](https://www.protondb.com/app/504230#DSplU_siay), [ZBUhkzlv5a](https://www.protondb.com/app/504230#ZBUhkzlv5a), [Pm_254oTeY](https://www.protondb.com/app/504230#Pm_254oTeY)

And most of the suggestions were to force "FNA3D" to use Vulkan, using either the environment variable (`FNA3D_FORCE_DRIVER=Vulkan`) or launch parameter (`/gldevice:Vulkan`). There were many different signals I was getting from ProtonDB, however. For one, there is a native Linux port of the game, and a lot of people were testing from that. There was also a good few people who suggested forcing the game to use OpenGL (using the same methods as to force Vulkan). Not all who said they were experiencing lighting issues seemed to be able to fix them, although it seemed some were able to.

Anyway, I tried forcing Vulkan using `FNA3D_FORCE_DRIVER=Vulkan`, and that was immediately met with the game not starting with instead the Windows notepad app opening to "error_log.txt" saying "No FNA3D driver found!" Asking ChatGPT & Claude about this just gave me a million more environment variables to set, although the main ones seemed to be `LD_LIBRARY_PATH`, `VK_LAYER_PATH` and `VK_ICD_FILENAMES`. These seemed to provide search paths for my native Vulkan drivers, which I learnt mainly live in `run/opengl-driver[-32]/share/vulkan/`. This did produce a different error; "vkQueueSubmit VK_ERROR_DEVICE_LOST", and that one seems to be... a lot harder to fix.\
Apparently, it's a runtime error due to bad interactions between FNA3D and my Vulkan driver (which is the Mesa RADV driver). There is also another Open-source AMD GPU Vulkan driver (called `amdvlk`), and so I tried changing to that one instead ([according to the NixOS wiki](https://nixos.wiki/wiki/AMD_GPU#AMDVLK)). That caused the game to crash immediately without any popup Windows text file. It also seemed to cause the other games I had to crash similarly. So I immediately gave up on that path.

This is all further complicated by the fact that the game is running in a Windows environment, and expects to make calls to a Windows Vulkan driver. Calls to this need to be forwarded to my actual native (Linux) Vulkan driver by the Wine prefix, which apparently it does by overriding `vulkan-1.dll` to one that uses `winevulkan.dll.so` for translation. This process seems to be working in general, as when I tried to run a different EXE using Vulkan ([Geek3D's Vulkan Raytacing Demo](https://www.geeks3d.com/dl/show/50110)) it worked flawlessly without needing to set envrionment variables or anything.

This poses the problem of why I got a "No FNA3D driver found!" error in the first place, which I needed to (seemingly) resolve using env variables. Another interesting data point here is using the launch parameter `/gldevice:Vulkan` *instead*. This (without requiring any env variables) got to the same "vkQueueSubmit VK_ERROR_DEVICE_LOST" crash. This seems to be some weird behavioural difference by FNA3D which ChatGPT claims to be by FNA using SDL ([Simple DirectMedia Layer](https://en.wikipedia.org/wiki/Simple_DirectMedia_Layer)) to initialise drivers (and the launch paramter simply being a "suggestion" to SDL to which one to pick) vs. the env variable which bypasses SDL and has FNA try to load the driver directly, lacking the discoverability/interaction with Wine to do so correctly.

There seem to be a few possibilities of what is causing "vkQueueSubmit VK_ERROR_DEVICE_LOST":

- The game being old with the Mesa RADV driver making backward-incompatible changes since then. Note that the Vulkan API itself hasn't undergone a new major release (2.0); the latest Vulkan version is 1.4&mdash; perhaps the time at which the Celeste binary was built it was 1.0. This would have to be because the drivers (like RADV) have become "stricter" and more standards-compliant, and FNA3D is trying to use undefined or outdated Vulkan behaviour. That does make this seem less likely as a possibility overall, though.
- FNA3D or Wine selecting the wrong GPU (the iGPU instead of the 7900 XTX), which doesn't support Vulkan
- Bugs in the latest Mesa RADV driver version
- Some part of the Vulkan environment is still incomplete. Note that Celeste seems to be a 32-bit binary as when trying to set `VK_ICD_FILENAMES` to fix the `FNA3D_FORCE_DRIVER=Vulkan` approach it *only* worked when including `/run/opengl-driver-32/share/vulkan/icd.d/radeon_icd.i686.json`. It would be nice to check if 32-bit Vulkan works on the Wine prefix, although it's not so easy to find some simple 32-bit Vulkan demo exe (it seems I have to build it first, within the Wine prefix, which is more work than I'm bothered to do right now).

It is kind of frustrating that this is happening. Especially since I got it running on Windows without any problems, and it seemed so much like that would be the same for Linux (until I got to Chapter 5 basically). It makes me wonder most of all who's at fault here.\
There is a pretty big initial leap I made, which is assuming that I needed to force Vulkan to solve my problems. It would've been most ideal if the OpenGL backend worked completely as intended, and there are definitely some bugs there that can be reported, either to FNA(3D), or Wine/Proton-GE, or Mesa RADV.

I also have a lot more learning I can do about how this whole Wine thing works. The Wine [manual](https://gitlab.winehq.org/wine/wine/-/wikis/Documentation) and [FAQ](https://gitlab.winehq.org/wine/wine/-/wikis/FAQ) (and [wiki](https://gitlab.winehq.org/wine/wine/-/wikis/home) in general) seem like pretty good resources.

Having a quick read through the FAQ, [I found a section](https://gitlab.winehq.org/wine/wine/-/wikis/FAQ#how-do-i-create-a-32-bit-wineprefix-on-a-64-bit-system) that said "at present there are some significant bugs that prevent many 32 bit applications from working in a 64 bit wineprefix." And in fact, that's exactly what I'm trying to do with Celeste; the Wine prefix is 64-bit Windows 10, and the Celeste executable is 32-bit&mdash; the output of `file Celeste.exe` is

```
Celeste.exe: PE32 executable (GUI) Intel 80386 Mono/.Net assembly, for MS Windows, 3 sections
```

"PE32" stands for "Portable Executable 32-bit" ("PE32+" would be "Portable Executable 64-bit"). \
That means that maybe this would go a lot smoother if I tried running it inside a 32-bit wine prefix instead! \
Something to try some other time, for sure... \
