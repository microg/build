#!/bin/bash
microg_dir=$(pwd)
microg_stamp=$(date +%s)

for f in lib/*.lib
do
	source "$f"
done

source local-config.microg-build

microg_targets=""
opt_pull=false
for opt in "$@"
do
	if [[ "$opt" == "-p" ]] || [[ "$opt" == "--pull" ]]
	then
		opt_pull=true
	else
		microg_targets="$microg_targets $opt"
	fi
done

if [[ "$microg_targets" == "" ]]
then
	microg_info "Usage: ./build.sh [options] <target(s)>"
	microg_info
	microg_info "Options:"
	microg_info "-p  --pull        Pull before build."
	microg_info
	microg_warning "You need to specify a target"
	microg_info "If you want to build a full flashable zip, use target \"microg-full\""
	microg_error "Invalid command line"
fi



android_sdk="$sdk_dir/platforms/android-$sdk_version/android.jar"
base_classpath="$android_sdk:"

mkdir -p sources
mkdir -p build out

if $opt_pull
then
	for src in ./sources/*
	do
		if [ -d $src/.git ]
		then
			pushd $src
			git pull
			popd
		fi
	done
fi

for microg_target in $microg_targets
do
	build_target "$microg_target"
	get_build_typeops "$microg_target"
	typeops="$_res"
	if [[ "$typeops" == *"apk"* ]]
	then
		cp "$microg_dir/build/$microg_target/$microg_target.apk" "$microg_dir/out"
		microg_success "Created file $microg_dir/out/$microg_target.apk"
	elif [[ "$typeops" == *"jar"* ]]
	then
		cp "$microg_dir/build/$microg_target/$microg_target.jar" "$microg_dir/out"
		microg_success "Created file $microg_dir/out/$microg_target.jar"
	fi
done
