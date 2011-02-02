all: compile

vlc-android/jni/Android.mk:
	@echo "=== Creating Android.mk ==="; \
	prefix=""; \
	# Check environment variables
	@if [ -z "$$ANDROID_NDK" -o -z "$$VLC_BUILD_DIR" -o -z "$$VLC_CONTRIB" ]; then \
	    echo "You must define ANDROID_NDK, VLC_BUILD_DIR and VLC_CONTRIB"; \
	    exit 1; \
	 fi; \
	# Append ../ to relative paths
	@if [ `echo $$VLC_BUILD_DIR | head -c 1` != "/" ] ; then \
	    prefix="../"; \
	 fi; \
	 if [ `echo $$VLC_CONTRIB | head -c 1` != "/" ] ; then \
	    VLC_CONTRIB="../$$VLC_CONTRIB"; \
	 fi; \
	 modules=`find $$VLC_BUILD_DIR/modules -name '*.a'`; \
	 LDFLAGS=""; \
	 DEFINITION=""; \
	 BUILTINS="const void *vlc_builtins_modules[] = {\n"; \
	 for file in $$modules; do \
	     name=`echo $$file | sed 's/.*\.libs\/lib//' | sed 's/_plugin\.a//'`; \
	     LDFLAGS="$$LDFLAGS\t$$prefix$$file \\\\\n"; \
	     DEFINITION=$$DEFINITION"vlc_declare_plugin($$name);\n"; \
	     BUILTINS=$$BUILTINS"    vlc_plugin($$name),\n"; \
	 done; \
	 BUILTINS=$$BUILTINS"    NULL\n};\n"; \
	 rm -f vlc-android/jni/libvlcjni.h; \
	 echo -e "/* File: libvlcjni.h"                                             > vlc-android/jni/libvlcjni.h; \
	 echo -e " * Autogenerated from the list of modules"                       >> vlc-android/jni/libvlcjni.h; \
	 echo -e " */\n"                                                           >> vlc-android/jni/libvlcjni.h; \
	 echo -e "$$DEFINITION\n"                                                  >> vlc-android/jni/libvlcjni.h; \
	 echo -e "$$BUILTINS\n"                                                    >> vlc-android/jni/libvlcjni.h; \
	 rm -f vlc-android/jni/Android.mk; \
	 echo -e 'LOCAL_PATH := $$(call my-dir)'                                   >> vlc-android/jni/Android.mk; \
	 echo -e "include \$$(CLEAR_VARS)\n"                                       >> vlc-android/jni/Android.mk; \
	 echo -e "LOCAL_MODULE    := libvlcjni"                                    >> vlc-android/jni/Android.mk; \
	 echo -e "LOCAL_SRC_FILES := libvlcjni.c vout.c"                           >> vlc-android/jni/Android.mk; \
	 echo -e "LOCAL_C_INCLUDES := \$$(LOCAL_PATH)/../../../../../include"      >> vlc-android/jni/Android.mk; \
	 echo -e "LOCAL_LDLIBS := -L$$VLC_CONTRIB/lib \\"                          >> vlc-android/jni/Android.mk; \
	 echo -e "\t-L$$ANDROID_NDK/platforms/android-8/arch-arm/usr/lib \\"       >> vlc-android/jni/Android.mk; \
	 echo -en "$$LDFLAGS"                                                      >> vlc-android/jni/Android.mk; \
	 echo -e "\t$$prefix$$VLC_BUILD_DIR/src/.libs/libvlc.a \\"                 >> vlc-android/jni/Android.mk; \
	 echo -e "\t$$prefix$$VLC_BUILD_DIR/src/.libs/libvlccore.a \\"             >> vlc-android/jni/Android.mk; \
	 echo -e "\t-ldl -lz -lm -logg -lvorbisenc -lvorbis -lFLAC -lspeex -ltheora -lavformat -lavcodec -lavcore -lavutil -lpostproc -lswscale -lmpeg2 -lgcc -lpng -ldca -ldvbpsi -ltwolame -lkate -llog -la52\n" \
	                                                                           >> vlc-android/jni/Android.mk; \
	 echo -e "include \$$(BUILD_SHARED_LIBRARY)\n"                             >> vlc-android/jni/Android.mk

vlc-android/libs/armeabi/libvlcjni.so: vlc-android/jni/Android.mk
	@echo "=== Building libvlcjni ==="
	@cd vlc-android/; \
	 $(ANDROID_NDK)/ndk-build

compile: vlc-android/libs/armeabi/libvlcjni.so

clean:
	rm -rf vlc-android/libs/*
	rm -rf vlc-android/obj/*

distclean: clean
	rm -rf vlc-android/jni/Android.mk

