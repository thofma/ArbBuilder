# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder

name = "libarb"
version = v"0.0.0-6c3738555d00b8b8b24a1f5e0065ef787432513c"

# Collection of sources required to build libarb
sources = [
    "https://github.com/fredrik-johansson/arb.git" =>
    "6c3738555d00b8b8b24a1f5e0065ef787432513c",

]

# Bash recipe for building across all platforms
script = raw"""
if [ $target != "x86_64-w64-mingw32" ]; then
cd $WORKSPACE/srcdir
cd arb/
./configure --prefix=$prefix --disable-static --enable-shared --with-gmp=$prefix --with-mpfr=$prefix --with-flint=$prefix
make -j${nproc}
make install

else
cd $WORKSPACE/srcdir
cd arb/
./configure --prefix=$prefix --disable-static --enable-shared --with-gmp=$prefix --with-mpfr=$prefix --with-flint=$prefix
if [ ! -f $prefx/lib/libflint-13.dll ]; then cp $prefix/bin/libflint-13.dll $prefix/lib/; fi
if [ ! -f $prefx/lib/libflint.dll ]; then cp $prefix/bin/libflint.dll $prefix/lib/; fi
#cp -n $prefix/bin/libflint-13.dll $prefix/bin/libflint.dll $prefix/lib/;
cp $prefix/bin/libflint-13.dll $prefix/bin/libflint.dll $prefix/lib/
make -j${nproc}
make install
rm $WORKSPACE/destdir/bin/libflint-13.dll
rm $WORKSPACE/destdir/bin/libflint.dll
cd $prefix/lib
mv libarb.so libarb.dll
fi

"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = [
    Windows(:x86_64),
    MacOS(:x86_64),
    Linux(:x86_64, libc=:glibc)
]

# The products that we will ensure are always built
products(prefix) = [
    LibraryProduct(prefix, "libarb", :libarb)
]

# Dependencies that must be installed before this package can be built
dependencies = [
    "https://github.com/JuliaPackaging/Yggdrasil/releases/download/GMP-v6.1.2-1/build_GMP.v6.1.2.jl",
    "https://github.com/JuliaPackaging/Yggdrasil/releases/download/MPFR-v4.0.2-1/build_MPFR.v4.0.2.jl",
    "https://github.com/thofma/Flint2Builder/releases/download/c58523/build_libflint.v0.0.0-c5852387025bf144f32c0593f0ecc906c81266f1.jl"
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies)

