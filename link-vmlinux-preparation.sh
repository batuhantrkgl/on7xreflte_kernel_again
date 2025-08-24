#!/bin/bash
# Created by Deokgyu Yang <secugyu@gmail.com>

# Create a soft link file named ld for use lld to fix the build error on modern clang
# This script handles cases where HOSTCC is not set or doesn't contain "/clang"

# Check if HOSTCC is set and not empty
if [ -z "$HOSTCC" ]; then
    echo "Warning: HOSTCC is not set. Assuming GCC build, skipping lld link creation."
    exit 0
fi

# Check if HOSTCC contains "clang"
if [[ "$HOSTCC" != *"clang"* ]]; then
    echo "Info: HOSTCC ($HOSTCC) doesn't contain 'clang'. Skipping lld link creation."
    exit 0
fi

# Extract the directory containing clang
if [[ "$HOSTCC" == *"/clang" ]]; then
    # HOSTCC ends with "/clang" - remove it
    CLANG_BIN="${HOSTCC%/clang}"
elif [[ "$HOSTCC" == "clang" ]]; then
    # HOSTCC is just "clang" - use current PATH
    CLANG_BIN="$(dirname "$(which clang)" 2>/dev/null || echo "/usr/bin")"
else
    # HOSTCC contains clang but doesn't end with "/clang" - get directory
    CLANG_BIN="$(dirname "$HOSTCC")"
fi

echo "CLANG_BIN detected: $CLANG_BIN"

# Check if lld exists in the same directory
if [ ! -f "${CLANG_BIN}/lld" ]; then
    echo "Warning: lld not found at ${CLANG_BIN}/lld. Cannot create ld symlink."
    exit 0
fi

# Check if ld symlink already exists
if [ -f "${CLANG_BIN}/ld" ]; then
    echo "Info: ${CLANG_BIN}/ld already exists."
    exit 0
fi

# Check if we have write permission to the directory
if [ ! -w "${CLANG_BIN}" ]; then
    echo "Error: No write permission to ${CLANG_BIN}. Cannot create ld symlink."
    echo "You may need to:"
    echo "  1. Run the build with appropriate permissions"
    echo "  2. Use a local clang installation"
    echo "  3. Manually create the symlink: sudo ln -s '${CLANG_BIN}/lld' '${CLANG_BIN}/ld'"
    exit 1
fi

# Create the symlink
ln -s "${CLANG_BIN}/lld" "${CLANG_BIN}/ld"
echo "Created symlink: ${CLANG_BIN}/ld -> ${CLANG_BIN}/lld"
