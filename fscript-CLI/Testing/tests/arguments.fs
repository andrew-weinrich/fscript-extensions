#!/Users/sphercow/fscript/build/Debug/fscript

process := NSProcessInfo processInfo.

sys out println:(sys args join:', ').
sys out println:(process arguments join:', ').
sys out println:(process environment).
sys out println:(process globallyUniqueString).
sys out println:(process globallyUniqueString).
sys out println:(process operatingSystemVersionString).
sys out println:(process processIdentifier).
sys out println:(process processName).
