# Define custom utilities
# Test for OSX with [ -n "$IS_OSX" ]

function pre_build {
    # Any stuff that you need to do before you start building the wheels
    # Runs in the root directory of this repository.
    if [ -n "$IS_OSX" ]; then
        install_pkg_config
    fi
    # build_simple cfitsio ${CFITSIO_VERSION:-3370} https://heasarc.gsfc.nasa.gov/FTP/software/fitsio/c/cfitsio
    local cfitsio_name_ver=cfitsio${CFITSIO_VERSION:-3370}
    fetch_unpack https://heasarc.gsfc.nasa.gov/FTP/software/fitsio/c/${cfitsio_name_ver}.tar.gz
    (cd cfitsio \
        && ./configure --prefix=$BUILD_PREFIX \
        && make && make shared && make install)

    export CFLAGS="-std=c99"
}

function pip_opts {
    # Extra options for pip
    if [ -n "$IS_OSX" ]; then
        local suffix=scipy_installers
    else
        local suffix=manylinux
    fi
    echo "--only-binary matplotlib --find-links https://nipy.bic.berkeley.edu/$suffix"
}

function run_tests {
    # Runs tests on installed distribution from an empty directory
    MPDAF_INSTALL_DIR=$(dirname $(python -c 'import mpdaf; print(mpdaf.__file__)'))
    echo $MPDAF_INSTALL_DIR
    python --version
    python -c "import mpdaf; print(mpdaf)"
    pytest $MPDAF_INSTALL_DIR
}
