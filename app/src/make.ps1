# Define the path to the Android NDK and release tag
pushd ../..
$ANDROID_NDK_HOME = if ($env:ANDROID_NDK_HOME) { $env:ANDROID_NDK_HOME } else { & ./gradlew -q printNDKPath }
$CK_RELEASE_TAG = "v$(& ./gradlew -q printVersionName)"
popd

# Check if the path to ndk-bundle exists
if (-not (Test-Path $ANDROID_NDK_HOME)) {
    Write-Host "Path to ndk-bundle not found"
    exit -1
}

# Set variables for the prebuilt toolchain paths
$HOST_TAG = "windows-x86_64"
$MIN_API = 21
$ANDROID_PREBUILT_TOOLCHAIN = "$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/$HOST_TAG"

$ANDROID_ARM_CC = "$ANDROID_PREBUILT_TOOLCHAIN/bin/armv7a-linux-androideabi${MIN_API}-clang"
$ANDROID_ARM64_CC = "$ANDROID_PREBUILT_TOOLCHAIN/bin/aarch64-linux-android21-clang"
$ANDROID_X86_CC = "$ANDROID_PREBUILT_TOOLCHAIN/bin/i686-linux-android${MIN_API}-clang"
$ANDROID_X86_64_CC = "$ANDROID_PREBUILT_TOOLCHAIN/bin/x86_64-linux-android${MIN_API}-clang"

# Set source directory and dependencies directory
$SRC_DIR = Split-Path -Parent $MyInvocation.MyCommand.Definition
$DEPS = Join-Path $SRC_DIR ".deps"
mkdir -Force $DEPS, "$SRC_DIR/main/jniLibs/armeabi-v7a", "$SRC_DIR/main/jniLibs/x86", "$SRC_DIR/main/jniLibs/arm64-v8a", "$SRC_DIR/main/jniLibs/x86_64" | Out-Null

Set-Location $DEPS
Write-Output "Getting Cloak source code"
Remove-Item -Recurse -Force Cloak
git clone https://github.com/notsure2/Cloak
Set-Location Cloak
git checkout tags/$CK_RELEASE_TAG
go get ./...
Set-Location cmd/ck-client

echo "Cross compiling ckclient for arm"
$env:CGO_ENABLED = 1
$env:CC = $ANDROID_ARM_CC
$env:GOOS = "android"
$env:GOARCH = "arm"
$env:GOARM = 7
go build -ldflags "-s -w"
Move-Item -Force ck-client "$SRC_DIR/main/jniLibs/armeabi-v7a/libck-client.so"

echo "Cross compiling ckclient for arm64"
$env:CC = $ANDROID_ARM64_CC
$env:GOARCH = "arm64"
go build -ldflags "-s -w"
Move-Item -Force ck-client "$SRC_DIR/main/jniLibs/arm64-v8a/libck-client.so"

echo "Cross compiling ckclient for x86"
$env:CC = $ANDROID_X86_CC
$env:GOARCH = "386"
go build -ldflags "-s -w"
Move-Item -Force ck-client "$SRC_DIR/main/jniLibs/x86/libck-client.so"

echo "Cross compiling ckclient for x86_64"
$env:CC = $ANDROID_X86_64_CC
$env:GOARCH = "amd64"
go build -ldflags "-s -w"
Move-Item -Force ck-client "$SRC_DIR/main/jniLibs/x86_64/libck-client.so"

cd ../../../..
