set -x

autoreconf -ivf

mkdir _builddir

pushd _builddir

../configure --disable-dependency-tracking --prefix="$PREFIX" --libdir="$PREFIX/lib"
make
make install

popd
